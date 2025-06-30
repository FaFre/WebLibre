import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabDataRepository extends _$TabDataRepository {
  Future<void> assignContainer(String tabId, String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .assignContainer(tabId, containerId: containerId);
  }

  Future<void> assignOrderKey(String tabId, String orderKey) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .assignOrderKey(tabId, orderKey: orderKey);
  }

  Future<void> closeAllTabsByContainer(String? containerId) async {
    final tabIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(containerId)
        .get();

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
    }
  }

  Future<void> closeAllTabsByHost(String? containerId, String host) async {
    final tabs = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabsData(containerId)
        .get();

    final filtered = tabs
        .where((tab) => tab.url?.host == host)
        .map((tab) => tab.id)
        .toList();

    if (filtered.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(filtered);
    }
  }

  Future<String?> containerTabId(String tabId) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerId(tabId)
        .getSingleOrNull();
  }

  @override
  void build() {}
}
