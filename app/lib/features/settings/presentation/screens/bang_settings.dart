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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_group_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';

class BangSettingsScreen extends HookConsumerWidget {
  const BangSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bang Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: [
              CustomListTile(
                title: 'Bang Frequencies',
                subtitle: 'Tracked usage for Bang recommendations',
                suffix: FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(bangDataRepositoryProvider.notifier)
                        .resetFrequencies();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                ),
              ),
              const SettingSubSection(name: 'Repositories'),
              const BangGroupListTile(
                group: BangGroup.general,
                title: 'General Bangs',
                subtitle: 'Sync on demand from GitHub',
              ),
              const BangGroupListTile(
                group: BangGroup.assistant,
                title: 'Assistant Bangs',
                subtitle: 'Sync on-demand from GitHub',
              ),
              const BangGroupListTile(
                group: BangGroup.kagi,
                title: 'Kagi Bangs',
                subtitle: 'Sync on-demand from GitHub',
              ),
            ],
          );
        },
      ),
    );
  }
}
