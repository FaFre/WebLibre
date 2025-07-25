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
    final query = db.setting.select()
      ..where((r) => r.partitionKey.equalsNullable(partitionKey));

    return query.map((row) => MapEntry(row.key, row.value));
  }
}
