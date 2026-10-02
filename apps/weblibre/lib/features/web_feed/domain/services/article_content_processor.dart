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
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/web_feed/data/database/daos/article.dart';
import 'package:weblibre/features/web_feed/data/providers.dart';

part 'article_content_processor.g.dart';

/// Converts a list of HTML documents, answering in the same order: `null` for
/// a document that failed to convert.
typedef HtmlConverter =
    Future<List<TurndownResults?>> Function(List<String> html);

/// How long one batch may take in the browser extension. A batch is bounded by
/// [ArticleContentProcessor.maxBatchArticles] and
/// [ArticleContentProcessor.maxBatchChars], so this is far beyond what one
/// should need; running out of it means the extension is stuck.
const _batchTimeout = Duration(seconds: 15);

@Riverpod(keepAlive: true)
class ArticleContentProcessorService extends _$ArticleContentProcessorService {
  @override
  void build() {
    final db = ref.watch(feedDatabaseProvider);

    final processor = ArticleContentProcessor(
      db.articleDao,
      (html) => GeckoBrowserExtensionService.turndownHtml(
        html,
        timeout: _batchTimeout,
      ),
    )..start();

    ref.onDispose(() async {
      await processor.dispose();
    });
  }
}

/// Fills in the markdown and plain text of feed articles from their HTML,
/// which only the browser extension can convert.
///
/// One drain runs at a time and takes the backlog in bounded batches: a feed
/// refresh inserts articles feed by feed, and each insert used to start
/// another conversion of the *whole* backlog, overlapping the ones still
/// running, in a single request that a large backlog could not finish before
/// it timed out — so it was sent again, and again.
///
/// Two kinds of failure are told apart. A document the extension cannot
/// convert fails the same way every time: it is not stored, and the article is
/// left alone until the next start. A request that fails — not answered in
/// time, the extension not listening yet — says nothing about its articles:
/// the drain backs off and tries again, taking the articles of the failed
/// request one at a time after any fresh work, so that a single document that
/// stalls the extension holds up nothing but itself.
class ArticleContentProcessor {
  /// The most articles converted in one request.
  static const maxBatchArticles = 10;

  /// The most HTML, in characters, converted in one request — unless a single
  /// article holds more on its own.
  static const maxBatchChars = 256 * 1024;

  final ArticleDao _dao;
  final HtmlConverter _convert;
  final Duration _initialRetryDelay;
  final Duration _maxRetryDelay;
  Duration _nextRetryDelay;

  StreamSubscription<List<String>>? _workSubscription;
  Timer? _retryTimer;
  bool _draining = false;
  bool _workArrived = false;
  bool _disposed = false;

  /// Articles with a document the extension failed to convert. Left alone
  /// until the next start rather than converted again with every drain.
  final _unconvertible = <String>{};

  /// Articles of requests that failed, retried one at a time in this order. A
  /// retry that fails again moves its article to the back.
  final _suspects = <String>{};

  ArticleContentProcessor(
    this._dao,
    this._convert, {
    Duration retryDelay = const Duration(seconds: 30),
    Duration maxRetryDelay = const Duration(minutes: 10),
  }) : _initialRetryDelay = retryDelay,
       _nextRetryDelay = retryDelay,
       _maxRetryDelay = maxRetryDelay;

  /// Whether a drain is running or waiting to retry.
  @visibleForTesting
  bool get isBusy => _draining || _retryTimer != null;

  /// Starts watching for articles to convert.
  void start() {
    _workSubscription = _dao.getUnprocessedArticleIds().watch().listen(
      (ids) {
        if (ids.any((id) => !_unconvertible.contains(id))) {
          _scheduleDrain();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error watching for unprocessed articles',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> dispose() async {
    _disposed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    await _workSubscription?.cancel();
  }

  void _scheduleDrain() {
    if (_disposed || _retryTimer != null) {
      // A pending retry picks the work up.
      return;
    }

    if (_draining) {
      _workArrived = true;
      return;
    }

    unawaited(_drain());
  }

  Future<void> _drain() async {
    _draining = true;
    try {
      do {
        _workArrived = false;

        while (!_disposed) {
          final articles = await _nextBatch();
          if (articles.isEmpty) {
            break;
          }

          if (!await _process(articles)) {
            _retryLater();
            return;
          }
        }
        // Articles written after the last read above came in as work while
        // the read was pending.
      } while (_workArrived && !_disposed);

      // Only a drain that got through everything ends the backing off: one
      // that converted fresh articles and then failed on a stalling document
      // again keeps waiting longer.
      _nextRetryDelay = _initialRetryDelay;
    } catch (error, stackTrace) {
      logger.e(
        'Error processing articles',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _draining = false;
    }
  }

  /// Fresh articles first, as many as fit into one batch; then one article of
  /// a request that failed, on its own.
  Future<List<ArticleHtml>> _nextBatch() async {
    final fresh = await _dao
        .getUnprocessedArticles(
          limit: maxBatchArticles,
          excluding: {..._unconvertible, ..._suspects},
        )
        .get();
    if (fresh.isNotEmpty) {
      return _fitToBatch(fresh);
    }

    while (_suspects.isNotEmpty) {
      final id = _suspects.first;
      final suspect = await _dao
          .getUnprocessedArticles(limit: 1, among: [id])
          .get();
      if (suspect.isNotEmpty) {
        return suspect;
      }

      // Converted or gone in the meantime.
      _suspects.remove(id);
    }

    return const [];
  }

  /// The leading [articles] that fit into one batch, and at least one.
  List<ArticleHtml> _fitToBatch(List<ArticleHtml> articles) {
    var chars = 0;
    var count = 0;
    for (final article in articles) {
      chars +=
          (article.contentHtml?.length ?? 0) +
          (article.summaryHtml?.length ?? 0);
      if (count > 0 && chars > maxBatchChars) {
        break;
      }
      count++;
    }

    return articles.sublist(0, count);
  }

  /// Converts and stores [articles]. Returns `false` when the request failed
  /// and the drain should back off.
  Future<bool> _process(List<ArticleHtml> articles) async {
    final ids = articles.map((article) => article.id);

    final Set<String> unconvertible;
    try {
      unconvertible = await _convertAndStore(articles);
    } catch (error, stackTrace) {
      if (_disposed) {
        return true;
      }

      final unavailable =
          error is PlatformException &&
          error.code == GeckoBrowserExtensionService.unavailableErrorCode;
      if (!unavailable) {
        // Nothing was even tried while the extension is not listening; any
        // other failure may be down to one of these documents. Removed first
        // so that suspects failing again queue up behind the others.
        _suspects
          ..removeAll(ids)
          ..addAll(ids);
        logger.w(
          'Converting ${articles.length} articles failed, retrying later',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return false;
    }

    _suspects.removeAll(ids);
    if (unconvertible.isNotEmpty) {
      logger.w(
        'Leaving ${unconvertible.length} articles unprocessed until restart: '
        'the extension failed to convert them',
      );
      _unconvertible.addAll(unconvertible);
    }

    return true;
  }

  /// Converts and stores [articles], and returns the ids of those with a
  /// document the extension failed to convert. Their other field is stored
  /// all the same.
  Future<Set<String>> _convertAndStore(List<ArticleHtml> articles) async {
    // Every field of the batch in one request; a missing or empty field is
    // not sent.
    final html = <String>[];
    int? enqueue(String? field) {
      if (field == null || field.isEmpty) {
        return null;
      }
      html.add(field);
      return html.length - 1;
    }

    final slots = [
      for (final article in articles)
        (
          article: article,
          content: enqueue(article.contentHtml),
          summary: enqueue(article.summaryHtml),
        ),
    ];

    final results = html.isEmpty ? <TurndownResults?>[] : await _convert(html);
    if (results.length != html.length) {
      throw StateError(
        'Converted ${results.length} documents for ${html.length} requested',
      );
    }

    final unconvertible = <String>{};

    // `null` leaves the field as it is: it has no HTML, or its HTML failed to
    // convert. Empty HTML converts to empty text, which marks it done.
    ConvertedText? converted(ArticleHtml article, String? field, int? slot) {
      if (slot == null) {
        return field == null ? null : (markdown: '', plain: '');
      }

      final result = results[slot];
      if (result == null) {
        unconvertible.add(article.id);
        return null;
      }

      return (markdown: result.markdown ?? '', plain: result.plain);
    }

    final processed = [
      for (final (:article, :content, :summary) in slots)
        (
          source: article,
          content: converted(article, article.contentHtml, content),
          summary: converted(article, article.summaryHtml, summary),
        ),
    ];

    if (!_disposed) {
      await _dao.writeProcessedArticles(processed);
    }

    return unconvertible;
  }

  void _retryLater() {
    if (_disposed) {
      return;
    }

    _retryTimer = Timer(_nextRetryDelay, () {
      _retryTimer = null;
      _scheduleDrain();
    });
    _nextRetryDelay = Duration(
      microseconds: min(
        _nextRetryDelay.inMicroseconds * 2,
        _maxRetryDelay.inMicroseconds,
      ),
    );
  }
}
