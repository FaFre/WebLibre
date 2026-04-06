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
import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/sort_field.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/search/domain/entities/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'providers.g.dart';

typedef TabStateWithContainer = (TabState, ContainerData?);

@Riverpod()
bool canManualTabReorder(Ref ref) {
  final filterOptions = ref.watch(tabViewFilterControllerProvider);

  final hasActiveSearch = ref.watch(
    tabSearchRepositoryProvider(
      TabSearchPartition.preview,
    ).select((value) => (value.value?.query ?? '').isNotEmpty),
  );

  return !filterOptions.hasActiveFilter && !hasActiveSearch;
}

@Riverpod(keepAlive: true)
class SelectedBangTrigger extends _$SelectedBangTrigger {
  // ignore: document_ignores api decision
  // ignore: use_setters_to_change_properties
  void setTrigger(BangKey trigger) {
    state = trigger;
  }

  void clearTrigger() {
    state = null;
  }

  @override
  BangKey? build({String? domain}) {
    return null;
  }
}

@Riverpod()
class SelectedBangData extends _$SelectedBangData {
  @override
  BangData? build({String? domain}) {
    final repository = ref.watch(bangDataRepositoryProvider.notifier);
    final selectedBangTrigger = ref.watch(
      selectedBangTriggerProvider(domain: domain),
    );

    final subscription = repository.watchBang(selectedBangTrigger).listen((
      value,
    ) {
      if (ref.mounted) {
        state = value;
      }
    });

    ref.onDispose(() async {
      await subscription.cancel();
    });

    return null;
  }
}

@Riverpod()
EquatableValue<List<DefaultTabEntity>> containerTabEntities(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final containerTabs = ref.watch(
    watchContainerTabIdsProvider(
      containerFilter,
    ).select((value) => value.value),
  );
  final tabList = ref.watch(tabListProvider);
  final orderKeys = ref.watch(
    watchTabOrderKeysProvider.select((value) => value.value),
  );

  final availableTabs =
      containerTabs?.where((tabId) => tabList.value.contains(tabId)).toList() ??
      [];

  switch (containerFilter) {
    case ContainerFilterById():
      return EquatableValue(
        availableTabs
            .map(
              (t) => DefaultTabEntity(
                tabId: t,
                orderKey: orderKeys?[t] ?? '',
                containerId: containerFilter.containerId,
              ),
            )
            .toList(),
      );
    case ContainerFilterDisabled():
      return ref.watch(
        watchTabsContainerIdProvider(EquatableValue(availableTabs)).select(
          (value) => EquatableValue(
            value.value?.entries
                    .map(
                      (e) => DefaultTabEntity(
                        tabId: e.key,
                        orderKey: orderKeys?[e.key] ?? '',
                        containerId: e.value,
                      ),
                    )
                    .toList() ??
                [],
          ),
        ),
      );
  }
}

@Riverpod()
EquatableValue<Map<String, TabState>> containerTabStates(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final availableTabs = ref.watch(
    containerTabEntitiesProvider(containerFilter),
  );
  final tabStates = ref.watch(tabStatesProvider);

  return EquatableValue({
    for (final tabEntity in availableTabs.value)
      if (tabStates.containsKey(tabEntity.tabId))
        tabEntity.tabId: tabStates[tabEntity.tabId]!,
  });
}

@Riverpod(keepAlive: true)
EquatableValue<List<TabStateWithContainer>> fifoTabStates(Ref ref) {
  final containerData = ref
      .watch(watchContainersWithCountProvider.select((value) => value.value))
      .mapNotNull(
        (value) => Map.fromEntries(value.map((c) => MapEntry(c.id, c))),
      );

  final sortedTabs = ref.watch(
    watchTabsFifoProvider.select((value) => value.value),
  );

  final tabStates = ref.watch(tabStatesProvider);

  return EquatableValue([
    if (sortedTabs != null)
      for (final tab in sortedTabs)
        if (tabStates.containsKey(tab.id))
          (
            tabStates[tab.id]!,
            tab.containerId.mapNotNull(
              (containerId) => containerData?[containerId],
            ),
          ),
  ]);
}

@Riverpod()
EquatableValue<List<TabStateWithContainer>>
selectedContainerTabStatesWithContainer(Ref ref) {
  final filter = ref.watch(
    selectedContainerProvider.select(
      (value) => ContainerFilterById(containerId: value),
    ),
  );

  final containerData = ref
      .watch(watchContainersWithCountProvider.select((value) => value.value))
      .mapNotNull(
        (value) => Map.fromEntries(value.map((c) => MapEntry(c.id, c))),
      );

  final sortedTabs = ref.watch(
    containerTabEntitiesProvider(filter).select((value) => value.value),
  );

  final tabStates = ref.watch(tabStatesProvider);

  final pinnedTabIds = ref.watch(
    watchPinnedTabIdsProvider.select((value) => value.value),
  );

  final orderKeys = {for (final tab in sortedTabs) tab.tabId: tab.orderKey};

  final items = [
    for (final tabEntity in sortedTabs)
      if (tabStates.containsKey(tabEntity.tabId))
        (
          tabStates[tabEntity.tabId]!,
          tabEntity.containerId.mapNotNull(
            (containerId) => containerData?[containerId],
          ),
        ),
  ];

  items.sort((a, b) {
    final aPinned = pinnedTabIds?.contains(a.$1.id) ?? false;
    final bPinned = pinnedTabIds?.contains(b.$1.id) ?? false;

    if (aPinned != bPinned) {
      return aPinned ? -1 : 1;
    }

    final aOrderKey = orderKeys[a.$1.id] ?? '';
    final bOrderKey = orderKeys[b.$1.id] ?? '';
    return aOrderKey.compareTo(bOrderKey);
  });

  return EquatableValue(items);
}

@Riverpod()
EquatableValue<List<TabStateWithContainer>> quickTabSwitcherTabStates(
  Ref ref,
  QuickTabSwitcherMode mode,
) {
  final effectiveMode = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.effectiveUiQuickTabSwitcherMode(),
    ),
  );
  final selectedTabId = ref.watch(selectedTabProvider);

  final tabStates = switch (effectiveMode) {
    QuickTabSwitcherMode.lastUsedTabs => ref.watch(fifoTabStatesProvider).value,
    QuickTabSwitcherMode.containerTabs =>
      ref.watch(selectedContainerTabStatesWithContainerProvider).value,
  };

  return EquatableValue(switch (effectiveMode) {
    QuickTabSwitcherMode.lastUsedTabs =>
      tabStates.where((state) => state.$1.id != selectedTabId).toList(),
    QuickTabSwitcherMode.containerTabs => tabStates,
  });
}

@Riverpod()
Future<List<VisitInfo>> quickTabSwitcherHistorySuggestions(
  Ref ref,
  QuickTabSwitcherMode mode,
) async {
  final effectiveMode = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.effectiveUiQuickTabSwitcherMode(),
    ),
  );
  final showHistorySuggestions = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.quickTabSwitcherShowHistorySuggestions,
    ),
  );

  if (!showHistorySuggestions) {
    return [];
  }

  final hasTabStates = ref.watch(
    quickTabSwitcherTabStatesProvider(
      effectiveMode,
    ).select((value) => value.value.isNotEmpty),
  );
  if (hasTabStates) {
    return [];
  }

  return ref
      .read(historyRepositoryProvider.notifier)
      .getVisitsPaginated(count: 25);
}

@Riverpod()
AsyncValue<bool> quickTabSwitcherHasResults(
  Ref ref,
  QuickTabSwitcherMode mode,
) {
  final effectiveMode = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.effectiveUiQuickTabSwitcherMode(),
    ),
  );
  final showQuickTabSwitcherBar = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.tabBarShowQuickTabSwitcherBar,
    ),
  );
  if (!showQuickTabSwitcherBar) {
    return const AsyncValue.data(false);
  }

  final hasResults = ref.watch(
    quickTabSwitcherTabStatesProvider(
      effectiveMode,
    ).select((value) => value.value.isNotEmpty),
  );

  if (hasResults) {
    return const AsyncValue.data(true);
  }

  return ref
      .watch(quickTabSwitcherHistorySuggestionsProvider(effectiveMode))
      .whenData((visits) => visits.isNotEmpty);
}

@Riverpod()
EquatableValue<List<TabEntity>> suggestedTabEntities(
  Ref ref,
  String? containerId,
) {
  final enableAiFeatures = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.enableLocalAiFeatures,
    ),
  );

  if (!enableAiFeatures) {
    return EquatableValue([]);
  }

  final excludedTabIds = ref.watch(
    watchContainerTabIdsProvider(
      // ignore: provider_parameters
      ContainerFilterById(containerId: containerId),
    ).select((value) => EquatableValue(value.value)),
  );

  final orderKeys = ref.watch(
    watchTabOrderKeysProvider.select((value) => value.value),
  );

  final suggestions = ref.watch(
    containerTabSuggestionsProvider(containerId).select(
      (value) => EquatableValue(
        value.value.mapNotNull(
              (result) => result
                  .whereNot(
                    (tabId) => excludedTabIds.value?.contains(tabId) ?? false,
                  )
                  .map(
                    (tabId) => DefaultTabEntity(
                      tabId: tabId,
                      orderKey: orderKeys?[tabId] ?? '',
                      containerId: containerId,
                    ),
                  )
                  .toList(),
            ) ??
            const [],
      ),
    ),
  );

  return suggestions;
}

List<TabEntity> _applyTabFiltersAndSort(
  List<TabEntity> entities,
  TabViewFilterOptions filterOptions,
  Map<String, TabState> tabStates,
  Set<String> pinnedTabIds,
  Map<String, DateTime>? tabTimestamps,
) {
  final sortField = filterOptions.sortType.sortField;
  final filteredRows = <_TabFilterRow>[];
  var hasPinned = false;

  for (final entity in entities) {
    final tabState = tabStates[entity.tabId];
    final timestamp = tabTimestamps?[entity.tabId];

    if (!filterOptions.matchesTab(tabState?.tabMode, timestamp)) {
      continue;
    }

    final isPinned = pinnedTabIds.contains(entity.tabId);
    hasPinned = hasPinned || isPinned;

    filteredRows.add(
      _TabFilterRow(
        entity: entity,
        isPinned: isPinned,
        titleKey:
            sortField == SortField.titleAsc || sortField == SortField.titleDesc
            ? (tabState?.titleOrAuthority ?? '').toLowerCase()
            : null,
        urlKey: sortField == SortField.urlAsc || sortField == SortField.urlDesc
            ? (tabState?.url.toString() ?? '')
            : null,
        dateKey:
            sortField == SortField.dateAsc || sortField == SortField.dateDesc
            ? (timestamp ?? DateTime(0))
            : null,
      ),
    );
  }

  if (sortField != null) {
    filteredRows.sort((a, b) {
      if (filterOptions.sortPinnedFirst && a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1;
      }

      final cmp = switch (sortField) {
        SortField.titleAsc => a.titleKey!.compareTo(b.titleKey!),
        SortField.titleDesc => b.titleKey!.compareTo(a.titleKey!),
        SortField.urlAsc => a.urlKey!.compareTo(b.urlKey!),
        SortField.urlDesc => b.urlKey!.compareTo(a.urlKey!),
        SortField.dateAsc => a.dateKey!.compareTo(b.dateKey!),
        SortField.dateDesc => b.dateKey!.compareTo(a.dateKey!),
      };

      if (cmp == 0) return a.entity.orderKey.compareTo(b.entity.orderKey);

      return cmp;
    });

    return filteredRows.map((row) => row.entity).toList();
  }

  if (!hasPinned || !filterOptions.sortPinnedFirst) {
    return filteredRows.map((row) => row.entity).toList();
  }

  final pinned = <TabEntity>[];
  final unpinned = <TabEntity>[];
  for (final row in filteredRows) {
    if (row.isPinned) {
      pinned.add(row.entity);
    } else {
      unpinned.add(row.entity);
    }
  }

  return [...pinned, ...unpinned];
}

class _TabFilterRow {
  final TabEntity entity;
  final bool isPinned;
  final String? titleKey;
  final String? urlKey;
  final DateTime? dateKey;

  const _TabFilterRow({
    required this.entity,
    required this.isPinned,
    required this.titleKey,
    required this.urlKey,
    required this.dateKey,
  });
}

@Riverpod()
EquatableValue<List<TabEntity>> seamlessFilteredTabEntities(
  Ref ref, {
  required TabSearchPartition searchPartition,
  required ContainerFilter containerFilter,
  required bool groupTrees,
}) {
  final orderKeys = ref.watch(
    watchTabOrderKeysProvider.select((value) => value.value),
  );

  final tabSearchResults = ref
      .watch(
        tabSearchRepositoryProvider(searchPartition).select(
          (value) => EquatableValue(
            value.value.mapNotNull(
              (result) => result.results
                  .map(
                    (tab) => SearchResultTabEntity(
                      tabId: tab.id,
                      orderKey: orderKeys?[tab.id] ?? '',
                      containerId: tab.containerId,
                      searchQuery: result.query,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      )
      .value;

  final availableTabs = ref.watch(
    containerTabEntitiesProvider(containerFilter),
  );

  // Tree mode: no filtering/sorting, return as-is
  if (groupTrees && tabSearchResults == null) {
    final trees = ref.watch(
      watchTabTreesProvider.select(
        (value) => EquatableValue(
          value.value?.map((tree) {
                // Find the container ID for the latest tab
                final containerForTab = availableTabs.value
                    .where((t) => t.tabId == tree.latestTabId)
                    .firstOrNull
                    ?.containerId;

                return TabTreeEntity(
                  tabId: tree.latestTabId,
                  orderKey: orderKeys?[tree.latestTabId] ?? '',
                  containerId: containerForTab,
                  rootId: tree.rootTabId,
                  totalTabs: tree.totalTabs,
                );
              }).toList() ??
              [],
        ),
      ),
    );

    return EquatableValue(
      trees.value
          .where(
            (tree) => availableTabs.value.any(
              (available) => available.tabId == tree.tabId,
            ),
          )
          .toList(),
    );
  }

  final tabStates = ref.watch(tabStatesProvider);

  final filterOptions = ref.watch(tabViewFilterControllerProvider);

  final pinnedTabIds = ref.watch(
    watchPinnedTabIdsProvider.select(
      (value) => value.value ?? const <String>{},
    ),
  );

  // Only pull timestamps from DB when date filtering/sorting is active
  final needsTimestamps =
      filterOptions.effectiveDateRange != null ||
      filterOptions.sortType.sortField == SortField.dateAsc ||
      filterOptions.sortType.sortField == SortField.dateDesc;
  final tabTimestamps = needsTimestamps
      ? ref.watch(watchTabTimestampsProvider.select((value) => value.value))
      : null;

  if (tabSearchResults == null) {
    if (filterOptions.hasActiveFilter || pinnedTabIds.isNotEmpty) {
      return EquatableValue(
        _applyTabFiltersAndSort(
          availableTabs.value,
          filterOptions,
          tabStates,
          pinnedTabIds,
          tabTimestamps,
        ),
      );
    }

    return availableTabs;
  }

  final searchFiltered = tabSearchResults
      .where(
        (tab) => availableTabs.value.any(
          (available) => available.tabId == tab.tabId,
        ),
      )
      .toList();

  if (filterOptions.hasActiveFilter || pinnedTabIds.isNotEmpty) {
    return EquatableValue(
      _applyTabFiltersAndSort(
        searchFiltered,
        filterOptions,
        tabStates,
        pinnedTabIds,
        tabTimestamps,
      ),
    );
  }

  return EquatableValue(searchFiltered);
}

@Riverpod()
EquatableValue<List<TabPreview>> filteredTabPreviews(
  Ref ref,
  TabSearchPartition searchPartition,
  ContainerFilter containerFilter,
) {
  final tabSearchResults = ref
      .watch(
        tabSearchRepositoryProvider(
          searchPartition,
        ).select((value) => EquatableValue(value.value)),
      )
      .value;

  final availableTabStates = ref.watch(
    containerTabStatesProvider(containerFilter),
  );

  if (tabSearchResults == null) {
    return EquatableValue([]);
  }

  return EquatableValue(
    tabSearchResults.results
        .where((tab) => availableTabStates.value.containsKey(tab.id))
        .map((tab) {
          final tabState = availableTabStates.value[tab.id]!;

          return TabPreview(
            id: tab.id,
            containerId: tab.containerId,
            title: tab.title ?? tabState.title,
            icon: tabState.icon,
            url: tab.cleanUrl ?? tabState.url,
            highlightedUrl: tab.url,
            extractedContent: tab.extractedContent,
            fullContent: tab.fullContent,
            sourceSearchQuery: tabSearchResults.query,
          );
        })
        .whereType<TabPreview>()
        .toList(),
  );
}

@Riverpod()
class AppLinksModeNotifier extends _$AppLinksModeNotifier {
  final _service = GeckoEngineSettingsService();

  Future<void> setMode(AppLinksMode mode) async {
    await _service.setAppLinksMode(mode);
    ref.invalidateSelf();
  }

  @override
  Future<AppLinksMode> build() {
    return _service.getAppLinksMode();
  }
}
