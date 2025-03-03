import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_repository.g.dart';

@Riverpod(keepAlive: true)
class FeedRepository extends _$FeedRepository {
  Future<List<FeedData>> getAllFeeds() {
    return ref.read(feedDatabaseProvider).feedDao.getFeeds().get();
  }

  Future<void> touchFeedFetched(Uri feedId) {
    return ref
        .read(feedDatabaseProvider)
        .feedDao
        .updateFeedFetched(feedId, DateTime.now());
  }

  Future<void> upsertFeed(FeedData feedData) {
    return ref.read(feedDatabaseProvider).feedDao.upsertFeed(feedData);
  }

  Future<void> upsertArticles(List<FeedArticle> articles) {
    return ref.read(feedDatabaseProvider).articleDao.upsertArticles(articles);
  }

  Future<int> deleteFeed(Uri feedId) {
    return ref.read(feedDatabaseProvider).feedDao.deleteFeed(feedId);
  }

  Future<void> touchArticleRead(String articleId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .updateArticleRead(articleId, DateTime.now());
  }

  Future<void> unsetArticleRead(String articleId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .updateArticleRead(articleId, null);
  }

  Stream<List<FeedData>> watchFeeds() {
    return ref.read(feedDatabaseProvider).feedDao.getFeeds().watch();
  }

  Stream<FeedData?> watchFeed(Uri feedId) {
    return ref
        .read(feedDatabaseProvider)
        .feedDao
        .getFeed(feedId)
        .watchSingleOrNull();
  }

  Stream<List<FeedArticle>> watchFeedArticles(Uri? feedId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .getFeedArticles(feedId)
        .watch();
  }

  Stream<FeedArticle?> watchArticle(String articleId) {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .getArticleById(articleId)
        .watchSingleOrNull();
  }

  Stream<Map<String, int>> watchUnreadFeedArticleCount() {
    return ref
        .read(feedDatabaseProvider)
        .articleDao
        .getUnreadArticleCount()
        .watch()
        .map(
          (results) =>
              Map.fromEntries(results.map((e) => MapEntry(e.$1, e.$2))),
        );
  }

  @override
  void build() {}
}
