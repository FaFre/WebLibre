import 'dart:ui';

import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container.g.dart';

@Riverpod(keepAlive: true)
class ContainerRepository extends _$ContainerRepository {
  Future<void> addContainer(ContainerData container) {
    return ref.read(tabDatabaseProvider).containerDao.addContainer(container);
  }

  Future<void> replaceContainer(ContainerData container) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .replaceContainer(container);
  }

  Future<ContainerData?> getContainerData(String id) async {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerData(id)
        .getSingleOrNull();
  }

  Future<void> deleteContainer(String id) async {
    await ref.read(tabDataRepositoryProvider.notifier).closeAllTabs(id);

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

  @override
  void build() {}
}
