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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:json_annotation/json_annotation.dart';

final Map<String, IconData> _mdiIconsByName = Map.unmodifiable({
  for (final iconData in MdiIcons.values)
    if (iconData.mdiMetadata case final metadata?) metadata.name: iconData,
});

final Map<int, IconData> _mdiIconsByCodePoint = Map.unmodifiable({
  for (final iconData in MdiIcons.values) iconData.codePoint: iconData,
});

class IconDataJsonConverter
    implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataJsonConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    if (json['name'] case final String name) {
      final iconData = _mdiIconsByName[name];
      if (iconData != null) {
        return iconData;
      }
    }

    final codePoint = json['codePoint'];
    if (codePoint is int) {
      final iconData = _mdiIconsByCodePoint[codePoint];
      if (iconData != null) {
        return iconData;
      }
    }

    throw FormatException('Unknown MDI icon data: $json');
  }

  @override
  Map<String, dynamic> toJson(IconData iconData) {
    final metadata = iconData.mdiMetadata;
    if (metadata == null) {
      throw ArgumentError.value(
        iconData,
        'iconData',
        'Icon is not an MDI icon',
      );
    }

    return <String, dynamic>{'name': metadata.name};
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
    return jsonEncode(const IconDataJsonConverter().toJson(value));
  }
}
