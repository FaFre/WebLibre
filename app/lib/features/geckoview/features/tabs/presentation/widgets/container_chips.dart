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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_title.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';

class ContainerChips extends HookConsumerWidget {
  final bool displayMenu;

  final ContainerData? selectedContainer;
  final bool Function(ContainerDataWithCount)? containerFilter;
  final void Function(ContainerDataWithCount?)? onSelected;
  final void Function(ContainerDataWithCount)? onDeleted;

  final ValueListenable<TextEditingValue>? searchTextListenable;

  const ContainerChips({
    required this.selectedContainer,
    required this.onSelected,
    required this.onDeleted,
    this.containerFilter,
    this.searchTextListenable,
    this.displayMenu = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useListenableSelector(
      searchTextListenable,
      () => searchTextListenable?.value.text,
    );

    final containersAsync = ref.watch(
      matchSortedContainersWithCountProvider(searchText),
    );

    final dragTargetTabId = useValueNotifier<String?>(null);

    return containersAsync.when(
      data: (containers) {
        final availableContainers =
            containerFilter.mapNotNull(
              (filter) => containers.where(filter).toList(),
            ) ??
            containers;

        if (selectedContainer == null &&
            availableContainers.isEmpty &&
            !displayMenu) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 48,
          child: Row(
            children: [
              if (selectedContainer != null || availableContainers.isNotEmpty)
                Expanded(
                  child: SelectableChips(
                    deleteIcon: false,
                    itemId: (container) => container.id,
                    itemAvatar: (container) => Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: container.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    itemLabel: (container) =>
                        ContainerTitle(container: container),
                    itemBadgeCount: (container) => container.tabCount,
                    itemWrap: (child, container) {
                      return HookBuilder(
                        builder: (context) {
                          final overlayController =
                              useOverlayPortalController();

                          return DragTarget<TabDragData>(
                            onMove: (details) {
                              ref
                                  .read(willAcceptDropProvider.notifier)
                                  .setData(
                                    ContainerDropData(details.data.tabId),
                                  );

                              dragTargetTabId.value = details.data.tabId;
                              overlayController.show();
                            },
                            onLeave: (data) {
                              ref.read(willAcceptDropProvider.notifier).clear();

                              dragTargetTabId.value = null;
                              overlayController.hide();
                            },
                            onAcceptWithDetails: (details) async {
                              await ref
                                  .read(tabDataRepositoryProvider.notifier)
                                  .assignContainer(
                                    details.data.tabId,
                                    container,
                                  );

                              dragTargetTabId.value = null;
                              overlayController.hide();
                            },
                            builder: (context, candidateData, rejectedData) {
                              final renderBox =
                                  context.findRenderObject() as RenderBox?;
                              final position =
                                  renderBox?.localToGlobal(Offset.zero) ??
                                  Offset.zero;

                              return OverlayPortal(
                                controller: overlayController,
                                overlayChildBuilder: (context) => Positioned(
                                  top: position.dy,
                                  left: position.dx,
                                  child: IgnorePointer(
                                    child: Transform.scale(
                                      scale: 1.1,
                                      child: child,
                                    ),
                                  ),
                                ),
                                child: HookBuilder(
                                  builder: (context) {
                                    final dragTabId = useValueListenable(
                                      dragTargetTabId,
                                    );

                                    return Opacity(
                                      opacity: (dragTabId == null) ? 1.0 : 0.0,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    prefixListItems: [
                      Consumer(
                        builder: (context, ref, child) {
                          final tabCount = ref.watch(
                            containerTabCountProvider(
                              // ignore: provider_parameters
                              ContainerFilterById(containerId: null),
                            ).select((value) => value.valueOrNull ?? 0),
                          );

                          return FilterChip(
                            avatar: const Icon(MdiIcons.folderHidden),
                            labelPadding: (tabCount > 0)
                                ? null
                                : const EdgeInsets.only(right: 2.0),
                            label: (tabCount > 0)
                                ? Text(tabCount.toString())
                                : const SizedBox.shrink(),
                            selected: selectedContainer == null,
                            showCheckmark: false,
                            onSelected: (value) {
                              if (value) {
                                onSelected?.call(null);
                              }
                            },
                          );
                        },
                      ),
                    ],
                    availableItems: availableContainers,
                    selectedItem: selectedContainer,
                    onSelected: onSelected,
                    onDeleted: onDeleted,
                  ),
                )
              else
                Visibility(
                  visible: displayMenu,
                  child: Expanded(
                    child: Text(
                      "Press '>' to manage Containers.",
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              if (displayMenu)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await ContainerListRoute().push(context);
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox(height: 48, width: double.infinity),
    );
  }
}
