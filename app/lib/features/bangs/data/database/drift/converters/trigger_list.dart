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

class TriggerListConverter extends TypeConverter<Set<String>?, String?> {
  const TriggerListConverter();

  @override
  Set<String>? fromSql(String? fromDb) {
    return fromDb.mapNotNull(
      (value) => (jsonDecode(value) as List).cast<String>().toSet(),
    );
  }

  @override
  String? toSql(Set<String>? value) {
    return value.mapNotNull((value) => jsonEncode(value.toList()));
  }
}
