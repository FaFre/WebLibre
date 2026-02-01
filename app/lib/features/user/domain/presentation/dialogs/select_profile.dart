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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_switch_handler.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// Bottom sheet widget to select a user profile.
class SelectProfileDialog extends HookConsumerWidget {
  const SelectProfileDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(profileRepositoryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select user',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            usersAsync.when(
              skipLoadingOnReload: true,
              data: (profiles) => Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 16,
                children: [
                  ...profiles.map(
                    (profile) => _ProfileAvatar(
                      profile: profile,
                      isActive: filesystem.selectedProfile == profile.uuidValue,
                      onTap: () async {
                        await handleSwitchProfile(context, ref, profile);
                      },
                      onLongPress: () async {
                        await EditProfileRoute(
                          profile: jsonEncode(profile.toJson()),
                        ).push(context);
                      },
                    ),
                  ),
                  _AddProfileAvatar(
                    onTap: () async {
                      await CreateProfileRoute().push(context);
                    },
                  ),
                ],
              ),
              error: (error, stackTrace) => Center(
                child: FailureWidget(
                  title: 'Failed to load Profiles',
                  exception: error,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                await ProfileListRoute().push(context);
              },
              icon: const Icon(MdiIcons.accountGroup),
              label: const Text('Manage Profiles'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProfileAvatar({
    required this.profile,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.person,
              size: 24,
              color: isActive
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              profile.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onSurfaceVariant,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              'Add user',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
