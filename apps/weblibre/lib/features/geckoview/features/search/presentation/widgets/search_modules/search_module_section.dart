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
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_header.dart';

const previewItemsPerModule = 3;

/// A reusable wrapper for search module sections that handles:
/// - Display state management (preview/expanded/collapsed)
/// - Pinned header with collapse/expand and show-all/show-less controls
/// - Visible item count calculation
///
/// **Always render this widget, even when [totalCount] is 0.** The header
/// carries the long-press affordance that activates reorder mode and the
/// visibility toggle — short-circuiting to `SizedBox.shrink()` at the call
/// site means the user can lose their only entry-point to module
/// configuration. Set [hideWhenEmpty] explicitly if the section should
/// collapse silently.
class SearchModuleSection extends ConsumerWidget {
  final String title;
  final SearchModuleType moduleType;
  final int totalCount;

  /// Builds the content slivers for this module.
  ///
  /// [isCollapsed] indicates whether the section is fully collapsed (no items).
  /// [visibleCount] is the number of items to display (0 when collapsed,
  /// limited in preview, or all when expanded).
  /// Optional widget placed in the header between title and trailing button.
  final Widget? headerTrailing;

  /// The maximum number of items shown in preview mode for this section.
  final int previewLimit;

  /// If true and [totalCount] is 0, the entire section (header included)
  /// is omitted. Use sparingly — see the class doc for why hiding the
  /// header is usually undesirable.
  final bool hideWhenEmpty;

  /// Set false for modules whose body is a single non-paginated widget
  /// (e.g. a chip strip with its own scrolling). When false:
  ///   - the "Show all N / Show less" affordance is suppressed,
  ///   - [visibleCount] passed to [contentSliverBuilder] is always
  ///     [totalCount] (the section can't be partially shown),
  ///   - the section can still be fully collapsed via the header chevron.
  ///
  /// This replaces the prior workaround of passing `totalCount: 0,
  /// previewLimit: 0` to suppress pagination.
  final bool showPagination;

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
    this.headerTrailing,
    this.previewLimit = previewItemsPerModule,
    this.hideWhenEmpty = false,
    this.showPagination = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleOrder = ref.watch(searchModuleOrderProvider(moduleType.group));
    final isVisible = moduleOrder.any((e) => e.type == moduleType && e.visible);
    if (!isVisible) {
      return MultiSliver(children: const []);
    }

    if (hideWhenEmpty && totalCount == 0) {
      return MultiSliver(children: const []);
    }

    final displayState = ref.watch(
      searchModuleDisplayStateControllerProvider(moduleType),
    );

    final isCollapsed = displayState == SearchModuleDisplayState.collapsed;
    final showAllItems =
        !showPagination ||
        displayState == SearchModuleDisplayState.expanded ||
        totalCount <= previewLimit;
    final visibleCount = isCollapsed
        ? 0
        : (showAllItems ? totalCount : previewLimit);

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
              headerTrailing: isCollapsed ? null : headerTrailing,
              previewLimit: previewLimit,
              showPagination: showPagination,
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
              onLongPress: () => ref
                  .read(searchReorderModeProvider.notifier)
                  .activate(moduleType.group),
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
