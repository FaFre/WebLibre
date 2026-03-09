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
import 'package:weblibre/features/geckoview/features/top_sites/data/database/daos/top_site.drift.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/entities/stored_top_site_source.dart';

@DriftAccessor()
class TopSiteDao extends DatabaseAccessor<TopSiteDatabase>
    with $TopSiteDaoMixin {
  TopSiteDao(super.db);

  Selectable<TopSiteData> selectPersistedTopSites() {
    return db.topSite.select()..orderBy([(t) => OrderingTerm.asc(t.orderKey)]);
  }

  Future<List<TopSiteData>> getPersistedTopSites() {
    return selectPersistedTopSites().get();
  }

  Future<TopSiteData?> getPersistedTopSiteById(String id) {
    return (db.topSite.select()..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<TopSiteData?> getPersistedTopSiteByUrl(Uri url) {
    return (db.topSite.select()
          ..where((t) => t.url.equalsValue(url.normalized)))
        .getSingleOrNull();
  }

  Future<int> countPersistedSites() async {
    final count = db.topSite.id.count();
    final query = db.selectOnly(db.topSite)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }

  Future<int> insertPinnedSite({
    required String id,
    required String title,
    required Uri url,
    required String orderKey,
  }) {
    return db.topSite.insertOne(
      TopSiteCompanion.insert(
        id: id,
        title: title,
        url: url.normalized,
        source: StoredTopSiteSource.pinned,
        orderKey: orderKey,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> insertSeededSites(List<TopSiteCompanion> rows) {
    return db.batch((batch) {
      batch.insertAll(db.topSite, rows);
    });
  }

  Future<int> updatePersistedSite(
    String id, {
    required String title,
    required Uri url,
  }) {
    return (db.topSite.update()..where((t) => t.id.equals(id))).write(
      TopSiteCompanion(title: Value(title), url: Value(url.normalized)),
    );
  }

  Future<int> deletePersistedSite(String id) {
    return (db.topSite.delete()..where((t) => t.id.equals(id))).go();
  }

  Future<void> assignOrderKey(String id, {required String orderKey}) {
    return (db.topSite.update()..where((t) => t.id.equals(id))).write(
      TopSiteCompanion(orderKey: Value(orderKey)),
    );
  }

  Future<void> promoteToSource(
    String id, {
    required StoredTopSiteSource source,
    required String title,
    required String orderKey,
  }) {
    return (db.topSite.update()..where((t) => t.id.equals(id))).write(
      TopSiteCompanion(
        source: Value(source),
        title: Value(title),
        orderKey: Value(orderKey),
      ),
    );
  }

  SingleSelectable<String> generateLeadingOrderKey({int bucket = 0}) {
    return db.definitionsDrift.leadingOrderKey(bucket: bucket);
  }

  SingleSelectable<String> generateTrailingOrderKey({int bucket = 0}) {
    return db.definitionsDrift.trailingOrderKey(bucket: bucket);
  }

  SingleOrNullSelectable<String> generateOrderKeyAfterSiteId(String id) {
    return db.definitionsDrift.orderKeyAfterSite(siteId: id);
  }

  SingleSelectable<String> generateOrderKeyBeforeSiteId(String id) {
    return db.definitionsDrift.orderKeyBeforeSite(siteId: id);
  }
}
