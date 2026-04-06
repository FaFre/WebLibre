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
import 'package:weblibre/features/small_web/data/database/daos/wander_console_dao.drift.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';

@DriftAccessor()
class WanderConsoleDao extends DatabaseAccessor<SmallWebDatabase>
    with $WanderConsoleDaoMixin {
  WanderConsoleDao(super.attachedDatabase);

  Future<void> upsertConsole(WanderConsole console) {
    return db.wanderConsoles.insertOne(
      console,
      onConflict: DoUpdate(
        (old) => WanderConsolesCompanion(
          lastFetchedAt: Value(console.lastFetchedAt),
          lastFetchFailed: Value(console.lastFetchFailed),
        ),
        target: [db.wanderConsoles.url],
      ),
    );
  }

  SingleOrNullSelectable<WanderConsole?> getConsole(Uri url) {
    return (db.wanderConsoles.select()..where((c) => c.url.equalsValue(url)));
  }

  Selectable<Uri> getExistingConsoleUrls(List<Uri> urls) {
    final query = selectOnly(db.wanderConsoles)
      ..addColumns([db.wanderConsoles.url])
      ..where(db.wanderConsoles.url.isInValues(urls));

    return query.map((row) => row.readWithConverter(db.wanderConsoles.url)!);
  }

  Selectable<Uri> getDiscoveredConsoleUrls({int limit = 1000}) {
    return db.definitionsDrift.getDiscoveredConsoleUrls(limit: limit);
  }
}
