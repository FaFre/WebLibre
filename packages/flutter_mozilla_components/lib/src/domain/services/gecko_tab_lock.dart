/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoTabLockApi();

/// Native's copy of the tab locks, which it enforces for every removal.
///
/// The app's database is the record of what the user asked for; native's set
/// always contains it. See [GeckoTabLockApi] for what each call promises.
class GeckoTabLockService {
  final GeckoTabLockApi _api;

  GeckoTabLockService({GeckoTabLockApi? api}) : _api = api ?? _apiInstance;

  /// The trusted startup snapshot, before the engine restores the session.
  Future<void> bootstrapLockedTabs(List<String> tabIds) {
    return _api.bootstrapLockedTabs(tabIds);
  }

  /// Locks or unlocks [tabId], checked against the open tabs.
  Future<TabLockChange> setTabLocked(String tabId, {required bool locked}) {
    return _api.setTabLocked(tabId, locked);
  }

  /// Which of [tabIds] native holds locked right now.
  Future<Set<String>> lockedTabIdsAmong(Iterable<String> tabIds) async {
    final ids = tabIds.toList();
    if (ids.isEmpty) return const {};
    return (await _api.lockedTabIdsAmong(ids)).toSet();
  }

  /// After the session restore only: native's set becomes [tabIds] limited to
  /// the open tabs. Returns the ids that were dropped.
  Future<List<String>> reconcileLockedTabs(List<String> tabIds) {
    return _api.reconcileLockedTabs(tabIds);
  }
}
