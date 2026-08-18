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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/container_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/enable_ai_tab_suggestions_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Widget for tab filters (container chips with synced option)
class _TabFilters extends ConsumerWidget {
  final TabsViewMode tabsViewMode;

  const _TabFilters({required this.tabsViewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );

    final selectedContainer = ref.watch(
      selectedContainerDataProvider.select((value) => value.value),
    );

    final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);
    final syncedTabCountAsync = ref.watch(syncedTabsTotalCountProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContainerChips(
          showGroupSuggestions: switch (tabsViewMode) {
            TabsViewMode.list || TabsViewMode.grid => true,
            TabsViewMode.tree => false,
          },
          enableDragAndDrop: switch (tabsViewMode) {
            TabsViewMode.list || TabsViewMode.grid => true,
            TabsViewMode.tree => false,
          },
          showSyncedChip: isAuthenticated && tabsViewMode != TabsViewMode.tree,
          syncedChipSelected: isSyncedScope,
          syncedTabCount: syncedTabCountAsync.when(
            data: (count) => count,
            loading: () => 0,
            error: (_, _) => 0,
          ),
          onSyncedChipSelected: () {
            ref.read(tabsTrayScopeControllerProvider.notifier).showSynced();
          },
          selectedContainer: selectedContainer,
          onSelected: (container) async {
            ref.read(tabsTrayScopeControllerProvider.notifier).showLocal();

            if (container != null) {
              final result = await ref
                  .read(selectedContainerProvider.notifier)
                  .setContainerId(container.id);

              if (context.mounted && result == SetContainerResult.success) {
                await ensureProxyStartedForContainer(context, ref, container);
              }
            } else {
              ref.read(selectedContainerProvider.notifier).clearContainer();
            }
          },
          onDeleted: (container) {
            ref.read(tabsTrayScopeControllerProvider.notifier).showLocal();
            ref.read(selectedContainerProvider.notifier).clearContainer();
          },
          enableContextMenu: true,
        ),
        if (isSyncedScope) ...[
          const SizedBox(height: 8),
          _SyncedDeviceSelector(),
        ],
      ],
    );
  }
}

/// Widget for synced device selector
class _SyncedDeviceSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteDevicesAsync = ref.watch(syncRemoteTabsProvider);
    final selectedDeviceId = ref.watch(selectedSyncedTabsDeviceIdProvider);

    return remoteDevicesAsync.when(
      skipLoadingOnReload: true,
      data: (devices) {
        if (devices.isEmpty) {
          return const SizedBox.shrink();
        }

        final effectiveSelectedDeviceId =
            selectedDeviceId != null &&
                devices.any((device) => device.deviceId == selectedDeviceId)
            ? selectedDeviceId
            : devices.first.deviceId;

        return SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: devices
                .map((device) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(device.deviceName),
                      selected: effectiveSelectedDeviceId == device.deviceId,
                      onSelected: (_) {
                        ref
                            .read(selectedSyncedTabsDeviceIdProvider.notifier)
                            .selectDevice(device.deviceId);
                      },
                    ),
                  );
                })
                .toList(growable: false),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class TabViewHeader extends HookConsumerWidget {
  static const headerSize = 124.0;

  final TabsViewMode tabsViewMode;
  final VoidCallback onClose;

  const TabViewHeader({
    super.key,
    required this.onClose,
    required this.tabsViewMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode = useState(false);
    final searchTextFocus = useFocusNode();
    final searchTextController = useTextEditingController();

    final viewModeMenuController = useMenuController();
    final tabsActionMenuController = useMenuController();
    final filterMenuController = useMenuController();

    final hasSearchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final enableAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    );
    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.showContainerUi,
      ),
    );
    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );
    final canManualTabReorder = ref.watch(canManualTabReorderProvider);

    final tabsReorderable = ref.watch(tabsReorderableControllerProvider);

    final canManualReorder =
        !isSyncedScope &&
        tabsViewMode != TabsViewMode.tree &&
        canManualTabReorder;

    final didShowReorderDisabledInfo = useRef(false);

    useEffect(() {
      if (tabsReorderable && !canManualReorder) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(tabsReorderableControllerProvider.notifier).hide();

          if (!didShowReorderDisabledInfo.value) {
            didShowReorderDisabledInfo.value = true;

            if (context.mounted) {
              ui_helper.showInfoMessage(
                context,
                'Tab reordering is only available in default manual mode',
              );
            }
          }
        });
      } else {
        didShowReorderDisabledInfo.value = false;
      }

      return null;
    }, [tabsReorderable, canManualReorder]);

    // Keep the in-place tab filter in lockstep with the search field. The
    // preview query lives in a provider whose lifetime is independent of this
    // header and of [searchMode], so it can outlive the search UI and leave the
    // tab list filtered with no visible search box (#421). Whenever we are not
    // searching, drop any lingering query so all tabs are shown again.
    useEffect(() {
      if (!searchMode.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ref.exists(
            tabSearchRepositoryProvider(TabSearchPartition.preview),
          )) {
            unawaited(
              ref
                  .read(
                    tabSearchRepositoryProvider(
                      TabSearchPartition.preview,
                    ).notifier,
                  )
                  .addQuery(''),
            );
          }
        });
      }

      return null;
    }, [searchMode.value]);

    useOnListenableChange(searchTextController, () async {
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
                  children: [
                    if (tabsViewMode != TabsViewMode.tree)
                      IconButton(
                        icon: const Icon(MdiIcons.tabSearch),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        tooltip: 'Search inside tabs',
                        onPressed: () {
                          searchMode.value = true;
                          searchTextFocus.requestFocus();
                        },
                      ),
                    if (!isSyncedScope && tabsViewMode != TabsViewMode.tree)
                      Consumer(
                        builder: (context, ref, child) {
                          final filterOptions = ref.watch(
                            tabViewFilterControllerProvider,
                          );
                          final hasActiveFilter = filterOptions.hasActiveFilter;

                          return MenuAnchor(
                            controller: filterMenuController,
                            consumeOutsideTap: true,
                            menuChildren: [
                              // Tab type filter
                              SubmenuButton(
                                leadingIcon: const Icon(MdiIcons.tabUnselected),
                                menuChildren: TabTypeFilter.values.map((type) {
                                  final appColors = AppColors.of(context);
                                  final (icon, color) = switch (type) {
                                    TabTypeFilter.all => (
                                      MdiIcons.tabUnselected,
                                      null,
                                    ),
                                    TabTypeFilter.regularOnly => (
                                      MdiIcons.tab,
                                      null,
                                    ),
                                    TabTypeFilter.privateOnly => (
                                      MdiIcons.dominoMask,
                                      appColors.privateTabPurple,
                                    ),
                                    TabTypeFilter.isolatedOnly => (
                                      MdiIcons.snowflake,
                                      appColors.isolatedTabTeal,
                                    ),
                                  };

                                  return MenuItemButton(
                                    leadingIcon: Icon(
                                      filterOptions.tabTypeFilter == type
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                    ),
                                    trailingIcon: Icon(icon, color: color),
                                    child: Text(type.label),
                                    onPressed: () {
                                      ref
                                          .read(
                                            tabViewFilterControllerProvider
                                                .notifier,
                                          )
                                          .setTabTypeFilter(type);
                                    },
                                  );
                                }).toList(),
                                child: const Text('Tab Type'),
                              ),
                              // Sort
                              SubmenuButton(
                                leadingIcon: const Icon(Icons.sort),
                                menuChildren: [
                                  ...TabSortType.values.map(
                                    (sort) => MenuItemButton(
                                      leadingIcon: Icon(
                                        filterOptions.sortType == sort
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                      ),
                                      child: Text(sort.label),
                                      onPressed: () {
                                        ref
                                            .read(
                                              tabViewFilterControllerProvider
                                                  .notifier,
                                            )
                                            .setSortType(sort);
                                      },
                                    ),
                                  ),
                                  const Divider(),
                                  MenuItemButton(
                                    leadingIcon: Icon(
                                      filterOptions.sortPinnedFirst ||
                                              filterOptions
                                                      .sortType
                                                      .sortField ==
                                                  null
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                    ),
                                    onPressed:
                                        filterOptions.sortType.sortField == null
                                        ? null
                                        : () {
                                            ref
                                                .read(
                                                  tabViewFilterControllerProvider
                                                      .notifier,
                                                )
                                                .setSortPinnedFirst(
                                                  !filterOptions
                                                      .sortPinnedFirst,
                                                );
                                          },
                                    child: const Text('Sort Pinned First'),
                                  ),
                                ],
                                child: const Text('Sort'),
                              ),
                              MenuItemButton(
                                leadingIcon: Icon(
                                  filterOptions.showHierarchicalTabs
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                ),
                                onPressed: () {
                                  ref
                                      .read(
                                        tabViewFilterControllerProvider
                                            .notifier,
                                      )
                                      .setShowHierarchicalTabs(
                                        !filterOptions.showHierarchicalTabs,
                                      );
                                },
                                child: const Text('Hierarchical View'),
                              ),
                              const Divider(),
                              // Date range picker
                              MenuItemButton(
                                closeOnActivate: false,
                                leadingIcon: const Icon(MdiIcons.calendarRange),
                                trailingIcon: filterOptions.dateRange != null
                                    ? IconButton(
                                        onPressed: () {
                                          ref
                                              .read(
                                                tabViewFilterControllerProvider
                                                    .notifier,
                                              )
                                              .setDateRange(null);
                                        },
                                        icon: const Icon(Icons.clear),
                                      )
                                    : null,
                                child: filterOptions.dateRange != null
                                    ? Text(
                                        '${DateFormat.yMd().format(filterOptions.dateRange!.start)} - ${DateFormat.yMd().format(filterOptions.dateRange!.end)}',
                                      )
                                    : const Text('Filter Date'),
                                onPressed: () async {
                                  final range = await showDateRangePicker(
                                    context: context,
                                    initialDateRange: filterOptions.dateRange,
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now(),
                                  );
                                  if (range != null) {
                                    ref
                                        .read(
                                          tabViewFilterControllerProvider
                                              .notifier,
                                        )
                                        .setDateRange(
                                          DateTimeRange(
                                            start: range.start,
                                            end: range.end.add(
                                              const Duration(days: 1) -
                                                  const Duration(
                                                    milliseconds: 1,
                                                  ),
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              // Quick intervals
                              SubmenuButton(
                                leadingIcon: const Icon(MdiIcons.clockOutline),
                                menuChildren: TabQuickInterval.values
                                    .map(
                                      (interval) => MenuItemButton(
                                        leadingIcon: Icon(
                                          filterOptions.quickInterval ==
                                                  interval
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                        ),
                                        child: Text(interval.label),
                                        onPressed: () {
                                          ref
                                              .read(
                                                tabViewFilterControllerProvider
                                                    .notifier,
                                              )
                                              .setQuickInterval(
                                                filterOptions.quickInterval ==
                                                        interval
                                                    ? null
                                                    : interval,
                                              );
                                        },
                                      ),
                                    )
                                    .toList(),
                                child: const Text('Quick Interval'),
                              ),
                              const Divider(),
                              // Reset
                              MenuItemButton(
                                leadingIcon: const Icon(MdiIcons.restore),
                                child: const Text('Reset Filter'),
                                onPressed: () {
                                  ref
                                      .read(
                                        tabViewFilterControllerProvider
                                            .notifier,
                                      )
                                      .reset();
                                },
                              ),
                            ],
                            child: IconButton(
                              tooltip: 'Filter & Sort',
                              onPressed: () {
                                if (filterMenuController.isOpen) {
                                  filterMenuController.close();
                                } else {
                                  filterMenuController.open();
                                }
                              },
                              icon: Badge(
                                isLabelVisible: hasActiveFilter,
                                child: const Icon(MdiIcons.filter, size: 18),
                              ),
                            ),
                          );
                        },
                      ),
                    const Spacer(),
                    MenuAnchor(
                      controller: viewModeMenuController,
                      menuChildren: TabsViewMode.values
                          .map(
                            (mode) => MenuItemButton(
                              leadingIcon: Icon(mode.icon),
                              child: Text(mode.label),
                              onPressed: () {
                                if (mode == TabsViewMode.tree) {
                                  searchTextController.clear();
                                  searchMode.value = false;
                                }

                                ref
                                    .read(
                                      tabsViewModeControllerProvider.notifier,
                                    )
                                    .set(mode);
                              },
                            ),
                          )
                          .toList(),
                      child: IconButton(
                        tooltip: 'Change view mode',
                        onPressed: isSyncedScope
                            ? null
                            : () {
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
                    if (enableAiFeatures &&
                        switch (tabsViewMode) {
                          TabsViewMode.list || TabsViewMode.grid => true,
                          TabsViewMode.tree => false,
                        })
                      Consumer(
                        builder: (context, ref, child) {
                          final tabSuggestionsEnabled = ref.watch(
                            persistedBoolProvider(
                              PersistedBoolKey.tabSuggestions,
                            ),
                          );
                          final downloadProgress = ref.watch(
                            mlDownloadStateProvider,
                          );

                          return Badge(
                            isLabelVisible: downloadProgress != null,
                            offset: const Offset(-2, 2),
                            label: downloadProgress != null
                                ? Text(
                                    '${downloadProgress.progress.toInt()}%',
                                    style: const TextStyle(fontSize: 10),
                                  )
                                : null,
                            child: IconButton.filledTonal(
                              icon: const Icon(MdiIcons.imageAutoAdjust),
                              isSelected: tabSuggestionsEnabled,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              tooltip: downloadProgress != null
                                  ? 'Downloading AI models (${downloadProgress.progress.toInt()}%)'
                                  : tabSuggestionsEnabled
                                  ? 'Disable AI tab suggestions'
                                  : 'Enable AI tab suggestions',
                              onPressed: () async {
                                if (!tabSuggestionsEnabled) {
                                  final result =
                                      await showEnableAiTabSuggestionsDialog(
                                        context,
                                      );

                                  if (result == true) {
                                    ref
                                        .read(
                                          persistedBoolProvider(
                                            PersistedBoolKey.tabSuggestions,
                                          ).notifier,
                                        )
                                        .set(true);
                                  }
                                } else {
                                  ref
                                      .read(
                                        persistedBoolProvider(
                                          PersistedBoolKey.tabSuggestions,
                                        ).notifier,
                                      )
                                      .set(false);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    if (switch (tabsViewMode) {
                      TabsViewMode.list || TabsViewMode.grid => true,
                      TabsViewMode.tree => false,
                    })
                      IconButton.filledTonal(
                        icon: const Icon(Icons.swap_vert),
                        isSelected: tabsReorderable,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        tooltip: tabsReorderable
                            ? 'Disable reordering mode'
                            : canManualReorder
                            ? 'Enable reordering mode'
                            : 'Reordering requires default manual mode',
                        onPressed: canManualReorder
                            ? () {
                                final wasEnabled = tabsReorderable;

                                ref
                                    .read(
                                      tabsReorderableControllerProvider
                                          .notifier,
                                    )
                                    .toggle();

                                // Show info when enabling reordering
                                if (!wasEnabled && context.mounted) {
                                  ui_helper.showInfoMessage(
                                    context,
                                    'Drag and drop tabs to reorder them',
                                  );
                                }
                              }
                            : null,
                      ),
                    Consumer(
                      builder: (context, ref, child) {
                        // The id is known synchronously; the row it points at
                        // loads asynchronously. Scope the tab-bulk actions to
                        // the id, or they would fall back to "unassigned"
                        // during that window.
                        final selectedContainerId = ref.watch(
                          selectedContainerProvider,
                        );
                        final selectedContainer = ref.watch(
                          selectedContainerDataProvider.select(
                            (value) => value.value,
                          ),
                        );

                        // Tab-bulk actions scoped to the container currently in
                        // view. The container's own actions (edit, pin, assigned
                        // sites, delete) hang off the chip's long-press menu,
                        // which is the same [ContainerMenu] with more items
                        // enabled.
                        return ContainerMenu(
                          controller: tabsActionMenuController,
                          container: selectedContainer,
                          scopeContainerId: selectedContainerId,
                          // The synced scope lists tabs from other devices;
                          // none of these act on them.
                          enabled: !isSyncedScope,
                          enableCloseFilteredTabs:
                              tabsViewMode != TabsViewMode.tree,
                          builder: (context, controller, _) => IconButton(
                            tooltip: 'Tab actions',
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            icon: const Icon(MdiIcons.dotsVertical),
                          ),
                        );
                      },
                    ),
                  ],
                )
              else
                TextField(
                  controller: searchTextController,
                  focusNode: searchTextFocus,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(MdiIcons.tabSearch, size: 18),
                    hintText: 'Search tabs',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasSearchText)
                          SpeechToTextButton(
                            onTextReceived: (data) {
                              searchTextController.text = data;
                            },
                          ),
                        IconButton(
                          onPressed: () {
                            if (searchTextController.text.isNotEmpty) {
                              searchTextController.clear();
                              searchTextFocus.requestFocus();
                            } else {
                              searchMode.value = false;
                            }
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                ),
              const Divider(),
              if (showContainerUi) _TabFilters(tabsViewMode: tabsViewMode),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
