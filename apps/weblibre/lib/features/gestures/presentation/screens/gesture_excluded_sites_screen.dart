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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/gestures/presentation/widgets/string_list_editor.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Manages the list of sites on which gestures are disabled.
class GestureExcludedSitesScreen extends HookConsumerWidget {
  const GestureExcludedSitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excludedSites = ref.watch(
      gestureSettingsWithDefaultsProvider.select((s) => s.excludedSites),
    );

    return SettingsCustomScrollScaffold(
      title: 'Excluded sites',
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Gestures are disabled on these sites. Subdomains are included '
              '(e.g. "example.com" also covers "m.example.com").',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: StringListEditor(
            values: excludedSites,
            hintText: 'example.com',
            itemIcon: Icons.public_off,
            emptyLabel: 'No sites excluded.',
            normalize: normalizeGestureSiteHost,
            onChanged: (next) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) => current.copyWith.excludedSites(next),
                  );
            },
          ),
        ),
      ],
    );
  }
}
