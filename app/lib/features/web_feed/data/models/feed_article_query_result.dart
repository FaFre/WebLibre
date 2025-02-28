import 'package:lensai/features/web_feed/data/models/feed_article.dart';

class FeedArticleQueryResult extends FeedArticle {
  final double weightedRank;

  FeedArticleQueryResult({
    required super.id,
    required super.feedId,
    required super.fetched,
    required this.weightedRank,
    super.created,
    super.updated,
    super.lastRead,
    super.title,
    super.authors,
    super.tags,
    super.links,
    super.summaryMarkdown,
    super.summaryPlain,
    super.contentMarkdown,
    super.contentPlain,
  });

  @override
  List<Object?> get hashParameters => [...super.hashParameters, weightedRank];
}
