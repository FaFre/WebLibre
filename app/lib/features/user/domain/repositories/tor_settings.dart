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
      'autoConfig': settings['autoConfig']?.readAs(
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
      (value) => value.valueOrNull ?? TorSettings.withDefaults(),
    ),
  );
}
