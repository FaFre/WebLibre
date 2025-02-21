import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/geckoview/domain/entities/states/tab.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_list.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/share_intent/domain/entities/shared_content.dart';
import 'package:lensai/utils/debouncer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();

  Future<String> addTab({
    Uri? url,
    bool selectTab = true,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    bool private = false,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
  }) async {
    final selectedContainer =
        await ref.read(selectedContainerProvider.notifier).fetchData();

    return ref.read(tabDatabaseProvider).tabDao.upsertContainerTabTransactional(
      () {
        return _tabsService.addTab(
          url: url,
          selectTab: selectTab,
          startLoading: startLoading,
          parentId: parentId,
          flags: flags,
          contextId: selectedContainer?.metadata.contextualIdentity,
          source: source,
          private: private,
          historyMetadata: historyMetadata,
          additionalHeaders: additionalHeaders,
        );
      },
      containerId: Value(selectedContainer?.id),
    );
  }

  Future<String> duplicateTab({
    required String? selectTabId,
    String? containerId,
    bool selectTab = true,
  }) async {
    final containerData = await containerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    return ref.read(tabDatabaseProvider).tabDao.upsertContainerTabTransactional(
      () {
        return _tabsService.duplicateTab(
          selectTabId: selectTabId,
          newContextId: containerData?.metadata.contextualIdentity,
          selectNewTab: selectTab,
        );
      },
      containerId: Value(containerData?.id),
    );
  }

  Future<void> selectTab(String tabId) {
    return _tabsService.selectTab(tabId: tabId);
  }

  Future<void> closeTab(String tabId) {
    return _tabsService.removeTab(tabId: tabId);
  }

  Future<void> closeTabs(List<String> tabIds) {
    return _tabsService.removeTabs(ids: tabIds);
  }

  @override
  void build() {
    final eventSerivce = ref.watch(eventServiceProvider);
    final tabContentService = ref.watch(tabContentServiceProvider);

    final db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen((tabId) async {
      final containerId = ref.read(selectedContainerProvider);
      await db.tabDao.upsertUnassignedTab(
        tabId,
        containerId: Value(containerId),
      );
    });

    final tabContentSub = tabContentService.tabContentStream.listen((
      content,
    ) async {
      await db.tabDao.updateTabContent(
        content.tabId,
        isProbablyReaderable: content.isProbablyReaderable,
        extractedContentMarkdown: content.extractedContentMarkdown,
        extractedContentPlain: content.extractedContentPlain,
        fullContentMarkdown: content.fullContentMarkdown,
        fullContentPlain: content.fullContentPlain,
      );
    });

    ref.listen(selectedTabProvider, (previous, tabId) async {
      if (tabId != null) {
        await db.tabDao.touchTab(tabId, timestamp: DateTime.now());
      }
    });

    ref.listen(tabListProvider, (previous, next) async {
      //Only sync tabs if there has been a previous value or is not empty
      final syncTabs =
          next.collection.isNotEmpty ||
          (previous?.collection.isNotEmpty ?? false);

      if (syncTabs) {
        await db.tabDao.syncTabs(retainTabIds: next.collection);
      }
    });

    final tabStateDebouncer = Debouncer(const Duration(seconds: 3));
    Map<String, TabState>? debounceStartValue;

    ref.listen(tabStatesProvider, (previous, next) async {
      //Since state changes occure pretty often and our map always contains
      //the latest state, we cache the value before starting debouncing and
      //later diff to that, to avoid frequent database writes
      if (!tabStateDebouncer.isDebouncing) {
        debounceStartValue = previous;
      }

      tabStateDebouncer.eventOccured(() async {
        await db.tabDao.updateTabs(debounceStartValue, next);
      });
    });

    ref.listen(intentStreamProvider, (previous, next) {
      next.whenData((value) async {
        switch (value) {
          case SharedUrl():
            await addTab(url: value.url);
          case SharedText():
            final defaultSearchBang =
                ref.read(selectedBangDataProvider()) ??
                await ref.read(defaultSearchBangDataProvider.future);

            await addTab(url: defaultSearchBang?.getUrl(value.text));
        }
      });
    });

    ref.onDispose(() {
      tabStateDebouncer.dispose();
      unawaited(tabAddedSub.cancel());
      unawaited(tabContentSub.cancel());
    });
  }
}
