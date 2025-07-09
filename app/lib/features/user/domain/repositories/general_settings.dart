import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
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
      'proxyPrivateTabsTor': settings['proxyPrivateTabsTor']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
      'showExtensionShortcut': settings['showExtensionShortcut']?.readAs(
        DriftSqlType.bool,
        db.typeMapping,
      ),
    });
  }

  //Eager fetch, when up to date settings are required
  Future<GeneralSettings> fetch() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(UpdateGeneralSettingsFunc updateWithCurrent) {
    final oldJson = state.toJson();
    final newJson = updateWithCurrent(state).toJson();

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
  GeneralSettings build() {
    final db = ref.watch(userDatabaseProvider);

    final watchSub = db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .listen((event) {
          state = _deserializeSettings(event);
        });

    ref.onDispose(() async {
      await watchSub.cancel();
    });

    return GeneralSettings.withDefaults();
  }
}
