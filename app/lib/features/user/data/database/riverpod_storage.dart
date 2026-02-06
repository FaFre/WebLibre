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

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

final class RiverpodStorage extends Storage<String, String> {
  final UserDatabase _db;

  RiverpodStorage(this._db);

  @override
  Future<void> delete(String key) {
    return _db.riverpod.deleteWhere((x) => x.key.equals(key));
  }

  @override
  Future<void> deleteOutOfDate() {
    return _db.riverpod.deleteWhere(
      (x) => x.expireAt.isSmallerThanValue(DateTime.now()),
    );
  }

  @override
  Future<PersistedData<String>?> read(String key) async {
    final query = _db.riverpod.select()..where((x) => x.key.equals(key));

    final data = await query.getSingleOrNull();

    return data.mapNotNull(
      (data) => PersistedData(
        data.json,
        destroyKey: data.destroyKey,
        expireAt: data.expireAt,
      ),
    );
  }

  @override
  Future<void> write(String key, String value, StorageOptions options) {
    return _db.riverpod.insertOne(
      RiverpodCompanion.insert(
        key: key,
        json: value,
        destroyKey: Value(options.destroyKey),
        expireAt: Value(
          options.cacheTime.duration.mapNotNull(
            (duration) => DateTime.now().add(duration),
          ),
        ),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
