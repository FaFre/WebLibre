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
import 'package:weblibre/features/small_web/data/database/daos/small_web_item_dao.drift.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';

@DriftAccessor()
class SmallWebItemDao extends DatabaseAccessor<SmallWebDatabase>
    with $SmallWebItemDaoMixin {
  SmallWebItemDao(super.attachedDatabase);

  SingleOrNullSelectable<DateTime?> getLatestFetchedAt(
    SmallWebSourceKind sourceKind,
    KagiSmallWebMode? mode,
  ) {
    final query = selectOnly(db.smallWebMemberships)
      ..addColumns([db.smallWebMemberships.fetchedAt])
      ..where(
        db.smallWebMemberships.sourceKind.equalsValue(sourceKind) &
            (mode == null
                ? db.smallWebMemberships.mode.isNull()
                : db.smallWebMemberships.mode.equals(mode.name)),
      )
      ..orderBy([
        OrderingTerm(
          expression: db.smallWebMemberships.fetchedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(1);

    return query.map((row) => row.read(db.smallWebMemberships.fetchedAt));
  }

  Selectable<SmallWebItem> getDiscoverableKagiItems(
    KagiSmallWebMode mode,
    String? category,
  ) {
    return db.definitionsDrift.getDiscoverableKagiItems(
      sourceKind: SmallWebSourceKind.kagi,
      mode: mode.name,
      category: category,
    );
  }

  Future<void> updateTitle(String id, String title) {
    return (db.smallWebItems.update()..where((i) => i.id.equals(id))).write(
      SmallWebItemsCompanion(
        title: Value(title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
