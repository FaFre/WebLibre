/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoDeleteBrowsingDataController();

class GeckoDeleteBrowserDataService {
  final GeckoDeleteBrowsingDataController _api;

  GeckoDeleteBrowserDataService({GeckoDeleteBrowsingDataController? api})
    : _api = api ?? _apiInstance;

  Future<void> deleteTabs() {
    return _api.deleteTabs();
  }

  /// The ids of every tab the next session restore could bring back: the open
  /// tabs, and those a not yet updated saved session still holds.
  Future<Set<String>> getSessionTabIds() async {
    return (await _api.getSessionTabIds()).toSet();
  }

  /// Deletes only the tabs the session restore brought back, after it completed;
  /// with [onlyTabIds], only those of them listed there.
  Future<void> deletePreviousSessionTabs({Set<String>? onlyTabIds}) {
    return _api.deletePreviousSessionTabs(onlyTabIds?.toList());
  }

  Future<void> deleteBrowsingHistory() {
    return _api.deleteBrowsingHistory();
  }

  Future<void> deleteCookiesAndSiteData() {
    return _api.deleteCookiesAndSiteData();
  }

  Future<void> deleteCachedFiles() {
    return _api.deleteCachedFiles();
  }

  Future<void> deleteSitePermissions() {
    return _api.deleteSitePermissions();
  }

  Future<void> deleteDownloads() {
    return _api.deleteDownloads();
  }

  Future<void> clearDataForContext(String contextId) {
    return _api.clearDataForSessionContext(contextId);
  }
}
