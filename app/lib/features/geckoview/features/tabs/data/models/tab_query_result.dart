class TabQueryResult {
  final String id;

  final String? title;
  final String? cleanUrl;

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
}
