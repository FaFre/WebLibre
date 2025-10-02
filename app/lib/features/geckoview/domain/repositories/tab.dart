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
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/utils/debouncer.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();

  final _tabFromIntent = <String>{};

  bool hasLaunchedFromIntent(String? tabId) {
    if (tabId == null) {
      return false;
    }

    return _tabFromIntent.contains(tabId);
  }

  Future<String> addTab({
    Uri? url,
    bool selectTab = true,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    required bool private,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
    Value<ContainerData?>? container,
    bool launchedFromIntent = false,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    final assingedContainer =
        container ??
        Value<ContainerData?>(
          // ignore: only_use_keep_alive_inside_keep_alive
          await ref.read(selectedContainerProvider.notifier).fetchData(),
        );

    final newTabId = await tabDao.upsertContainerTabTransactional(
      () {
        return _tabsService.addTab(
          url: url,
          selectTab: selectTab,
          startLoading: startLoading,
          parentId: parentId,
          flags: flags,
          contextId: assingedContainer.value?.metadata.contextualIdentity,
          source: source,
          private: private,
          historyMetadata: historyMetadata,
          additionalHeaders: additionalHeaders,
        );
      },
      parentId: Value(parentId),
      containerId: Value(assingedContainer.value?.id),
    );

    if (launchedFromIntent) {
      _tabFromIntent.add(newTabId);
    }

    return newTabId;
  }

  Future<String> duplicateTab({
    required String? selectTabId,
    String? containerId,
    bool selectTab = true,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    final containerData = await containerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    return await tabDao.upsertContainerTabTransactional(
      () {
        return _tabsService.duplicateTab(
          selectTabId: selectTabId,
          newContextId: containerData?.metadata.contextualIdentity,
          selectNewTab: selectTab,
        );
      },
      parentId: const Value.absent(),
      containerId: Value(containerData?.id),
    );
  }

  Future<bool> selectPreviouslyOpenedTab(String tabId) async {
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByTimestamp(tabId: tabId)
        .getSingleOrNull();

    if (ref.mounted && previousTabId != null) {
      return selectTab(previousTabId);
    }

    return false;
  }

  Future<bool> selectPreviousTab(
    String tabId, {
    String? containerId,
    bool skipContainerCheck = true,
  }) async {
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByOrderKey(
          tabId: tabId,
          containerId: containerId,
          skipContainerCheck: skipContainerCheck,
        )
        .getSingleOrNull();

    if (ref.mounted && previousTabId != null) {
      return selectTab(previousTabId);
    }

    return false;
  }

  Future<bool> selectNextTab(
    String tabId, {
    String? containerId,
    bool skipContainerCheck = true,
  }) async {
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .nextTabByOrderKey(
          tabId: tabId,
          containerId: containerId,
          skipContainerCheck: skipContainerCheck,
        )
        .getSingleOrNull();

    if (ref.mounted && previousTabId != null) {
      return selectTab(previousTabId);
    }

    return false;
  }

  Future<bool> selectTab(String tabId) async {
    final containerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getContainerTabId(tabId);

    if (!ref.mounted) return false;

    final containerData = await containerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    if (!ref.mounted) return false;

    if (containerData != null) {
      if (containerData.metadata.authSettings.authenticationRequired) {
        // ignore: only_use_keep_alive_inside_keep_alive
        if (containerId != ref.read(selectedContainerProvider)) {
          logger.w(
            'Tried to open authenticated tab $tabId but container not selected',
          );
          return false;
        }
      }

      if (containerData.metadata.useProxy) {
        final proxyPluginHealthy = await GeckoContainerProxyService()
            .healthcheck();

        if (!proxyPluginHealthy) {
          logger.w(
            'Tried to open proxied tab $tabId but proxy plugin not responding',
          );
          return false;
        }
      }
    }

    await _tabsService.selectTab(tabId: tabId);
    return true;
  }

  Future<void> _selectNextTab(String tabId) async {
    // ignore: only_use_keep_alive_inside_keep_alive
    final tabState = ref.read(tabStateProvider(tabId));

    final currentContainerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getContainerTabId(tabId);

    if (!ref.mounted) return;

    final sameContainerTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(currentContainerId)
        .then((tabs) => tabs.where((tab) => tab != tabId).toList());

    if (!ref.mounted) return;

    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByTimestamp(tabId: tabId)
        .getSingleOrNull();

    if (previousTabId != null) {
      if (sameContainerTabs.any((tab) => tab == previousTabId)) {
        return _tabsService.selectTab(tabId: previousTabId);
      }
    }

    if (tabState?.parentId != null) {
      if (sameContainerTabs.any((tab) => tab == tabState?.parentId)) {
        return _tabsService.selectTab(tabId: tabState!.parentId!);
      }
    }

    if (!ref.mounted) return;

    final previousOrderedTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByOrderKey(
          tabId: tabId,
          containerId: currentContainerId,
          skipContainerCheck: false,
        )
        .getSingleOrNull();

    if (previousOrderedTabId != null) {
      return _tabsService.selectTab(tabId: previousOrderedTabId);
    }

    if (!ref.mounted) return;

    final nextOrderedTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .nextTabByOrderKey(
          tabId: tabId,
          containerId: currentContainerId,
          skipContainerCheck: false,
        )
        .getSingleOrNull();

    if (nextOrderedTabId != null) {
      return _tabsService.selectTab(tabId: nextOrderedTabId);
    }

    if (!ref.mounted) return;

    final unassignedTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(null)
        .then((tabs) => tabs.where((tab) => tab != tabId).toList());

    if (unassignedTabs.isNotEmpty) {
      return _tabsService.selectTab(tabId: unassignedTabs.first);
    }

    if (!ref.mounted) return;

    //We only take containers without authentication!
    final availableContainers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();

    final nextAvailableContainerUnauthenticated = availableContainers
        .firstWhereOrNull(
          (container) =>
              container.metadata.authSettings.authenticationRequired == false,
        );

    if (!ref.mounted) return;

    final nextContainerTabs = await nextAvailableContainerUnauthenticated
        .mapNotNull(
          (container) => ref
              .read(containerRepositoryProvider.notifier)
              .getContainerTabIds(container.id)
              .then((tabs) => tabs.where((tab) => tab != tabId).toList()),
        );

    if (nextContainerTabs.isNotEmpty) {
      return _tabsService.selectTab(tabId: nextContainerTabs!.first);
    }

    if (ref.mounted && availableContainers.isNotEmpty) {
      //Last resort push new tab to avoid any authenticated tab is selected
      // ignore: avoid_redundant_argument_values
      await addTab(selectTab: true, private: false);
    }
  }

  Future<void> closeTab(String tabId) async {
    if (ref.read(selectedTabProvider) == tabId) {
      await _selectNextTab(tabId);
    }

    return _tabsService.removeTab(tabId: tabId);
  }

  Future<void> closeTabs(List<String> tabIds) async {
    final selectedTab = ref.read(selectedTabProvider);
    if (selectedTab.mapNotNull(tabIds.contains) ?? false) {
      await _selectNextTab(selectedTab!);
    }

    return _tabsService.removeTabs(ids: tabIds);
  }

  Future<void> undoClose() {
    return _tabsService.undo();
  }

  @override
  void build() {
    final eventSerivce = ref.watch(eventServiceProvider);
    final tabContentService = ref.watch(tabContentServiceProvider);

    final db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen((tabId) async {
      // ignore: only_use_keep_alive_inside_keep_alive
      final containerId = ref.read(selectedContainerProvider);
      await db.tabDao.upsertUnassignedTab(
        tabId,
        parentId: const Value.absent(),
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

    ref.listen(
      fireImmediately: true,
      selectedTabProvider,
      (previous, tabId) async {
        if (tabId != null) {
          await db.tabDao.touchTab(tabId, timestamp: DateTime.now());
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to selectedTabProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      tabListProvider,
      (previous, next) async {
        //Only sync tabs if there has been a previous value or is not empty
        final syncTabs =
            next.value.isNotEmpty || (previous?.value.isNotEmpty ?? false);

        if (syncTabs) {
          await db.tabDao.syncTabs(retainTabIds: next.value);
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to tabListProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final tabStateDebouncer = Debouncer(const Duration(seconds: 3));
    Map<String, TabState>? debounceStartValue;

    ref.listen(
      tabStatesProvider,
      (previous, next) {
        //Since state changes occure pretty often and our map always contains
        //the latest state, we cache the value before starting debouncing and
        //later diff to that, to avoid frequent database writes
        if (!tabStateDebouncer.isDebouncing) {
          debounceStartValue = previous;
        }

        tabStateDebouncer.eventOccured(() async {
          await db.tabDao.updateTabs(debounceStartValue, next);
        });
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to tabStatesProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      tabStateDebouncer.dispose();
      await tabAddedSub.cancel();
      await tabContentSub.cancel();
    });
  }
}
