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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/search/util/tokenized_filter.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Stream<List<ContainerDataWithCount>> watchContainersWithCount(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.definitionsDrift.containersWithCount().watch();
}

@Riverpod()
AsyncValue<List<ContainerDataWithCount>> matchSortedContainersWithCount(
  Ref ref,
  String? searchText,
) {
  return ref.watch(
    watchContainersWithCountProvider.select((value) {
      if (searchText.isEmpty) {
        return value;
      }

      return value.whenData(
        (cb) => TokenizedFilter.sort(
          items: cb,
          toString: (item) => item.name,
          query: searchText!,
        ).filtered,
      );
    }),
  );
}

@Riverpod()
Stream<List<String>> watchContainerTabIds(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final db = ref.watch(tabDatabaseProvider);

  switch (containerFilter) {
    case ContainerFilterById(:final containerId):
      return db.containerDao.getContainerTabIds(containerId).watch();
    case ContainerFilterDisabled():
      return db.tabDao.getAllTabIds().watch();
  }
}

@Riverpod(keepAlive: true)
Stream<List<TabData>> watchTabsFifo(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);

  return db.tabDao.getTabsFifo().watch();
}

@Riverpod()
Future<int> containerTabCount(Ref ref, ContainerFilter containerFilter) {
  return ref.watch(
    watchContainerTabIdsProvider(
      containerFilter,
    ).selectAsync((tabs) => tabs.length),
  );
}

@Riverpod()
Stream<List<TabTreesResult>> watchTabTrees(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.definitionsDrift.tabTrees().watch();
}

@Riverpod()
Stream<Map<String, String?>> watchTabDescendants(Ref ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.definitionsDrift.unorderedTabDescendants(tabId: tabId).watch().map((
    results,
  ) {
    return Map.fromEntries(
      results.map((pair) => MapEntry(pair.id, pair.parentId)),
    );
  });
}

@Riverpod()
Stream<List<TabData>> watchContainerTabsData(Ref ref, String? containerId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.getContainerTabsData(containerId).watch();
}

@Riverpod()
Stream<ContainerData?> watchContainerData(Ref ref, String containerId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.getContainerData(containerId).watchSingleOrNull();
}

@Riverpod()
Stream<String?> watchContainerTabId(Ref ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.getTabContainerId(tabId).watchSingleOrNull();
}

@Riverpod()
Stream<ContainerData?> watchTabContainerData(Ref ref, String? tabId) {
  if (tabId == null) {
    return const Stream.empty();
  }

  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.getTabContainerData(tabId).watchSingleOrNull();
}

@Riverpod()
Stream<Map<String, String?>> watchTabsContainerId(
  Ref ref,
  EquatableValue<List<String>> tabIds,
) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getTabsContainerId(tabIds.value)
      .watch()
      .map(Map.fromEntries);
}

@Riverpod()
Stream<List<SiteAssignment>> watchAllAssignedSites(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.allAssignedSites().watch();
}

@Riverpod()
Stream<bool> watchIsCurrentSiteAssignedToContainer(Ref ref) {
  final currentUri = ref.watch(
    selectedTabStateProvider.select(
      (value) => value?.url ?? TabState.$default('').url,
    ),
  );

  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.isSiteAssignedToContainer(currentUri).watchSingle();
}
