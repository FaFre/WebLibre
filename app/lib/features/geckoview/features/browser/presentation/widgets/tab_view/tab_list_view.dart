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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/scroll_visibility.dart';

class _TabDraggable extends HookConsumerWidget {
  final TabEntity entity;
  final String? suggestedContainerId;
  final VoidCallback onClose;
  final double height;

  const _TabDraggable({
    required this.entity,
    required this.onClose,
    required this.height,
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
          ? SuggestedSingleListTabPreview(
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
          : SingleListTabPreview(
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
          colorFilter: const ColorFilter.mode(Colors.red, BlendMode.modulate),
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

  static const _itemHeight = 80.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenWidth = MediaQuery.of(context).size.width;

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

    final lastScroll = useRef<String?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          if (lastScroll.value != activeTab) {
            final index = filteredTabEntities.value.indexWhere(
              (entity) => entity.tabId == activeTab,
            );

            if (index > -1) {
              final offset = index * _itemHeight;

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
              ? ListView.builder(
                  controller: scrollController,
                  itemCount: itemCount,
                  itemExtent: _itemHeight,
                  itemBuilder: (context, index) {
                    final CustomDraggable tab;

                    if (index < filteredTabEntities.value.length) {
                      final entity = filteredTabEntities.value[index];
                      tab = CustomDraggable(
                        key: Key(entity.tabId),
                        data: TabDragData(entity.tabId),
                        child: _TabDraggable(
                          entity: entity,
                          onClose: onClose,
                          height: _itemHeight,
                        ),
                      );
                    } else {
                      final suggestedIndex =
                          index - filteredTabEntities.value.length;
                      final entity = suggestedTabEntities.value[suggestedIndex];

                      tab = CustomDraggable(
                        key: Key('suggested_${entity.tabId}'),
                        child: _TabDraggable(
                          entity: entity,
                          onClose: onClose,
                          suggestedContainerId: containerId,
                          height: _itemHeight,
                        ),
                      );
                    }

                    return LongPressDraggable(
                      feedback: Material(
                        color: Colors
                            .transparent, // removes white corners when having shadow
                        child: Transform.scale(
                          scale: 1.05,
                          child: SizedBox(
                            height: _itemHeight,
                            width: MediaQuery.of(context).size.width,
                            child: tab.child,
                          ),
                        ),
                      ),
                      data: tab.data,
                      childWhenDragging: const SizedBox(height: _itemHeight),
                      child: tab.child,
                    );
                  },
                )
              : ReorderableListView.builder(
                  scrollController: controller,
                  itemCount: itemCount,
                  itemExtent: _itemHeight,
                  onReorderStart: (index) {
                    ref.read(willAcceptDropProvider.notifier).clear();
                  },
                  onReorder: (oldIndex, newIndex) async {
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
                        .getTabContainerId(tabId);

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
                  itemBuilder: (context, index) {
                    final CustomDraggable tab;

                    if (index < filteredTabEntities.value.length) {
                      final entity = filteredTabEntities.value[index];
                      tab = CustomDraggable(
                        key: Key(entity.tabId),
                        data: TabDragData(entity.tabId),
                        child: _TabDraggable(
                          entity: entity,
                          onClose: onClose,
                          height: _itemHeight,
                        ),
                      );
                    } else {
                      final suggestedIndex =
                          index - filteredTabEntities.value.length;
                      final entity = suggestedTabEntities.value[suggestedIndex];

                      tab = CustomDraggable(
                        key: Key('suggested_${entity.tabId}'),
                        child: _TabDraggable(
                          entity: entity,
                          onClose: onClose,
                          suggestedContainerId: containerId,
                          height: _itemHeight,
                        ),
                      );
                    }

                    // return LongPressDraggable(
                    //   key: tab.key,
                    //   feedback: Material(
                    //     color: Colors
                    //         .transparent, // removes white corners when having shadow
                    //     child: Transform.scale(
                    //       scale: 1.05,
                    //       child: SizedBox(
                    //         height: _itemHeight,
                    //         width: MediaQuery.of(context).size.width,
                    //         child: tab.child,
                    //       ),
                    //     ),
                    //   ),
                    //   data: tab.data,
                    //   child: tab.child,
                    // );
                    return tab;
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
    // Track FAB visibility based on scroll direction
    final isFabVisible = useScrollVisibility(scrollController);

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
        if (showNewTabFab)
          AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: isFabVisible.value ? Offset.zero : const Offset(0, 2),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isFabVisible.value ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: TabViewHeader.headerSize + 4,
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
            ),
          ),
      ],
    );
  }
}
