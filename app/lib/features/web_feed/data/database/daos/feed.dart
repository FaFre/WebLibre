import 'package:drift/drift.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';

part 'feed.g.dart';

@DriftAccessor()
class FeedDao extends DatabaseAccessor<FeedDatabase> with _$FeedDaoMixin {
  FeedDao(super.attachedDatabase);

  Selectable<FeedData> getFeeds() {
    return db.feed.select();
  }

  Future<int> updateFeedFetched(Uri url, DateTime fetched) {
    final statement =
        db.feed.update()..where((feed) => feed.url.equalsValue(url));

    return statement.write(FeedCompanion(lastFetched: Value(fetched)));
  }

  Future<int> deleteFeed(Uri url) {
    return db.feed.deleteWhere((feed) => feed.url.equals(url.toString()));
  }

  Future<int> upsertFeed(FeedData feedData) {
    return db.feed.insertOne(
      feedData,
      onConflict: DoUpdate((old) {
        return FeedCompanion(
          authors: Value(feedData.authors),
          title: Value(feedData.title),
          description: Value(feedData.description),
          tags: Value(feedData.tags),
        );
      }),
    );
  }
}
