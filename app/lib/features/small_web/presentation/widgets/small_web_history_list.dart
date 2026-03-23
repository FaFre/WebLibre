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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/data/providers.dart';
import 'package:weblibre/features/small_web/domain/providers.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_session_controller.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class SmallWebHistoryHeader extends ConsumerWidget {
  final SmallWebSourceKind sourceKind;
  final KagiSmallWebMode? mode;

  const SmallWebHistoryHeader({
    super.key,
    required this.sourceKind,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final modeLabel = mode?.label;

    return Row(
      children: [
        Text('Recent Discoveries', style: theme.textTheme.titleSmall),
        const Spacer(),
        PopupMenuButton<_ClearAction>(
          icon: Icon(
            Icons.more_vert,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          offset: const Offset(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (action) async {
            switch (action) {
              case _ClearAction.clearMode:
                await ref
                    .read(smallWebDatabaseProvider)
                    .smallWebVisitDao
                    .deleteVisitsBySourceAndMode(
                      sourceKind: sourceKind,
                      mode: mode,
                    );
              case _ClearAction.clearAll:
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear all discoveries?'),
                    content: const Text(
                      'This will permanently remove all recent discovery history across every mode and source.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(smallWebDatabaseProvider)
                      .smallWebVisitDao
                      .deleteAllVisits();
                }
            }
          },
          itemBuilder: (context) => [
            if (modeLabel != null)
              PopupMenuItem(
                value: _ClearAction.clearMode,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_sweep, size: 20),
                  title: Text('Clear $modeLabel'),
                ),
              ),
            PopupMenuItem(
              value: _ClearAction.clearAll,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_forever,
                  size: 20,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Clear all discoveries',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _ClearAction { clearMode, clearAll }

class SmallWebHistoryList extends HookConsumerWidget {
  static const _initialCount = 10;

  final SmallWebSourceKind sourceKind;
  final KagiSmallWebMode? mode;

  const SmallWebHistoryList({
    super.key,
    required this.sourceKind,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(
      smallWebRecentVisitsProvider(sourceKind, mode),
    );

    final expanded = useState(false);

    return visitsAsync.when(
      data: (visits) {
        if (visits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No discoveries yet.\nTap Discover to start exploring!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        final hasMore = visits.length > _initialCount;
        final visibleCount = expanded.value || !hasMore
            ? visits.length
            : _initialCount;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleCount,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return _HistoryListItem(
                  visit: visit,
                  sourceKind: sourceKind,
                  mode: mode,
                );
              },
            ),
            if (hasMore && !expanded.value)
              TextButton(
                onPressed: () => expanded.value = true,
                child: Text('Show ${visits.length - _initialCount} more'),
              ),
          ],
        );
      },
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Failed to load history: $error')),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _HistoryListItem extends ConsumerWidget {
  final GetRecentVisitsResult visit;
  final SmallWebSourceKind sourceKind;
  final KagiSmallWebMode? mode;

  const _HistoryListItem({
    required this.visit,
    required this.sourceKind,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const borderRadius = BorderRadius.all(Radius.circular(12));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: const BoxDecoration(borderRadius: borderRadius),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () async {
            await ref
                .read(smallWebSessionControllerProvider.notifier)
                .revisit(
                  itemId: visit.itemId,
                  url: visit.url,
                  sourceKind: sourceKind,
                  mode: mode,
                  consoleUrl: visit.consoleUrl,
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
            child: Row(
              children: [
                UrlIcon([visit.url], iconSize: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        visit.title ?? visit.domain,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      UriBreadcrumb(
                        uri: visit.url,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await ref
                        .read(smallWebDatabaseProvider)
                        .smallWebVisitDao
                        .deleteVisitById(visit.id);
                  },
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
