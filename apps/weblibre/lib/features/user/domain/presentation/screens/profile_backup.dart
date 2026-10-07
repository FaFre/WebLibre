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
import 'package:saf_util/saf_util.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/entities/restart_cost.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_maintenance_dialogs.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_authorization.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/maintenance_outcome_l10n.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart';

class ProfileBackupScreen extends HookConsumerWidget {
  final Profile profile;

  const ProfileBackupScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final integrityVerification = useState(true);

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
                  icon: const Icon(MdiIcons.safe),
                  onPressed: () async {
                    // Re-checked, not just remembered. A grant persists
                    // across reboots but not across the user revoking it,
                    // the volume being unmounted, or the folder being
                    // deleted — and asking again here costs one call, while
                    // finding out after the restart costs the whole backup.
                    final remembered = ref.read(backupDirectoryUriProvider);
                    // Held across the picker rather than read after it: the
                    // folder picker is a different activity, and this screen
                    // is not guaranteed to still be mounted when it returns.
                    final backupDirectory = ref.read(
                      backupDirectoryUriProvider.notifier,
                    );
                    final usable =
                        remembered != null &&
                        await safTargetIsWritable(remembered);

                    if (!usable) {
                      final dir = await SafUtil().pickDirectory(
                        writePermission: true,
                        persistablePermission: true,
                      );
                      if (dir == null) return;
                      backupDirectory.set(Uri.parse(dir.uri));
                    }

                    // Confirmed last, after the folder is settled: a
                    // dialog answered and then followed by a system folder
                    // picker is a confirmation for something else.
                    //
                    // Backup is the only maintenance action that destroys
                    // nothing it names, which is exactly why it needs asking:
                    // it still leaves through `exitApp`, and that takes the
                    // current profile's private tabs with it.
                    final restartCost = await readRestartCost(ref);
                    if (!context.mounted) return;

                    final confirmed = await showBackupProfileDialog(
                      context,
                      profileName: profile.name,
                      restartCost: restartCost,
                    );
                    if (confirmed != true || !context.mounted) return;

                    // A backup is the profile's whole session — cookies and
                    // logins — under a password whoever starts it picks. So
                    // it takes whatever unlocks this profile, asked fresh, and
                    // that holds when it is started from another profile too.
                    final authorized = await authorizeProfileAction(
                      context,
                      ref,
                      profile,
                      reason: l10n.user_authReasonBackupProfile(profile.name),
                    );
                    if (!authorized) return;

                    // Queues the work and restarts. The archive is written
                    // by the next process, where nothing has the profile
                    // open — this one has its databases and engine running,
                    // so a backup taken here could not be called consistent.
                    backupFuture.value = _queueAndRestart(
                      ref,
                      profile,
                      integrityCheck: integrityVerification.value,
                    );
                  },
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
