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
import 'package:weblibre/core/maintenance/backup_archive_name.dart';
import 'package:weblibre/core/maintenance/maintenance_outcome.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/entities/restart_cost.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_maintenance_dialogs.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_authorization.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_labels.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_switch_handler.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/maintenance_outcome_l10n.dart';
import 'package:weblibre/presentation/utils/profile_copy_l10n.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

enum RestoreTarget { createOrOverride, createNew }

/// Scope for the device prompt a device-locked clone must pass before it
/// exists. It has no profile id yet, and nothing is cached under it.
const _restoreAuthKey = 'profile_access::restore';

class ProfileRestoreScreen extends HookConsumerWidget {
  final Uri backupFileUri;

  /// The user to replace, when the caller has already decided which one.
  ///
  /// Set by the first-run restore, where there is exactly one answer: the
  /// profile this process is already serving. Offering a choice there produced
  /// the opposite of what was asked for — a *second* user built from the
  /// backup, with the freshly created one left behind empty and the lock the
  /// user had just configured on it replaced by the archive's.
  final Profile? forcedOverwriteTarget;

  /// Whether the replaced user takes the archive's name.
  ///
  /// Only first-run sets it. See [RestoreOperation.adoptArchiveName].
  final bool adoptArchiveName;

  const ProfileRestoreScreen({
    super.key,
    required this.backupFileUri,
    this.forcedOverwriteTarget,
    this.adoptArchiveName = false,
  });

  /// Whether the target is fixed and the screen only has to confirm it.
  bool get _targetIsFixed => forcedOverwriteTarget != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final passwordTextController = useTextEditingController();
    final nameTextController = useTextEditingController();

    final restoreFuture = useState<Future<Profile?>?>(null);
    final restoreState = useFuture(restoreFuture.value);

    /// Whether the last attempt failed for a reason the password could explain.
    ///
    /// Kept apart from the snackbar because the two say different things in
    /// different places, exactly as on the maintenance screen: the message
    /// explains what happened, and this puts a mark on the one control that can
    /// change the answer.
    final passwordRejected = useState(false);

    final restoreTarget = useState(
      _targetIsFixed ? RestoreTarget.createOrOverride : RestoreTarget.createNew,
    );
    final overwriteTarget = useState<Profile?>(forcedOverwriteTarget);
    final profiles =
        ref.watch(profileRepositoryProvider).value ?? const <Profile>[];

    // The archive's own file name, which is the only thing about it that can be
    // read without the password. It carries a *name*, and names are not
    // identities: `validateProfileName` checks only that one is present and
    // well-formed, so two users can share one.
    final archive = useFuture(
      useMemoized(
        () => SafUtil()
            .documentFileFromUri(backupFileUri.toString(), false)
            .then((file) => BackupArchiveName.tryParse(file?.name ?? '')),
        [backupFileUri],
      ),
    ).data;

    // The archive names the profile it was taken from, and that name is on the
    // screen two lines further down — but the field the user has to fill in
    // started empty, so a restore of "Work" meant reading "Work" off the page
    // and typing it back in. Seeded rather than forced: a clone is a *different*
    // profile, and the name is the one part of it the user may well want to
    // change.
    final seededName = useRef<String?>(null);
    useEffect(() {
      final name = archive?.profileName;
      if (name == null || name == seededName.value) return null;
      seededName.value = name;
      // Only into a field the user has not touched. Overwriting what they typed
      // because the archive metadata arrived a frame later is worse than not
      // helping at all.
      if (nameTextController.text.isEmpty) {
        nameTextController.text = name;
      }
      return null;
    }, [archive?.profileName]);

    final labels = profileLabels(profiles);
    String labelFor(Profile profile) => labelOfProfile(profile, labels);

    final archiveMatches = archive == null
        ? const <Profile>[]
        : profiles
              .where((profile) => profile.name == archive.profileName)
              .toList();

    // Pre-selected only when the name identifies exactly one user. Taking the
    // first of several would aim a destructive replace at whichever happened to
    // sort first — and since a backup may now be restored over *any* user, the
    // profile-id check that used to refuse a wrong target no longer stands
    // behind this guess.
    useEffect(() {
      if (_targetIsFixed) return null;
      if (overwriteTarget.value != null) return null;
      if (archiveMatches.length == 1) {
        overwriteTarget.value = archiveMatches.single;
      }
      return null;
    }, [archive, profiles.length]);

    final mismatched =
        archive != null &&
        overwriteTarget.value != null &&
        overwriteTarget.value!.name != archive.profileName;

    // One-shot: a successful restore navigates away, but rebuilds before the
    // route swap completes can otherwise re-fire the success branch.
    final successHandled = useRef(false);

    useEffect(() {
      if (restoreState.hasError) {
        passwordRejected.value = classifyMaintenanceFailure(
          restoreState.error!,
        ).blamesPassword;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          // Through the same describer the maintenance screen uses. This path
          // unpacks the archive in-process, so a wrong password surfaces here as
          // the raw `FormatException: Filter error, bad data` — which told the
          // user nothing, on the one restore path where retrying is free.
          final error = restoreState.error!;
          showErrorMessage(
            context,
            error is CloneDeviceLockUnconfirmed
                ? l10n.user_restoreDeviceLockUnconfirmed(
                    l10n.profileCopy_nothingChanged,
                  )
                : describeMaintenanceFailure(l10n, error),
          );
        });
      } else if (restoreState.hasData && !successHandled.value) {
        successHandled.value = true;
        // `hasData` is false for a null value, so this branch is the create-new
        // path only; replacing an existing user returns null and exits instead.
        final restored = restoreState.data;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;
          showInfoMessage(context, l10n.user_backupRestoredMessage);

          // Restoring a backup is almost always a prelude to using it, and
          // getting there otherwise means Users → the profile → Switch →
          // confirm. Offered rather than done: switching closes and reopens the
          // browser, which is too much to attach silently to a restore, and
          // someone restoring several archives in a row does not want it after
          // each one.
          if (restored != null) {
            await handleSwitchProfile(context, ref, restored);
          }

          // Only reached when the switch was declined — accepting it ends the
          // process.
          if (context.mounted) {
            ProfileListRoute().go(context);
          }
        });
      }

      return null;
    }, [restoreState.hasError, restoreState.hasData, restoreState.error]);

    final disableInteraction =
        restoreState.connectionState == ConnectionState.waiting;

    // Watched rather than read, so the button follows the field: a plain
    // `controller.text` only samples it at build time. Unconditionally, and
    // before the target is consulted — `&&` short-circuits, and a hook that
    // stops being called when the user picks the other radio button is a hook
    // order violation.
    final passwordText = useValueListenable(passwordTextController).text;

    // Only the create-new path opens the archive here; the replace path hands
    // the password question to the maintenance screen and has nothing to check.
    final passwordMissing =
        restoreTarget.value == RestoreTarget.createNew && passwordText.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.user_restoreBackupTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                // Only the create-new path opens the archive here. Replacing an
                // existing user queues the work for the maintenance process,
                // which asks for the password itself — collecting one here would
                // take it, discard it, and give no feedback if it were wrong.
                if (restoreTarget.value == RestoreTarget.createNew) ...[
                  // The same field the maintenance restore screen uses. A backup
                  // password is long, typed once, and cannot be checked until the
                  // whole archive has been opened — so being unable to see what
                  // was typed made the one restore path where retrying is free
                  // feel like the one where it is not.
                  ObscurableTextField(
                    controller: passwordTextController,
                    enabled: !disableInteraction,
                    keyboardType: TextInputType.visiblePassword,
                    // Clears as soon as the user starts fixing it, so the mark
                    // describes the text that failed rather than the text now in
                    // the field.
                    onChanged: (_) => passwordRejected.value = false,
                    decoration: InputDecoration(
                      labelText: l10n.user_passwordFieldLabel,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      // On the control that can change the answer, not only in a
                      // snackbar that is gone by the time the user looks back.
                      errorText: passwordRejected.value
                          ? l10n.user_wrongBackupPassword
                          : null,
                      helperText: l10n.user_passwordHelperText,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (!_targetIsFixed)
                  RadioGroup(
                    groupValue: restoreTarget.value,
                    onChanged: (value) {
                      if (value != null) {
                        restoreTarget.value = value;
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile(
                          enabled: !disableInteraction,
                          value: RestoreTarget.createNew,
                          title: Text(l10n.user_createNewProfileTitle),
                          subtitle: Text(l10n.user_createNewProfileSubtitle),
                        ),
                        RadioListTile(
                          enabled: !disableInteraction,
                          value: RestoreTarget.createOrOverride,
                          title: Text(l10n.user_replaceExistingProfileTitle),
                          subtitle: Text(
                            l10n.user_replaceExistingProfileSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (restoreTarget.value == RestoreTarget.createNew) ...[
                  TextFormField(
                    controller: nameTextController,
                    enabled: !disableInteraction,
                    decoration: InputDecoration(
                      label: Text(l10n.user_nameFieldLabel),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (value) =>
                        validateProfileName(value, l10n: l10n),
                  ),
                  const SizedBox(height: 8),
                  // Said before the restore, not discovered after it. A clone is
                  // a different profile from the one the archive was taken from,
                  // so the state that identifies that profile does not come with
                  // it — see `applyCloneParticipantPolicy`.
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.user_newProfileNoSignInTitle),
                    subtitle: Text(l10n.user_newProfileNoSignInSubtitle),
                  ),
                ],
                if (restoreTarget.value == RestoreTarget.createOrOverride) ...[
                  if (_targetIsFixed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(
                        l10n.user_restoringIntoTitle(
                          labelFor(forcedOverwriteTarget!),
                        ),
                      ),
                      subtitle: Text(
                        adoptArchiveName
                            ? l10n.user_backupKeepsLockConfigured
                            : l10n.user_profileKeepsNameAndLock,
                      ),
                    )
                  else
                    // Chosen explicitly rather than read out of the archive: the
                    // archive cannot be opened without the password, and the
                    // password is not asked for until the maintenance process. The
                    // restore still refuses if the archive turns out to describe a
                    // different profile — that check just happens where it is safe
                    // to act on, before anything is moved.
                    DropdownButtonFormField<Profile>(
                      // Keyed on the value because `initialValue` is
                      // `FormField.initialValue`: it is read once, and
                      // `FormFieldState.didUpdateWidget` never re-reads it. The
                      // single-match auto-selection resolves asynchronously with
                      // the archive header, so without this the field can be
                      // built empty, stay empty, and then fail validation over a
                      // target the user cannot see was already chosen.
                      key: ValueKey(overwriteTarget.value?.id),
                      initialValue: overwriteTarget.value,
                      decoration: InputDecoration(
                        label: Text(l10n.user_profileToReplaceLabel),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      items: [
                        for (final profile in profiles)
                          DropdownMenuItem(
                            value: profile,
                            // Disambiguated only where it has to be: a uuid
                            // fragment beside every name would be noise, and
                            // beside two identical ones it is the whole point.
                            child: Text(labelFor(profile)),
                          ),
                      ],
                      onChanged: disableInteraction
                          ? null
                          : (value) => overwriteTarget.value = value,
                      validator: (value) => value == null
                          ? l10n.user_selectProfileToReplaceValidator
                          : null,
                    ),
                  if (!_targetIsFixed &&
                      archiveMatches.length > 1 &&
                      overwriteTarget.value == null) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.help_outline),
                      title: Text(
                        l10n.user_multipleProfilesShareNameTitle(
                          archiveMatches.length,
                          archive!.profileName,
                        ),
                      ),
                      subtitle: Text(
                        l10n.user_multipleProfilesShareNameSubtitle(
                          l10n.profileCopy_cannotBeUndone,
                        ),
                      ),
                    ),
                  ],
                  if (mismatched && !adoptArchiveName) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.swap_horiz),
                      title: Text(
                        l10n.user_backupTakenFromTitle(archive.profileName),
                      ),
                      // Allowed, and worth saying anyway: the uuid names where a
                      // tree lives rather than what is in it, so the data is
                      // re-addressed to the user being replaced.
                      //
                      // Shortcuts go on both sides. `PwaShortcutParticipant`
                      // replaces the target's launch tokens with the archive's,
                      // and the archive's are keyed to the profile that made
                      // them, so they are filtered out — leaving none. That is
                      // right rather than unfortunate: the target's old
                      // shortcuts would otherwise still authenticate into data
                      // that is now someone else's.
                      subtitle: Text(
                        l10n.user_backupTakenFromSubtitle(
                          labelFor(overwriteTarget.value!),
                          l10n.profileCopy_shortcutsNeedPinningAgain,
                        ),
                      ),
                    ),
                  ],
                  if (adoptArchiveName && archive != null) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(
                        l10n.user_profileWillBeCalledTitle(archive.profileName),
                      ),
                      subtitle: Text(
                        l10n.user_profileWillBeCalledSubtitle(
                          l10n.profileCopy_shortcutsNeedPinningAgain,
                        ),
                      ),
                    ),
                  ],
                  // Restoring over an existing user replays every participant,
                  // so the WebLibre account, sync and proxy state in the
                  // archive is installed. A *new* user does not get it —
                  // see `applyCloneParticipantPolicy` — and saying so on only one of
                  // the two branches is what made the backup screen's
                  // "comes back signed in" read as a contradiction.
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.key_outlined),
                    title: Text(l10n.user_accountDataRestoredTitle),
                    subtitle: Text(
                      l10n.user_accountDataRestoredSubtitle(
                        l10n.profileCopy_secretDataDescription,
                        l10n.profileCopy_signedInFromBackup,
                        l10n.profileCopy_olderBackupKeepsCredentials,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.warning_amber_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      _targetIsFixed
                          ? l10n.user_replacesSetupProfileTitle
                          : l10n.user_replacesEverythingTitle,
                    ),
                    // Two sentences rather than one with a hole in it: the
                    // first-run target was created minutes ago, and telling
                    // someone their tabs and history are about to be lost when
                    // they have none is how a warning stops being read.
                    subtitle: Text(
                      _targetIsFixed
                          ? l10n.user_replacesSetupProfileSubtitle(
                              restartsThenAsksPassword(l10n),
                            )
                          : l10n.user_replacesEverythingSubtitle(
                              restartsThenAsksPassword(l10n),
                              l10n.profileCopy_dataDescription,
                              overwriteTarget.value == null
                                  ? l10n.user_thatProfileFallbackLabel
                                  : '"${labelFor(overwriteTarget.value!)}"',
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (disableInteraction)
                  Column(
                    children: [
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      // Only the clone path unpacks anything here. The replace
                      // path records the task and closes; saying "Restoring"
                      // claimed work that has not started and will not start
                      // until the next process asks for the password.
                      Text(
                        restoreTarget.value == RestoreTarget.createNew
                            ? l10n.user_restoringBackupProgress
                            : l10n.user_closingToRestoreProgress,
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    icon: const Icon(MdiIcons.backupRestore),
                    // The password field is no longer a `TextFormField`, so the
                    // form no longer speaks for it. Gated on the button instead,
                    // the same way the maintenance restore screen does it: an
                    // empty password can only ever produce a failure the user
                    // already knows the reason for.
                    onPressed: passwordMissing
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            switch (restoreTarget.value) {
                              case RestoreTarget.createOrOverride:
                                // Replacing a user's data is irreversible and, unlike
                                // every other destructive action here, used to happen
                                // straight off this button: pick from a dropdown, tap
                                // once, and the app closes.
                                final target = overwriteTarget.value!;

                                // Before the dialog, so the counts are on it
                                // the moment it appears rather than a frame
                                // later, under the user's thumb.
                                final restartCost = await readRestartCost(ref);
                                if (!context.mounted) return;

                                final confirmed =
                                    await showReplaceProfileDialog(
                                      context,
                                      profileName: labelFor(target),
                                      restartCost: restartCost,
                                      sourceProfileName: mismatched
                                          ? archive.profileName
                                          : null,
                                      adoptedName: adoptArchiveName
                                          ? archive?.profileName
                                          : null,
                                      replacesPlaceholder: _targetIsFixed,
                                    );
                                if (confirmed != true || !context.mounted) {
                                  return;
                                }

                                // Replacing a locked profile would hand it the
                                // archive's data — sessions, sign-ins — under
                                // the lock its owner trusts. Only whoever can
                                // open it may do that.
                                final authorized = await authorizeProfileAction(
                                  context,
                                  ref,
                                  target,
                                  reason: l10n.user_authReasonReplaceProfile(
                                    labelFor(target),
                                  ),
                                );
                                if (!authorized) return;

                                restoreFuture.value = _queueOverwrite(
                                  ref,
                                  target,
                                  backupFileUri,
                                  adoptArchiveName: adoptArchiveName,
                                );

                              case RestoreTarget.createNew:
                                // Captured now rather than read inside the
                                // callback: it runs once the archive is open,
                                // when this screen may no longer be mounted.
                                final localAuth = ref.read(
                                  localAuthenticationServiceProvider.notifier,
                                );
                                final reason =
                                    l10n.user_authReasonConfirmUnlock;
                                final alsoRemember =
                                    await activeProfileDeviceUnlock();
                                if (!context.mounted) return;

                                restoreFuture.value = ref
                                    .read(userBackupServiceProvider.notifier)
                                    .restoreAndCreateNew(
                                      backupFileUri,
                                      profileName: nameTextController.text,
                                      password: passwordTextController.text,
                                      confirmDeviceLock: () async =>
                                          (await localAuth.authenticate(
                                            authKey: _restoreAuthKey,
                                            localizedTitle:
                                                l10n.user_deviceAuthPromptTitle,
                                            localizedReason: reason,
                                            alsoRemember: alsoRemember,
                                          )).passed,
                                    );
                            }
                          },
                    label: Text(l10n.user_actionRestore),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Records the replacement and restarts so the next process can perform it.
///
/// Returns null because there is no restored profile to hand back here — the
/// work happens after the restart, under a maintenance lease.
Future<Profile?> _queueOverwrite(
  WidgetRef ref,
  Profile target,
  Uri backupFileUri, {
  required bool adoptArchiveName,
}) async {
  await ref
      .read(userBackupServiceProvider.notifier)
      .queueRestoreOver(
        target,
        sourceFileUri: backupFileUri,
        adoptArchiveName: adoptArchiveName,
      );

  await exitApp(ref.container, restart: true);
  return null;
}
