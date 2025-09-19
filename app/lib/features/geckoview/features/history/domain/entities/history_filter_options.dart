import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

part 'history_filter_options.g.dart';

@CopyWith()
class HistoryFilterOptions with FastEquatable {
  final DateTimeRange<DateTime>? dateRange;
  final Set<VisitType> visitTypes;

  HistoryFilterOptions({required this.dateRange, required this.visitTypes});

  HistoryFilterOptions.withDefaults()
    : this(dateRange: null, visitTypes: {VisitType.link, VisitType.typed});

  @override
  List<Object?> get hashParameters => [dateRange, visitTypes];
}
