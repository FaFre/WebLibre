import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/models/feed_link.dart';
import 'package:lensai/features/web_feed/extensions/atom.dart';
import 'package:nullability/nullability.dart';

extension FeedArticleX on FeedArticle {
  String get displayTitle =>
      title ??
      links
          ?.getRelation(FeedLinkRelation.alternate)
          .mapNotNull(
            (link) => link.title.whenNotEmpty ?? link.uri.toString(),
          ) ??
      'Unnamed Article';
}
