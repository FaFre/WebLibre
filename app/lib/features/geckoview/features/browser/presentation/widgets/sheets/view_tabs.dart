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
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:lensai/features/geckoview/features/controllers/overlay_dialog.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

class _SliverHeaderDelagate extends SliverPersistentHeaderDelegate {
  static const _headerSize = 104.0;

  final VoidCallback onClose;

  _SliverHeaderDelagate({required this.onClose});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      child: Consumer(
        builder: (context, ref, child) {
          //Fix layout issue https://github.com/flutter/flutter/issues/78748#issuecomment-1194680555
          return Align(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(tabRepositoryProvider.notifier)
                            .addTab(url: Uri.https('kagi.com'));

                        onClose();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Tab'),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
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
          );
        },
      ),
    );
  }

  @override
  double get minExtent => _headerSize;

  @override
  double get maxExtent => _headerSize;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class ViewTabsSheetWidget extends HookConsumerWidget {
  final ScrollController sheetScrollController;
  final VoidCallback onClose;

  const ViewTabsSheetWidget({
    required this.onClose,
    required this.sheetScrollController,
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
    return CustomScrollView(
      controller: sheetScrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelagate(onClose: onClose),
        ),
        HookConsumer(
          builder: (context, ref, child) {
            final container = ref.watch(selectedContainerProvider);
            final availableTabs = ref
                .watch(
                  availableTabIdsProvider(container).select(
                    (value) => EquatableCollection(value, immutable: true),
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
                final index =
                    availableTabs.indexWhere((webView) => webView == activeTab);

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
              [availableTabs, activeTab],
            );

            final tabs = useMemoized(
              () => availableTabs
                  .mapIndexed(
                    (index, tabId) => ReorderableGridDelayedDragStartListener(
                      key: ValueKey(tabId),
                      index: index,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final tab = ref.watch(tabStateProvider(tabId));
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
                                            tabRepositoryProvider.notifier,
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
                                          tabRepositoryProvider.notifier,
                                        )
                                        .closeTab(tab.id);
                                  },
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                  )
                  .toList(),
              [availableTabs, activeTab],
            );

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              sliver: SliverReorderableGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

                  final tabId = availableTabs[oldIndex];
                  final containerId = await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .containerTabId(tabId);

                  final String key;
                  if (newIndex <= 0) {
                    key = await containerRepository
                        .getLeadingOrderKey(containerId);
                  } else if (newIndex >= availableTabs.length - 1) {
                    key = await containerRepository
                        .getTrailingOrderKey(containerId);
                  } else {
                    final orderAfterIndex = newIndex - 1;
                    key = await containerRepository.getOrderKeyAfterTab(
                      availableTabs[orderAfterIndex],
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
    );
  }
}
