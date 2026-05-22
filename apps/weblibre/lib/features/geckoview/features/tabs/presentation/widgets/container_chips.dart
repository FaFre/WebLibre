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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chip_content.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/tab_drag_container_target.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/inline_count_badge.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';

ContainerColorPalette _palette(BuildContext context, Color color) {
  return ContainerColors.palette(context, color);
}

Color _chipColor(BuildContext context, Color color, bool isSelected) {
  final palette = _palette(context, color);
  return isSelected ? palette.selectedBackgroundColor : palette.backgroundColor;
}

BorderSide _chipSide(BuildContext context, Color color, bool isSelected) {
  final palette = _palette(context, color);
  return isSelected ? palette.selectedBorderSide : palette.borderSide;
}

InlineCountBadge _countBadge(BuildContext context, Color color, int count) {
  final palette = _palette(context, color);
  return InlineCountBadge(
    count: count,
    backgroundColor: palette.badgeBackgroundColor,
    foregroundColor: palette.badgeForegroundColor,
  );
}

class _UnassignedContainerChip extends ConsumerWidget {
  final int? Function()? containerBadgeCount;
  final bool selected;
  final void Function(ContainerDataWithCount?)? onSelected;

  const _UnassignedContainerChip({
    required this.containerBadgeCount,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int tabCount =
        containerBadgeCount?.call() ??
        ref.watch(
          containerTabCountProvider(
            // ignore: provider_parameters
            ContainerFilterById(containerId: null),
          ).select((value) => value.value ?? 0),
        );

    return FilterChip(
      avatar: const Icon(MdiIcons.folderHidden),
      labelPadding: const EdgeInsets.only(left: 6),
      label: SizedBox(
        height: 20,
        child: Center(
          child: _countBadge(
            context,
            Theme.of(context).colorScheme.primary,
            tabCount,
          ),
        ),
      ),
      color: WidgetStatePropertyAll(
        _chipColor(context, Theme.of(context).colorScheme.primary, selected),
      ),
      selected: selected,
      side: _chipSide(context, Theme.of(context).colorScheme.primary, selected),
      showCheckmark: false,
      onSelected: (value) {
        if (value) {
          onSelected?.call(null);
        }
      },
    );
  }
}

class _SyncedTabsChip extends ConsumerWidget {
  final bool selected;
  final int count;
  final VoidCallback onSelected;

  const _SyncedTabsChip({
    required this.selected,
    required this.count,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilterChip(
      avatar: const Icon(Icons.devices_other),
      label: count > 0
          ? _countBadge(context, Theme.of(context).colorScheme.primary, count)
          : const SizedBox.shrink(),
      color: WidgetStatePropertyAll(
        _chipColor(context, Theme.of(context).colorScheme.primary, selected),
      ),
      selected: selected,
      side: _chipSide(context, Theme.of(context).colorScheme.primary, selected),
      showCheckmark: false,
      onSelected: (value) {
        if (value) {
          onSelected();
        }
      },
    );
  }
}

class _ContainerSuggestionsChip extends ConsumerWidget {
  const _ContainerSuggestionsChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabSuggestionsEnabled = ref.watch(
      persistedBoolProvider(PersistedBoolKey.tabSuggestions),
    );
    final enableAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    );

    if (!enableAiFeatures || !tabSuggestionsEnabled) {
      return const SizedBox.shrink();
    }

    final suggestions = ref.watch(suggestClustersProvider);

    return suggestions.when(
      skipLoadingOnReload: true,
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }

        return FilterChip(
          avatar: const Icon(MdiIcons.autoFix),
          label: Text(data!.length.toString()),
          color: WidgetStatePropertyAll(
            _chipColor(context, Theme.of(context).colorScheme.primary, false),
          ),
          side: _chipSide(
            context,
            Theme.of(context).colorScheme.primary,
            false,
          ),
          showCheckmark: false,
          onSelected: (_) async {
            await const ContainerDraftRoute().push(context);
          },
        );
      },
      error: (error, stackTrace) {
        logger.e(
          'Error suggesting containers',
          error: error,
          stackTrace: stackTrace,
        );
        return const SizedBox.shrink();
      },
      loading: () {
        return FilterChip(
          avatar: const Icon(MdiIcons.autoFix),
          label: const Skeletonizer(child: Text('0')),
          color: WidgetStatePropertyAll(
            _chipColor(context, Theme.of(context).colorScheme.primary, false),
          ),
          side: _chipSide(
            context,
            Theme.of(context).colorScheme.primary,
            false,
          ),
          showCheckmark: false,
          onSelected: null,
        );
      },
    );
  }
}

class ContainerChips extends HookConsumerWidget {
  final bool displayMenu;
  final bool showUnassignedChip;
  final bool showGroupSuggestions;
  final bool enableDragAndDrop;
  final bool showSyncedChip;
  final bool syncedChipSelected;
  final bool? unassignedChipSelected;
  final int syncedTabCount;
  final VoidCallback? onSyncedChipSelected;

  final ContainerData? selectedContainer;
  final bool Function(ContainerDataWithCount)? containerFilter;
  final int Function(ContainerDataWithCount?)? containerBadgeCount;
  final void Function(ContainerDataWithCount?)? onSelected;
  final void Function(ContainerDataWithCount)? onDeleted;
  final void Function(ContainerDataWithCount)? onLongPress;

  final ValueListenable<TextEditingValue>? searchTextListenable;

  const ContainerChips({
    super.key,
    required this.selectedContainer,
    required this.onSelected,
    required this.onDeleted,
    this.onLongPress,
    this.containerFilter,
    this.containerBadgeCount,
    this.searchTextListenable,
    this.displayMenu = true,
    this.showUnassignedChip = true,
    this.showGroupSuggestions = false,
    this.enableDragAndDrop = true,
    this.showSyncedChip = false,
    this.syncedChipSelected = false,
    this.unassignedChipSelected,
    this.syncedTabCount = 0,
    this.onSyncedChipSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containerUiEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.showContainerUi,
      ),
    );
    if (!containerUiEnabled) {
      return const SizedBox.shrink();
    }

    final searchText = useListenableSelector(
      searchTextListenable,
      () => searchTextListenable?.value.text,
    );
    final chipScrollController = useScrollController();
    final activeItemKey = useRef(GlobalKey());
    final isUserScrolling = useRef(false);
    final userScrollTimer = useRef<Timer?>(null);

    useEffect(() {
      return userScrollTimer.value?.cancel;
    }, []);

    final containersAsync = ref.watch(
      matchSortedContainersWithCountProvider(searchText),
    );

    useEffect(() {
      final selectedId = selectedContainer?.id;
      if (selectedId == null || isUserScrolling.value) {
        return null;
      }

      final renderedContainers =
          containerFilter.mapNotNull(
            (filter) => containersAsync.value?.where(filter).toList(),
          ) ??
          containersAsync.value;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final activeContext = activeItemKey.value.currentContext;
        if (activeContext != null) {
          unawaited(
            Scrollable.ensureVisible(
              activeContext,
              alignment: 0.5,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            ),
          );
          return;
        }

        if (!chipScrollController.hasClients || renderedContainers == null) {
          return;
        }

        final activeIndex = renderedContainers.indexWhere(
          (container) => container.id == selectedId,
        );
        if (activeIndex < 0) {
          return;
        }

        final totalItems = renderedContainers.length;
        final maxExtent = chipScrollController.position.maxScrollExtent;
        if (totalItems <= 0 || maxExtent <= 0) {
          return;
        }

        chipScrollController.jumpTo(
          (activeIndex / totalItems * maxExtent).clamp(0.0, maxExtent),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final retryContext = activeItemKey.value.currentContext;
          if (retryContext != null) {
            unawaited(
              Scrollable.ensureVisible(
                retryContext,
                alignment: 0.5,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              ),
            );
          }
        });
      });

      return null;
    }, [selectedContainer?.id, containersAsync.value]);

    return containersAsync.when(
      skipLoadingOnReload: true,
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

        return NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            userScrollTimer.value?.cancel();
            if (notification.direction != ScrollDirection.idle) {
              isUserScrolling.value = true;
            }
            userScrollTimer.value = Timer(
              const Duration(milliseconds: 1500),
              () {
                isUserScrolling.value = false;
              },
            );
            return false;
          },
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child:
                      SelectableChips<
                        ContainerDataWithCount,
                        ContainerData,
                        String
                      >(
                        enableDelete: false,
                        maxCount: null,
                        scrollController: chipScrollController,
                        activeItemKey: activeItemKey.value,
                        cacheExtent: 500,
                        itemId: (container) => container.id,
                        decoration: SelectableChipDecoration(
                          color: (container, isSelected) =>
                              _chipColor(context, container.color, isSelected),
                          side: (container, isSelected) =>
                              _chipSide(context, container.color, isSelected),
                        ),
                        itemAvatar: (container) {
                          final isSelected =
                              selectedContainer?.id == container.id;
                          return buildContainerChipAvatar(
                            context,
                            container,
                            isSelected,
                          );
                        },
                        selectedBorderColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        itemLabel: (container) {
                          final isSelected =
                              selectedContainer?.id == container.id;
                          final count =
                              containerBadgeCount?.call(container) ??
                              container.tabCount;
                          return buildContainerChipLabel(
                            context,
                            container,
                            isSelected,
                            trailing: count != null && count > 0
                                ? _countBadge(context, container.color, count)
                                : null,
                          );
                        },
                        itemWrap: enableDragAndDrop
                            ? (child, container) {
                                return TabDragContainerTarget(
                                  container: container,
                                  child: child,
                                );
                              }
                            : null,
                        prefixListItems: [
                          if (showSyncedChip)
                            _SyncedTabsChip(
                              selected: syncedChipSelected,
                              count: syncedTabCount,
                              onSelected: onSyncedChipSelected ?? () {},
                            ),
                          if (showUnassignedChip)
                            enableDragAndDrop
                                ? TabDragContainerTarget(
                                    container: null,
                                    child: _UnassignedContainerChip(
                                      containerBadgeCount: () =>
                                          containerBadgeCount?.call(null),
                                      selected:
                                          unassignedChipSelected ??
                                          (selectedContainer == null &&
                                              !syncedChipSelected),
                                      onSelected: onSelected,
                                    ),
                                  )
                                : _UnassignedContainerChip(
                                    containerBadgeCount: () =>
                                        containerBadgeCount?.call(null),
                                    selected:
                                        unassignedChipSelected ??
                                        (selectedContainer == null &&
                                            !syncedChipSelected),
                                    onSelected: onSelected,
                                  ),
                          if (showGroupSuggestions)
                            const _ContainerSuggestionsChip(),
                        ],
                        availableItems: availableContainers,
                        selectedItem: selectedContainer,
                        onSelected: onSelected,
                        onDeleted: onDeleted,
                        onLongPress: onLongPress,
                      ),
                ),
                if (displayMenu)
                  IconButton(
                    // visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      await const ContainerListRoute().push(context);
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => SizedBox(
        height: 48,
        width: double.infinity,
        child: Center(
          child: Icon(
            Icons.error_outline,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      loading: () => const SizedBox(height: 48, width: double.infinity),
    );
  }
}
