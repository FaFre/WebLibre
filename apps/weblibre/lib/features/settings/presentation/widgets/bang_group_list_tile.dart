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
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/sync.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sync_details_table.dart';

class BangGroupListTile extends HookConsumerWidget {
  final BangGroup group;

  final String title;
  final String subtitle;

  const BangGroupListTile({
    required this.group,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastSync = ref.watch(
      lastSyncOfGroupProvider(group).select((value) => value.value),
    );

    final count = ref.watch(
      bangCountOfGroupProvider(group).select((value) => value.value),
    );

    return CustomListTile(
      title: title,
      subtitle: subtitle,
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SyncDetailsTable(count, lastSync),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await ref
              .read(bangSyncRepositoryProvider.notifier)
              .syncRemoteBangGroup(group, null);
        },
        icon: const Icon(Icons.sync),
        label: const Text('Sync'),
      ),
    );
  }
}
