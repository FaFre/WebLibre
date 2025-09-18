import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

part 'history_filter_options.g.dart';

@CopyWith()
class HistoryFilterOptions with FastEquatable {
  final DateTime? start;
  final DateTime? end;
  final Set<VisitType> visitTypes;

  HistoryFilterOptions({
    required this.start,
    required this.end,
    required this.visitTypes,
  });

  HistoryFilterOptions.withDefaults()
    : this(
        start: null,
        end: null,
        visitTypes: {VisitType.link, VisitType.typed},
      );

  @override
  List<Object?> get hashParameters => [start, end, visitTypes];
}
