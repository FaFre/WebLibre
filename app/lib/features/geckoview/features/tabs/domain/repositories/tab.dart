import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabDataRepository extends _$TabDataRepository {
  Future<void> assignContainer(
    String tabId,
    ContainerData targetContainer,
  ) async {
    final currentContainerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .containerTabId(tabId);

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
      await ref
          .read(tabRepositoryProvider.notifier)
          .duplicateTab(selectTabId: tabId, containerId: targetContainer.id);

      await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);
    }
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
