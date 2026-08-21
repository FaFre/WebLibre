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
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/delete_profile_dialog.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_switch_handler.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Scope for the confirmation taken *before* a locked profile exists.
///
/// Deliberately not a per-profile key: there is no profile id yet, and the value
/// only scopes `LocalAuthenticationService`'s result cache.
const _newProfileAuthKey = 'profile_access::pending';

const _timeoutOptions = <DropdownMenuItem<Duration?>>[
  DropdownMenuItem(value: Duration(minutes: 1), child: Text('1 minute')),
  DropdownMenuItem(value: Duration(minutes: 5), child: Text('5 minutes')),
  DropdownMenuItem(value: Duration(minutes: 15), child: Text('15 minutes')),
  DropdownMenuItem(value: Duration(hours: 1), child: Text('1 hour')),
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

    // Require confirmation whenever a lock is involved — including on the
    // *create* path, which used to skip it because there was no existing profile
    // to compare against. Skipping it meant a user could switch the lock on with
    // nothing enrolled on the device: `authenticate` catches `LocalAuthException`
    // and reports failure, there is no way to clear the lock from outside the
    // profile, and the result was a user that could never be opened. Proving the
    // gate works before it is armed is the only thing standing between the toggle
    // and that.
    final locking = profile != null
        ? profile!.authSettings.authenticationRequired ||
              authSettings.authenticationRequired
        : authSettings.authenticationRequired;

    if (locking) {
      final authResult = await ref
          .read(localAuthenticationServiceProvider.notifier)
          .authenticate(
            // A profile being created has no id yet, and the key only scopes the
            // result cache — nothing has been created for it to belong to.
            authKey: profile != null
                ? profileAccessAuthKey(profile!.id)
                : _newProfileAuthKey,
            localizedReason: profile != null
                ? 'Require authentication for profile'
                : 'Confirm you can unlock this profile',
            settings: authSettings,
          );

      if (!authResult) {
        if (context.mounted) {
          showErrorMessage(
            context,
            profile != null
                ? 'Could not confirm your identity. $nothingChanged'
                : 'Could not confirm your identity. A locked profile is only '
                      'created once this device can unlock it.',
          );
        }
        return;
      }
    }

    if (profile != null) {
      await ref
          .read(profileRepositoryProvider.notifier)
          .updateProfileMetadata(
            profile!.copyWith(name: name, authSettings: authSettings),
          );

      if (context.mounted) {
        context.pop();
      }
    } else {
      await ref
          .read(profileRepositoryProvider.notifier)
          .createProfile(name: name, authSettings: authSettings);

      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameTextController = useTextEditingController(text: profile?.name);
    final authSettings = useState(
      profile?.authSettings ?? AuthSettings.withDefaults(),
    );

    return Scaffold(
      appBar: AppBar(
        title: (profile != null)
            ? const Text('Edit Profile')
            : const Text('Create Profile'),
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
                decoration: const InputDecoration(
                  label: Text('Name'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: validateProfileName,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSection(name: 'Authentication'),
        SwitchListTile.adaptive(
          value: authSettings.authenticationRequired,
          title: const Text('Require authentication'),
          subtitle: const Text('Ask before this profile can be opened'),
          secondary: const Icon(MdiIcons.fingerprint),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            onAuthSettingsChanged(
              authSettings.copyWith.authenticationRequired(value),
            );
          },
        ),
        if (authSettings.authenticationRequired) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Auto-lock'),
                  subtitle: Text('When to lock the profile again'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(MdiIcons.lockClock),
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
                  child: const Column(
                    children: [
                      RadioListTile.adaptive(
                        value: AutoLockMode.background,
                        title: Text('Lock in background'),
                        subtitle: Text('As soon as WebLibre leaves the screen'),
                      ),
                      RadioListTile.adaptive(
                        value: AutoLockMode.timeout,
                        title: Text('Lock after a timeout'),
                        subtitle: Text('After a period of inactivity'),
                      ),
                      RadioListTile.adaptive(
                        value: AutoLockMode.startup,
                        title: Text('Lock on startup only'),
                        subtitle: Text(
                          'Unlock once at startup, then stay unlocked until '
                          'WebLibre is fully closed',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (authSettings.autoLockMode == AutoLockMode.timeout)
            ListTile(
              title: const Text('Timeout'),
              subtitle: const Text('How long to wait before locking'),
              leading: const Icon(MdiIcons.timerOutline),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              trailing: DropdownButton<Duration?>(
                value: authSettings.timeout,
                items: _timeoutOptions,
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
    // Backup is offered for every profile, the active one included: it does not
    // run here at all — it is queued and taken by the next process, with the
    // profile closed. Switching and deleting are the two that genuinely cannot
    // act on the profile this process is serving, so they are left out rather
    // than shown to fail.
    final isActive = filesystem.selectedProfile == profile.uuidValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSection(name: 'Profile actions'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            label: const Text('Backup'),
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
              'Switching and deleting are unavailable for the profile you '
              'are using.',
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
              label: const Text('Switch to this profile'),
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
              label: const Text('Delete'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final result = await showDeleteProfileDialog(
                  context,
                  profileName: profile.name,
                );

                if (result == true) {
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
                      showErrorMessage(context, 'Could not delete: $error');
                    }
                    return;
                  }

                  if (queued) {
                    await exitApp(ref.container, restart: true);
                  } else if (context.mounted) {
                    // Refused rather than failed — the profile is gone already or
                    // its metadata is too damaged to discover. Saying so beats a
                    // screen that just closes after a confirmed delete.
                    showErrorMessage(context, 'Could not delete this profile');
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
