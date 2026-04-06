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
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class IconDataJsonConverter
    implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataJsonConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'] as int,
      fontFamily: json['fontFamily'] as String,
      fontPackage: json['fontPackage'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson(IconData iconData) {
    return <String, dynamic>{
      'codePoint': iconData.codePoint,
      'fontFamily': iconData.fontFamily,
      'fontPackage': iconData.fontPackage,
    };
  }
}

class IconDataTypeConverter implements TypeConverter<IconData, String> {
  const IconDataTypeConverter();

  @override
  IconData fromSql(String fromDb) {
    final json = jsonDecode(fromDb) as Map<String, dynamic>;
    return const IconDataJsonConverter().fromJson(json);
  }

  @override
  String toSql(IconData value) {
    assert(
      value.fontFamily != null,
      'Font family must be provided to identify icon',
    );

    return jsonEncode(const IconDataJsonConverter().toJson(value));
  }
}
