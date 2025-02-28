import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_filter.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Stream<List<FeedData>> feedList(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeeds();
}

@Riverpod()
Stream<List<FeedArticle>> feedArticleList(Ref ref, FeedFilter filter) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeedArticles(filter);
}

@Riverpod()
Stream<FeedArticle?> feedArticle(Ref ref, String articleId) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchArticle(articleId);
}

@Riverpod()
Raw<Stream<Map<String, int>>> _unreadArticleCount(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchUnreadFeedArticleCount();
}

@Riverpod()
Stream<int?> unreadFeedArticleCount(Ref ref, Uri feedId) {
  final stream = ref.watch(_unreadArticleCountProvider);
  return stream.map((counts) => counts[feedId.toString()]);
}
