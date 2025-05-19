import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:weblibre/features/web_feed/domain/services/feed_reader.dart';

part 'fetch_articles.g.dart';

@Riverpod()
class FetchArticlesController extends _$FetchArticlesController {
  Future<void> fetchAllArticles() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final feeds =
          await ref.read(feedRepositoryProvider.notifier).getAllFeeds();

      await Future.wait(
        feeds.map((feed) async {
          try {
            final result = await ref
                .read(feedReaderProvider.notifier)
                .parseFeed(feed.url);

            await ref
                .read(feedRepositoryProvider.notifier)
                .upsertArticles(result.articleData);

            await ref
                .read(feedRepositoryProvider.notifier)
                .touchFeedFetched(feed.url);
          } catch (e, s) {
            logger.e(
              'Failed fetching feed ${feed.url}',
              error: e,
              stackTrace: s,
            );
          }
        }).toList(),
      );
    });
  }

  Future<void> fetchFeedArticles(Uri uri) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(feedReaderProvider.notifier).parseFeed(uri);

      await ref
          .read(feedRepositoryProvider.notifier)
          .upsertArticles(result.articleData);

      await ref.read(feedRepositoryProvider.notifier).touchFeedFetched(uri);
    });
  }

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }
}
