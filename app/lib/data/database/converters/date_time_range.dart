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
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class DateTimeRangeConverter
    implements JsonConverter<DateTimeRange?, Map<String, dynamic>?> {
  const DateTimeRangeConverter();

  @override
  DateTimeRange? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return DateTimeRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  @override
  Map<String, dynamic>? toJson(DateTimeRange? dateTimeRange) {
    if (dateTimeRange == null) return null;

    return {
      'start': dateTimeRange.start.toIso8601String(),
      'end': dateTimeRange.end.toIso8601String(),
    };
  }
}
