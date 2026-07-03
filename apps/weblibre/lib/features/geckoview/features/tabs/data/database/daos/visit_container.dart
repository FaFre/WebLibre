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
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/visit_container.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';

/// Data access for the visit → container relation (`visit_container`).
///
/// Mozilla Places owns the browsing history itself; this table only records
/// which WebLibre container each contained visit belonged to. Reads are joined
/// back to Places `VisitInfo`s in the domain layer on
/// (url_canonical, nearest visit_time).
@DriftAccessor()
class VisitContainerDao extends DatabaseAccessor<TabDatabase>
    with $VisitContainerDaoMixin {
  VisitContainerDao(super.db);

  /// Record that a visit to [rawUrl] (canonical [urlCanonical]) at [visitTime]
  /// (epoch millis) belonged to [containerId]. Append-only: one row per visit.
  Future<void> insertRelation({
    required String rawUrl,
    required String urlCanonical,
    required int visitTime,
    required String containerId,
  }) {
    return into(db.visitContainer).insert(
      VisitContainerCompanion.insert(
        rawUrl: rawUrl,
        urlCanonical: urlCanonical,
        visitTime: visitTime,
        containerId: containerId,
      ),
    );
  }

  /// All relation rows whose canonical URL is in [canonicals]. Used to tag a
  /// page of Places visits with their container (matched by nearest visit_time
  /// in the domain layer). Returns empty for an empty input.
  ///
  /// Queried in chunks: an unfiltered history timeline can span every distinct
  /// URL in Places, and a single `IN (?, ?, …)` over that whole set would blow
  /// past SQLite's bound-variable limit and throw.
  Future<List<VisitContainerData>> relationsForCanonicalUrls(
    Set<String> canonicals,
  ) async {
    if (canonicals.isEmpty) return const [];

    // Stay well under SQLite's SQLITE_MAX_VARIABLE_NUMBER (defaults 999 on older
    // builds, 32766 on newer ones).
    const chunkSize = 500;
    final canonicalList = canonicals.toList(growable: false);
    final results = <VisitContainerData>[];
    for (var start = 0; start < canonicalList.length; start += chunkSize) {
      final chunk = canonicalList.sublist(
        start,
        math.min(start + chunkSize, canonicalList.length),
      );
      final rows = await (db.select(db.visitContainer)
            ..where((t) => t.urlCanonical.isIn(chunk)))
          .get();
      results.addAll(rows);
    }
    return results;
  }

  /// All relation rows for [containerId], newest first. Used by the
  /// container-filtered timeline and the per-container Places-delete mirror.
  Future<List<VisitContainerData>> relationsForContainer(String containerId) {
    return (db.select(db.visitContainer)
          ..where((t) => t.containerId.equals(containerId))
          ..orderBy([(t) => OrderingTerm.desc(t.visitTime)]))
        .get();
  }

  /// Remove a single relation row by primary key. Used when an individual
  /// history entry is deleted, so its tag can't later reattach (via the
  /// nearest-time join) to a different same-URL visit within the match window.
  Future<int> deleteById(int id) {
    return (db.delete(db.visitContainer)..where((t) => t.id.equals(id))).go();
  }

  /// Remove all relation rows for [containerId] (explicit per-container clear).
  /// Container deletion dissolves relations automatically via ON DELETE CASCADE
  /// and does not go through here.
  Future<int> deleteForContainer(String containerId) {
    return (db.delete(db.visitContainer)
          ..where((t) => t.containerId.equals(containerId)))
        .go();
  }

  /// Remove every relation row, all containers. Used when the user clears all
  /// browsing history: the Places visits these rows tag are gone, so the tags
  /// must go too — otherwise they dangle and could re-attach to a future,
  /// unrelated visit of the same URL within the nearest-time window.
  Future<int> clearAll() {
    return db.delete(db.visitContainer).go();
  }
}
