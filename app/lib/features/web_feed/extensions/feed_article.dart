import 'package:collection/collection.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/models/feed_link.dart';

extension FeedArticleX on FeedArticle {
  String get displayTitle =>
      title ??
      links
          ?.firstWhereOrNull(
            (link) => link.relation == FeedLinkRelation.alternate,
          )
          .mapNotNull(
            (link) => link.title.whenNotEmpty ?? link.uri.toString(),
          ) ??
      'Unnamed Article';
}
