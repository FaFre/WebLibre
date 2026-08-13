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
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'proxy_routing_settings.g.dart';

typedef UpdateProxyRoutingSettingsFunc =
    ProxyRoutingSettings Function(ProxyRoutingSettings currentSettings);

@Riverpod(keepAlive: true)
class ProxyRoutingSettingsRepository extends _$ProxyRoutingSettingsRepository {
  final _partitionKey = 'proxy_routing';

  ProxyRoutingSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final settings = Map.fromEntries(entries);

    final db = ref.read(userDatabaseProvider);

    return ProxyRoutingSettings.fromJson({
      'regularTabsMode': settings['regularTabsMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'regularTabsProxyConnectionId': settings['regularTabsProxyConnectionId']
          ?.readAs(DriftSqlType.string, db.typeMapping),
      'privateTabsProxyConnectionId': settings['privateTabsProxyConnectionId']
          ?.readAs(DriftSqlType.string, db.typeMapping),
      // Stored as a JSON document in a TEXT column (the setting DAO encodes
      // maps on write), so it has to be decoded before `fromJson`, which
      // expects the parsed map. A key added here and not below writes fine and
      // never reads back.
      'isolationContextRoutes': _decodeJsonMapSetting(
        settings['isolationContextRoutes']?.readAs(
          DriftSqlType.string,
          db.typeMapping,
        ),
      ),
    });
  }

  /// Decode a settings row holding a JSON object, or null if it does not.
  ///
  /// Every other value in this partition is a scalar the type mapping can be
  /// trusted with; this one is free-form text that only *this* app is supposed
  /// to write. A truncated or hand-edited row would otherwise throw out of
  /// `jsonDecode` — or out of the generated `fromJson` cast, when it decodes to
  /// something that is not an object — before [parseIsolationContextRoutes]
  /// gets its chance to drop bad entries. That throw lands in the settings
  /// stream that gates the routing snapshot, which then never resolves and
  /// leaves the extension blocking every request. Falling back to no routes
  /// costs the user their isolation overrides; throwing costs them the browser.
  Map<String, dynamic>? _decodeJsonMapSetting(String? raw) {
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      logger.w('Discarding a routing settings value that is not a JSON object');
    } catch (error, stackTrace) {
      logger.w(
        'Discarding an unreadable routing settings value',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return null;
  }

  //Eager fetch, when up to date settings are required
  Future<ProxyRoutingSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(
    UpdateProxyRoutingSettingsFunc updateWithCurrent,
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

  /// Route the isolation group [isolationContextId] through
  /// [proxyConnectionId], or connect it directly when that is null.
  ///
  /// Overrides whatever the group's container would route it through; use
  /// [clearIsolationContextRoute] to go back to following the container.
  Future<void> setIsolationContextRoute(
    String isolationContextId,
    ProxyConnectionId? proxyConnectionId,
  ) {
    return updateSettings(
      (current) => current.copyWith(
        isolationContextRoutes: {
          ...current.isolationContextRoutes,
          isolationContextId: proxyConnectionId,
        },
      ),
    );
  }

  /// Drop [isolationContextId]'s override so the group follows its container
  /// again (or the global route, when it has no container).
  Future<void> clearIsolationContextRoute(String isolationContextId) {
    return updateSettings((current) {
      if (!current.isolationContextRoutes.containsKey(isolationContextId)) {
        return current;
      }

      return current.copyWith(
        isolationContextRoutes: {...current.isolationContextRoutes}
          ..remove(isolationContextId),
      );
    });
  }

  /// Carry [from]'s override over to [to].
  ///
  /// Duplicating an isolated tab mints a fresh isolation context; without this
  /// the copy would silently fall back to its container's route.
  Future<void> copyIsolationContextRoute(String from, String to) {
    return updateSettings((current) {
      if (!current.isolationContextRoutes.containsKey(from)) {
        return current;
      }

      return current.copyWith(
        isolationContextRoutes: {
          ...current.isolationContextRoutes,
          to: current.isolationContextRoutes[from],
        },
      );
    });
  }

  @override
  Stream<ProxyRoutingSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map(_deserializeSettings);
  }
}

@Riverpod(keepAlive: true)
ProxyRoutingSettings proxyRoutingSettingsWithDefaults(Ref ref) {
  return ref.watch(
    proxyRoutingSettingsRepositoryProvider.select(
      (value) => value.value ?? ProxyRoutingSettings.withDefaults(),
    ),
  );
}
