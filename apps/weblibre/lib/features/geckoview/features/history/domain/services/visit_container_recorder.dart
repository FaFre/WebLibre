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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/services/history_exclusion_replication.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/utils/url_canonical.dart';

part 'visit_container_recorder.g.dart';

class _HistoryEventsReceiver extends GeckoHistoryEvents {
  _HistoryEventsReceiver(this._onVisit);

  final void Function(String url, int visitTime, String tabId) _onVisit;

  @override
  void onVisitRecorded(String url, int visitTime, String tabId) {
    _onVisit(url, visitTime, tabId);
  }
}

/// Records the visit→container relation. Mozilla Places owns the visit itself;
/// on each Places visit the tab's native history delegate forwards the id of the
/// session that produced it, which this service maps to that tab's WebLibre
/// container and persists as a `visit_container` row (keyed on the visit's
/// canonical URL + time so the history UI can join it back to Places).
///
/// Graceful absence: a visit from a tab with no container — or from one WebLibre
/// holds no row for even after [VisitContainerRecorder._resolveAttempts], e.g. a
/// custom tab — writes no row and simply appears untagged. Activated eagerly at
/// startup.
@Riverpod(keepAlive: true)
class VisitContainerRecorder extends _$VisitContainerRecorder {
  /// A tab created by the engine (`window.open`) is persisted by WebLibre only
  /// after the fact, so its first visit can arrive before the row exists. Retry
  /// briefly rather than dropping the tag; a tab still absent after the whole
  /// budget is one WebLibre does not track at all (a custom tab), and is not
  /// asked about again — see [_unresolvedTabIds].
  static const _resolveAttempts = 4;
  static const _resolveRetryDelay = Duration(milliseconds: 150);

  /// Cap on the give-up set below. Only ever reached by a session that opens an
  /// implausible number of untracked tabs; clearing simply costs those tabs one
  /// more resolve attempt.
  static const _unresolvedTabIdsLimit = 256;

  @override
  void build() {
    // Resolved at the instant the visit is reported: a container reassignment
    // landing while the write is in flight must not retag the visit that
    // happened before it. Absent key = tab unknown, null value = uncontained.
    var tabContainerIds = ref.read(tabContainerIdsProvider);

    // Tabs the retry budget already gave up on. A custom tab is never in the tab
    // table, yet reports a visit on every page load, so without this each of
    // those loads would re-run the full budget: 4 queries spread over 450 ms.
    // An id is dropped again the moment a snapshot does cover it, so a row that
    // merely arrived late is not written off for good.
    final unresolvedTabIds = <String>{};

    ref.listen(tabContainerIdsProvider, (_, next) {
      tabContainerIds = next;
      unresolvedTabIds.removeWhere(next.containsKey);
    });

    /// Waits for the tab's row to appear. Distinguishes "no row yet" from "row
    /// with no container": the row existing at all ends the wait, so an
    /// uncontained tab does not sit through the whole retry budget.
    Future<String?> awaitTabRow(String tabId) async {
      if (unresolvedTabIds.contains(tabId)) return null;

      final db = ref.read(tabDatabaseProvider);

      for (var attempt = 0; attempt < _resolveAttempts; attempt++) {
        final rows = await db.tabDao.getTabsContainerId([tabId]).get();
        if (rows.isNotEmpty) return rows.single.value;

        if (attempt == _resolveAttempts - 1) break;
        await Future<void>.delayed(_resolveRetryDelay);
        if (!ref.mounted) return null;

        // The in-memory map may have caught up in the meantime.
        if (tabContainerIds.containsKey(tabId)) {
          return tabContainerIds[tabId];
        }
      }

      if (unresolvedTabIds.length >= _unresolvedTabIdsLimit) {
        unresolvedTabIds.clear();
      }
      unresolvedTabIds.add(tabId);

      return null;
    }

    Future<void> recordVisit(String url, int visitTime, String tabId) async {
      final canonical = canonicalizeUrl(url);
      if (canonical == null) return;

      final containerId = tabContainerIds.containsKey(tabId)
          ? tabContainerIds[tabId]
          : await awaitTabRow(tabId);

      // Uncontained tab, or one WebLibre has no row for → nothing to tag.
      if (containerId == null) return;
      if (!ref.mounted) return;

      await ref
          .read(tabDatabaseProvider)
          .visitContainerDao
          .insertRelation(
            rawUrl: url,
            urlCanonical: canonical.canonical,
            visitTime: visitTime,
            containerId: containerId,
          );
    }

    final receiver = _HistoryEventsReceiver((url, visitTime, tabId) {
      unawaited(recordVisit(url, visitTime, tabId));
    });

    GeckoHistoryEvents.setUp(receiver);
    ref.onDispose(() => GeckoHistoryEvents.setUp(null));
  }
}
