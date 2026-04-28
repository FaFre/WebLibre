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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabDataRepository extends _$TabDataRepository {
  Future<void> assignContainer(
    String tabId,
    ContainerData targetContainer, {
    bool closeOldTab = true,
  }) async {
    final selectedTabId = ref.read(selectedTabProvider);
    final tabState = ref.read(tabStatesProvider)[tabId];

    // Isolated tabs: always do DB-only assignment (never recreate/recontext)
    if (tabState != null && tabState.tabMode is IsolatedTabMode) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: targetContainer.id);
      return;
    }

    final currentContainerData = await getTabContainerData(tabId);

    if (targetContainer.metadata.contextualIdentity ==
        currentContainerData?.metadata.contextualIdentity) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: targetContainer.id);
    } else {
      if (tabState != null) {
        if (closeOldTab) {
          await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);
        }

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: tabState.url,
              tabMode: tabState.tabMode,
              containerSelection: TabContainerSelection.specific(
                targetContainer,
              ),
              // parentId defaults to null - breaks parent chain when changing contextual identity
              selectTab: selectedTabId == tabState.id,
            );
      }
    }
  }

  Future<void> unassignContainer(String tabId) async {
    final selectedTabId = ref.read(selectedTabProvider);
    final tabState = ref.read(tabStatesProvider)[tabId];

    // Isolated tabs: always do DB-only unassignment (never recreate/recontext)
    if (tabState != null && tabState.tabMode is IsolatedTabMode) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: null);
      return;
    }

    final currentContainerData = await getTabContainerData(tabId);

    if (currentContainerData?.metadata.contextualIdentity == null) {
      return ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: null);
    } else {
      if (tabState != null) {
        await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: tabState.url,
              tabMode: tabState.tabMode,
              containerSelection: const TabContainerSelection.unassigned(),
              // parentId defaults to null - breaks parent chain when removing contextual identity
              selectTab: selectedTabId == tabState.id,
            );
      }
    }
  }

  Future<void> setPinned(String tabId, {required bool pinned}) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .setPinned(tabId, pinned: pinned);
  }

  Future<void> assignOrderKey(String tabId, String orderKey) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .assignOrderKey(tabId, orderKey: orderKey);
  }

  Future<int> closeAllTabs({
    bool includeRegular = true,
    bool includePrivate = true,
    bool includeIsolated = true,
  }) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getAllTabIds(
          includeRegular: includeRegular,
          includePrivate: includePrivate,
          includeIsolated: includeIsolated,
        )
        .get();

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }

    return tabIds.length;
  }

  Future<List<String>> closeContainerTabs(
    String? containerId, {
    bool includeRegular = true,
    bool includePrivate = true,
    bool includeIsolated = true,
  }) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(
          containerId,
          includeRegular: includeRegular,
          includePrivate: includePrivate,
          includeIsolated: includeIsolated,
        )
        .get();

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }

    return tabIds;
  }

  Future<int> closeAllTabsByHost(String? containerId, String host) async {
    final tabs = await getContainerTabsData(containerId);

    final filtered = tabs
        .where((tab) => tab.url?.host == host)
        .map((tab) => tab.id)
        .toList();

    if (filtered.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(filtered);
    }

    return filtered.length;
  }

  Future<TabData?> getTabDataById(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabDataById(tabId)
        .getSingleOrNull();
  }

  Future<List<TabData>> getContainerTabsData(String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabsData(containerId)
        .get();
  }

  Future<String?> getTabContainerId(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerId(tabId)
        .getSingleOrNull();
  }

  Future<ContainerData?> getTabContainerData(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerData(tabId)
        .getSingleOrNull();
  }

  Future<Map<String, String?>> getTabsContainerId(Iterable<String> tabIds) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabsContainerId(tabIds)
        .get()
        .then(Map.fromEntries);
  }

  Future<Map<String, String?>> getTabDescendants(String tabId) async {
    final results = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .unorderedTabDescendants(tabId: tabId)
        .get();

    return Map.fromEntries(
      results.map((pair) => MapEntry(pair.id, pair.parentId)),
    );
  }

  Future<List<String>> getFilteredTabIds(String? containerId) async {
    final db = ref.read(tabDatabaseProvider);
    final filterOptions = ref.read(tabViewFilterControllerProvider);
    final tabStates = ref.read(tabStatesProvider);

    // Get all tab IDs in this container from DB
    final containerTabIds = await db.containerDao
        .getContainerTabIds(containerId)
        .get();

    // Only keep tabs that exist in the engine
    final candidateIds = containerTabIds
        .where((id) => tabStates.containsKey(id))
        .toList();

    if (candidateIds.isEmpty) return const [];

    if (!filterOptions.hasActiveFilter) return candidateIds;

    // Only fetch timestamps when date filtering is active
    final timestamps = filterOptions.effectiveDateRange != null
        ? Map.fromEntries(await db.tabDao.getTabTimestamps().get())
        : null;

    return candidateIds.where((id) {
      final state = tabStates[id];
      return filterOptions.matchesTab(state?.tabMode, timestamps?[id]);
    }).toList();
  }

  Future<int> deleteUnassignedTabsOlderThan(DateTime threshold) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getUnassignedRegularTabsOlderThan(threshold);

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }

    return tabIds.length;
  }

  @override
  void build() {}
}
