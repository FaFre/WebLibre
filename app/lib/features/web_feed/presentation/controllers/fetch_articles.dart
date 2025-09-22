/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:weblibre/features/web_feed/domain/services/feed_reader.dart';

part 'fetch_articles.g.dart';

@Riverpod(keepAlive: true)
class FetchArticlesController extends _$FetchArticlesController {
  Future<void> fetchAllArticles() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final feeds = await ref
          .read(feedRepositoryProvider.notifier)
          .getAllFeeds();

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
