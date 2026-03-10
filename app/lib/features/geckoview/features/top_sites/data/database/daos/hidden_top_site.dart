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
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/database/daos/hidden_top_site.drift.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/database/definitions.drift.dart';

@DriftAccessor()
class HiddenTopSiteDao extends DatabaseAccessor<TopSiteDatabase>
    with $HiddenTopSiteDaoMixin {
  HiddenTopSiteDao(super.db);

  Future<Set<String>> getHiddenUrls() async {
    final rows = await db.hiddenTopSite.select().get();
    return rows.map((r) => r.url.normalized.toString()).toSet();
  }

  Stream<Set<String>> watchHiddenUrls() {
    return db.hiddenTopSite.select().watch().map(
      (rows) => rows.map((r) => r.url.normalized.toString()).toSet(),
    );
  }

  Future<void> hideUrl(Uri url) {
    return db.hiddenTopSite.insertOne(
      HiddenTopSiteCompanion.insert(url: url.normalized),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> unhideUrl(Uri url) {
    return (db.hiddenTopSite.delete()
          ..where((t) => t.url.equalsValue(url.normalized)))
        .go();
  }
}
