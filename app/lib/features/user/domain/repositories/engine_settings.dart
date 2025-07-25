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

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'engine_settings.g.dart';

typedef UpdateEngineSettingsFunc =
    EngineSettings Function(EngineSettings currentSettings);

@Riverpod(keepAlive: true)
class EngineSettingsRepository extends _$EngineSettingsRepository {
  final _partitionKey = 'engine';

  Future<void> updateSettings(UpdateEngineSettingsFunc updateWithCurrent) {
    final oldJson = state.toJson();
    final newJson = updateWithCurrent(state).toJson();

    return ref.read(userDatabaseProvider).transaction(() async {
      for (final MapEntry(:key, :value) in newJson.entries) {
        if (oldJson[key] != value) {
          await ref
              .read(userDatabaseProvider)
              .settingDao
              .updateSetting(key, _partitionKey, value);
        }
      }
    });
  }

  @override
  EngineSettings build() {
    final db = ref.watch(userDatabaseProvider);

    final watchSub = db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .listen((entries) {
          final settings = Map.fromEntries(entries);

          state = EngineSettings.fromJson({
            'incognitoMode': settings['incognitoMode']?.readAs(
              DriftSqlType.bool,
              db.typeMapping,
            ),
            'javascriptEnabled': settings['javascriptEnabled']?.readAs(
              DriftSqlType.bool,
              db.typeMapping,
            ),
            'trackingProtectionPolicy': settings['trackingProtectionPolicy']
                ?.readAs(DriftSqlType.string, db.typeMapping),
            'httpsOnlyMode': settings['httpsOnlyMode']?.readAs(
              DriftSqlType.string,
              db.typeMapping,
            ),
            'globalPrivacyControlEnabled':
                settings['globalPrivacyControlEnabled']?.readAs(
                  DriftSqlType.bool,
                  db.typeMapping,
                ),
            'cookieBannerHandlingMode': settings['cookieBannerHandlingMode']
                ?.readAs(DriftSqlType.string, db.typeMapping),
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
            'webContentIsolationStrategy':
                settings['webContentIsolationStrategy']?.readAs(
                  DriftSqlType.string,
                  db.typeMapping,
                ),
            'userAgent': settings['userAgent']?.readAs(
              DriftSqlType.string,
              db.typeMapping,
            ),
          });
        });

    ref.onDispose(() async {
      await watchSub.cancel();
    });

    return EngineSettings.withDefaults();
  }
}
