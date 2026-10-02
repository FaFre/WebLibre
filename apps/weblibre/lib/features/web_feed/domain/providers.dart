/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'dart:async';

import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/data/models/feed_parse_result.dart';
import 'package:weblibre/features/web_feed/data/providers.dart';
import 'package:weblibre/features/web_feed/domain/providers/article_filter.dart';
import 'package:weblibre/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:weblibre/features/web_feed/domain/services/feed_reader.dart';

part 'providers.g.dart';

/// How long typing has to pause before a feed search runs.
const _searchDebounce = Duration(milliseconds: 150);

@Riverpod()
class ArticleSearch extends _$ArticleSearch {
  late StreamController<List<FeedArticleSummary>> _streamController;
  Timer? _pendingSearch;

  /// The query whose results are wanted: the one asked for last.
  String? _query;

  /// Searches for [input] once typing pauses.
  ///
  /// Asking for the current query again does nothing — a search field reports
  /// caret and selection moves as changes too. Results of a query that a newer
  /// one replaced are dropped, so a slow query cannot overwrite a later one.
  void search(
    String input, {
    int snippetLength = 120,
    int maxResults = 25,
    String matchPrefix = '***',
    String matchSuffix = '***',
    String ellipsis = '…',
  }) {
    if (input == _query) {
      return;
    }

    _query = input;
    _pendingSearch?.cancel();
    if (input.isEmpty) {
      return;
    }

    _pendingSearch = Timer(_searchDebounce, () async {
      try {
        final results = await ref
            .read(feedDatabaseProvider)
            .articleDao
            .queryArticles(
              matchPrefix: matchPrefix,
              matchSuffix: matchSuffix,
              ellipsis: ellipsis,
              snippetLength: snippetLength,
              searchString: input,
              feedId: feedId,
              limit: maxResults,
            )
            .get();

        if (input == _query && !_streamController.isClosed) {
          _streamController.add(results);
        }
      } catch (error, stackTrace) {
        logger.e(
          'Error searching feed articles',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Stream<List<FeedArticleSummary>> build(Uri? feedId) {
    _streamController = StreamController();

    ref.onDispose(() async {
      _pendingSearch?.cancel();
      await _streamController.close();
    });

    return ConcatStream([Stream.value([]), _streamController.stream]);
  }
}

@Riverpod()
Stream<List<FeedData>> feedList(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeeds();
}

@Riverpod()
Stream<FeedData?> feedData(Ref ref, Uri? feedId) {
  final repository = ref.watch(feedRepositoryProvider.notifier);

  if (feedId == null) {
    return Stream.value(null);
  }

  return repository.watchFeed(feedId);
}

@Riverpod()
Stream<List<FeedArticleListEntry>> feedArticleList(Ref ref, Uri? feedId) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeedArticles(feedId);
}

/// The newest [count] articles across all feeds, limited in the query rather
/// than cut from the whole list: the stream re-runs on every write to the
/// article table.
@Riverpod()
Stream<List<FeedArticleListEntry>> recentFeedArticles(Ref ref, int count) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchFeedArticles(null, limit: count);
}

@Riverpod()
class FilteredArticleList extends _$FilteredArticleList {
  bool _hasSearch = false;

  void search(String input) {
    if (input.isNotEmpty) {
      if (!_hasSearch) {
        _hasSearch = true;
        ref.invalidateSelf();
      }

      ref.read(articleSearchProvider(feedId).notifier).search(input);
    } else if (_hasSearch) {
      _hasSearch = false;
      ref.invalidateSelf();
    }
  }

  @override
  AsyncValue<List<FeedArticleSummary>> build(Uri? feedId) {
    final filterTags = ref.watch(articleFilterProvider);

    final articlesAsync = _hasSearch
        ? ref.watch(articleSearchProvider(feedId))
        : ref.watch(feedArticleListProvider(feedId));

    return articlesAsync.whenData((articles) {
      if (filterTags.isNotEmpty) {
        return articles.where((article) {
          final tags = article.tags?.map((tag) => tag.id).toSet();

          final authors = article.authors
              ?.map((author) => author.name.whenNotEmpty)
              .nonNulls
              .toSet();

          return filterTags.every(
            (filter) =>
                (tags?.contains(filter) ?? false) ||
                (authors?.contains(filter) ?? false),
          );
        }).toList();
      }

      return articles;
    });
  }
}

@Riverpod()
Stream<FeedArticle?> feedArticle(
  Ref ref,
  String articleId, {
  required bool updateReadDate,
}) async* {
  final repository = ref.watch(feedRepositoryProvider.notifier);

  if (updateReadDate) {
    await repository.touchArticleRead(articleId);
  }

  yield* repository.watchArticle(articleId);
}

@Riverpod()
Raw<Stream<Map<String, int>>> unreadArticleCount(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider.notifier);
  return repository.watchUnreadFeedArticleCount();
}

@Riverpod()
Stream<int?> unreadFeedArticleCount(Ref ref, Uri feedId) {
  final stream = ref.watch(unreadArticleCountProvider);
  return stream.map((counts) => counts[feedId.toString()]);
}

@Riverpod()
Future<FeedParseResult> fetchWebFeed(Ref ref, Uri url) {
  return ref.read(feedReaderProvider.notifier).parseFeed(url);
}
