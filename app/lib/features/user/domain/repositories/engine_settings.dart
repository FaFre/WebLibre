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
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'engine_settings.g.dart';

typedef UpdateEngineSettingsFunc =
    EngineSettings Function(EngineSettings currentSettings);

@Riverpod(keepAlive: true)
class EngineSettingsRepository extends _$EngineSettingsRepository {
  final _partitionKey = 'engine';

  EngineSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final db = ref.read(userDatabaseProvider);
    final settings = Map.fromEntries(entries);

    return EngineSettings.fromJson({
      'incognitoMode': settings['incognitoMode']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'javascriptEnabled': settings['javascriptEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'trackingProtectionPolicy': settings['trackingProtectionPolicy']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'httpsOnlyMode': settings['httpsOnlyMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'globalPrivacyControlEnabled': settings['globalPrivacyControlEnabled']
          ?.readAs(DriftSqlType.bool, db.typeMapping),
      'cookieBannerHandlingMode': settings['cookieBannerHandlingMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'cookieBannerHandlingModePrivateBrowsing':
          settings['cookieBannerHandlingModePrivateBrowsing']?.readAs(
            DriftSqlType.string,
            db.typeMapping,
          ),
      'cookieBannerHandlingGlobalRules':
          settings['cookieBannerHandlingGlobalRules']?.readAs(
            DriftSqlType.bool,
            db.typeMapping,
          ),
      'cookieBannerHandlingGlobalRulesSubFrames':
          settings['cookieBannerHandlingGlobalRulesSubFrames']?.readAs(
            DriftSqlType.bool,
            db.typeMapping,
          ),
      'webContentIsolationStrategy': settings['webContentIsolationStrategy']
          ?.readAs(DriftSqlType.string, db.typeMapping),
      'userAgent': settings['userAgent']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'queryParameterStripping': settings['queryParameterStripping']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'bounceTrackingProtectionMode': settings['bounceTrackingProtectionMode']
          ?.readAs(DriftSqlType.string, db.typeMapping),
      'enterpriseRootsEnabled': settings['enterpriseRootsEnabled']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'addonCollection': settings['addonCollection']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohSettingsMode': settings['dohSettingsMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohProviderUrl': settings['dohProviderUrl']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohDefaultProviderUrl': settings['dohDefaultProviderUrl']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'dohExceptionsList': settings['dohExceptionsList']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
      'fingerprintingProtectionOverrides':
          settings['fingerprintingProtectionOverrides']?.readAs(
            DriftSqlType.string,
            db.typeMapping,
          ),
      'enablePdfJs': settings['enablePdfJs']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
    });
  }

  Future<void> updateSettings(
    UpdateEngineSettingsFunc updateWithCurrent,
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

  Future<EngineSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  @override
  Stream<EngineSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map((entries) {
          return _deserializeSettings(entries);
        });
  }
}

@Riverpod()
EngineSettings engineSettingsWithDefaults(Ref ref) {
  return ref.watch(
    engineSettingsRepositoryProvider.select(
      (value) => value.value ?? EngineSettings.withDefaults(),
    ),
  );
}
