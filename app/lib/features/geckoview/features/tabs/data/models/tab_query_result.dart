import 'package:fast_equatable/fast_equatable.dart';

class TabQueryResult with FastEquatable {
  final String id;

  final String? title;
  final Uri? cleanUrl;

  final String? url;
  final String? extractedContent;
  final String? fullContent;

  final double weightedRank;

  TabQueryResult({
    required this.id,
    required this.title,
    required this.url,
    required this.cleanUrl,
    this.extractedContent,
    this.fullContent,
    required this.weightedRank,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
    id,
    title,
    cleanUrl,
    url,
    extractedContent,
    fullContent,
    weightedRank,
  ];
}
