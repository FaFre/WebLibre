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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_settings.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_labels.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ProfileListScreen extends HookConsumerWidget {
  const ProfileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(profileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            onPressed: () async {
              await ProfileBackupListRoute().push(context);
            },
            icon: const Icon(MdiIcons.backupRestore),
          ),
        ],
      ),
      body: SafeArea(
        child: usersAsync.when(
          skipLoadingOnReload: true,
          data: (profiles) {
            // Two users with one name are two identical rows, and the row you
            // tap is the one whose Delete you reach.
            final labels = profileLabels(profiles);

            return ListView.builder(
              // One extra row for the startup prompt switch, kept in the same
              // scrollable so a long profile list does not push it out of reach.
              itemCount: profiles.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _StartupPromptTile();
                }

                final profile = profiles[index - 1];
                final isSelected =
                    filesystem.selectedProfile == profile.uuidValue;

                // The active profile is tappable like any other: its edit screen
                // is the only way to reach backup, rename and auth settings, and
                // all three work on the profile this process is serving. Only
                // switching and deleting do not, and the edit screen hides those.
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(labelOfProfile(profile, labels)),
                  subtitle: isSelected ? const Text('Active') : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await EditProfileRoute(
                      profile: jsonEncode(profile.toJson()),
                    ).push(context);
                  },
                );
              },
            );
          },
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: 'Could not load profiles',
              exception: error,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await CreateProfileRoute().push(context);
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

/// Switches the global startup profile prompt.
///
/// It lives here rather than in settings because settings are per profile, and
/// this decides which profile starts — a per-profile switch could be on in one
/// and off in another with no way to say which wins.
///
/// Turning it on changes nothing until a second profile exists: with one profile
/// there is nothing to choose between, so startup does not stop to ask.
class _StartupPromptTile extends HookConsumerWidget {
  const _StartupPromptTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(profilePromptSettingProvider);

    return SwitchListTile(
      secondary: const Icon(MdiIcons.accountQuestion),
      title: const Text('Ask which profile to open'),
      subtitle: const Text('At startup, when more than one profile exists'),
      value: setting.value == ProfilePromptMode.browserOnly,
      onChanged: setting.isLoading
          ? null
          : (enabled) async {
              await ref
                  .read(profilePromptSettingProvider.notifier)
                  .setMode(
                    enabled
                        ? ProfilePromptMode.browserOnly
                        : ProfilePromptMode.off,
                  );
            },
    );
  }
}
