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
import 'dart:math' as math;

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
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_view_reorder.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_context_menu_draggable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_drop_target.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_group_expand_toggle.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_new_tab_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/reorderable_hold_drag.dart';

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

    final l10n = AppLocalizations.of(context);

    // In a scroll view of its own, which tells the header that no tabs are
    // scrolled under it anymore ([TabViewScrolledUnderListener]).
    Widget placeholder(Widget child) => CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverFillRemaining(hasScrollBody: false, child: Center(child: child)),
      ],
    );

    return syncedTabs.when(
      skipLoadingOnReload: true,
      data: (tabs) {
        if (tabs.isEmpty) {
          return placeholder(Text(l10n.browser_noSyncedTabsAvailable));
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
      loading: () => placeholder(const CircularProgressIndicator()),
      error: (error, _) => placeholder(
        Text(l10n.browser_failedToLoadSyncedTabs(error.toString())),
      ),
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
    final treeRows = ref.watch(
      watchTabsWithRootAndDepthProvider(
        containerId,
      ).select((value) => value.value ?? const []),
    );

    final hasActiveSearch = ref.watch(
      tabSearchRepositoryProvider(
        TabSearchPartition.preview,
      ).select((value) => (value.value?.query ?? '').isNotEmpty),
    );

    List<TabViewItem> primaryRows;
    if (hasActiveSearch) {
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
      final visibleItems = ref.watch(
        visibleTabListItemsProvider(
          containerId: containerId,
          scope: TabListScope.tray,
        ),
      );
      primaryRows = [
        for (final item in visibleItems.value)
          switch (item) {
            TabListStandaloneItem(:final tabId) => TabViewItem.standalone(
              tabId: tabId,
            ),
            final TabListParentGroup g =>
              showHierarchicalTabs
                  ? TabViewItem.parent(tabId: g.tabId, parentGroup: g)
                  : TabViewItem.standalone(tabId: g.tabId),
            final TabListChildItem c =>
              showHierarchicalTabs
                  ? TabViewItem.child(tabId: c.tabId, childItem: c)
                  : TabViewItem.standalone(tabId: c.tabId),
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

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients && activeTab != null) {
          final index = primaryRows.indexWhere((row) => row.tabId == activeTab);

          if (index > -1) {
            final viewportDimension =
                scrollController.position.viewportDimension;
            final tabStart = index * _itemHeight;

            final targetOffset =
                (tabStart - viewportDimension / 2 + _itemHeight / 2).clamp(
                  0.0,
                  scrollController.position.maxScrollExtent,
                );

            if (disableAnimations) {
              scrollController.jumpTo(targetOffset);
            } else {
              scrollController.animateTo(
                targetOffset,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          }
        }
      });

      return null;
    }, [activeTab, primaryRows.length]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: !reorderEnabled
          ? ListView.builder(
              padding: const EdgeInsets.only(bottom: 56),
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
              scrollController: scrollController,
              padding: const EdgeInsets.only(bottom: 56),
              itemCount: displayItemCount,
              itemExtent: _itemHeight,
              // Drag handles are supplied per item so the drag arms later than
              // the long-press context menu, and so the non-reorderable
              // suggestion rows don't get one at all.
              buildDefaultDragHandles: false,
              onReorderStart: (index) {
                ref.read(willAcceptDropProvider.notifier).clear();
              },
              onReorderItem: (oldIndex, newIndex) async {
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
                      parentChange: result.parentChange,
                    );
              },
              itemBuilder: (context, index) {
                if (index < primaryRows.length) {
                  final row = primaryRows[index];
                  return CustomDraggable(
                    key: Key(row.tabId),
                    data: TabDragData(row.tabId),
                    child: ReorderableHoldDragListener(
                      index: index,
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
    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );
    final scrolledUnder = useValueNotifier(false);

    return Column(
      children: [
        Expanded(
          child: Stack(
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
                                  scrolledUnder: scrolledUnder,
                                ),
                              ),
                        ) ??
                        TabViewHeader(
                          onClose: onClose,
                          tabsViewMode: TabsViewMode.list,
                          scrolledUnder: scrolledUnder,
                        ),
                  ),
                ],
                // The header and the action bar keep clear of the system
                // bars, the list runs between them.
                body: TabViewScrolledUnderListener(
                  scrolledUnder: scrolledUnder,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: _TabListView(
                      scrollController: scrollController,
                      tabsReorderable: tabsReorderable,
                      onClose: onClose,
                    ),
                  ),
                ),
              ),
              if (showNewTabFab && !isSyncedScope)
                TabTrayNewTabFab(
                  scrollController: scrollController,
                  sheetController: draggableScrollableController,
                  onClose: onClose,
                ),
            ],
          ),
        ),
        const TabViewActionBar(tabsViewMode: TabsViewMode.list),
      ],
    );
  }
}
