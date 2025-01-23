import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_list.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/utils/debouncer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();

  late TabDatabase _db;

  Future<String> addTab({
    Uri? url,
    bool selectTab = true,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    String? contextId,
    Source source = Internal.newTab,
    bool private = false,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
  }) {
    return _tabsService.addTab(
      url: url,
      selectTab: selectTab,
      startLoading: startLoading,
      parentId: parentId,
      flags: flags,
      contextId: contextId,
      source: source,
      private: private,
      historyMetadata: historyMetadata,
      additionalHeaders: additionalHeaders,
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

    final tabStateDebouncer = Debouncer(const Duration(seconds: 3));
    Map<String, TabState>? debounceStartValue;

    _db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen(
      (tabId) async {
        final containerId = ref.read(selectedContainerProvider);
        await _db.tabDao.upsertTab(tabId, containerId: Value(containerId));
      },
    );

    final tabContentSub =
        tabContentService.tabContentStream.listen((content) async {
      await _db.tabDao.updateTabContent(
        content.tabId,
        isProbablyReaderable: content.isProbablyReaderable,
        extractedContentMarkdown: content.extractedContentMarkdown,
        extractedContentPlain: content.extractedContentPlain,
        fullContentMarkdown: content.fullContentMarkdown,
        fullContentPlain: content.fullContentPlain,
      );
    });

    ref.listen(
      selectedTabProvider,
      (previous, tabId) async {
        if (tabId != null) {
          await _db.tabDao.touchTab(tabId, timestamp: DateTime.now());
        }
      },
    );

    ref.listen(
      tabListProvider,
      (previous, next) async {
        //Only sync tabs if there has been a previous value or is not empty
        final syncTabs = next.isNotEmpty || (previous?.isNotEmpty ?? false);

        if (syncTabs) {
          await _db.tabDao.syncTabs(retainTabIds: next);
        }
      },
    );

    ref.listen(
      tabStatesProvider,
      (previous, next) async {
        //Since state changes occure pretty often and our map always contains
        //the latest state, we cache the value before starting debouncing and
        //later diff to that, to avoid frequent database writes
        if (!tabStateDebouncer.isDebouncing) {
          debounceStartValue = previous;
        }

        tabStateDebouncer.eventOccured(() async {
          await _db.tabDao.updateTabs(debounceStartValue, next);
        });
      },
    );

    ref.onDispose(() {
      tabStateDebouncer.dispose();
      unawaited(tabAddedSub.cancel());
      unawaited(tabContentSub.cancel());
    });
  }
}
