/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoRecentlyClosedTabsApi();

/// The engine's recently closed list: closed tabs with their back history.
class GeckoRecentlyClosedTabsService {
  final GeckoRecentlyClosedTabsApi _api;

  GeckoRecentlyClosedTabsService({GeckoRecentlyClosedTabsApi? api})
    : _api = api ?? _apiInstance;

  /// Most recently selected first.
  Future<List<RecentlyClosedTab>> getTabs() {
    return _api.getRecentlyClosedTabs();
  }

  /// Reopens [id] under the same id in [contextId], the one it was closed in,
  /// and takes it off the list. Null when it is no longer on the list.
  Future<String?> restore(
    String id, {
    required String? contextId,
    required bool selectTab,
    required bool excludeFromHistory,
  }) {
    return _api.restoreRecentlyClosedTab(
      id: id,
      contextId: contextId,
      selectTab: selectTab,
      excludeFromHistory: excludeFromHistory,
    );
  }

  Future<void> remove(String id) {
    return _api.removeRecentlyClosedTab(id);
  }

  Future<void> removeAll() {
    return _api.removeAllRecentlyClosedTabs();
  }

  /// Keeps the tabs [ids] off the list when they are closed next: tabs closed
  /// by WebLibre rather than the user. Await it before closing them.
  Future<void> keepOff(List<String> ids) {
    return _api.keepOffRecentlyClosed(ids);
  }
}
