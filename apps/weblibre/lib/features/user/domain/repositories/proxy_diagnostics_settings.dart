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
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

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

  /// The settings as they apply, read fresh: the stored ones with detailed
  /// logs at their hidden value while hidden.
  Future<ProxyDiagnosticsSettings> fetchEffectiveSettings() async {
    final stored = await fetchSettings();
    final general = await ref
        .read(generalSettingsRepositoryProvider.notifier)
        .fetchSettings();
    return stored.effective(general.isFeatureShown);
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

    return await db.transaction(() async {
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

/// The diagnostics settings as stored, for the screens that edit them.
@Riverpod(keepAlive: true)
ProxyDiagnosticsSettings storedProxyDiagnosticsSettings(Ref ref) {
  return ref.watch(
    proxyDiagnosticsSettingsRepositoryProvider.select(
      (value) => value.value ?? ProxyDiagnosticsSettings.withDefaults(),
    ),
  );
}

/// The diagnostics settings as they apply
/// ([ProxyDiagnosticsSettings.effective]).
@Riverpod(keepAlive: true)
ProxyDiagnosticsSettings proxyDiagnosticsSettingsWithDefaults(Ref ref) {
  final shown = ref.watch(shownFeaturesProvider);
  return ref
      .watch(storedProxyDiagnosticsSettingsProvider)
      .effective(shown.contains);
}

/// The log level in force once the diagnostics and general settings have
/// loaded, null before.
@Riverpod(keepAlive: true)
ProxyLogLevel? loadedProxyLogLevel(Ref ref) {
  final stored = ref.watch(
    proxyDiagnosticsSettingsRepositoryProvider.select((value) => value.value),
  );
  final generalLoaded = ref.watch(
    generalSettingsRepositoryProvider.select((value) => value.hasValue),
  );
  if (stored == null || !generalLoaded) return null;

  final shown = ref.watch(shownFeaturesProvider);
  return stored.effective(shown.contains).logLevel;
}
