import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/providers.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/data/models/drag_data.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:lensai/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:lensai/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/speech_to_text_button.dart';

class _TabDraggable extends HookConsumerWidget {
  final String tabId;
  final String? activeTabId;

  final void Function() onClose;

  _TabDraggable({
    required this.tabId,
    required this.activeTabId,
    required this.onClose,
  }) : super(key: ValueKey(tabId));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabStateProvider(tabId));

    if (tab == null) {
      return const SizedBox.shrink();
    }

    return TabPreview(
      tab: tab,
      isActive: tabId == activeTabId,
      onTap: () async {
        if (tabId != activeTabId) {
          //Close first to avoid rebuilds
          onClose();
          await ref.read(tabRepositoryProvider.notifier).selectTab(tab.id);
        } else {
          onClose();
        }
      },
      // onDoubleTap: () {
      //   ref.read(overlayDialogControllerProvider.notifier).show(
      //         TabActionDialog(
      //           initialTab: tab,
      //           onDismiss:
      //               ref.read(overlayDialogControllerProvider.notifier).dismiss,
      //         ),
      //       );
      // },
      onDelete: () async {
        await ref.read(tabRepositoryProvider.notifier).closeTab(tab.id);
      },
    );
  }
}

class _Tab extends HookConsumerWidget {
  static const headerSize = 124.0;

  final VoidCallback onClose;

  const _Tab({required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode = useState(false);
    final searchTextFocus = useFocusNode();
    final searchTextController = useTextEditingController();

    final hasSearchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
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
                    TextButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      onPressed: () {
                        searchMode.value = true;
                        searchTextFocus.requestFocus();
                      },
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final container = ref.read(selectedContainerProvider);
                        await ref
                            .read(tabDataRepositoryProvider.notifier)
                            .closeAllTabs(container);

                        onClose();
                      },
                      icon: const Icon(Icons.delete),
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
                    prefixIcon: const Icon(Icons.search),
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
                            searchMode.value = false;
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 12),
                child: Consumer(
                  builder: (context, ref, child) {
                    final selectedContainer = ref.watch(
                      selectedContainerDataProvider.select(
                        (value) => value.valueOrNull,
                      ),
                    );

                    return ContainerChips(
                      selectedContainer: selectedContainer,
                      onSelected: (container) async {
                        final result = await ref
                            .read(selectedContainerProvider.notifier)
                            .setContainerId(container.id);

                        if (context.mounted &&
                            result == SetContainerResult.successHasProxy) {
                          await ref
                              .read(startProxyControllerProvider.notifier)
                              .maybeStartProxy(context);
                        }
                      },
                      onDeleted: (container) async {
                        ref
                            .read(selectedContainerProvider.notifier)
                            .clearContainer();
                      },
                    );
                  },
                ),
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
              child: _Tab(onClose: onClose),
            ),
            Expanded(
              child: HookConsumer(
                builder: (context, ref, child) {
                  final container = ref.watch(selectedContainerProvider);

                  final filteredTabIds = ref.watch(
                    seamlessFilteredTabIdsProvider(
                      TabSearchPartition.preview,
                      // ignore: provider_parameters
                      ContainerFilterById(containerId: container),
                    ),
                  );

                  final activeTab = ref.watch(selectedTabProvider);

                  final itemHeight = useMemoized(
                    () => _calculateItemHeight(
                      screenWidth: MediaQuery.of(context).size.width,
                      childAspectRatio: 0.75,
                      horizontalPadding: 4.0,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      crossAxisCount: 2,
                    ),
                    [MediaQuery.of(context).size.width],
                  );

                  useEffect(() {
                    final index = filteredTabIds.collection.indexWhere(
                      (webView) => webView == activeTab,
                    );

                    if (index > -1) {
                      final offset = (index ~/ 2) * itemHeight;

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
                  }, [filteredTabIds, activeTab],);

                  final tabs = useMemoized(() {
                    return filteredTabIds.collection
                        .mapIndexed(
                          (index, tabId) => CustomDraggable(
                            key: Key(tabId),
                            data: TabDragData(tabId),
                            child: Consumer(
                              child: _TabDraggable(
                                tabId: tabId,
                                activeTabId: activeTab,
                                onClose: onClose,
                              ),
                              builder: (context, ref, child) {
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

                                return switch (dragData) {
                                  ContainerDropData() => Opacity(
                                    opacity: 0.3,
                                    child: Transform.scale(
                                      scale: 0.9,
                                      child: child,
                                    ),
                                  ),
                                  DeleteDropData() => Opacity(
                                    opacity: 0.3,
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Colors.red,
                                        BlendMode.modulate,
                                      ),
                                      child: child,
                                    ),
                                  ),
                                  null => child!,
                                };
                              },
                            ),
                          ),
                        )
                        .toList();
                  }, [filteredTabIds, activeTab],);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ReorderableBuilder(
                      scrollController: sheetScrollController,
                      children: tabs,
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

                        final tabId = filteredTabIds.collection[oldIndex];
                        final containerId = await ref
                            .read(tabDataRepositoryProvider.notifier)
                            .containerTabId(tabId);

                        final String key;
                        if (newIndex <= 0) {
                          key = await containerRepository.getLeadingOrderKey(
                            containerId,
                          );
                        } else if (newIndex >=
                            filteredTabIds.collection.length - 1) {
                          key = await containerRepository.getTrailingOrderKey(
                            containerId,
                          );
                        } else {
                          final orderAfterIndex = newIndex;
                          key = await containerRepository.getOrderKeyAfterTab(
                            filteredTabIds.collection[orderAfterIndex],
                            containerId,
                          );
                        }

                        await ref
                            .read(tabDataRepositoryProvider.notifier)
                            .assignOrderKey(tabId, key);
                      },
                      builder: (children) {
                        return GridView.builder(
                          controller: sheetScrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                //Sync values for itemHeight calculation _calculateItemHeight
                                childAspectRatio: 0.75,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                                crossAxisCount: 2,
                              ),
                          itemCount: children.length,
                          itemBuilder: (context, index) => children[index],
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
          padding: const EdgeInsets.only(top: _Tab.headerSize + 4, right: 4),
          child: FloatingActionButton.small(
            onPressed: () async {
              await context.push(const SearchRoute().location);

              onClose();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
