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
