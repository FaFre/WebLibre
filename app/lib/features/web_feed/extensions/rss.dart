import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_category.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:rss_dart/domain/dublin_core/dublin_core.dart';

extension ParseDublinCategory on DublinCore {
  List<FeedCategory> toFeedCategories() {
    return subjects
        .where((subject) => subject.isNotEmpty)
        .map((subject) => FeedCategory(id: subject))
        .toList();
  }
}

extension ParseRssCategory on List<RssCategory> {
  List<FeedCategory> toFeedCategories() {
    return where((category) => category.value.isNotEmpty)
        .map(
          (category) =>
              FeedCategory(id: '${category.domain} ${category.value}'.trim()),
        )
        .toList();
  }
}
