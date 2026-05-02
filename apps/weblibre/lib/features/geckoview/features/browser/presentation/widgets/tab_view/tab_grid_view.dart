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
import 'dart:async';
import 'dart:math' as math;

import 'package:fading_scroll/fading_scroll.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_view_reorder.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_context_menu_draggable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_drop_target.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_group_expand_toggle.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/browser/utils/grid_calculations.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    show TabsWithRootAndDepthResult;
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Top-left expand/collapse toggle for grid cells. Returns null for any
/// row that is not a parent — leaf children rely on the bottom-left depth
/// indicator instead.
Widget? _gridGroupToggleFor(TabViewItem row) {
  final parentGroup = row.parentGroup;
  if (parentGroup != null) {
    return TabGroupExpandToggle(
      parentId: parentGroup.tabId,
      childCount: parentGroup.childCount,
      style: TabGroupToggleStyle.grid,
    );
  }
  final child = row.childItem;
  if (child != null && child.childCount > 0) {
    return TabGroupExpandToggle(
      parentId: child.tabId,
      childCount: child.childCount,
      style: TabGroupToggleStyle.grid,
    );
  }
  return null;
}

int _gridDepthFor(TabViewItem row) => row.childItem?.depth ?? 0;

class _TabDraggable extends HookConsumerWidget {
  final String tabId;
  final String? sourceSearchQuery;
  final String? suggestedContainerId;
  final VoidCallback onClose;
  final Widget? groupToggle;
  final int depth;

  const _TabDraggable({
    required this.tabId,
    required this.onClose,
    this.sourceSearchQuery,
    this.suggestedContainerId,
    this.groupToggle,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(selectedTabProvider);

    final dragData = ref.watch(
      willAcceptDropProvider.select((value) {
        final dragTabId = switch (value) {
          ContainerDropData() => value.tabId,
          DeleteDropData() => value.tabId,
          null => null,
        };

        return (dragTabId == tabId) ? value : null;
      }),
    );

    // Cache the tab widget to avoid rebuilding
    final tab = useMemoized(() {
      return (suggestedContainerId != null)
          ? SuggestedSingleGridTabPreview(
              key: ValueKey(tabId),
              tabId: tabId,
              activeTabId: activeTab,
              onTap: () async {
                final containerData = await ref
                    .read(containerRepositoryProvider.notifier)
                    .getContainerData(suggestedContainerId!);

                if (containerData != null) {
                  await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .assignContainer(tabId, containerData);
                }
              },
            )
          : SingleGridTabPreview(
              key: ValueKey(tabId),
              tabId: tabId,
              activeTabId: activeTab,
              onClose: onClose,
              sourceSearchQuery: sourceSearchQuery,
              groupToggle: groupToggle,
              depth: depth,
            );
    }, [tabId, activeTab, suggestedContainerId, groupToggle, depth]);

    return switch (dragData) {
      ContainerDropData() => Opacity(
        opacity: 0.3,
        child: Transform.scale(scale: 0.9, child: tab),
      ),
      DeleteDropData() => Opacity(
        opacity: 0.3,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.red, BlendMode.modulate),
          child: tab,
        ),
      ),
      null => tab,
    };
  }
}

class _TabGridView extends HookConsumerWidget {
  final ScrollController scrollController;
  final bool tabsReorderable;
  final VoidCallback onClose;

  const _TabGridView({
    required this.scrollController,
    required this.tabsReorderable,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final canManualReorder = ref.watch(canManualTabReorderProvider);
    final containerId = ref.watch(selectedContainerProvider);
    final reorderEnabled = tabsReorderable && canManualReorder;
    final filterOptions = ref.watch(tabViewFilterControllerProvider);
    final showHierarchicalTabs = filterOptions.showHierarchicalTabs;
    final tabListDirection = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListDirection),
    );
    final pinnedTabIds = ref.watch(
      watchPinnedTabIdsProvider.select(
        (value) => value.value ?? const <String>{},
      ),
    );
    final collapsedGroups = ref.watch(collapsedGroupsProvider);
    final List<TabsWithRootAndDepthResult> treeRows = showHierarchicalTabs
        ? ref.watch(
            watchTabsWithRootAndDepthProvider(
              containerId,
            ).select((value) => value.value ?? const []),
          )
        : const <TabsWithRootAndDepthResult>[];

    final hasActiveSearch = ref.watch(
      tabSearchRepositoryProvider(
        TabSearchPartition.preview,
      ).select((value) => (value.value?.query ?? '').isNotEmpty),
    );

    final List<TabViewItem> primaryRows;
    if (hasActiveSearch || !showHierarchicalTabs) {
      final flat = ref.watch(
        seamlessFilteredTabEntitiesProvider(
          searchPartition: TabSearchPartition.preview,
          // ignore: document_ignores using fast equatable
          // ignore: provider_parameters
          containerFilter: ContainerFilterById(containerId: containerId),
          groupTrees: false,
        ),
      );
      primaryRows = [
        for (final entity in flat.value)
          TabViewItem.search(
            tabId: entity.tabId,
            sourceSearchQuery: switch (entity) {
              DefaultTabEntity _ => null,
              final SearchResultTabEntity e => e.searchQuery,
              TabTreeEntity _ => null,
            },
          ),
      ];
    } else {
      final grouped = ref.watch(
        groupedTabListItemsProvider(containerId: containerId),
      );
      primaryRows = [
        for (final item in grouped.value)
          switch (item) {
            TabListStandaloneItem(:final tabId) => TabViewItem.standalone(
              tabId: tabId,
            ),
            final TabListParentGroup g => TabViewItem.parent(
              tabId: g.tabId,
              parentGroup: g,
            ),
            final TabListChildItem c => TabViewItem.child(
              tabId: c.tabId,
              childItem: c,
            ),
          },
      ];
    }

    final tabSuggestionsEnabled = ref.watch(
      persistedBoolProvider(PersistedBoolKey.tabSuggestions),
    );

    final suggestedTabEntities = tabSuggestionsEnabled
        ? ref.watch(suggestedTabEntitiesProvider(containerId))
        : EquatableValue(<TabEntity>[]);

    final itemCount =
        primaryRows.length +
        //Limit to 3 sugegstions for now
        math.min<int>(suggestedTabEntities.value.length, 3);
    final displayItemCount = reorderEnabled ? primaryRows.length : itemCount;

    final activeTab = ref.watch(selectedTabProvider);

    final crossAxisCount = useMemoized(() {
      final calculatedCount = calculateCrossAxisItemCount(
        screenWidth: screenWidth,
        horizontalPadding: 4.0,
        crossAxisSpacing: 8.0,
      );

      return math.max(math.min(calculatedCount, itemCount), 2);
    }, [screenWidth, itemCount]);

    final itemSize = useMemoized(
      () => calculateItemSize(
        screenWidth: screenWidth,
        childAspectRatio: 0.75,
        horizontalPadding: 4.0,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        crossAxisCount: crossAxisCount,
      ),
      [screenWidth, crossAxisCount],
    );

    final didInitialScroll = useRef(false);

    useEffect(() {
      if (didInitialScroll.value) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients && activeTab != null) {
          final index = primaryRows.indexWhere((row) => row.tabId == activeTab);

          if (index > -1) {
            final row = index ~/ crossAxisCount;
            final viewportStart = scrollController.offset;
            final viewportEnd =
                viewportStart + scrollController.position.viewportDimension;
            final tabStart = row * itemSize.height;
            final tabEnd = tabStart + itemSize.height;

            final isVisible =
                tabStart >= viewportStart && tabEnd <= viewportEnd;

            if (!isVisible) {
              if (disableAnimations) {
                scrollController.jumpTo(tabStart);
              } else {
                unawaited(
                  scrollController.animateTo(
                    tabStart,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  ),
                );
              }

              didInitialScroll.value = true;
            } else {
              didInitialScroll.value = true;
            }
          } else {
            didInitialScroll.value = true;
          }
        }
      });

      return null;
    }, [activeTab]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FadingScroll(
        fadingSize: 5,
        controller: scrollController,
        builder: (context, controller) {
          return !reorderEnabled
              ? _TabGrid(
                  key: ValueKey(crossAxisCount),
                  crossAxisCount: crossAxisCount,
                  itemCount: displayItemCount,
                  scrollController: controller,
                  itemBuilder: (widget, _) {
                    if (widget is CustomDraggable) {
                      if (widget.data case final TabDragData dragData) {
                        return TabContextMenuDraggable(
                          tabId: dragData.tabId,
                          data: dragData,
                          feedbackSize: itemSize,
                          child: widget.child,
                        );
                      }
                    }

                    return widget;
                  },
                  suggestedContainerId: containerId,
                  primaryRows: primaryRows,
                  suggestedTabEntities: suggestedTabEntities,
                  onClose: onClose,
                )
              : ReorderableBuilder.builder(
                  //Rebuild when cross axis count changes
                  key: ValueKey(crossAxisCount),
                  scrollController: controller,
                  itemCount: displayItemCount,
                  onDragStarted: (index) {
                    ref.read(willAcceptDropProvider.notifier).clear();
                  },
                  onReorderPositions: (positions) async {
                    assert(
                      positions.length == 1,
                      'Not ready for multiple reorders',
                    );

                    final oldIndex = positions.first.oldIndex;
                    final newIndex = positions.first.newIndex;

                    //Suggestions are at the end and not reorderable, so skip
                    if (oldIndex >= primaryRows.length) {
                      return;
                    }

                    final result = buildTabViewReorderResult(
                      visibleItems: primaryRows,
                      treeRows: treeRows,
                      collapsedGroups: collapsedGroups,
                      pinnedTabIds: pinnedTabIds,
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                      tabListDirection: tabListDirection,
                      hierarchical: showHierarchicalTabs && !hasActiveSearch,
                      sortPinnedFirst: filterOptions.sortPinnedFirst,
                    );

                    if (result == null) return;

                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .reorderTabs(
                          movingTabIds: result.movingTabIds,
                          previousTabId: result.previousTabId,
                          nextTabId: result.nextTabId,
                        );
                  },
                  childBuilder: (reorderableItemBuilder) {
                    return _TabGrid(
                      crossAxisCount: crossAxisCount,
                      itemCount: displayItemCount,
                      scrollController: controller,
                      itemBuilder: (widget, index) {
                        // Wrap with context menu before passing to reorderable
                        Widget wrapped = widget;
                        if (widget is CustomDraggable) {
                          if (widget.data case final TabDragData dragData) {
                            wrapped = CustomDraggable(
                              key: widget.key!,
                              data: widget.data,
                              child: TabContextMenuDraggable(
                                tabId: dragData.tabId,
                                feedbackSize: Size.zero,
                                externalDrag: true,
                                child: widget.child,
                              ),
                            );
                          }
                        }
                        return reorderableItemBuilder(wrapped, index);
                      },
                      suggestedContainerId: containerId,
                      primaryRows: primaryRows,
                      suggestedTabEntities: suggestedTabEntities,
                      onClose: onClose,
                    );
                  },
                );
        },
      ),
    );
  }
}

class _TabGrid extends StatelessWidget {
  const _TabGrid({
    super.key,
    required this.crossAxisCount,
    required this.scrollController,
    required this.itemCount,
    required this.itemBuilder,
    required this.suggestedContainerId,
    required this.primaryRows,
    required this.suggestedTabEntities,
    required this.onClose,
  });

  final int crossAxisCount;
  final int itemCount;
  final ScrollController? scrollController;
  final String? suggestedContainerId;
  final List<TabViewItem> primaryRows;
  final EquatableValue<List<TabEntity>> suggestedTabEntities;
  final Widget Function(Widget, int)? itemBuilder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //Sync values for itemHeight calculation _calculateItemHeight
        childAspectRatio: 0.75,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < primaryRows.length) {
          final row = primaryRows[index];
          final tab = CustomDraggable(
            key: Key(row.tabId),
            data: TabDragData(row.tabId),
            child: _TabDraggable(
              tabId: row.tabId,
              sourceSearchQuery: row.sourceSearchQuery,
              onClose: onClose,
              groupToggle: _gridGroupToggleFor(row),
              depth: _gridDepthFor(row),
            ),
          );

          if (itemBuilder == null) {
            return TabDropTarget(targetTabId: row.tabId, child: tab);
          }
          return itemBuilder!(tab, index);
        }

        final suggestedIndex = index - primaryRows.length;
        final entity = suggestedTabEntities.value[suggestedIndex];

        final tab = CustomDraggable(
          key: Key('suggested_${entity.tabId}'),
          child: _TabDraggable(
            tabId: entity.tabId,
            onClose: onClose,
            suggestedContainerId: suggestedContainerId,
          ),
        );

        return (itemBuilder != null) ? itemBuilder!(tab, index) : tab;
      },
    );
  }
}

class ViewTabGridWidget extends HookConsumerWidget {
  final ScrollController scrollController;
  final DraggableScrollableController? draggableScrollableController;
  final bool showNewTabFab;
  final bool tabsReorderable;
  final VoidCallback onClose;

  static const _hideThreshold = 0.02; // 2% of sheet size change
  static const _showThreshold = 0.02;

  const ViewTabGridWidget({
    required this.onClose,
    required this.scrollController,
    this.draggableScrollableController,
    required this.tabsReorderable,
    required this.showNewTabFab,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isFabVisible = useState(true);
    final lastSheetSize = useRef(0.0);
    final isInitialized = useRef(false);

    // Delay initialization to ignore initial animations
    useEffect(() {
      final timer = Timer(
        disableAnimations ? Duration.zero : const Duration(milliseconds: 500),
        () {
          isInitialized.value = true;
          // Initialize lastSheetSize with current size
          if (draggableScrollableController?.isAttached == true) {
            lastSheetSize.value = draggableScrollableController!.size;
          }
        },
      );
      return timer.cancel;
    }, [disableAnimations]);

    // Listen to DraggableScrollableController for sheet size changes
    useEffect(() {
      final controller = draggableScrollableController;
      if (controller == null) return null;

      void listener() {
        if (!isInitialized.value) return;
        if (!controller.isAttached) return;

        final currentSize = controller.size;
        final difference = currentSize - lastSheetSize.value;

        // Hide when sheet expands (dragging up / scrolling down)
        if (difference > _hideThreshold && isFabVisible.value) {
          isFabVisible.value = false;
        }
        // Show when sheet collapses (dragging down / scrolling up)
        else if (difference < -_showThreshold && !isFabVisible.value) {
          isFabVisible.value = true;
        }

        lastSheetSize.value = currentSize;
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [draggableScrollableController]);

    // Fallback: Also listen to scroll controller for fullscreen mode (no draggable sheet)
    useEffect(() {
      if (draggableScrollableController != null) return null;

      var lastOffset = 0.0;
      void listener() {
        if (!isInitialized.value) return;

        final currentOffset = scrollController.offset;
        final difference = currentOffset - lastOffset;

        if (difference > 10.0 && isFabVisible.value) {
          isFabVisible.value = false;
        } else if ((difference < -10.0 || currentOffset <= 0) &&
            !isFabVisible.value) {
          isFabVisible.value = true;
        }

        lastOffset = currentOffset;
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, draggableScrollableController]);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child:
                  draggableScrollableController.mapNotNull(
                    (draggableScrollableController) =>
                        DraggableScrollableHeader(
                          controller: draggableScrollableController,
                          child: TabViewHeader(
                            onClose: onClose,
                            tabsViewMode: TabsViewMode.grid,
                          ),
                        ),
                  ) ??
                  TabViewHeader(
                    onClose: onClose,
                    tabsViewMode: TabsViewMode.grid,
                  ),
            ),
          ],
          body: _TabGridView(
            scrollController: scrollController,
            tabsReorderable: tabsReorderable,
            onClose: onClose,
          ),
        ),
        if (showNewTabFab)
          AnimatedSlide(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 200),
            offset: isFabVisible.value ? Offset.zero : const Offset(0, 2),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              opacity: isFabVisible.value ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: TabViewHeader.headerSize + 4,
                  right: 4,
                ),
                child: FloatingActionButton.small(
                  onPressed: () async {
                    final settings = ref.read(
                      generalSettingsWithDefaultsProvider,
                    );

                    await SearchRoute(
                      tabType:
                          ref.read(selectedTabTypeProvider) ??
                          settings.effectiveDefaultCreateTabType,
                    ).push(context);

                    onClose();
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
