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
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'general_settings.g.dart';

typedef UpdateGeneralSettingsFunc =
    GeneralSettings Function(GeneralSettings currentSettings);

@Riverpod(keepAlive: true)
class GeneralSettingsRepository extends _$GeneralSettingsRepository {
  final _partitionKey = 'general';

  GeneralSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final settings = Map.fromEntries(entries);

    final db = ref.read(userDatabaseProvider);

    return GeneralSettings.fromJson({
      'themeMode': settings['themeMode']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'enableReadability': settings['enableReadability']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'enforceReadability': settings['enforceReadability']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'deleteBrowsingDataOnQuit': settings['deleteBrowsingDataOnQuit']
          ?.readAs(DriftSqlType.string, db.typeMapping)
          .mapNotNull(jsonDecode),
      'defaultSearchProvider': settings['defaultSearchProvider']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'defaultSearchSuggestionsProvider':
          settings['defaultSearchSuggestionsProvider']?.readAs(
            DriftSqlType.string,
            db.typeMapping,
          ),
      'createChildTabsOption': settings['createChildTabsOption']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'showExtensionShortcut': settings['showExtensionShortcut']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'enableLocalAiFeatures': settings['enableLocalAiFeatures']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'defaultCreateTabType': settings['defaultCreateTabType']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'tabIntentOpenSetting': settings['tabIntentOpenSetting']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'autoHideTabBar': settings['autoHideTabBar']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'tabBarSwipeAction': settings['tabBarSwipeAction']?.readAs(
        DriftSqlType.string,
        db.typeMapping,
      ),
      'historyAutoCleanInterval': settings['historyAutoCleanInterval']?.readAs(
        DriftSqlType.int,
        db.typeMapping,
      ),
    });
  }

  //Eager fetch, when up to date settings are required
  Future<GeneralSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(
    UpdateGeneralSettingsFunc updateWithCurrent,
  ) async {
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
  Stream<GeneralSettings> build() {
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
GeneralSettings generalSettingsWithDefaults(Ref ref) {
  return ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.value ?? GeneralSettings.withDefaults(),
    ),
  );
}
