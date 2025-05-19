import 'package:weblibre/features/web_feed/data/models/feed_article.dart';

class FeedArticleQueryResult extends FeedArticle {
  final String? titleHighlight;
  final String? summarySnippet;
  final String? contentSnippet;

  final double weightedRank;

  FeedArticleQueryResult({
    required super.id,
    required super.feedId,
    required super.fetched,
    required this.weightedRank,
    required super.created,
    required super.updated,
    required super.lastRead,
    required super.title,
    required super.authors,
    required super.tags,
    required super.links,
    required super.summaryHtml,
    required super.summaryMarkdown,
    required super.summaryPlain,
    required super.contentHtml,
    required super.contentMarkdown,
    required super.contentPlain,
    required super.icon,
    this.titleHighlight,
    this.summarySnippet,
    this.contentSnippet,
  });

  @override
  List<Object?> get hashParameters => [
    ...super.hashParameters,
    weightedRank,
    summarySnippet,
    contentSnippet,
    titleHighlight,
  ];
}
