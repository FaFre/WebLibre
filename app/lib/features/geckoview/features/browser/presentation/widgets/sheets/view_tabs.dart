import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/dialogs/tab_action.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:lensai/presentation/widgets/speech_to_text_button.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:lensai/features/geckoview/domain/controllers/overlay_dialog.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

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

    useListenableCallback(
      searchTextController,
      () async {
        await ref
            .read(tabSearchRepositoryProvider.notifier)
            .addQuery(searchTextController.text);
      },
    );

    return Material(
      //Fix layout issue https://github.com/flutter/flutter/issues/78748#issuecomment-1194680555
      child: Align(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
            left: 8.0,
            top: 8.0,
          ),
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
                      selectedContainerDataProvider
                          .select((value) => value.valueOrNull),
                    );

                    return ContainerChips(
                      selectedContainer: selectedContainer,
                      onSelected: (container) {
                        ref
                            .read(selectedContainerProvider.notifier)
                            .setContainerId(container.id);
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
              child: CustomScrollView(
                controller: sheetScrollController,
                slivers: [
                  HookConsumer(
                    builder: (context, ref, child) {
                      final container = ref.watch(selectedContainerProvider);

                      final filteredTabs = ref
                          .watch(
                            seamlessFilteredTabsProvider(container).select(
                              (value) =>
                                  EquatableCollection(value, immutable: true),
                            ),
                          )
                          .collection;

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

                      useEffect(
                        () {
                          final index = filteredTabs
                              .indexWhere((webView) => webView == activeTab);

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
                        },
                        [filteredTabs, activeTab],
                      );

                      final tabs = useMemoized(
                        () {
                          return filteredTabs
                              .mapIndexed(
                                (index, tabId) =>
                                    ReorderableGridDelayedDragStartListener(
                                  key: ValueKey(tabId),
                                  index: index,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final tab =
                                          ref.watch(tabStateProvider(tabId));
                                      return (tab != null)
                                          ? TabPreview(
                                              tab: tab,
                                              isActive: tabId == activeTab,
                                              onTap: () async {
                                                if (tabId != activeTab) {
                                                  //Close first to avoid rebuilds
                                                  onClose();
                                                  await ref
                                                      .read(
                                                        tabRepositoryProvider
                                                            .notifier,
                                                      )
                                                      .selectTab(tab.id);
                                                } else {
                                                  onClose();
                                                }
                                              },
                                              onDoubleTap: () {
                                                ref
                                                    .read(
                                                      overlayDialogControllerProvider
                                                          .notifier,
                                                    )
                                                    .show(
                                                      TabActionDialog(
                                                        initialTab: tab,
                                                        onDismiss: ref
                                                            .read(
                                                              overlayDialogControllerProvider
                                                                  .notifier,
                                                            )
                                                            .dismiss,
                                                      ),
                                                    );
                                              },
                                              onDelete: () async {
                                                await ref
                                                    .read(
                                                      tabRepositoryProvider
                                                          .notifier,
                                                    )
                                                    .closeTab(tab.id);
                                              },
                                            )
                                          : const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              )
                              .toList();
                        },
                        [
                          EquatableCollection(filteredTabs, immutable: true),
                          activeTab,
                        ],
                      );

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        sliver: SliverReorderableGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            //Sync values for itemHeight calculation _calculateItemHeight
                            childAspectRatio: 0.75,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                            crossAxisCount: 2,
                          ),
                          itemCount: tabs.length,
                          itemBuilder: (context, index) => tabs[index],
                          onReorder: (oldIndex, newIndex) async {
                            final containerRepository =
                                ref.read(containerRepositoryProvider.notifier);

                            final tabId = filteredTabs[oldIndex];
                            final containerId = await ref
                                .read(tabDataRepositoryProvider.notifier)
                                .containerTabId(tabId);

                            final String key;
                            if (newIndex <= 0) {
                              key = await containerRepository
                                  .getLeadingOrderKey(containerId);
                            } else if (newIndex >= filteredTabs.length - 1) {
                              key = await containerRepository
                                  .getTrailingOrderKey(containerId);
                            } else {
                              final orderAfterIndex = newIndex;
                              key =
                                  await containerRepository.getOrderKeyAfterTab(
                                filteredTabs[orderAfterIndex],
                                containerId,
                              );
                            }

                            await ref
                                .read(tabDataRepositoryProvider.notifier)
                                .assignOrderKey(tabId, key);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: _Tab.headerSize + 4,
            right: 4,
          ),
          child: FloatingActionButton.small(
            onPressed: () async {
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .addTab(url: Uri.https('kagi.com'));

              onClose();
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
