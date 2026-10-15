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

/// Backs Riverpod's `persist()` with the `riverpod` table of `user.db`.
///
/// Once [preload] has run, reads are answered synchronously from memory. That
/// is what decides whether a persisted provider's first frame is right: when
/// [read] returns a value rather than a future, `persist()` applies it inside
/// the provider's first build, so the default never reaches the screen. An
/// asynchronous read lands a frame or more later, and every collapsed home
/// section, customised menu and remembered view mode first painted as its
/// default and then snapped to the saved state (#665).
///
/// The copy can stand in for the table because this class is the table's only
/// reader and writer. Writes still go to the database, in the same order as
/// before.
final class RiverpodStorage extends Storage<String, String> {
  final UserDatabase _db;

  RiverpodStorage(this._db);

  /// Every row of the table, once [preload] has completed.
  Map<String, PersistedData<String>>? _cache;

  Future<void>? _preload;

  /// Writes (a value) and deletes (null) made while [preload]'s query is out.
  ///
  /// The query was queued ahead of them, so its result cannot contain them, and
  /// adopting it as-is would bring the old value back.
  final _writtenDuringPreload = <String, PersistedData<String>?>{};

  /// Loads the whole table into memory. Safe to call more than once.
  ///
  /// The table holds a few dozen small JSON values, so one query costs about
  /// what a single keyed read does. If it fails, reads keep going to the
  /// database, and a later call tries again.
  Future<void> preload() => _preload ??= _load();

  Future<void> _load() async {
    try {
      final rows = await _db.riverpod.select().get();

      _cache = {
        for (final row in rows)
          row.key: PersistedData(
            row.json,
            destroyKey: row.destroyKey,
            expireAt: row.expireAt,
          ),
      };

      for (final MapEntry(:key, :value) in _writtenDuringPreload.entries) {
        _remember(key, value);
      }
    } catch (_) {
      _preload = null;
      rethrow;
    } finally {
      _writtenDuringPreload.clear();
    }
  }

  void _remember(String key, PersistedData<String>? data) {
    final cache = _cache;

    if (cache != null) {
      if (data == null) {
        cache.remove(key);
      } else {
        cache[key] = data;
      }
    } else if (_preload != null) {
      _writtenDuringPreload[key] = data;
    }
  }

  @override
  Future<void> delete(String key) {
    _remember(key, null);
    return _db.riverpod.deleteWhere((x) => x.key.equals(key));
  }

  @override
  Future<void> deleteOutOfDate() {
    final now = DateTime.now();
    _cache?.removeWhere(
      (_, data) => data.expireAt != null && data.expireAt!.isBefore(now),
    );

    return _db.riverpod.deleteWhere((x) => x.expireAt.isSmallerThanValue(now));
  }

  @override
  FutureOr<PersistedData<String>?> read(String key) {
    final cache = _cache;
    if (cache != null) {
      return cache[key];
    }

    return _readFromDatabase(key);
  }

  Future<PersistedData<String>?> _readFromDatabase(String key) async {
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
    final expireAt = options.cacheTime.duration.mapNotNull(
      (duration) => DateTime.now().add(duration),
    );

    _remember(
      key,
      PersistedData(value, destroyKey: options.destroyKey, expireAt: expireAt),
    );

    return _db.riverpod.insertOne(
      RiverpodCompanion.insert(
        key: key,
        json: value,
        destroyKey: Value(options.destroyKey),
        expireAt: Value(expireAt),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
