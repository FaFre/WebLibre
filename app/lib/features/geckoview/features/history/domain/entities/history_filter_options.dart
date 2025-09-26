import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/data/database/converters/date_time_range.dart';

part 'history_filter_options.g.dart';

@JsonSerializable()
@CopyWith()
class HistoryFilterOptions with FastEquatable {
  @DateTimeRangeConverter()
  final DateTimeRange<DateTime>? dateRange;
  final Set<VisitType> visitTypes;

  HistoryFilterOptions({required this.dateRange, required this.visitTypes});

  HistoryFilterOptions.withDefaults()
    : this(dateRange: null, visitTypes: {VisitType.link});

  @override
  List<Object?> get hashParameters => [dateRange, visitTypes];

  factory HistoryFilterOptions.fromJson(Map<String, dynamic> json) =>
      _$HistoryFilterOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryFilterOptionsToJson(this);
}
