/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/entities/restart_cost.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_maintenance_dialogs.dart';
import 'package:weblibre/features/user/domain/presentation/utils/backup_folder_picker.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_authorization.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/maintenance_outcome_l10n.dart';
import 'package:weblibre/presentation/widgets/button_spinner.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/saf_tree_uri.dart';
import 'package:weblibre/utils/ui_helper.dart';

class ProfileBackupScreen extends HookConsumerWidget {
  final Profile profile;

  const ProfileBackupScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupDirectory = ref.watch(backupDirectoryUriProvider);
    final folderName = ref.watch(
      backupFolderNameProvider.select((value) => value.value),
    );
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final integrityVerification = useState(true);

    /// Whether the folder's last write check blamed it, so the row can say so
    /// instead of naming the folder as if it were fine. Set from every check,
    /// so one that passes clears it again.
    final folderRefused = useState(false);

    /// True while a write check runs, and only then: the check is several
    /// calls into the folder's provider — over the network, for a cloud one —
    /// and this is what the spinner shows. The folder picker, the confirmation
    /// and the authorization prompt are the user's to answer, and a spinner
    /// behind them would claim that something is working.
    final checking = useState(false);

    /// Held from the tap on Backup, or on the folder row, until that flow has
    /// handed over or given up, so a second tap does not stack a second check,
    /// dialog or picker on top of the first. A ref, not state: it guards, and
    /// is never drawn.
    final flowRunning = useRef(false);

    final backupFuture = useState<Future<bool>?>(null);
    final backupState = useFuture(backupFuture.value);

    // One-shot: success navigates away; rebuilds before the route swap
    // completes would otherwise re-fire navigation and the snackbar.
    final successHandled = useRef(false);

    useEffect(() {
      if (backupState.hasError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showErrorMessage(
            context,
            describeMaintenanceFailure(l10n, backupState.error!),
          );
        });
      } else if (backupState.hasData && !successHandled.value) {
        successHandled.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showInfoMessage(context, l10n.user_restartingToTakeBackup);
          ProfileListRoute().go(context);
        });
      }

      return null;
    }, [backupState.hasError, backupState.hasData, backupState.error]);

    final disableInteraction =
        backupState.connectionState == ConnectionState.waiting;

    final shownFolderName = backupDirectory == null
        ? null
        : folderName ?? describeSafTreeUri(backupDirectory.toString());

    /// Runs [flow] unless another one is still running.
    Future<void> exclusively(Future<void> Function() flow) async {
      if (flowRunning.value) return;
      flowRunning.value = true;
      try {
        await flow();
      } finally {
        flowRunning.value = false;
      }
    }

    /// The folder's name for a message about [check]: what the check itself
    /// read from the provider, so it is never the previous folder's name
    /// lingering in [backupFolderNameProvider].
    String nameOf(Uri folder, BackupFolderCheck check) =>
        check.folderName ?? describeSafTreeUri(folder.toString());

    /// Checks [folder] by creating a test file in it, and keeps the row's
    /// warning in step with the answer.
    Future<BackupFolderCheck> check(Uri folder) async {
      checking.value = true;
      try {
        final result = await probeBackupTarget(folder);
        if (context.mounted) {
          final lost = result.verdict == SafFolderVerdict.lost;
          // A refused pick is not saved, so the row's warning goes on
          // describing the folder that is still set.
          if (!lost || folder == ref.read(backupDirectoryUriProvider)) {
            folderRefused.value = lost;
          }
        }
        return result;
      } finally {
        if (context.mounted) checking.value = false;
      }
    }

    /// Tells the user what [result] means for [folder], and what comes next.
    ///
    /// The one mapping from a verdict to this screen, for the remembered
    /// folder, a freshly chosen one and the folder row alike. Only a folder
    /// that blames itself is handled by the caller, through [onLost]: whether
    /// that asks to choose again or says it failed depends on where the folder
    /// came from.
    ///
    /// Only a verdict stops the backup. A check that reached none goes ahead,
    /// as it does when the queued backup runs: it is not evidence against the
    /// folder, and the backup then reports what actually goes wrong.
    ///
    /// Returns true to go on to the confirmation.
    Future<bool> respond(
      Uri folder,
      BackupFolderCheck result, {
      required Future<bool> Function(String folderName) onLost,
    }) async {
      final name = nameOf(folder, result);
      switch (result.verdict) {
        case SafFolderVerdict.writable:
        case SafFolderVerdict.unknown:
          return true;
        case SafFolderVerdict.full:
          // Not the folder's fault, so not met with a picker: the folder is
          // kept, and the user is told what actually has to change.
          showErrorMessage(context, l10n.user_backupFolderFull(name));
          return false;
        case SafFolderVerdict.unresponsive:
          // Stopped here, as the queued backup would stop: the write would
          // hang on the same provider after the restart.
          showErrorMessage(context, l10n.user_backupFolderUnresponsive(name));
          return false;
        case SafFolderVerdict.lost:
          return await onLost(name);
      }
    }

    /// Opens the picker and checks the folder chosen in it. Returns true when
    /// a backup can go there.
    ///
    /// The fresh grant is checked too: a folder the provider will not write
    /// to fails the same way after the restart however recently it was picked.
    ///
    /// [previousRefused] says the folder set before the picker opened failed
    /// its check. Only choosing that same folder again and failing again is
    /// "it didn't help"; any other refusal is a refusal of the folder chosen.
    Future<bool> chooseAndCheck({required bool previousRefused}) async {
      final previous = ref.read(backupDirectoryUriProvider);
      BackupFolderCheck? result;
      final chosen = await chooseBackupFolder(
        ref,
        // Checked before it is saved, so a folder the provider refuses does
        // not replace one that works.
        accept: (picked) async {
          // The screen is gone, so there is nobody to tell about a refusal.
          if (!context.mounted) return true;
          final checked = await check(picked);
          result = checked;
          return checked.verdict != SafFolderVerdict.lost;
        },
      );
      final checked = result;
      if (chosen == null || checked == null || !context.mounted) return false;

      return await respond(
        chosen,
        checked,
        onLost: (name) async {
          showErrorMessage(
            context,
            previousRefused && previous == chosen
                ? l10n.user_backupFolderStillRefused(name)
                : l10n.user_backupFolderRefused(name),
          );
          return false;
        },
      );
    }

    /// Settles where the backup goes. Returns true to go on to the
    /// confirmation.
    ///
    /// Re-checked, not just remembered, and by creating a test file rather
    /// than by asking for the grant. A grant persists across reboots but not
    /// across the user revoking it, the volume being unmounted, or the folder
    /// being deleted — and in #698 the grant was still on record for a folder
    /// that was still there, and the provider refused the backup anyway.
    /// Finding out here costs one check; finding out after the restart costs
    /// the whole backup.
    Future<bool> settleFolder() async {
      final remembered = ref.read(backupDirectoryUriProvider);
      if (remembered == null) {
        return await chooseAndCheck(previousRefused: false);
      }

      final result = await check(remembered);
      if (!context.mounted) return false;

      return await respond(
        remembered,
        result,
        onLost: (name) async {
          // Asked first, because choosing the folder again is the user's
          // call and keeps the folder if they decline.
          final chooseAgain = await showBackupFolderRefusedDialog(
            context,
            folderName: name,
          );
          return chooseAgain == true &&
              context.mounted &&
              await chooseAndCheck(previousRefused: true);
        },
      );
    }

    Future<void> startBackup() async {
      if (!await settleFolder() || !context.mounted) return;

      // Confirmed last, after the folder is settled: a dialog answered and
      // then followed by a system folder picker is a confirmation for
      // something else.
      //
      // Backup is the only maintenance action that destroys nothing it names,
      // which is exactly why it needs asking: it still leaves through
      // `exitApp`, and that takes the current profile's private tabs with it.
      final restartCost = await readRestartCost(ref);
      if (!context.mounted) return;

      final confirmed = await showBackupProfileDialog(
        context,
        profileName: profile.name,
        restartCost: restartCost,
      );
      if (confirmed != true || !context.mounted) return;

      // A backup is the profile's whole session — cookies and logins — under
      // a password whoever starts it picks. So it takes whatever unlocks this
      // profile, asked fresh, and that holds when it is started from another
      // profile too.
      final authorized = await authorizeProfileAction(
        context,
        ref,
        profile,
        reason: l10n.user_authReasonBackupProfile(profile.name),
      );
      if (!authorized || !context.mounted) return;

      // Queues the work and restarts. The archive is written by the next
      // process, where nothing has the profile open — this one has its
      // databases and engine running, so a backup taken here could not be
      // called consistent.
      backupFuture.value = _queueAndRestart(
        ref,
        profile,
        integrityCheck: integrityVerification.value,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.user_createBackupTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: ListView(
            children: [
              // First, and on its own. It used to be the subtitle of the
              // password tile below, where it read as logistics rather than as
              // "your session ends when you tap this" — and it said "the
              // profile is closed", which is only half of it: the profile that
              // closes is *this* one, whether or not it is the one being
              // backed up.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.user_backupRestartsTitle),
                subtitle: Text(
                  l10n.user_backupRestartsSubtitle(
                    l10n.profileCopy_restartClosesCurrentProfile,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.user_setPasswordNextTitle),
                // Asked for after the restart instead of here. A password is
                // the one thing that must not be written into the durable task
                // record that survives it.
                subtitle: Text(l10n.user_setPasswordNextSubtitle),
              ),
              const SizedBox(height: 16),
              // Where the backup goes, before what it contains. It used to be
              // nowhere on this screen: the only way to change it was an icon
              // on the restore list, and a folder that had stopped accepting
              // files (#698) failed the backup with no hint of where to fix it.
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !disableInteraction && !checking.value,
                leading: Icon(
                  folderRefused.value
                      ? MdiIcons.folderAlertOutline
                      : MdiIcons.folderOutline,
                  color: folderRefused.value ? theme.colorScheme.error : null,
                ),
                title: Text(l10n.user_backupFolderTitle),
                subtitle: Text(
                  switch ((shownFolderName, folderRefused.value)) {
                    (null, _) => l10n.user_backupFolderNotChosen,
                    (final name?, true) =>
                      l10n.user_backupFolderRefusedSubtitle(name),
                    (final name?, false) => name,
                  },
                  style: folderRefused.value
                      ? TextStyle(color: theme.colorScheme.error)
                      : null,
                ),
                trailing: const Icon(MdiIcons.folderCogOutline),
                // Checked like the folder Backup settles on, so the warning
                // only clears for a folder that takes files.
                onTap: () => exclusively(() async {
                  await chooseAndCheck(previousRefused: folderRefused.value);
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: integrityVerification.value,
                onChanged: disableInteraction
                    ? null
                    : (value) {
                        integrityVerification.value = value;
                      },
                title: Text(l10n.user_verifyBackupIntegrityTitle),
                subtitle: Text(l10n.user_verifyBackupIntegritySubtitle),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.user_tempDataSkippedTitle),
                // Not a toggle any more: the exclusion list is part of the
                // backup format, so a restored profile can rely on it.
                subtitle: Text(
                  l10n.user_tempDataSkippedSubtitle(
                    l10n.profileCopy_shortcutsNeedPinningAgain,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.key_outlined),
                // Said plainly, because it changes what the file is. It also has
                // to say *when* they are used: the archive always carries them,
                // but only replacing a user installs them — restoring into a new
                // user discards the whole payload on purpose
                // (`applyCloneParticipantPolicy`), because one login on two
                // profiles is the isolation failure the profile boundary exists
                // to prevent. Saying only the first half read as a contradiction
                // of what the restore screen says.
                title: Text(l10n.user_accountDataIncludedTitle),
                subtitle: Text(
                  l10n.user_accountDataIncludedSubtitle(
                    l10n.profileCopy_secretDataDescription,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (disableInteraction)
                Column(
                  children: [
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    // Not "Creating Backup": nothing is written here. This
                    // records the task and closes the app, and the next
                    // process takes the archive.
                    Text(l10n.user_closingToTakeBackup),
                  ],
                )
              else
                FilledButton.icon(
                  icon: checking.value
                      ? const ButtonSpinner()
                      : const Icon(MdiIcons.safe),
                  onPressed: checking.value
                      ? null
                      : () => exclusively(startBackup),
                  label: Text(l10n.user_actionBackup),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Records the backup and restarts so the next process can take it.
///
/// Returns true when the restart is armed. It never returns normally after that
/// in practice — [exitApp] ends the process — but the future still completes on
/// the paths where arming failed.
Future<bool> _queueAndRestart(
  WidgetRef ref,
  Profile profile, {
  required bool integrityCheck,
}) async {
  await ref
      .read(userBackupServiceProvider.notifier)
      .queueBackup(profile, integrityCheck: integrityCheck);

  await exitApp(ref.container, restart: true);
  return true;
}
