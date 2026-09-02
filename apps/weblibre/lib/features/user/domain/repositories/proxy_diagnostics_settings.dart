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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'proxy_diagnostics_settings.g.dart';

typedef UpdateProxyDiagnosticsSettingsFunc =
    ProxyDiagnosticsSettings Function(ProxyDiagnosticsSettings currentSettings);

@Riverpod(keepAlive: true)
class ProxyDiagnosticsSettingsRepository
    extends _$ProxyDiagnosticsSettingsRepository {
  final _partitionKey = 'proxy_diagnostics';

  ProxyDiagnosticsSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final settings = Map.fromEntries(entries);

    final db = ref.read(userDatabaseProvider);

    // Every key of the model has to be read back here by hand. One added above
    // and forgotten below writes fine and then silently reads as its default.
    return ProxyDiagnosticsSettings.fromJson({
      'logLevel': settings['logLevel']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
    });
  }

  //Eager fetch, when up to date settings are required
  Future<ProxyDiagnosticsSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(
    UpdateProxyDiagnosticsSettingsFunc updateWithCurrent,
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

  Future<void> setLogLevel(ProxyLogLevel logLevel) {
    return updateSettings((current) => current.copyWith(logLevel: logLevel));
  }

  @override
  Stream<ProxyDiagnosticsSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map(_deserializeSettings);
  }
}

@Riverpod(keepAlive: true)
ProxyDiagnosticsSettings proxyDiagnosticsSettingsWithDefaults(Ref ref) {
  return ref.watch(
    proxyDiagnosticsSettingsRepositoryProvider.select(
      (value) => value.value ?? ProxyDiagnosticsSettings.withDefaults(),
    ),
  );
}
