import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  Future<void> closeAllTabs(String? containerId) async {
    final tabIds =
        await ref
            .read(tabDatabaseProvider)
            .containerDao
            .getContainerTabIds(containerId)
            .get();

    if (tabIds.isNotEmpty) {
      await ref.read(tabRepositoryProvider.notifier).closeTabs(tabIds);
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
