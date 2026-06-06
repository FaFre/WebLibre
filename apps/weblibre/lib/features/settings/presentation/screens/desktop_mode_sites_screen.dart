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
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/string_list_settings_screen.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/host_rules.dart';

/// Manages the list of sites that always load in desktop mode.
class DesktopModeSitesScreen extends HookConsumerWidget {
  const DesktopModeSitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktopModeSites = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.desktopModeSites),
    );

    return StringListSettingsScreen(
      title: 'Desktop mode sites',
      description:
          'These sites always load in desktop mode, overriding the default. '
          'Subdomains are included (e.g. "example.com" also covers '
          '"m.example.com").',
      values: desktopModeSites,
      hintText: 'example.com',
      itemIcon: Icons.desktop_windows,
      emptyLabel: 'No sites added.',
      normalize: normalizeRuleHost,
      onChanged: (next) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((current) => current.copyWith.desktopModeSites(next));
      },
    );
  }
}
