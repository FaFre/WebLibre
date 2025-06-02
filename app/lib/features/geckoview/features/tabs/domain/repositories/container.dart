import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/color_palette.dart';

part 'container.g.dart';

@Riverpod(keepAlive: true)
class ContainerRepository extends _$ContainerRepository {
  Future<void> addContainer(ContainerData container) {
    return ref.read(tabDatabaseProvider).containerDao.addContainer(container);
  }

  Future<List<ContainerDataWithCount>> getAllContainersWithCount() {
    return ref.read(tabDatabaseProvider).containersWithCount().get();
  }

  Future<void> replaceContainer(ContainerData container) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .replaceContainer(container);
  }

  Future<ContainerData?> getContainerData(String id) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerData(id)
        .getSingleOrNull();
  }

  Future<List<String>> getContainerTabIds(String? id) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(id)
        .get();
  }

  Future<void> deleteContainer(String id) async {
    await ref
        .read(tabDataRepositoryProvider.notifier)
        .closeAllTabsByContainer(id);

    return ref.read(tabDatabaseProvider).containerDao.deleteContainer(id);
  }

  Future<Set<Color>> getDistinctColors() {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getDistinctColors()
        .get()
        .then((colors) => colors.toSet());
  }

  Future<String> getLeadingOrderKey(String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateLeadingOrderKey(containerId)
        .getSingle();
  }

  Future<String> getTrailingOrderKey(String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateTrailingOrderKey(containerId)
        .getSingle();
  }

  Future<String> getOrderKeyAfterTab(String tabId, String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateOrderKeyAfterTabId(containerId, tabId)
        .getSingle();
  }

  Future<Color> unusedRandomContainerColor() async {
    final allColors = colorTypes.flattened.toList();
    final usedColors = await getDistinctColors();

    Color randomColor;
    do {
      randomColor = randomColorShade(allColors);
    } while (usedColors.contains(randomColor));

    return randomColor;
  }

  @override
  void build() {}
}
