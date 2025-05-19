import 'package:nullability/nullability.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';
import 'package:weblibre/features/web_feed/extensions/atom.dart';

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
