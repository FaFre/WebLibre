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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_group_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

const List<SettingsSectionDefinition> bangSettingsSections = [
  SettingsSectionDefinition(
    title: 'Usage Data',
    entries: [
      SettingsEntryDefinition(
        title: 'Bang Frequencies',
        subtitle: 'Tracked usage for bang recommendations',
        keywords: ['usage', 'recommendations'],
        child: _BangFrequenciesTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Repositories',
    entries: [
      SettingsEntryDefinition(
        title: 'General Bangs',
        subtitle: 'Sync on demand from GitHub',
        keywords: ['repository'],
        child: BangGroupListTile(
          group: BangGroup.general,
          title: 'General Bangs',
          subtitle: 'Sync on demand from GitHub',
        ),
      ),
      SettingsEntryDefinition(
        title: 'Kagi Bangs',
        subtitle: 'Sync on demand from GitHub',
        keywords: ['repository'],
        child: BangGroupListTile(
          group: BangGroup.kagi,
          title: 'Kagi Bangs',
          subtitle: 'Sync on-demand from GitHub',
        ),
      ),
    ],
  ),
];

class BangSettingsScreen extends HookConsumerWidget {
  const BangSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsDetailScaffold(
      title: 'Bang Settings',
      subtitle: 'Bang shortcuts usage, repositories, and on-demand sync.',
      icon: MdiIcons.exclamationThick,
      sections: bangSettingsSections,
    );
  }
}

class _BangFrequenciesTile extends HookConsumerWidget {
  const _BangFrequenciesTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomListTile(
      title: 'Bang Frequencies',
      subtitle: 'Tracked usage for bang recommendations',
      suffix: FilledButton.icon(
        onPressed: () async {
          await ref
              .read(bangDataRepositoryProvider.notifier)
              .resetFrequencies();
        },
        icon: const Icon(Icons.delete),
        label: const Text('Clear'),
      ),
    );
  }
}
