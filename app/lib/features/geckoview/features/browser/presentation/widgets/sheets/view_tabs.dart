import 'dart:async';
import 'dart:math' as math;

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_suggestions.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tree_view.dart';
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
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';

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

    final tab = (suggestedContainerId != null)
        ? SuggestedSingleTabPreview(
            tabId: entity.tabId,
            activeTabId: activeTab,
            containerId: suggestedContainerId!,
          )
        : SingleTabPreview(
            tabId: entity.tabId,
            activeTabId: activeTab,
            onClose: onClose,
            sourceSearchQuery: switch (entity) {
              DefaultTabEntity _ => null,
              final SearchResultTabEntity entity => entity.searchQuery,
              TabTreeEntity _ => throw UnimplementedError(),
            },
          );

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

class _TabSheetHeader extends HookConsumerWidget {
  static const headerSize = 124.0;

  final bool treeViewEnabled;
  final VoidCallback onClose;

  const _TabSheetHeader({required this.onClose, required this.treeViewEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode = useState(false);
    final searchTextFocus = useFocusNode();
    final searchTextController = useTextEditingController();

    final hasSearchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final enableAiFeatures = ref.watch(
      generalSettingsRepositoryProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    );

    useListenableCallback(searchTextController, () async {
      await ref
          .read(
            tabSearchRepositoryProvider(TabSearchPartition.preview).notifier,
          )
          .addQuery(searchTextController.text);
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
                                .read(treeViewControllerProvider.notifier)
                                .hide();

                            searchMode.value = true;
                            searchTextFocus.requestFocus();
                          },
                        ),
                        const SizedBox(
                          height: 32,
                          child: VerticalDivider(indent: 4, endIndent: 4),
                        ),
                        IconButton(
                          icon: const Icon(MdiIcons.familyTree),
                          selectedIcon: const Icon(MdiIcons.table),
                          isSelected: treeViewEnabled,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref
                                .read(treeViewControllerProvider.notifier)
                                .toggle();
                          },
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
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final container = ref.read(selectedContainerProvider);
                        final result = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Close All Tabs'),
                              content: Text(
                                (container != null)
                                    ? 'Are you sure you want to close all container tabs?'
                                    : 'Are you sure you want to close all unassigned tabs?',
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
                          await ref
                              .read(tabDataRepositoryProvider.notifier)
                              .closeAllTabsByContainer(container);
                        }
                      },
                      icon: const Icon(MdiIcons.closeBoxMultiple),
                      label: const Text('Close All'),
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
              if (!treeViewEnabled)
                Consumer(
                  builder: (context, ref, child) {
                    final selectedContainer = ref.watch(
                      selectedContainerDataProvider.select(
                        (value) => value.valueOrNull,
                      ),
                    );

                    return ContainerChips(
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

class ViewTabsSheetWidget extends HookConsumerWidget {
  final ScrollController sheetScrollController;
  final DraggableScrollableController draggableScrollableController;
  final VoidCallback onClose;

  const ViewTabsSheetWidget({
    required this.onClose,
    required this.sheetScrollController,
    required this.draggableScrollableController,
    super.key,
  });

  int _calculateCrossAxisItemCount({
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

  double _calculateItemHeight({
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
    final totalItemHeight = itemHeight + mainAxisSpacing;

    return totalItemHeight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          children: [
            DraggableScrollableHeader(
              controller: draggableScrollableController,
              child: _TabSheetHeader(onClose: onClose, treeViewEnabled: false),
            ),
            Expanded(
              child: HookConsumer(
                builder: (context, ref, child) {
                  final gridViewKey = useMemoized(() => GlobalKey());

                  final containerId = ref.watch(selectedContainerProvider);

                  final filteredTabEntities = ref.watch(
                    seamlessFilteredTabEntitiesProvider(
                      searchPartition: TabSearchPartition.preview,
                      // ignore: document_ignores using fast equatable
                      // ignore: provider_parameters
                      containerFilter: ContainerFilterById(
                        containerId: containerId,
                      ),
                      groupTrees: false,
                    ),
                  );

                  final tabSuggestionsEnabled = ref.watch(
                    tabSuggestionsControllerProvider,
                  );
                  final enableAiFeatures = ref.watch(
                    generalSettingsRepositoryProvider.select(
                      (settings) => settings.enableLocalAiFeatures,
                    ),
                  );
                  final suggestedTabEntities = ref.watch(
                    suggestedTabEntitiesProvider(
                      (enableAiFeatures && tabSuggestionsEnabled)
                          ? containerId
                          : null,
                    ),
                  );

                  final itemCount =
                      filteredTabEntities.value.length +
                      suggestedTabEntities.value.length;

                  final activeTab = ref.watch(selectedTabProvider);

                  final crossAxisCount = useMemoized(() {
                    final calculatedCount = _calculateCrossAxisItemCount(
                      screenWidth: MediaQuery.of(context).size.width,
                      horizontalPadding: 4.0,
                      crossAxisSpacing: 8.0,
                    );

                    return math.max(math.min(calculatedCount, itemCount), 2);
                  }, [MediaQuery.of(context).size.width, itemCount]);

                  final itemHeight = useMemoized(
                    () => _calculateItemHeight(
                      screenWidth: MediaQuery.of(context).size.width,
                      childAspectRatio: 0.75,
                      horizontalPadding: 4.0,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      crossAxisCount: crossAxisCount,
                    ),
                    [MediaQuery.of(context).size.width, crossAxisCount],
                  );

                  final lastScroll = useRef<String?>(null);
                  final scrollControllerIsAttached = useListenableSelector(
                    sheetScrollController,
                    () => sheetScrollController.hasClients,
                  );

                  useEffect(
                    () {
                      if (scrollControllerIsAttached) {
                        if (lastScroll.value != activeTab) {
                          final index = filteredTabEntities.value.indexWhere(
                            (entity) => entity.tabId == activeTab,
                          );

                          if (index > -1) {
                            final offset = (index ~/ 2) * itemHeight;

                            if (offset != sheetScrollController.offset) {
                              lastScroll.value = activeTab;

                              unawaited(
                                sheetScrollController.animateTo(
                                  offset,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                ),
                              );
                            }
                          }
                        }
                      }

                      return null;
                    },
                    [
                      filteredTabEntities,
                      activeTab,
                      scrollControllerIsAttached,
                    ],
                  );

                  final tabs = useMemoized(() {
                    return [
                      ...filteredTabEntities.value.map(
                        (entity) => CustomDraggable(
                          key: Key(entity.tabId),
                          data: TabDragData(entity.tabId),
                          child: _TabDraggable(
                            entity: entity,
                            onClose: onClose,
                          ),
                        ),
                      ),
                      ...suggestedTabEntities.value.map(
                        (entity) => CustomDraggable(
                          key: Key('suggested_${entity.tabId}'),
                          child: _TabDraggable(
                            entity: entity,
                            onClose: onClose,
                            suggestedContainerId: containerId,
                          ),
                        ),
                      ),
                    ];
                  }, [filteredTabEntities, suggestedTabEntities]);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FadingScroll(
                      fadingSize: 5,
                      controller: sheetScrollController,
                      builder: (context, controller) {
                        return ReorderableBuilder.builder(
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

                            final tabId =
                                filteredTabEntities.value[oldIndex].tabId;
                            final containerId = await ref
                                .read(tabDataRepositoryProvider.notifier)
                                .getContainerTabId(tabId);

                            final String key;
                            if (newIndex <= 0) {
                              key = await containerRepository
                                  .getLeadingOrderKey(containerId);
                            } else if (newIndex >=
                                filteredTabEntities.value.length - 1) {
                              key = await containerRepository
                                  .getTrailingOrderKey(containerId);
                            } else {
                              if (newIndex < oldIndex) {
                                key = await containerRepository
                                    .getOrderKeyAfterTab(
                                      filteredTabEntities
                                          .value[newIndex - 1]
                                          .tabId,
                                      containerId,
                                    );
                              } else {
                                key = await containerRepository
                                    .getOrderKeyBeforeTab(
                                      filteredTabEntities
                                          .value[newIndex + 1]
                                          .tabId,
                                      containerId,
                                    );
                              }
                            }

                            await ref
                                .read(tabDataRepositoryProvider.notifier)
                                .assignOrderKey(tabId, key);
                          },
                          childBuilder: (itemBuilder) {
                            return GridView.builder(
                              key: gridViewKey,
                              controller: controller,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    //Sync values for itemHeight calculation _calculateItemHeight
                                    childAspectRatio: 0.75,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                    crossAxisCount: crossAxisCount,
                                  ),
                              itemCount: itemCount,
                              itemBuilder: (context, index) =>
                                  itemBuilder(tabs[index], index),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: _TabSheetHeader.headerSize + 4,
            right: 4,
          ),
          child: FloatingActionButton.small(
            onPressed: () async {
              await SearchRoute(
                tabType: ref.read(selectedTabTypeProvider) ?? TabType.regular,
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

class ViewTabTreesSheetWidget extends HookConsumerWidget {
  final ScrollController sheetScrollController;
  final VoidCallback onClose;

  const ViewTabTreesSheetWidget({
    required this.onClose,
    required this.sheetScrollController,
    super.key,
  });

  int _calculateCrossAxisItemCount({
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

  Size _calculateItemSize({
    required double screenWidth,
    required double childAspectRatio,
    required double horizontalPadding,
    required double crossAxisSpacing,
    required int crossAxisCount,
  }) {
    final totalHorizontalPadding = horizontalPadding * 2;
    final totalCrossAxisSpacing = crossAxisSpacing * (crossAxisCount - 1);
    final availableWidth =
        screenWidth - totalHorizontalPadding - totalCrossAxisSpacing;
    final itemWidth = availableWidth / crossAxisCount;
    final itemHeight = itemWidth / childAspectRatio;

    return Size(itemWidth, itemHeight);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          children: [
            _TabSheetHeader(onClose: onClose, treeViewEnabled: true),
            Expanded(
              child: HookConsumer(
                builder: (context, ref, child) {
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

                  final crossAxisCount = useMemoized(
                    () {
                      final calculatedCount = _calculateCrossAxisItemCount(
                        screenWidth: MediaQuery.of(context).size.width,
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
                    },
                    [
                      MediaQuery.of(context).size.width,
                      filteredTabEntities.value.length,
                    ],
                  );

                  final itemSize = useMemoized(
                    () =>
                        _calculateItemSize(
                          screenWidth: MediaQuery.of(context).size.width,
                          childAspectRatio: 0.75,
                          horizontalPadding: 4.0,
                          crossAxisSpacing: 8.0,
                          crossAxisCount: crossAxisCount,
                        ) +
                        //mainAxisSpacing
                        const Offset(0, 8.0),
                    [MediaQuery.of(context).size.width, crossAxisCount],
                  );

                  useEffect(() {
                    final index = filteredTabEntities.value.indexWhere(
                      (entity) => entity.tabId == activeTab,
                    );

                    if (index > -1) {
                      final offset = (index ~/ 2) * itemSize.height;

                      if (offset != sheetScrollController.offset) {
                        unawaited(
                          sheetScrollController.animateTo(
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
                      controller: sheetScrollController,
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
        Padding(
          padding: const EdgeInsets.only(
            top: _TabSheetHeader.headerSize + 4,
            right: 4,
          ),
          child: FloatingActionButton.small(
            onPressed: () async {
              await SearchRoute(
                tabType: ref.read(selectedTabTypeProvider) ?? TabType.regular,
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
