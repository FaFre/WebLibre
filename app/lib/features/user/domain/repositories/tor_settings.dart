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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'tor_settings.g.dart';

typedef UpdateTorSettingsFunc =
    TorSettings Function(TorSettings currentSettings);

@Riverpod(keepAlive: true)
class TorSettingsRepository extends _$TorSettingsRepository {
  final _partitionKey = 'tor';

  TorSettings _deserializeSettings(List<MapEntry<String, DriftAny?>> entries) {
    final settings = Map.fromEntries(entries);

    final db = ref.read(userDatabaseProvider);

    return TorSettings.fromJson({
      'proxyPrivateTabsTor': settings['proxyPrivateTabsTor']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'config': settings['config']?.readAs(DriftSqlType.string, db.typeMapping),
      'requireBridge': settings['requireBridge']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'fetchRemoteBridges': settings['fetchRemoteBridges']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
    });
  }

  //Eager fetch, when up to date settings are required
  Future<TorSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(UpdateTorSettingsFunc updateWithCurrent) async {
    final current = await fetchSettings();

    final oldJson = current.toJson();
    final newJson = updateWithCurrent(current).toJson();

    final db = ref.read(userDatabaseProvider);

    return db.transaction(() async {
      for (final MapEntry(:key, :value) in newJson.entries) {
        if (oldJson[key] != value) {
          await db.settingDao.updateSetting(key, _partitionKey, value);
        }
      }
    });
  }

  @override
  Stream<TorSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map((event) {
          return _deserializeSettings(event);
        });
  }
}

@Riverpod()
TorSettings torSettingsWithDefaults(Ref ref) {
  return ref.watch(
    torSettingsRepositoryProvider.select(
      (value) => value.value ?? TorSettings.withDefaults(),
    ),
  );
}
