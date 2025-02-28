import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_filter.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_repository.g.dart';

@Riverpod(keepAlive: true)
class FeedRepository extends _$FeedRepository {
  Future<List<FeedData>> getAllFeeds() {
    return ref.read(feedDatabaseProvider).feedDao.getFeeds().get();
  }

  Future<void> touchFeedFetched(Uri url) {
    return ref
        .read(feedDatabaseProvider)
        .feedDao
        .updateFeedFetched(url, DateTime.now());
  }

  Future<void> upsertFeed(FeedData feedData) {
    return ref.read(feedDatabaseProvider).feedDao.upsertFeed(feedData);
  }

  Future<void> upsertArticles(List<FeedArticle> articles) {
    return ref.read(feedDatabaseProvider).articleDao.upsertArticles(articles);
  }

  Future<int> deleteFeed(Uri url) {
    return ref.read(feedDatabaseProvider).feedDao.deleteFeed(url);
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

  Stream<List<FeedArticle>> watchFeedArticles(
    FeedFilter filter, {
    int snippetLength = 120,
    String matchPrefix = '***',
    String matchSuffix = '***',
    String ellipsis = '…',
  }) {
    final stream =
        filter.query.isNotEmpty
            ? ref
                .read(feedDatabaseProvider)
                .articleDao
                .queryArticles(
                  matchPrefix: matchPrefix,
                  matchSuffix: matchSuffix,
                  ellipsis: ellipsis,
                  snippetLength: snippetLength,
                  searchString: filter.query!,
                  feedId: filter.feedId,
                )
                .watch()
            : ref
                .read(feedDatabaseProvider)
                .articleDao
                .getFeedArticles(filter.feedId)
                .watch();

    if (filter.tags.isNotEmpty) {
      return stream.map(
        (articles) =>
            articles
                .where(
                  (article) =>
                      article.tags?.toSet().containsAll(filter.tags!) ?? false,
                )
                .toList(),
      );
    } else {
      return stream;
    }
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
