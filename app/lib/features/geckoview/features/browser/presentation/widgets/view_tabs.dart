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
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:fading_scroll/fading_scroll.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

int calculateCrossAxisItemCount({
  required double screenWidth,
  required double horizontalPadding,
  required double crossAxisSpacing,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final availableWidth =
      screenWidth - totalHorizontalPadding - crossAxisSpacing;

  final crossAxisCount = availableWidth ~/ 180.0;

  return crossAxisCount;
}

Size calculateItemSize({
  required double screenWidth,
  required double childAspectRatio,
  required double horizontalPadding,
  required double mainAxisSpacing,
  required double crossAxisSpacing,
  required int crossAxisCount,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final totalCrossAxisSpacing = crossAxisSpacing * (crossAxisCount - 1);
  final availableWidth =
      screenWidth - totalHorizontalPadding - totalCrossAxisSpacing;
  final itemWidth = availableWidth / crossAxisCount;
  final itemHeight = itemWidth / childAspectRatio;

  return Size(itemWidth, itemHeight + mainAxisSpacing);
}

class _TabDraggable extends HookConsumerWidget {
  final TabEntity entity;
  final String? suggestedContainerId;
  final VoidCallback onClose;

  const _TabDraggable({
    required this.entity,
    required this.onClose,
    this.suggestedContainerId,
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

        return (dragTabId == entity.tabId) ? value : null;
      }),
    );

    // Cache the tab widget to avoid rebuilding
    final tab = useMemoized(() {
      return (suggestedContainerId != null)
          ? SuggestedSingleTabPreview(
              key: ValueKey(entity.tabId),
              tabId: entity.tabId,
              activeTabId: activeTab,
              onTap: () async {
                final containerData = await ref
                    .read(containerRepositoryProvider.notifier)
                    .getContainerData(suggestedContainerId!);

                if (containerData != null) {
                  await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .assignContainer(entity.tabId, containerData);
                }
              },
            )
          : SingleTabPreview(
              key: ValueKey(entity.tabId),
              tabId: entity.tabId,
              activeTabId: activeTab,
              onClose: onClose,
              sourceSearchQuery: switch (entity) {
                DefaultTabEntity _ => null,
                final SearchResultTabEntity entity => entity.searchQuery,
                TabTreeEntity _ => throw UnimplementedError(),
              },
            );
    }, [entity.tabId, activeTab, suggestedContainerId]);

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

class _TabViewHeader extends HookConsumerWidget {
  static const headerSize = 124.0;

  final TabsViewMode tabsViewMode;
  final VoidCallback onClose;

  const _TabViewHeader({required this.onClose, required this.tabsViewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode = useState(false);
    final searchTextFocus = useFocusNode();
    final searchTextController = useTextEditingController();

    final viewModeMenuController = useMenuController();
    final tabsActionMenuController = useMenuController();

    final hasSearchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final enableAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    );

    useListenableCallback(searchTextController, () async {
      if (ref.exists(tabSearchRepositoryProvider(TabSearchPartition.preview))) {
        await ref
            .read(
              tabSearchRepositoryProvider(TabSearchPartition.preview).notifier,
            )
            .addQuery(searchTextController.text);
      }
    });

    return Material(
      //Fix layout issue https://github.com/flutter/flutter/issues/78748#issuecomment-1194680555
      child: Align(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!searchMode.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(MdiIcons.tabSearch),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref
                                .read(tabsViewModeControllerProvider.notifier)
                                .set(TabsViewMode.grid);

                            searchMode.value = true;
                            searchTextFocus.requestFocus();
                          },
                        ),
                        const SizedBox(
                          height: 32,
                          child: VerticalDivider(indent: 4, endIndent: 4),
                        ),
                        MenuAnchor(
                          controller: viewModeMenuController,
                          menuChildren: TabsViewMode.values
                              .map(
                                (mode) => MenuItemButton(
                                  leadingIcon: Icon(mode.icon),
                                  child: Text(mode.label),
                                  onPressed: () {
                                    ref
                                        .read(
                                          tabsViewModeControllerProvider
                                              .notifier,
                                        )
                                        .set(mode);
                                  },
                                ),
                              )
                              .toList(),
                          child: IconButton(
                            onPressed: () {
                              if (viewModeMenuController.isOpen) {
                                viewModeMenuController.close();
                              } else {
                                viewModeMenuController.open();
                              }
                            },
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tabsViewMode.icon, size: 18),
                                const Icon(Icons.arrow_drop_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                        if (enableAiFeatures)
                          Consumer(
                            builder: (context, ref, child) {
                              final tabSuggestionsEnabled = ref.watch(
                                tabSuggestionsControllerProvider,
                              );

                              return IconButton.filledTonal(
                                icon: const Icon(MdiIcons.imageAutoAdjust),
                                isSelected: tabSuggestionsEnabled,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  ref
                                      .read(
                                        tabSuggestionsControllerProvider
                                            .notifier,
                                      )
                                      .toggle();
                                },
                              );
                            },
                          ),
                        Consumer(
                          builder: (context, ref, child) {
                            final tabsReorderabe = ref.watch(
                              tabsReorderableControllerProvider,
                            );

                            return IconButton.filledTonal(
                              icon: const Icon(MdiIcons.orderNumericAscending),
                              isSelected: tabsReorderabe,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                ref
                                    .read(
                                      tabsReorderableControllerProvider
                                          .notifier,
                                    )
                                    .toggle();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    MenuAnchor(
                      controller: tabsActionMenuController,
                      menuChildren: [
                        MenuItemButton(
                          leadingIcon: const Icon(MdiIcons.bookmarkPlusOutline),
                          child: const Text('Bookmark all'),
                          onPressed: () async {
                            final containerId = ref.read(
                              selectedContainerProvider,
                            );

                            final tabData = await ref
                                .read(tabDataRepositoryProvider.notifier)
                                .getContainerTabsData(containerId);

                            for (final tab in tabData) {
                              if (context.mounted) {
                                await BookmarkEntryAddRoute(
                                  bookmarkInfo: jsonEncode(
                                    BookmarkInfo(
                                      title: tab.title,
                                      url: tab.url.toString(),
                                    ).encode(),
                                  ),
                                ).push(context);
                              }
                            }
                          },
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(MdiIcons.closeBoxMultiple),
                          child: const Text('Close All'),
                          onPressed: () async {
                            final result = await showDialog<bool?>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  icon: const Icon(Icons.warning),
                                  title: const Text('Close All Tabs'),
                                  content: const Text(
                                    'Are you sure you want to close all displayed tabs?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result == true) {
                              final container = ref.read(
                                selectedContainerProvider,
                              );

                              final count = await ref
                                  .read(tabDataRepositoryProvider.notifier)
                                  .closeAllTabsByContainer(container);

                              if (context.mounted) {
                                ui_helper.showTabUndoClose(
                                  context,
                                  ref
                                      .read(tabRepositoryProvider.notifier)
                                      .undoClose,
                                  count: count,
                                );
                              }
                            }
                          },
                        ),
                      ],
                      child: IconButton(
                        onPressed: () {
                          if (tabsActionMenuController.isOpen) {
                            tabsActionMenuController.close();
                          } else {
                            tabsActionMenuController.open();
                          }
                        },
                        icon: const Icon(MdiIcons.dotsVertical),
                      ),
                    ),
                  ],
                )
              else
                TextField(
                  controller: searchTextController,
                  focusNode: searchTextFocus,
                  // enableIMEPersonalizedLearning: !incognitoEnabled,
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    prefixIcon: const Icon(MdiIcons.tabSearch, size: 18),
                    hintText: 'Search inside tabs...',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasSearchText)
                          SpeechToTextButton(
                            onTextReceived: (data) {
                              searchTextController.text = data.toString();
                            },
                          ),
                        IconButton(
                          onPressed: () {
                            searchTextController.clear();
                            searchTextFocus.requestFocus();
                            searchMode.value = false;
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                ),
              if (tabsViewMode == TabsViewMode.grid)
                Consumer(
                  builder: (context, ref, child) {
                    final selectedContainer = ref.watch(
                      selectedContainerDataProvider.select(
                        (value) => value.value,
                      ),
                    );

                    return ContainerChips(
                      showGroupSuggestions: true,
                      selectedContainer: selectedContainer,
                      onSelected: (container) async {
                        if (container != null) {
                          final result = await ref
                              .read(selectedContainerProvider.notifier)
                              .setContainerId(container.id);

                          if (context.mounted &&
                              result == SetContainerResult.successHasProxy) {
                            await ref
                                .read(startProxyControllerProvider.notifier)
                                .maybeStartProxy(context);
                          }
                        } else {
                          ref
                              .read(selectedContainerProvider.notifier)
                              .clearContainer();
                        }
                      },
                      onDeleted: (container) {
                        ref
                            .read(selectedContainerProvider.notifier)
                            .clearContainer();
                      },
                      onLongPress: (container) async {
                        await ContainerEditRoute(
                          containerData: jsonEncode(container.toJson()),
                        ).push(context);
                      },
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabView extends HookConsumerWidget {
  final ScrollController scrollController;
  final bool tabsReorderable;
  final VoidCallback onClose;

  const _TabView({
    required this.scrollController,
    required this.tabsReorderable,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    final containerId = ref.watch(selectedContainerProvider);

    final filteredTabEntities = ref.watch(
      seamlessFilteredTabEntitiesProvider(
        searchPartition: TabSearchPartition.preview,
        // ignore: document_ignores using fast equatable
        // ignore: provider_parameters
        containerFilter: ContainerFilterById(containerId: containerId),
        groupTrees: false,
      ),
    );

    final tabSuggestionsEnabled = ref.watch(tabSuggestionsControllerProvider);

    final suggestedTabEntities = tabSuggestionsEnabled
        ? ref.watch(suggestedTabEntitiesProvider(containerId))
        : EquatableValue(<TabEntity>[]);

    final itemCount =
        filteredTabEntities.value.length +
        //Limit to 3 sugegstions for now
        math.min<int>(suggestedTabEntities.value.length, 3);

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

    final lastScroll = useRef<String?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          if (lastScroll.value != activeTab) {
            final index = filteredTabEntities.value.indexWhere(
              (entity) => entity.tabId == activeTab,
            );

            if (index > -1) {
              final offset = (index ~/ 2) * itemSize.height;

              if (offset != scrollController.offset) {
                lastScroll.value = activeTab;

                unawaited(
                  scrollController.animateTo(
                    offset,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  ),
                );
              }
            }
          }
        }
      });

      return null;
    }, [filteredTabEntities, activeTab]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FadingScroll(
        fadingSize: 5,
        controller: scrollController,
        builder: (context, controller) {
          return !tabsReorderable
              ? _TabGrid(
                  key: ValueKey(crossAxisCount),
                  crossAxisCount: crossAxisCount,
                  itemCount: itemCount,
                  scrollController: controller,
                  itemBuilder: (widget, _) {
                    if (widget is CustomDraggable) {
                      return LongPressDraggable(
                        feedback: Material(
                          color: Colors
                              .transparent, // removes white corners when having shadow
                          child: Transform.scale(
                            scale: 1.05,
                            child: SizedBox(
                              height: itemSize.height,
                              width: itemSize.width,
                              child: widget.child,
                            ),
                          ),
                        ),
                        data: widget.data,
                        child: widget.child,
                      );
                    }

                    return widget;
                  },
                  suggestedContainerId: containerId,
                  filteredTabEntities: filteredTabEntities,
                  suggestedTabEntities: suggestedTabEntities,
                  onClose: onClose,
                )
              : ReorderableBuilder.builder(
                  //Rebuild when cross axis count changes
                  key: ValueKey(crossAxisCount),
                  scrollController: controller,
                  itemCount: itemCount,
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

                    final containerRepository = ref.read(
                      containerRepositoryProvider.notifier,
                    );

                    //Suggestions are at the end and not reorderable, so skip
                    if (oldIndex >= filteredTabEntities.value.length) {
                      return;
                    }

                    final tabId = filteredTabEntities.value[oldIndex].tabId;
                    final containerId = await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .getContainerTabId(tabId);

                    final String key;
                    if (newIndex <= 0) {
                      key = await containerRepository.getLeadingOrderKey(
                        containerId,
                      );
                    } else if (newIndex >=
                        filteredTabEntities.value.length - 1) {
                      key = await containerRepository.getTrailingOrderKey(
                        containerId,
                      );
                    } else {
                      if (newIndex < oldIndex) {
                        key = (await containerRepository.getOrderKeyAfterTab(
                          filteredTabEntities.value[newIndex - 1].tabId,
                          containerId,
                        ))!;
                      } else {
                        key = await containerRepository.getOrderKeyBeforeTab(
                          filteredTabEntities.value[newIndex + 1].tabId,
                          containerId,
                        );
                      }
                    }

                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .assignOrderKey(tabId, key);
                  },
                  childBuilder: (itemBuilder) {
                    return _TabGrid(
                      crossAxisCount: crossAxisCount,
                      itemCount: itemCount,
                      scrollController: controller,
                      itemBuilder: itemBuilder,
                      suggestedContainerId: containerId,
                      filteredTabEntities: filteredTabEntities,
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
    required this.filteredTabEntities,
    required this.suggestedTabEntities,
    required this.onClose,
  });

  final int crossAxisCount;
  final int itemCount;
  final ScrollController? scrollController;
  final String? suggestedContainerId;
  final EquatableValue<List<TabEntity>> filteredTabEntities;
  final EquatableValue<List<TabEntity>> suggestedTabEntities;
  final Widget Function(Widget, int)? itemBuilder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //Sync values for itemHeight calculation _calculateItemHeight
        childAspectRatio: 0.75,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        crossAxisCount: crossAxisCount,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final Widget tab;
        if (index < filteredTabEntities.value.length) {
          final entity = filteredTabEntities.value[index];
          tab = CustomDraggable(
            key: Key(entity.tabId),
            data: TabDragData(entity.tabId),
            child: _TabDraggable(entity: entity, onClose: onClose),
          );
        } else {
          final suggestedIndex = index - filteredTabEntities.value.length;
          final entity = suggestedTabEntities.value[suggestedIndex];

          tab = CustomDraggable(
            key: Key('suggested_${entity.tabId}'),
            child: _TabDraggable(
              entity: entity,
              onClose: onClose,
              suggestedContainerId: suggestedContainerId,
            ),
          );
        }

        return (itemBuilder != null) ? itemBuilder!(tab, index) : tab;
      },
    );
  }
}

class ViewTabsWidget extends HookConsumerWidget {
  final ScrollController scrollController;
  final DraggableScrollableController? draggableScrollableController;
  final bool showNewTabFab;
  final bool tabsReorderable;
  final VoidCallback onClose;

  const ViewTabsWidget({
    required this.onClose,
    required this.scrollController,
    this.draggableScrollableController,
    required this.tabsReorderable,
    required this.showNewTabFab,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          child: _TabViewHeader(
                            onClose: onClose,
                            tabsViewMode: TabsViewMode.grid,
                          ),
                        ),
                  ) ??
                  _TabViewHeader(
                    onClose: onClose,
                    tabsViewMode: TabsViewMode.grid,
                  ),
            ),
          ],
          body: _TabView(
            scrollController: scrollController,
            tabsReorderable: tabsReorderable,
            onClose: onClose,
          ),
        ),
        if (showNewTabFab)
          Padding(
            padding: const EdgeInsets.only(
              top: _TabViewHeader.headerSize + 4,
              right: 4,
            ),
            child: FloatingActionButton.small(
              onPressed: () async {
                final settings = ref.read(generalSettingsWithDefaultsProvider);

                await SearchRoute(
                  tabType:
                      ref.read(selectedTabTypeProvider) ??
                      settings.defaultCreateTabType,
                ).push(context);

                onClose();
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}

class ViewTabTreesWidget extends HookConsumerWidget {
  final ScrollController scrollController;
  final VoidCallback onClose;
  final bool showNewTabFab;

  const ViewTabTreesWidget({
    required this.onClose,
    required this.scrollController,
    required this.showNewTabFab,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          children: [
            _TabViewHeader(onClose: onClose, tabsViewMode: TabsViewMode.tree),
            Expanded(
              child: HookConsumer(
                builder: (context, ref, child) {
                  final screenWidth = MediaQuery.of(context).size.width;

                  final filteredTabEntities = ref.watch(
                    seamlessFilteredTabEntitiesProvider(
                      searchPartition: TabSearchPartition.preview,
                      // ignore: document_ignores using fast equatable
                      // ignore: provider_parameters
                      containerFilter: ContainerFilterDisabled(),
                      groupTrees: true,
                    ),
                  );

                  final activeTab = ref.watch(selectedTabProvider);

                  final crossAxisCount = useMemoized(() {
                    final calculatedCount = calculateCrossAxisItemCount(
                      screenWidth: screenWidth,
                      horizontalPadding: 4.0,
                      crossAxisSpacing: 8.0,
                    );

                    return math.max(
                      math.min(
                        calculatedCount,
                        filteredTabEntities.value.length,
                      ),
                      2,
                    );
                  }, [screenWidth, filteredTabEntities.value.length]);

                  final itemSize = useMemoized(
                    () => calculateItemSize(
                      screenWidth: screenWidth,
                      childAspectRatio: 0.75,
                      horizontalPadding: 4.0,
                      crossAxisSpacing: 8.0,
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 8.0,
                    ),
                    [screenWidth, crossAxisCount],
                  );

                  useEffect(() {
                    final index = filteredTabEntities.value.indexWhere(
                      (entity) => entity.tabId == activeTab,
                    );

                    if (index > -1) {
                      final offset = (index ~/ 2) * itemSize.height;

                      if (offset != scrollController.offset) {
                        unawaited(
                          scrollController.animateTo(
                            offset,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          ),
                        );
                      }
                    }

                    return null;
                  }, [filteredTabEntities, activeTab]);

                  final tabs = useMemoized(() {
                    return filteredTabEntities.value
                        .whereType<TabTreeEntity>()
                        .map((entity) {
                          return TabTreePreview(
                            entity: entity,
                            activeTabId: activeTab,
                            onClose: onClose,
                            stackPadding: const Offset(8, 8),
                          );
                        })
                        .toList();
                  }, [filteredTabEntities, activeTab]);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //Sync values for itemHeight calculation _calculateItemHeight
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        crossAxisCount: crossAxisCount,
                      ),
                      itemCount: tabs.length,
                      itemBuilder: (context, index) => tabs[index],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        if (showNewTabFab)
          Padding(
            padding: const EdgeInsets.only(
              top: _TabViewHeader.headerSize + 4,
              right: 4,
            ),
            child: FloatingActionButton.small(
              onPressed: () async {
                final settings = ref.read(generalSettingsWithDefaultsProvider);

                await SearchRoute(
                  tabType:
                      ref.read(selectedTabTypeProvider) ??
                      settings.defaultCreateTabType,
                ).push(context);

                onClose();
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
