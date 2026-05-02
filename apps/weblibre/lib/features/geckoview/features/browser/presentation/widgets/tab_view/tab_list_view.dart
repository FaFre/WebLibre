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
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    show TabsWithRootAndDepthResult;
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Build the hierarchy toggle injected into [ListTabPreview.groupToggle].
///
/// Returns a [TabGroupExpandToggle] for any node with descendants
/// (root parents AND intermediate children), and null otherwise.
Widget? _listGroupToggleFor(TabViewItem row) {
  final parentGroup = row.parentGroup;
  if (parentGroup != null) {
    return TabGroupExpandToggle(
      parentId: parentGroup.tabId,
      childCount: parentGroup.childCount,
    );
  }
  final child = row.childItem;
  if (child != null && child.childCount > 0) {
    return TabGroupExpandToggle(
      parentId: child.tabId,
      childCount: child.childCount,
    );
  }
  return null;
}

int _depthFor(TabViewItem row) => row.childItem?.depth ?? 0;

class _TabDraggable extends HookConsumerWidget {
  final String tabId;
  final String? sourceSearchQuery;
  final String? suggestedContainerId;
  final VoidCallback onClose;
  final double height;
  final Widget? groupToggle;
  final int depth;

  const _TabDraggable({
    required this.tabId,
    required this.onClose,
    required this.height,
    this.sourceSearchQuery,
    this.suggestedContainerId,
    this.groupToggle,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
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
          ? SuggestedSingleListTabPreview(
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
          : SingleListTabPreview(
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
        child: Transform.scale(
          scale: 0.9,
          child: SizedBox(
            height: height,
            width: MediaQuery.of(context).size.width,
            child: tab,
          ),
        ),
      ),
      DeleteDropData() => Opacity(
        opacity: 0.3,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(colorScheme.error, BlendMode.modulate),
          child: tab,
        ),
      ),
      null => tab,
    };
  }
}

class _TabListView extends HookConsumerWidget {
  final ScrollController scrollController;
  final bool tabsReorderable;
  final VoidCallback onClose;

  const _TabListView({
    required this.scrollController,
    required this.tabsReorderable,
    required this.onClose,
  });

  static const _itemHeight = 86.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(effectiveTabsTrayScopeProvider);

    return switch (scope) {
      TabsTrayScope.synced => _buildSyncedTabsView(context, ref),
      _ => _buildLocalTabsView(context, ref),
    };
  }

  Widget _buildSyncedTabsView(BuildContext context, WidgetRef ref) {
    final syncedTabs = ref.watch(syncedTabsForSelectedDeviceProvider);

    return syncedTabs.when(
      skipLoadingOnReload: true,
      data: (tabs) {
        if (tabs.isEmpty) {
          return const Center(child: Text('No synced tabs available'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ListView.builder(
            controller: scrollController,
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              final tab = tabs[index].tab;
              final uri = Uri.tryParse(tab.url);

              if (uri == null) {
                return const SizedBox.shrink();
              }

              return SyncedListTabPreview(
                title: tab.title.isNotEmpty ? tab.title : tab.url,
                url: uri,
                deviceName: tabs[index].deviceName,
                onTap: () async {
                  await OpenSharedContentRoute(
                    sharedUrl: uri.toString(),
                  ).push(context);
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load synced tabs: $error')),
    );
  }

  Widget _buildLocalTabsView(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final containerId = ref.watch(selectedContainerProvider);
    final canManualReorder = ref.watch(canManualTabReorderProvider);
    final reorderEnabled = tabsReorderable && canManualReorder;
    final filterOptions = ref.watch(tabViewFilterControllerProvider);
    final pinnedTabIds = ref.watch(
      watchPinnedTabIdsProvider.select(
        (value) => value.value ?? const <String>{},
      ),
    );
    final showHierarchicalTabs = filterOptions.showHierarchicalTabs;
    final tabListDirection = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListDirection),
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

    final didInitialScroll = useRef(false);

    useEffect(() {
      if (didInitialScroll.value) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients && activeTab != null) {
          final index = primaryRows.indexWhere((row) => row.tabId == activeTab);

          if (index > -1) {
            final viewportStart = scrollController.offset;
            final viewportEnd =
                viewportStart + scrollController.position.viewportDimension;
            final tabStart = index * _itemHeight;
            final tabEnd = tabStart + _itemHeight;

            final isVisible =
                tabStart >= viewportStart && tabEnd <= viewportEnd;

            if (!isVisible) {
              final targetOffset = (tabStart - _itemHeight).clamp(
                0.0,
                scrollController.position.maxScrollExtent,
              );

              if (disableAnimations) {
                scrollController.jumpTo(targetOffset);
              } else {
                unawaited(
                  scrollController.animateTo(
                    targetOffset,
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
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: scrollController,
                  itemCount: displayItemCount,
                  itemExtent: _itemHeight,
                  itemBuilder: (context, index) {
                    if (index < primaryRows.length) {
                      final row = primaryRows[index];
                      final tab = CustomDraggable(
                        key: Key(row.tabId),
                        data: TabDragData(row.tabId),
                        child: _TabDraggable(
                          tabId: row.tabId,
                          onClose: onClose,
                          sourceSearchQuery: row.sourceSearchQuery,
                          height: _itemHeight,
                          groupToggle: _listGroupToggleFor(row),
                          depth: _depthFor(row),
                        ),
                      );

                      return TabDropTarget(
                        targetTabId: row.tabId,
                        child: TabContextMenuDraggable(
                          tabId: row.tabId,
                          data: tab.data! as TabDragData,
                          feedbackSize: Size(
                            MediaQuery.of(context).size.width,
                            _itemHeight,
                          ),
                          child: tab.child,
                        ),
                      );
                    }

                    final suggestedIndex = index - primaryRows.length;
                    final entity = suggestedTabEntities.value[suggestedIndex];
                    final tab = CustomDraggable(
                      key: Key('suggested_${entity.tabId}'),
                      child: _TabDraggable(
                        tabId: entity.tabId,
                        onClose: onClose,
                        suggestedContainerId: containerId,
                        height: _itemHeight,
                      ),
                    );
                    return TabDropTarget(
                      targetTabId: entity.tabId,
                      enabled: false,
                      child: tab.child,
                    );
                  },
                )
              : ReorderableListView.builder(
                  scrollController: controller,
                  itemCount: displayItemCount,
                  itemExtent: _itemHeight,
                  onReorderStart: (index) {
                    ref.read(willAcceptDropProvider.notifier).clear();
                  },
                  onReorder: (oldIndex, newIndex) async {
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
                  itemBuilder: (context, index) {
                    if (index < primaryRows.length) {
                      final row = primaryRows[index];
                      return CustomDraggable(
                        key: Key(row.tabId),
                        data: TabDragData(row.tabId),
                        child: TabContextMenuDraggable(
                          tabId: row.tabId,
                          feedbackSize: Size.zero,
                          externalDrag: true,
                          child: _TabDraggable(
                            tabId: row.tabId,
                            onClose: onClose,
                            sourceSearchQuery: row.sourceSearchQuery,
                            height: _itemHeight,
                            groupToggle: _listGroupToggleFor(row),
                            depth: _depthFor(row),
                          ),
                        ),
                      );
                    } else {
                      final suggestedIndex = index - primaryRows.length;
                      final entity = suggestedTabEntities.value[suggestedIndex];

                      return CustomDraggable(
                        key: Key('suggested_${entity.tabId}'),
                        child: _TabDraggable(
                          tabId: entity.tabId,
                          onClose: onClose,
                          suggestedContainerId: containerId,
                          height: _itemHeight,
                        ),
                      );
                    }
                  },
                );
        },
      ),
    );
  }
}

class ViewTabListWidget extends HookConsumerWidget {
  final ScrollController scrollController;
  final DraggableScrollableController? draggableScrollableController;
  final bool showNewTabFab;
  final bool tabsReorderable;
  final VoidCallback onClose;

  static const _hideThreshold = 0.02; // 2% of sheet size change
  static const _showThreshold = 0.02;

  const ViewTabListWidget({
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
    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );

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
                            tabsViewMode: TabsViewMode.list,
                          ),
                        ),
                  ) ??
                  TabViewHeader(
                    onClose: onClose,
                    tabsViewMode: TabsViewMode.list,
                  ),
            ),
          ],
          body: _TabListView(
            scrollController: scrollController,
            tabsReorderable: tabsReorderable,
            onClose: onClose,
          ),
        ),
        if (showNewTabFab && !isSyncedScope)
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
