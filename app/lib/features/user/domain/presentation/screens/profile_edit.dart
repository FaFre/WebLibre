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
import 'package:weblibre/features/user/domain/presentation/dialogs/delete_profile_dialog.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_switch_handler.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/utils/form_validators.dart';

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

    // Require biometric confirmation when enabling/changing auth
    if (profile != null &&
        (profile!.authSettings.authenticationRequired ||
            authSettings.authenticationRequired)) {
      final authResult = await ref
          .read(localAuthenticationServiceProvider.notifier)
          .authenticate(
            authKey: profileAccessAuthKey(profile!.id),
            localizedReason: 'Require authentication for profile',
          );

      if (!authResult) {
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
            ? const Text('Edit User')
            : const Text('Create User'),
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
      body: Form(
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
            if (profile != null) ...[_ProfileActionsSection(profile: profile!)],
          ],
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
          title: const Text('Require Authentication'),
          subtitle: const Text(
            'Lock this profile when switching away from the app',
          ),
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
                  title: Text('Auto-lock Behavior'),
                  subtitle: Text('Choose when to lock the profile'),
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
                        title: Text('Lock on Background'),
                        subtitle: Text(
                          'Lock immediately when app goes to background',
                        ),
                      ),
                      RadioListTile.adaptive(
                        value: AutoLockMode.timeout,
                        title: Text('Lock After Timeout'),
                        subtitle: Text('Lock after a period of inactivity'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (authSettings.autoLockMode == AutoLockMode.timeout)
            ListTile(
              title: const Text('Timeout Duration'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSection(name: 'Profile Actions'),
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
        const SizedBox(height: 12),
        if (filesystem.selectedProfile != profile.uuidValue)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              label: const Text('Switch to this Profile'),
              icon: const Icon(MdiIcons.accountSwitch),
              onPressed: () async {
                await handleSwitchProfile(context, ref, profile);
              },
            ),
          ),
        if (filesystem.selectedProfile != profile.uuidValue)
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
              final result = await showDeleteProfileDialog(context);

              if (result == true) {
                await ref
                    .read(profileRepositoryProvider.notifier)
                    .deleteProfile(profile.uuidValue.uuid);

                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
