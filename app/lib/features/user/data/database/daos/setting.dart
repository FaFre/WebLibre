import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/user/data/database/database.dart';

part 'setting.g.dart';

@DriftAccessor()
class SettingDao extends DatabaseAccessor<UserDatabase> with _$SettingDaoMixin {
  SettingDao(super.attachedDatabase);

  Future<int> updateSetting(String key, String? partitionKey, Object? value) {
    final normalizedValue = (value is Iterable) ? jsonEncode(value) : value;

    final driftvalue = normalizedValue.mapNotNull(
      (normalizedValue) => DriftAny(normalizedValue),
    );

    return db.setting.insertOne(
      SettingCompanion.insert(
        key: key,
        partitionKey: Value(partitionKey),
        value: Value(driftvalue),
      ),
      onConflict: DoUpdate((old) => SettingCompanion(value: Value(driftvalue))),
    );
  }

  Selectable<MapEntry<String, DriftAny?>> getAllSettingsOfPartitionKey(
    String? partitionKey,
  ) {
    final query =
        db.setting.select()
          ..where((r) => r.partitionKey.equalsNullable(partitionKey));

    return query.map((row) => MapEntry(row.key, row.value));
  }
}
