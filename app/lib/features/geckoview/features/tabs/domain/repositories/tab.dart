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
import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabDataRepository extends _$TabDataRepository {
  Future<void> assignContainer(
    String tabId,
    ContainerData targetContainer, {
    bool closeOldTab = true,
  }) async {
    final currentContainerId = await getTabContainerId(tabId);
    final selectedTabId = ref.read(selectedTabProvider);

    final currentContainerData = await currentContainerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    if (targetContainer.metadata.contextualIdentity ==
        currentContainerData?.metadata.contextualIdentity) {
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: targetContainer.id);
    } else {
      final tabState = ref.read(tabStateProvider(tabId));
      if (tabState != null) {
        if (closeOldTab) {
          await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);
        }

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: tabState.url,
              private: tabState.isPrivate,
              container: Value(targetContainer),
              parentId: tabState.parentId,
              selectTab: selectedTabId == tabState.id,
            );
      }
    }
  }

  Future<void> unassignContainer(String tabId) async {
    final currentContainerId = await getTabContainerId(tabId);
    final selectedTabId = ref.read(selectedTabProvider);

    final currentContainerData = await currentContainerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    if (currentContainerData?.metadata.contextualIdentity == null) {
      return ref
          .read(tabDatabaseProvider)
          .tabDao
          .assignContainer(tabId, containerId: null);
    } else {
      final tabState = ref.read(tabStateProvider(tabId));
      if (tabState != null) {
        await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: tabState.url,
              private: tabState.isPrivate,
              container: const Value(null),
              parentId: tabState.parentId,
              selectTab: selectedTabId == tabState.id,
            );
      }
    }
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
  }) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getAllTabIds(
          includeRegular: includeRegular,
          includePrivate: includePrivate,
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
  }) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(
          containerId,
          includeRegular: includeRegular,
          includePrivate: includePrivate,
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

  @override
  void build() {}
}
