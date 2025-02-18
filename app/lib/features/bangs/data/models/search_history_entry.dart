import 'package:fast_equatable/fast_equatable.dart';

class SearchHistoryEntry with FastEquatable {
  final String searchQuery;
  final String trigger;
  final DateTime searchDate;

  SearchHistoryEntry({
    required this.searchQuery,
    required this.trigger,
    required this.searchDate,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [searchQuery, trigger, searchDate];
}
