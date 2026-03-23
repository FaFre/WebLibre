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
import 'package:drift/drift.dart';
import 'package:weblibre/features/small_web/data/database/daos/small_web_visit_dao.drift.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';

@DriftAccessor()
class SmallWebVisitDao extends DatabaseAccessor<SmallWebDatabase>
    with $SmallWebVisitDaoMixin {
  SmallWebVisitDao(super.attachedDatabase);

  Future<void> insertVisit(SmallWebVisit visit) {
    return db.smallWebVisits.insertOne(visit);
  }

  Selectable<GetRecentVisitsResult> getRecentVisits({
    required SmallWebSourceKind sourceKind,
    required KagiSmallWebMode? mode,
    int limit = 50,
  }) {
    return db.definitionsDrift.getRecentVisits(
      sourceKind: sourceKind,
      mode: mode?.name,
      limit: limit,
    );
  }

  Selectable<String> getRecentItemIds({
    required SmallWebSourceKind sourceKind,
    required KagiSmallWebMode? mode,
    int limit = 20,
  }) {
    return db.definitionsDrift.getRecentVisitItemIds(
      sourceKind: sourceKind,
      mode: mode?.name,
      limit: limit,
    );
  }

  Future<void> deleteVisitById(String visitId) {
    return (db.delete(
      db.smallWebVisits,
    )..where((t) => t.id.equals(visitId))).go();
  }

  Future<void> deleteVisitsBySourceAndMode({
    required SmallWebSourceKind sourceKind,
    required KagiSmallWebMode? mode,
  }) {
    return (db.delete(db.smallWebVisits)..where(
          (t) =>
              t.sourceKind.equalsValue(sourceKind) &
              (mode == null ? t.mode.isNull() : t.mode.equals(mode.name)),
        ))
        .go();
  }

  Future<void> deleteAllVisits() {
    return db.delete(db.smallWebVisits).go();
  }
}
