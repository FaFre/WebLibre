import 'package:collection/collection.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_author.dart';
import 'package:lensai/features/web_feed/data/models/feed_category.dart';
import 'package:lensai/features/web_feed/data/models/feed_link.dart';
import 'package:rss_dart/dart_rss.dart';

extension ParseAtomLink on List<AtomLink> {
  List<FeedLink> toFeedLinks() {
    return map((link) {
      final uri = link.href.mapNotNull(Uri.tryParse);
      if (uri == null) {
        return null;
      }

      final relation = link.rel.mapNotNull(
        (rel) => FeedLinkRelation.values.firstWhereOrNull((e) => e.name == rel),
      );

      return FeedLink(
        uri: uri,
        relation: relation,
        title: link.title.whenNotEmpty,
      );
    }).nonNulls.toList();
  }
}

extension SelectFeedLink on List<FeedLink> {
  FeedLink? getRelation(FeedLinkRelation relation) {
    return firstWhereOrNull((link) => link.relation == relation);
  }
}

extension ParseAtomCategory on List<AtomCategory> {
  List<FeedCategory> toFeedCategories() {
    return where((category) => category.term.isNotEmpty)
        .map(
          (category) => FeedCategory(
            id: category.term!,
            title: category.label.whenNotEmpty,
          ),
        )
        .toList();
  }
}

extension ParseAtomPerson on List<AtomPerson> {
  List<FeedAuthor> toFeedAuthors() {
    return where(
          (author) =>
              author.name.whenNotEmpty != null ||
              author.email.whenNotEmpty != null,
        )
        .map(
          (author) => FeedAuthor(
            name: author.name.whenNotEmpty,
            email: author.email.whenNotEmpty,
          ),
        )
        .toList();
  }
}
