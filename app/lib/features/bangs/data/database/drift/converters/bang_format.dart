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
import 'package:weblibre/features/bangs/data/models/bang.dart';

class BangFormatConverter extends TypeConverter<Set<BangFormat>?, String?> {
  const BangFormatConverter();

  @override
  Set<BangFormat>? fromSql(String? fromDb) {
    if (fromDb == null) {
      return null;
    }

    return Bang.decodeFormat(jsonDecode(fromDb) as List);
  }

  @override
  String? toSql(Set<BangFormat>? value) {
    if (value == null) {
      return null;
    }

    return jsonEncode(Bang.encodeFormat(value));
  }
}
