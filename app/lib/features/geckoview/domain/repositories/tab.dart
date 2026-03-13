/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/tor/domain/repositories/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/debouncer.dart';

part 'tab.g.dart';

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();

  final _tabFromIntent = <String>{};
  final _closeLock = Lock();
  final _pendingIsolationCleanup = <String>{};

  bool hasLaunchedFromIntent(String? tabId) {
    if (tabId == null) {
      return false;
    }

    return _tabFromIntent.contains(tabId);
  }

  void clearLaunchedFromIntent(String tabId) {
    _tabFromIntent.remove(tabId);
  }

  NewTabPosition _newTabPositionForParent(String? parentId) {
    if (parentId != null) {
      return NewTabPosition.first;
    }

    return ref.read(generalSettingsWithDefaultsProvider).newTabPosition;
  }

  Future<String?> _resolveParentIdForContext({
    required String? parentId,
    required String? targetContextId,
  }) async {
    if (parentId == null) {
      return null;
    }

    final parentContainerData = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerData(parentId)
        .getSingleOrNull();

    final parentContextId = parentContainerData?.metadata.contextualIdentity;

    return (parentContextId == targetContextId) ? parentId : null;
  }

  Future<String> addTab({
    required TabMode tabMode,
    Uri? url,
    required bool selectTab,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
    TabContainerSelection containerSelection =
        const TabContainerSelection.useSelected(),
    bool launchedFromIntent = false,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    final assignedContainer = switch (containerSelection) {
      UseSelectedContainerTabSelection() =>
        await ref.read(selectedContainerProvider.notifier).fetchData(),
      UnassignedContainerTabSelection() => null,
      SpecificContainerTabSelection(:final container) => container,
    };

    // For isolated tabs, skip parent context validation since
    // isolated tabs use their own immutable context ID.
    final validatedParentId = tabMode is IsolatedTabMode
        ? parentId
        : await _resolveParentIdForContext(
            parentId: parentId,
            targetContextId: assignedContainer?.metadata.contextualIdentity,
          );

    final effectiveIsolationContextId = tabMode.isolationContextId;

    final effectiveContextId = tabMode is IsolatedTabMode
        ? effectiveIsolationContextId
        : assignedContainer?.metadata.contextualIdentity;
    final newTabPosition = _newTabPositionForParent(validatedParentId);

    final newTabId = await tabDao.upsertTabTransactional(
      () {
        return _tabsService.addTab(
          url: url,
          selectTab: selectTab,
          startLoading: startLoading,
          parentId: validatedParentId,
          flags: flags,
          contextId: effectiveContextId,
          source: source,
          private: tabMode is PrivateTabMode,
          historyMetadata: historyMetadata,
          additionalHeaders: additionalHeaders,
        );
      },
      parentId: Value(validatedParentId),
      newTabPosition: newTabPosition,
      containerId: Value(assignedContainer?.id),
      url: Value(url),
      tabMode: Value(tabMode),
    );

    if (launchedFromIntent) {
      _tabFromIntent.add(newTabId);
    }

    return newTabId;
  }

  Future<List<String>> addMultipleTabs({
    required List<AddTabParams> tabs,
    String? selectTabId,
    TabContainerSelection containerSelection =
        const TabContainerSelection.unassigned(),
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final db = ref.read(tabDatabaseProvider);
    final assignedContainer = switch (containerSelection) {
      UseSelectedContainerTabSelection() =>
        await ref.read(selectedContainerProvider.notifier).fetchData(),
      UnassignedContainerTabSelection() => null,
      SpecificContainerTabSelection(:final container) => container,
    };

    return await db.transaction(() async {
      final createdTabIds = await _tabsService.addMultipleTabs(
        tabs: tabs,
        selectTabId: selectTabId,
      );
      // Build sets for validation
      final creatingTabIds = createdTabIds.toSet();
      final parentIdsToValidate = tabs
          .map((tab) => tab.parentId)
          .whereType<String>()
          .where((id) => !creatingTabIds.contains(id))
          .toSet();

      // Batch validate parent IDs that aren't in the current creation batch
      final existingParentIds = await tabDao
          .getExistingTabIds(parentIdsToValidate)
          .get()
          .then((ids) => ids.toSet());

      // Upsert all tabs in the database
      for (var i = 0; i < createdTabIds.length; i++) {
        final tabId = createdTabIds[i];
        final tab = tabs[i];

        // Validate parent exists in either the batch being created or database
        String? validatedParentId;
        if (tab.parentId != null) {
          if (creatingTabIds.contains(tab.parentId) ||
              existingParentIds.contains(tab.parentId)) {
            validatedParentId = tab.parentId;
          }
        }

        await tabDao.insertTab(
          tabId,
          parentId: Value(validatedParentId),
          source: TabSource.manual,
          newTabPosition: _newTabPositionForParent(validatedParentId),
          containerId: Value(assignedContainer?.id),
          url: Value(Uri.tryParse(tab.url)),
          tabMode: Value(
            isIsolatedContextId(tab.contextId)
                ? TabMode.isolated(tab.contextId!)
                : tab.private
                ? TabMode.private
                : TabMode.regular,
          ),
        );
      }

      return createdTabIds;
    });
  }

  Future<String> duplicateTab({
    required String selectTabId,
    required ContainerData? containerData,
    required bool selectTab,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    final sourceTabMode =
        await tabDao.getTabMode(selectTabId).getSingleOrNull() ??
        TabMode.regular;

    // Duplicating an isolated tab creates a new isolation group
    final duplicateIsolationContextId = sourceTabMode is IsolatedTabMode
        ? newIsolatedContextId()
        : null;

    final duplicateTabMode = sourceTabMode is IsolatedTabMode
        ? TabMode.isolated(duplicateIsolationContextId!)
        : sourceTabMode;

    // Isolated tabs always use their isolation context ID
    final effectiveContextId = sourceTabMode is IsolatedTabMode
        ? duplicateIsolationContextId
        : containerData?.metadata.contextualIdentity;

    return await tabDao.upsertTabTransactional(
      () {
        return _tabsService.duplicateTab(
          selectTabId: selectTabId,
          newContextId: effectiveContextId,
          selectNewTab: selectTab,
        );
      },
      parentId: const Value.absent(),
      newTabPosition: _newTabPositionForParent(null),
      containerId: Value(containerData?.id),
      tabMode: Value(duplicateTabMode),
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
    final containerData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerData(tabId);

    if (!ref.mounted) return false;

    if (containerData != null) {
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
    final tabState = ref.read(tabStatesProvider)[tabId];

    final currentContainerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerId(tabId);

    if (!ref.mounted) return;

    final sameContainerTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(currentContainerId)
        .then((tabs) => tabs.where((tab) => tab != tabId).toList());

    if (!ref.mounted) return;

    // Priority 1: Check for parent tab first
    if (tabState?.parentId != null) {
      return _tabsService.selectTab(tabId: tabState!.parentId!);
    }

    // Priority 2: Check for previous tab by timestamp
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

    final availableContainers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();

    final nextAvailableContainer = availableContainers.firstOrNull;

    if (!ref.mounted) return;

    final nextContainerTabs = await nextAvailableContainer.mapNotNull(
      (container) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerTabIds(container.id)
          .then((tabs) => tabs.where((tab) => tab != tabId).toList()),
    );

    if (nextContainerTabs.isNotEmpty) {
      return _tabsService.selectTab(tabId: nextContainerTabs!.first);
    }
  }

  Future<void> closeTab(String tabId) {
    return _closeLock.synchronized(() async {
      // Collect isolation context before close
      final isolationContextId = ref
          .read(tabStatesProvider)[tabId]
          ?.isolationContextId;

      if (ref.read(selectedTabProvider) == tabId) {
        await _selectNextTab(tabId);
      }

      await _tabsService.removeTab(tabId: tabId);

      // Queue isolation cleanup — actual cleanup runs after syncTabs
      // deletes the DB row, so the count check is accurate.
      if (isolationContextId != null) {
        _pendingIsolationCleanup.add(isolationContextId);
      }
    });
  }

  Future<void> closeTabs(List<String> tabIds) {
    return _closeLock.synchronized(() async {
      // Collect isolation contexts from tabs being closed
      for (final tabId in tabIds) {
        final contextId = ref
            .read(tabStatesProvider)[tabId]
            ?.isolationContextId;
        if (contextId != null) {
          _pendingIsolationCleanup.add(contextId);
        }
      }

      final selectedTab = ref.read(selectedTabProvider);
      if (selectedTab.mapNotNull(tabIds.contains) ?? false) {
        await _selectNextTab(selectedTab!);
      }

      await _tabsService.removeTabs(ids: tabIds);
    });
  }

  /// Clears Gecko browsing data and removes proxy alias for an isolation
  /// context if no more tabs share it.
  Future<void> _cleanupIsolationContextIfEmpty(String contextId) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    // Re-verify count after close (handles concurrent close races)
    final remaining = await tabDao.tabsInIsolationGroup(contextId).getSingle();

    if (remaining > 0) return;

    // Guard against debounced DB persistence: a sibling tab can already be
    // active in-memory for this context before isolation_context_id is written.
    final activeTabs = ref.read(tabListProvider).value;
    final activeStates = ref.read(tabStatesProvider);
    final hasActiveSibling = activeTabs.any((tabId) {
      final state = activeStates[tabId];
      if (state == null) return false;

      return state.isolationContextId == contextId ||
          state.contextId == contextId;
    });

    if (hasActiveSibling) {
      logger.i(
        'Skipping isolation cleanup for active context still in memory: $contextId',
      );
      return;
    }

    logger.i('Cleaning up isolation context: $contextId');

    // Clear Gecko browsing data for this context
    try {
      await ref
          .read(browserDataServiceProvider.notifier)
          .clearDataForContext(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to clear data for isolation context $contextId',
        error: e,
        stackTrace: st,
      );
    }

    // Best-effort: remove proxy alias (no-op if never set)
    try {
      await ref
          .read(torProxyRepositoryProvider.notifier)
          .removeContainerProxy(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to remove proxy for isolation context $contextId',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> undoClose() {
    return _tabsService.undo();
  }

  /// Cleans up isolation contexts from previous crashed sessions.
  /// Called once after tab list stabilizes on startup.
  // Future<void> _cleanupOrphanedIsolationContexts() async {
  //   final tabDao = ref.read(tabDatabaseProvider).tabDao;

  //   try {
  //     await _closeLock.synchronized(() async {
  //       if (!ref.mounted) return;

  //       // Reconcile DB rows against the current engine tab snapshot, including
  //       // valid empty-tab sessions (retainTabIds can be empty here).
  //       final syncTabsResult = await tabDao.syncTabs(
  //         retainTabIds: ref.read(tabListProvider).value,
  //       );
  //       _pendingIsolationCleanup.addAll(
  //         syncTabsResult.deletedIsolationContextIds,
  //       );

  //       if (_pendingIsolationCleanup.isNotEmpty) {
  //         final pending = Set<String>.of(_pendingIsolationCleanup);
  //         _pendingIsolationCleanup.clear();

  //         for (final contextId in pending) {
  //           if (!ref.mounted) return;
  //           logger.i('Cleaning orphaned isolation context: $contextId');
  //           await _cleanupIsolationContextIfEmpty(contextId);
  //         }
  //       }
  //     });
  //   } catch (e, st) {
  //     logger.e(
  //       'Error during orphan isolation context cleanup',
  //       error: e,
  //       stackTrace: st,
  //     );
  //   }
  // }

  @override
  void build() {
    final eventSerivce = ref.watch(eventServiceProvider);
    final tabContentService = ref.watch(tabContentServiceProvider);

    final db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen(
      (tabId) async {
        final containerId = ref.read(selectedContainerProvider);
        await db.tabDao.insertTab(
          tabId,
          parentId: const Value.absent(),
          source: TabSource.addedEvent,
          newTabPosition: _newTabPositionForParent(null),
          containerId: Value(containerId),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab added stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final containerSiteAssignementSub = eventSerivce.siteAssignementEvent.listen(
      (event) async {
        if (event.tabId != null) {
          final tabState = ref.read(tabStatesProvider)[event.tabId];
          if (tabState != null) {
            final uri = Uri.parse(event.url);
            final originUri = event.originUrl.mapNotNull(Uri.parse);

            final targetContainerId = await ref
                .read(containerRepositoryProvider.notifier)
                .siteAssignedContainerId(Uri.parse(uri.origin));
            final containerData = await targetContainerId.mapNotNull(
              (id) => ref
                  .read(containerRepositoryProvider.notifier)
                  .getContainerData(id),
            );

            if (containerData != null) {
              final tabIsEmpty =
                  tabState.url == TabState.defaultUrl &&
                  tabState.historyState.items.isEmpty;

              if (event.blocked || tabIsEmpty) {
                await addTab(
                  url: uri,
                  tabMode: tabState.tabMode,
                  containerSelection: TabContainerSelection.specific(
                    containerData,
                  ),
                  parentId: tabState.id,
                  selectTab: true,
                );

                if (tabState.historyState.items.isEmpty) {
                  await closeTab(tabState.id);
                }
              } else {
                final tabContainerId = await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .getTabContainerId(tabState.id);

                if (targetContainerId != tabContainerId) {
                  if (originUri == null) {
                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .assignContainer(tabState.id, containerData);
                  } else if (tabState.url == originUri) {
                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .assignContainer(
                          tabState.id,
                          containerData,
                          closeOldTab: false,
                        );
                  } else {
                    logger.w(
                      'Could not match origin url for assignment ${tabState.url} to request ${event.originUrl}',
                    );
                  }
                }
              }
            }
          } else {
            logger.w('Could not get tab for assignement ${tabState?.url}');
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in container site assignment stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final tabContentSub = tabContentService.tabContentStream.listen(
      (content) async {
        await db.tabDao.updateTabContent(
          content.tabId,
          isProbablyReaderable: content.isProbablyReaderable,
          extractedContentMarkdown: content.extractedContentMarkdown,
          extractedContentPlain: content.extractedContentPlain,
          fullContentMarkdown: content.fullContentMarkdown,
          fullContentPlain: content.fullContentPlain,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab content stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      selectedTabProvider,
      (previous, tabId) async {
        if (tabId != null) {
          await db.tabDao.touchTab(tabId, timestamp: DateTime.now());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
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
        final shouldSyncTabs =
            next.value.isNotEmpty || (previous?.value.isNotEmpty ?? false);

        if (shouldSyncTabs) {
          final syncTabsResult = await db.tabDao.syncTabs(
            retainTabIds: next.value,
          );
          // Capture isolation contexts from rows deleted by syncTabs
          // (orphaned tabs from crashes, or tabs the engine dropped).
          _pendingIsolationCleanup.addAll(
            syncTabsResult.deletedIsolationContextIds,
          );
        }

        // Process pending isolation context cleanups after syncTabs
        // has deleted the rows, so the count check is accurate.
        if (_pendingIsolationCleanup.isNotEmpty) {
          final pending = Set<String>.of(_pendingIsolationCleanup);
          _pendingIsolationCleanup.clear();
          for (final contextId in pending) {
            if (!ref.mounted) break;
            await _cleanupIsolationContextIfEmpty(contextId);
          }
        }

        // One-shot orphan cleanup after tab list stabilizes (5s debounce).
        // Also runs for DB-only contexts whose rows were already deleted
        // by syncTabs above (those are handled via _pendingIsolationCleanup).
        // if (!orphanCleanupDone) {
        //   orphanCleanupTimer?.cancel();
        //   orphanCleanupTimer = Timer(const Duration(seconds: 5), () async {
        //     if (orphanCleanupDone || !ref.mounted) return;
        //     orphanCleanupDone = true;
        //     await _cleanupOrphanedIsolationContexts();
        //   });
        // }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to tabListProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final tabStateDebouncer = Debouncer(const Duration(seconds: 1));
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
      onError: (Object error, StackTrace stackTrace) {
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
      await containerSiteAssignementSub.cancel();
    });
  }
}
