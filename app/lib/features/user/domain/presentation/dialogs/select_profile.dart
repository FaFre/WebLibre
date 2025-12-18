/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/utils/exit_app.dart';

class SelectProfileDialog extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(profileRepositoryProvider);

    return AlertDialog(
      title: const Text('Manage Users'),
      scrollable: true,
      content: usersAsync.when(
        skipLoadingOnReload: true,
        data: (profiles) => Column(
          children: profiles.map((profile) {
            final isSelected = filesystem.selectedProfile == profile.uuidValue;

            return ListTile(
              key: ValueKey(profile.id),
              enabled: !isSelected,
              leading: const Icon(Icons.person),
              title: Text(profile.name),
              subtitle: isSelected ? const Text('Active') : null,
              onTap: () async {
                final duplicateMozillaProfile = await filesystem
                    .checkForDuplicateMozillaProfile(profile.uuidValue);

                if (context.mounted) {
                  final result = await showDialog<(bool, bool)>(
                    context: context,
                    builder: (context) => HookBuilder(
                      builder: (context) {
                        final clearCache = useState(false);

                        return AlertDialog(
                          icon: const Icon(Icons.warning),
                          title: const Text('Switch User'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Switching to User '${profile.name}' will require a restart of the Browser.",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (duplicateMozillaProfile != null)
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: clearCache.value,
                                  title: const Text('Clear Shared Cache'),
                                  subtitle: const Text(
                                    'This User has been created based on an exisiting Mozilla Profile Identifier. Clearing cache will affect all linked accounts.',
                                  ),
                                  onChanged: (value) {
                                    clearCache.value = value;
                                  },
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop((false, false));
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop((true, clearCache.value));
                              },
                              child: const Text('Switch Profile'),
                            ),
                          ],
                        );
                      },
                    ),
                  );

                  if (result?.$1 == true) {
                    if (duplicateMozillaProfile != null && result?.$2 == true) {
                      await filesystem.clearMozillaProfileCache(
                        duplicateMozillaProfile,
                      );
                    }

                    await ref
                        .read(profileRepositoryProvider.notifier)
                        .switchProfile(profile.id);
                    await exitApp(ref.container);
                  }
                }
              },
            );
          }).toList(),
        ),
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed to load Profiles',
            exception: error,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () async {
            await ProfileListRoute().push(context);
          },
        ),
      ],
    );
  }
}
