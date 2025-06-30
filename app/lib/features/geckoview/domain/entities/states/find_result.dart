import 'package:fast_equatable/fast_equatable.dart';

class FindResultState with FastEquatable {
  final String? lastSearchText;

  final int activeMatchOrdinal;
  final int numberOfMatches;
  final bool isDoneCounting;

  bool get hasMatches => numberOfMatches > 0;

  FindResultState({
    required this.lastSearchText,
    required this.activeMatchOrdinal,
    required this.numberOfMatches,
    required this.isDoneCounting,
  });

  factory FindResultState.$default() => FindResultState(
    lastSearchText: null,
    activeMatchOrdinal: -1,
    numberOfMatches: 0,
    isDoneCounting: false,
  );

  @override
  List<Object?> get hashParameters => [
    lastSearchText,
    activeMatchOrdinal,
    numberOfMatches,
    isDoneCounting,
  ];
}
