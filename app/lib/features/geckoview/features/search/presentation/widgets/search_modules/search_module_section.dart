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
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_header.dart';

const previewItemsPerModule = 3;

/// A reusable wrapper for search module sections that handles:
/// - Display state management (preview/expanded/collapsed)
/// - Pinned header with collapse/expand and show-all/show-less controls
/// - Visible item count calculation
class SearchModuleSection extends ConsumerWidget {
  final String title;
  final SearchModuleType moduleType;
  final int totalCount;

  /// Builds the content slivers for this module.
  ///
  /// [isCollapsed] indicates whether the section is fully collapsed (no items).
  /// [visibleCount] is the number of items to display (0 when collapsed,
  /// limited in preview, or all when expanded).
  final List<Widget> Function({
    required bool isCollapsed,
    required int visibleCount,
  })
  contentSliverBuilder;

  const SearchModuleSection({
    super.key,
    required this.title,
    required this.moduleType,
    required this.totalCount,
    required this.contentSliverBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayState = ref.watch(
      searchModuleDisplayStateControllerProvider(moduleType),
    );

    final isCollapsed = displayState == SearchModuleDisplayState.collapsed;
    final showAllItems =
        displayState == SearchModuleDisplayState.expanded ||
        totalCount <= previewItemsPerModule;
    final visibleCount = isCollapsed
        ? 0
        : (showAllItems ? totalCount : previewItemsPerModule);

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        const SliverToBoxAdapter(child: Divider()),
        SliverPinnedHeader(
          child: ColoredBox(
            color: Theme.of(context).canvasColor,
            child: SearchModuleHeader(
              title: title,
              totalCount: totalCount,
              displayState: displayState,
              onToggleCollapse: () => ref
                  .read(
                    searchModuleDisplayStateControllerProvider(
                      moduleType,
                    ).notifier,
                  )
                  .toggleCollapse(),
              onToggleExpansion: () => ref
                  .read(
                    searchModuleDisplayStateControllerProvider(
                      moduleType,
                    ).notifier,
                  )
                  .toggleExpansion(),
            ),
          ),
        ),
        ...contentSliverBuilder(
          isCollapsed: isCollapsed,
          visibleCount: visibleCount,
        ),
      ],
    );
  }
}
