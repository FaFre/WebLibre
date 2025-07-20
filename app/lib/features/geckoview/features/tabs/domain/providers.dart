import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/search/util/tokenized_filter.dart';

part 'providers.g.dart';

@Riverpod()
Stream<List<ContainerDataWithCount>> containersWithCount(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containersWithCount().watch();
}

@Riverpod()
AsyncValue<List<ContainerDataWithCount>> matchSortedContainersWithCount(
  Ref ref,
  String? searchText,
) {
  return ref.watch(
    containersWithCountProvider.select((value) {
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
Stream<List<String>> containerTabIds(Ref ref, ContainerFilter containerFilter) {
  final db = ref.watch(tabDatabaseProvider);

  switch (containerFilter) {
    case ContainerFilterById(:final containerId):
      return db.containerDao.getContainerTabIds(containerId).watch();
    case ContainerFilterDisabled():
      return db.tabDao.getAllTabIds().watch();
  }
}

@Riverpod()
Future<int> containerTabCount(Ref ref, ContainerFilter containerFilter) {
  return ref.watch(
    containerTabIdsProvider(containerFilter).selectAsync((tabs) => tabs.length),
  );
}

@Riverpod()
Stream<List<TabTreesResult>> tabTrees(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabTrees().watch();
}

@Riverpod()
Stream<Map<String, String?>> tabDescendants(Ref ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.unorderedTabDescendants(tabId: tabId).watch().map((results) {
    return Map.fromEntries(
      results.map((pair) => MapEntry(pair.id, pair.parentId)),
    );
  });
}

@Riverpod()
Stream<List<TabData>> containerTabsData(Ref ref, String containerId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.getContainerTabsData(containerId).watch();
}

@Riverpod()
Stream<String?> watchContainerTabId(Ref ref, String tabId) {
  return ref
      .read(tabDatabaseProvider)
      .tabDao
      .getTabContainerId(tabId)
      .watchSingleOrNull();
}
