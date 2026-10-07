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
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

part 'browser_data.g.dart';

@Riverpod(keepAlive: true)
class BrowserDataService extends _$BrowserDataService {
  /// The [service] seam is test-only injection; production always constructs
  /// the default. Kept `final` so the live singleton's backing service can't be
  /// swapped at runtime.
  @visibleForTesting
  BrowserDataService({GeckoDeleteBrowserDataService? service})
    : _service = service ?? GeckoDeleteBrowserDataService();

  final GeckoDeleteBrowserDataService _service;

  var _onStartContainerDataCleared = false;

  /// Deletes every type in [types], each attempted even when one before it
  /// failed, then throws the first failure, if any.
  ///
  /// Stopping at the first failure would leave everything after it in place:
  /// on Quit, a failed history deletion used to keep the cookies.
  Future<void> deleteData(Set<DeleteBrowsingDataType>? types) async {
    if (types == null) return;

    (Object, StackTrace)? firstFailure;
    for (final type in types) {
      try {
        await deleteDataType(type);
      } catch (e, st) {
        logger.e('Failed to delete ${type.name}', error: e, stackTrace: st);
        firstFailure ??= (e, st);
      }
    }

    if (firstFailure case (final error, final stackTrace)) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Deletes one kind of browsing data.
  ///
  /// With [previousSessionTabsOnly], [DeleteBrowsingDataType.tabs] removes only
  /// the tabs the session restore brought back, never one opened since the
  /// engine started — and with [onlyTabIds] as well, only those of them listed
  /// there. Other types ignore both.
  Future<void> deleteDataType(
    DeleteBrowsingDataType type, {
    bool previousSessionTabsOnly = false,
    Set<String>? onlyTabIds,
  }) async {
    switch (type) {
      case DeleteBrowsingDataType.tabs:
        if (previousSessionTabsOnly) {
          await _service.deletePreviousSessionTabs(onlyTabIds: onlyTabIds);
        } else {
          await _service.deleteTabs();
        }
      case DeleteBrowsingDataType.history:
        await _service.deleteBrowsingHistory();
        await ref.read(tabDatabaseProvider).historyDao.clear();
        // Places visits are gone; drop their container tags too so they
        // don't dangle (and can't re-attach to a future same-URL visit).
        await ref.read(tabDatabaseProvider).visitContainerDao.clearAll();
      case DeleteBrowsingDataType.recentSearches:
        await ref
            .read(bangDataRepositoryProvider.notifier)
            .clearSearchHistory();
      case DeleteBrowsingDataType.cookies:
        await _service.deleteCookiesAndSiteData();
      case DeleteBrowsingDataType.cache:
        await _service.deleteCachedFiles();
      case DeleteBrowsingDataType.permissions:
        await _service.deleteSitePermissions();
      case DeleteBrowsingDataType.downloads:
        await _service.deleteDownloads();
    }
  }

  /// The ids of every tab the next session restore could bring back, including
  /// ones closed since the session was last saved.
  Future<Set<String>> sessionTabIds() => _service.getSessionTabIds();

  Future<void> clearDataForContext(String contextId) {
    return _service.clearDataForContext(contextId);
  }

  /// Clears Gecko session-context data for every [contextId], best-effort: a
  /// single failing context is logged and skipped so it never blocks the rest.
  ///
  /// Not gated by the one-shot startup guard — used both by the guarded
  /// [clearContainerDataOnEngineStart] fallback and directly on explicit Quit.
  Future<void> clearContainerData(List<String> contextIds) async {
    for (final contextId in contextIds) {
      try {
        await clearDataForContext(contextId);
      } catch (e, st) {
        logger.e(
          'Failed to clear data for container context $contextId',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  Future<void> clearContainerDataOnEngineStart(List<String> contextIds) async {
    if (!_onStartContainerDataCleared && contextIds.isNotEmpty) {
      _onStartContainerDataCleared = true;
      await clearContainerData(contextIds);
    }
  }

  @override
  void build() {}
}
