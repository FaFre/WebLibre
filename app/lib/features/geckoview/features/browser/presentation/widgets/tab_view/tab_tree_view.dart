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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/geckoview/features/browser/utils/grid_calculations.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class _TabTreePreview extends HookConsumerWidget {
  final TabTreeEntity entity;
  final String? activeTabId;

  final Offset stackPadding;

  final void Function() onClose;

  _TabTreePreview({
    required this.entity,
    required this.activeTabId,
    required this.onClose,
    required this.stackPadding,
  }) : super(key: ValueKey(entity));

  Widget _addPadding(int stackCount, int totalCount, Widget child) {
    final topPadding = stackPadding * stackCount.toDouble();
    final bottomPadding = stackPadding * (totalCount - stackCount).toDouble();

    return Positioned(
      top: topPadding.dy,
      left: topPadding.dx,
      right: bottomPadding.dx,
      bottom: bottomPadding.dy,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTabPrivate = ref.watch(
      tabStateProvider(entity.tabId).select((value) => value?.isPrivate),
    );

    if (isTabPrivate == null) {
      return const SizedBox.shrink();
    }

    final stackCount = math.min(entity.totalTabs, 3) - 1;

    return Stack(
      children: [
        for (var index = 0; index < stackCount; index++)
          _addPadding(
            index,
            stackCount,
            GridTabItemContainer(
              isActive: entity.tabId == activeTabId,
              isPrivate: isTabPrivate == true,
            ),
          ),
        _addPadding(
          stackCount,
          stackCount,
          Badge.count(
            isLabelVisible: entity.totalTabs > 1,
            count: entity.totalTabs,
            alignment: AlignmentDirectional.bottomEnd,
            offset: const Offset(-8, -24),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            textColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: GridTabPreview(
              tabId: entity.tabId,
              isActive: entity.tabId == activeTabId,
              onLongPress: () async {
                if (entity.tabId != activeTabId) {
                  //Close first to avoid rebuilds
                  onClose();
                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .selectTab(entity.tabId);
                } else {
                  onClose();
                }
              },
              onTap: () async {
                if (entity.totalTabs > 1) {
                  await TabTreeRoute(entity.rootId).push(context);
                } else if (entity.tabId != activeTabId) {
                  //Close first to avoid rebuilds
                  onClose();
                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .selectTab(entity.tabId);
                } else {
                  onClose();
                }
              },
              // onDeleteAll: (host) async {
              //   final containerId = await ref
              //       .read(tabDataRepositoryProvider.notifier)
              //       .containerTabId(tab.id);

              //   await ref
              //       .read(tabDataRepositoryProvider.notifier)
              //       .closeAllTabsByHost(containerId, host);
              // },
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
                final tabs = await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .getTabDescendants(entity.rootId);

                await ref
                    .read(tabRepositoryProvider.notifier)
                    .closeTabs(tabs.keys.toList());

                if (context.mounted) {
                  ui_helper.showTabUndoClose(
                    context,
                    ref.read(tabRepositoryProvider.notifier).undoClose,
                    count: tabs.length,
                  );
                }
              },
            ),
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
            TabViewHeader(onClose: onClose, tabsViewMode: TabsViewMode.tree),
            Expanded(
              child: HookConsumer(
                builder: (context, ref, child) {
                  final screenWidth = MediaQuery.of(context).size.width;

                  final containerId = ref.watch(selectedContainerProvider);

                  final filteredTabEntities = ref.watch(
                    seamlessFilteredTabEntitiesProvider(
                      searchPartition: TabSearchPartition.preview,
                      // ignore: document_ignores using fast equatable
                      // ignore: provider_parameters
                      containerFilter: ContainerFilterById(
                        containerId: containerId,
                      ),
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
                          return _TabTreePreview(
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
                      padding: EdgeInsets.zero,
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
      ],
    );
  }
}
