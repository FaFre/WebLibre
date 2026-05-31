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
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'gesture_settings.g.dart';

typedef UpdateGestureSettingsFunc =
    GestureSettings Function(GestureSettings currentSettings);

@Riverpod(keepAlive: true)
class GestureSettingsRepository extends _$GestureSettingsRepository {
  final _partitionKey = 'gesture';

  GestureSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final settings = Map.fromEntries(entries);

    final db = ref.read(userDatabaseProvider);

    return GestureSettings.fromJson({
      'enabled': settings['enabled']?.readAs(DriftSqlType.bool, db.typeMapping),
      'active': settings['active']?.readAs(DriftSqlType.bool, db.typeMapping),
      'strokeSize': settings['strokeSize']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'timeoutMs': settings['timeoutMs']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'maxFingers': settings['maxFingers']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'intervalMs': settings['intervalMs']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'showFeedback': settings['showFeedback']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'suggestNext': settings['suggestNext']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'minSuggestionStroke': settings['minSuggestionStroke']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
      'excludedSites': settings['excludedSites']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
      'bindings': settings['bindings']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
    });
  }

  //Eager fetch, when up to date settings are required
  Future<GestureSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(
    UpdateGestureSettingsFunc updateWithCurrent,
  ) async {
    final db = ref.read(userDatabaseProvider);

    final current = await fetchSettings();

    final oldJson = current.toJson();
    final newJson = updateWithCurrent(current).toJson();

    return db.transaction(() async {
      for (final MapEntry(:key, :value) in newJson.entries) {
        if (oldJson[key] != value) {
          await db.settingDao.updateSetting(key, _partitionKey, value);
        }
      }
    });
  }

  @override
  Stream<GestureSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map((event) {
          return _deserializeSettings(event);
        });
  }
}

@Riverpod(keepAlive: true)
GestureSettings gestureSettingsWithDefaults(Ref ref) {
  return ref.watch(
    gestureSettingsRepositoryProvider.select(
      (value) => value.value ?? GestureSettings.withDefaults(),
    ),
  );
}
