/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
}
