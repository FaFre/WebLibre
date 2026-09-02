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
import 'package:weblibre/data/database/extensions/database_table_size.dart';
import 'package:weblibre/features/user/data/database/daos/cache.drift.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/data/icon_cache_marker.dart';

@DriftAccessor()
class CacheDao extends DatabaseAccessor<UserDatabase> with $CacheDaoMixin {
  CacheDao(super.attachedDatabase);

  SingleSelectable<double> getIconCacheSize() {
    return db.tableSize(db.iconCache);
  }

  Future<int> clearIconCache() {
    return db.iconCache.deleteAll();
  }

  SingleOrNullSelectable<Uint8List?> getCachedIcon(String origin) {
    final query = selectOnly(db.iconCache)
      ..addColumns([db.iconCache.iconData])
      ..where(db.iconCache.origin.equals(origin));

    return query.map((row) => row.read(db.iconCache.iconData));
  }

  SingleOrNullSelectable<DateTime?> getCachedIconFetchDate(String origin) {
    final query = selectOnly(db.iconCache)
      ..addColumns([db.iconCache.fetchDate])
      ..where(db.iconCache.origin.equals(origin));

    return query.map((row) => row.read(db.iconCache.fetchDate));
  }

  Future<int> cacheIcon(String origin, Uint8List bytes) {
    return db.iconCache.insertOne(
      IconCacheCompanion.insert(
        origin: origin,
        iconData: bytes,
        fetchDate: DateTime.now(),
      ),
      onConflict: DoUpdate(
        (old) => IconCacheCompanion(
          iconData: Value(bytes),
          fetchDate: Value(DateTime.now()),
        ),
      ),
    );
  }

  /// Writes [bytes] for [origin] and reports whether what a reader would
  /// render actually changed.
  ///
  /// `fetch_date` is refreshed either way — it records when the icon was last
  /// *confirmed*, which is what the staleness check reads — but a
  /// byte-identical rewrite is not a change anyone above the DAO can observe.
  /// Gecko re-dispatches a page's favicon on essentially every navigation, so
  /// reporting each one as a change would drop the decoded icon out of the
  /// in-memory cache for the very site the user is looking at.
  Future<bool> cacheIconReportingChange(String origin, Uint8List bytes) {
    return transaction(() async {
      final existing = await getCachedIcon(origin).getSingleOrNull();
      await cacheIcon(origin, bytes);
      return !_rendersTheSame(existing, bytes);
    });
  }

  /// Writes [bytes] only when [origin] has no real icon yet, reporting whether
  /// that changed what a reader would render.
  Future<bool> cacheIconIfAbsent(String origin, Uint8List bytes) {
    return transaction(() async {
      final existing = await getCachedIcon(origin).getSingleOrNull();
      if (existing != null && !isMissingIconMarker(existing)) {
        return false;
      }

      await cacheIcon(origin, bytes);
      return !_rendersTheSame(existing, bytes);
    });
  }

  Future<bool> cacheMissingIcon(String origin) {
    return cacheIconReportingChange(origin, missingIconMarkerBytes);
  }

  /// Whether [stored] and [next] would put the same thing on screen.
  ///
  /// The missing-icon marker and an absent row are the same thing to every
  /// reader above the DAO — no icon — so moving between them is not a change,
  /// while replacing a real icon with the marker is.
  static bool _rendersTheSame(Uint8List? stored, Uint8List next) {
    final before = isMissingIconMarker(stored) ? null : stored;
    final after = isMissingIconMarker(next) ? null : next;

    if (before == null || after == null) {
      return (before == null) == (after == null);
    }

    if (before.length != after.length) {
      return false;
    }

    for (var i = 0; i < before.length; i++) {
      if (before[i] != after[i]) {
        return false;
      }
    }

    return true;
  }
}
