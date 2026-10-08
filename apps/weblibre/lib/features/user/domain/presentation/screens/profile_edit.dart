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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/entities/restart_cost.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_maintenance_dialogs.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_password_dialogs.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_authorization.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_switch_handler.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/maintenance_outcome_l10n.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Scope for the confirmation taken *before* a locked profile exists.
///
/// Deliberately not a per-profile key: there is no profile id yet, and the value
/// only scopes `LocalAuthenticationService`'s result cache.
const _newProfileAuthKey = 'profile_access::pending';

List<DropdownMenuItem<Duration?>> _timeoutOptions(AppLocalizations l10n) => [
  DropdownMenuItem(
    value: const Duration(minutes: 1),
    child: Text(l10n.user_timeoutOneMinute),
  ),
  DropdownMenuItem(
    value: const Duration(minutes: 5),
    child: Text(l10n.user_timeoutFiveMinutes),
  ),
  DropdownMenuItem(
    value: const Duration(minutes: 15),
    child: Text(l10n.user_timeoutFifteenMinutes),
  ),
  DropdownMenuItem(
    value: const Duration(hours: 1),
    child: Text(l10n.user_timeoutOneHour),
  ),
];

class ProfileEditScreen extends HookConsumerWidget {
  final Profile? profile;

  const ProfileEditScreen({super.key, required this.profile});

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String name,
    AuthSettings authSettings,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    // Read from disk rather than trusted from the route: what guards a profile
    // has to be what the profile says now.
    final existing = profile != null
        ? await readCurrentProfileMetadata(profile!)
        : null;
    if (!context.mounted) return;

    void reportFailure() {
      showErrorMessage(
        context,
        existing != null
            ? l10n.user_authFailedExisting(l10n.profileCopy_nothingChanged)
            : l10n.user_authFailedNew,
      );
    }

    // Any change to a locked profile — its name included — needs whatever
    // unlocks it now. Otherwise anyone with another profile open could reach
    // this screen from the profile list and simply switch the lock off.
    if (existing != null && existing.authSettings.authenticationRequired) {
      final authorized = await authorizeProfileAction(
        context,
        ref,
        existing,
        reason: l10n.user_authReasonEditProfile(existing.name),
      );
      if (!context.mounted) return;
      if (!authorized) {
        reportFailure();
        return;
      }
    }

    // Prove the device prompt works before it becomes the lock — including on
    // the *create* path, which used to skip it because there was no existing
    // profile to compare against. Skipping it meant a user could switch the
    // lock on with nothing enrolled on the device: `authenticate` catches
    // `LocalAuthException` and reports failure, and the result was a profile
    // that could never be opened. Already proved above when the profile was
    // device-locked before.
    final provesDevice =
        authSettings.lockMethod == ProfileLockMethod.device &&
        existing?.authSettings.lockMethod != ProfileLockMethod.device;

    if (provesDevice) {
      final alsoRemember = await activeProfileDeviceUnlock(existing);
      if (!context.mounted) return;

      final authResult = await ref
          .read(localAuthenticationServiceProvider.notifier)
          .authenticate(
            // A profile being created has no id yet, and the key only scopes the
            // result cache — nothing has been created for it to belong to.
            authKey: existing != null
                ? profileAccessAuthKey(existing.id)
                : _newProfileAuthKey,
            localizedTitle: l10n.user_deviceAuthPromptTitle,
            localizedReason: existing != null
                ? l10n.user_authReasonRequireAuth
                : l10n.user_authReasonConfirmUnlock,
            settings: authSettings,
            alsoRemember: alsoRemember,
          );

      if (!authResult.passed) {
        if (context.mounted) reportFailure();
        return;
      }
    }

    // The editor only offers the password method together with a password,
    // so this is a guard against a lock nobody could open, not a UI path.
    if (authSettings.lockMethod == ProfileLockMethod.password &&
        authSettings.passwordVerifier == null) {
      return;
    }

    // A verifier left behind by a method that no longer uses it would come
    // back to life, with the old password, the next time the method is chosen.
    final toSave = authSettings.lockMethod == ProfileLockMethod.password
        ? authSettings
        : authSettings.copyWith(passwordVerifier: null);

    if (profile != null) {
      await ref
          .read(profileRepositoryProvider.notifier)
          .updateProfileMetadata(
            existing!.copyWith(name: name, authSettings: toSave),
          );

      // The remembered unlock carries the auto-lock policy it was made under,
      // and `isCached`/`evictCacheOnBackground` read that copy rather than the
      // profile. Left alone, a switch from "on startup" to "in background"
      // would never lock this session. Every path above proved the new lock —
      // the old one was answered, the device prompt passed, or the password
      // was just typed twice — so the open profile stays unlocked, under the
      // new policy from now on.
      final authCache = ref.read(localAuthenticationServiceProvider.notifier);
      final authKey = profileAccessAuthKey(existing.id);
      if (existing.uuidValue == filesystem.selectedProfile &&
          toSave.authenticationRequired) {
        authCache.remember(authKey, toSave);
      } else {
        authCache.forget(authKey);
      }

      if (context.mounted) {
        context.pop();
      }
    } else {
      await ref
          .read(profileRepositoryProvider.notifier)
          .createProfile(name: name, authSettings: toSave);

      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameTextController = useTextEditingController(text: profile?.name);
    final authSettings = useState(
      profile?.authSettings ?? AuthSettings.withDefaults(),
    );

    return Scaffold(
      appBar: AppBar(
        title: (profile != null)
            ? Text(l10n.user_editProfileTitle)
            : Text(l10n.user_createProfileTitle),
        actions: [
          IconButton(
            onPressed: () async {
              await _handleSave(
                context,
                ref,
                formKey,
                nameTextController.text,
                authSettings.value,
              );
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              TextFormField(
                controller: nameTextController,
                decoration: InputDecoration(
                  label: Text(l10n.user_nameFieldLabel),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (value) => validateProfileName(value, l10n: l10n),
              ),
              const SizedBox(height: 24),
              _AuthSection(
                authSettings: authSettings.value,
                onAuthSettingsChanged: (newSettings) {
                  authSettings.value = newSettings;
                },
              ),
              const SizedBox(height: 24),
              if (profile != null) ...[
                _ProfileActionsSection(profile: profile!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthSection extends StatelessWidget {
  final AuthSettings authSettings;
  final ValueChanged<AuthSettings> onAuthSettingsChanged;

  const _AuthSection({
    required this.authSettings,
    required this.onAuthSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSection(name: l10n.user_authenticationSectionTitle),
        RadioGroup<ProfileLockMethod>(
          groupValue: authSettings.lockMethod,
          onChanged: (value) async {
            if (value == null) return;

            // Chosen only together with a password. A password method with no
            // password behind it is a profile nobody can open.
            if (value == ProfileLockMethod.password &&
                authSettings.passwordVerifier == null) {
              final verifier = await showSetProfilePasswordDialog(context);
              if (verifier == null || !context.mounted) return;

              onAuthSettingsChanged(
                authSettings.copyWith(
                  lockMethod: value,
                  passwordVerifier: verifier,
                ),
              );
              return;
            }

            onAuthSettingsChanged(authSettings.copyWith.lockMethod(value));
          },
          child: Column(
            children: [
              RadioListTile.adaptive(
                value: ProfileLockMethod.none,
                title: Text(l10n.user_lockMethodNoneTitle),
                subtitle: Text(l10n.user_lockMethodNoneSubtitle),
                secondary: const Icon(MdiIcons.lockOpenVariantOutline),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile.adaptive(
                value: ProfileLockMethod.device,
                title: Text(l10n.user_lockMethodDeviceTitle),
                subtitle: Text(l10n.user_lockMethodDeviceSubtitle),
                secondary: const Icon(MdiIcons.fingerprint),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile.adaptive(
                value: ProfileLockMethod.password,
                title: Text(l10n.user_lockMethodPasswordTitle),
                subtitle: Text(l10n.user_lockMethodPasswordSubtitle),
                secondary: const Icon(MdiIcons.formTextboxPassword),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        if (authSettings.lockMethod == ProfileLockMethod.password) ...[
          ListTile(
            title: Text(l10n.user_changeProfilePasswordTitle),
            leading: const Icon(MdiIcons.keyChange),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            onTap: () async {
              final verifier = await showSetProfilePasswordDialog(context);
              if (verifier == null || !context.mounted) return;

              onAuthSettingsChanged(
                authSettings.copyWith.passwordVerifier(verifier),
              );
            },
          ),
          ListTile(
            title: Text(l10n.user_profilePasswordUnrecoverableTitle),
            subtitle: Text(l10n.user_profilePasswordUnrecoverableSubtitle),
            leading: const Icon(Icons.info_outline),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
        if (authSettings.authenticationRequired) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(l10n.user_autoLockTitle),
                  subtitle: Text(l10n.user_autoLockSubtitle),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(MdiIcons.lockClock),
                ),
                RadioGroup<AutoLockMode>(
                  groupValue: authSettings.autoLockMode,
                  onChanged: (value) {
                    if (value != null) {
                      onAuthSettingsChanged(
                        authSettings.copyWith.autoLockMode(value),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile.adaptive(
                        value: AutoLockMode.background,
                        title: Text(l10n.user_lockInBackgroundTitle),
                        subtitle: Text(l10n.user_lockInBackgroundSubtitle),
                      ),
                      RadioListTile.adaptive(
                        value: AutoLockMode.timeout,
                        title: Text(l10n.user_lockAfterTimeoutTitle),
                        subtitle: Text(l10n.user_lockAfterTimeoutSubtitle),
                      ),
                      RadioListTile.adaptive(
                        value: AutoLockMode.startup,
                        title: Text(l10n.user_lockOnStartupTitle),
                        subtitle: Text(l10n.user_lockOnStartupSubtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (authSettings.autoLockMode == AutoLockMode.timeout)
            ListTile(
              title: Text(l10n.user_timeoutFieldTitle),
              subtitle: Text(l10n.user_timeoutFieldSubtitle),
              leading: const Icon(MdiIcons.timerOutline),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              trailing: DropdownButton<Duration?>(
                value: authSettings.timeout,
                items: _timeoutOptions(l10n),
                underline: const SizedBox.shrink(),
                onChanged: (Duration? value) {
                  if (value != null) {
                    onAuthSettingsChanged(authSettings.copyWith.timeout(value));
                  }
                },
              ),
            ),
        ],
      ],
    );
  }
}

class _ProfileActionsSection extends ConsumerWidget {
  final Profile profile;

  const _ProfileActionsSection({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Backup is offered for every profile, the active one included: it does not
    // run here at all — it is queued and taken by the next process, with the
    // profile closed. Switching and deleting are the two that genuinely cannot
    // act on the profile this process is serving, so they are left out rather
    // than shown to fail.
    final isActive = filesystem.selectedProfile == profile.uuidValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingSection(name: l10n.user_profileActionsSectionTitle),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            label: Text(l10n.user_actionBackup),
            icon: const Icon(MdiIcons.safe),
            onPressed: () async {
              await BackupProfileRoute(
                profile: jsonEncode(profile.toJson()),
              ).push(context);
            },
          ),
        ),
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.user_switchDeleteUnavailableForActive,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              label: Text(l10n.user_switchToThisProfileLabel),
              icon: const Icon(MdiIcons.accountSwitch),
              onPressed: () async {
                await handleSwitchProfile(context, ref, profile);
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                foregroundColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
              ),
              label: Text(l10n.common_delete),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // Read before the dialog opens, not inside it: counts that
                // arrive a frame late land on a dialog the user has already
                // started tapping through.
                final restartCost = await readRestartCost(ref);
                if (!context.mounted) return;

                final result = await showDeleteProfileDialog(
                  context,
                  profileName: profile.name,
                  restartCost: restartCost,
                );

                if (result != true || !context.mounted) return;

                // Deleting destroys nothing that leaves the device, but it
                // is still someone else's profile when this runs from another
                // one, and a lock that anyone could delete away is no lock.
                final authorized = await authorizeProfileAction(
                  context,
                  ref,
                  profile,
                  reason: l10n.user_authReasonDeleteProfile(profile.name),
                );

                if (authorized) {
                  // Queues the delete and restarts: a profile's state reaches
                  // beyond its directory, so removal needs an ownership snapshot
                  // and a journal, and both need a maintenance lease this process
                  // cannot hold while it is running the browser.
                  final bool queued;
                  try {
                    queued = await ref
                        .read(profileRepositoryProvider.notifier)
                        .deleteProfile(profile.uuidValue.uuid);
                  } catch (error) {
                    // Queued and then unqueued: the restart it needs could not be
                    // scheduled. Caught here because nothing above a button's
                    // handler would, and an uncaught error means the user taps
                    // "Delete" on a confirmed dialog and watches nothing happen.
                    if (context.mounted) {
                      showErrorMessage(
                        context,
                        l10n.user_deleteFailedWithError(
                          describeMaintenanceFailure(l10n, error),
                        ),
                      );
                    }
                    return;
                  }

                  if (queued) {
                    await exitApp(ref.container, restart: true);
                  } else if (context.mounted) {
                    // Refused rather than failed — the profile is gone already or
                    // its metadata is too damaged to discover. Saying so beats a
                    // screen that just closes after a confirmed delete.
                    showErrorMessage(
                      context,
                      l10n.user_deleteProfileFailedGeneric,
                    );
                    context.pop();
                  }
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}
