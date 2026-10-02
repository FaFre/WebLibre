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

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/domain/services/article_content_processor.dart';

final _feedUrl = Uri.parse('https://example.invalid/feed.xml');

/// Stands in for the browser extension: converts `x` to markdown `md x` and
/// plain text `plain x`, and records what it was asked.
class _Converter {
  final requests = <List<String>>[];

  /// While set, requests wait for it.
  Completer<void>? gate;

  /// Returns what a request fails with, if anything.
  Object? Function(List<String> html)? failure;

  /// Whether a document fails to convert, which turndown.js reports per
  /// document inside an answer that otherwise succeeds.
  bool Function(String document)? unconvertible;

  var _inFlight = 0;
  int maxInFlight = 0;

  Future<List<TurndownResults?>> call(List<String> html) async {
    requests.add(html);
    _inFlight++;
    maxInFlight = max(maxInFlight, _inFlight);
    try {
      await gate?.future;
      if (failure?.call(html) case final error?) {
        throw error;
      }
      return html.map(_convert).toList();
    } finally {
      _inFlight--;
    }
  }

  TurndownResults? _convert(String document) {
    if (unconvertible?.call(document) ?? false) {
      return null;
    }

    return TurndownResults(plain: 'plain $document', markdown: 'md $document');
  }

  /// How many times [document] was sent.
  int sent(String document) =>
      requests.expand((request) => request).where((d) => d == document).length;
}

void main() {
  late FeedDatabase db;
  late _Converter converter;
  late ArticleContentProcessor processor;

  ArticleContentProcessor newProcessor() => ArticleContentProcessor(
    db.articleDao,
    converter.call,
    retryDelay: const Duration(milliseconds: 10),
    maxRetryDelay: const Duration(milliseconds: 40),
  );

  setUp(() async {
    db = FeedDatabase(NativeDatabase.memory());
    await db.feedDao.upsertFeed(
      FeedData(url: _feedUrl, title: 'Example', lastFetched: DateTime(2026)),
    );
    converter = _Converter();
    processor = newProcessor();
  });

  tearDown(() async {
    await processor.dispose();
    await db.close();
  });

  Future<void> insert(
    Iterable<int> numbers, {
    String Function(int number)? content,
    String? Function(int number)? summary,
    String? summaryPlain,
  }) {
    return db.articleDao.upsertArticles([
      for (final number in numbers)
        FeedArticle(
          id: 'article-$number',
          feedId: _feedUrl,
          fetched: DateTime(2026),
          created: DateTime(2026, 1, 1, 0, number),
          title: 'Article $number',
          contentHtml: content?.call(number) ?? '<p>content $number</p>',
          summaryHtml: summary != null
              ? summary(number)
              : '<p>summary $number</p>',
          summaryPlain: summaryPlain,
        ),
    ]);
  }

  Future<FeedArticle> article(int number) async => (await db.articleDao
      .getArticleById('article-$number')
      .getSingleOrNull())!;

  Future<Set<String>> unprocessed() async =>
      (await db.articleDao.getUnprocessedArticleIds().get()).toSet();

  Future<void> eventually(FutureOr<bool> Function() condition) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!await condition()) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Condition not met in time');
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  /// Waits until nothing is left to convert and the processor has stopped.
  Future<void> settle({Set<String> leftOver = const {}}) async {
    await eventually(() async => setEquals(await unprocessed(), leftOver));
    await eventually(() => !processor.isBusy);
    // Room for a stray drain to show itself.
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  test('converts a backlog in bounded batches, one at a time', () async {
    await insert(List.generate(25, (i) => i + 1));

    processor.start();
    await settle();

    expect(converter.maxInFlight, 1);
    for (final request in converter.requests) {
      // Content and summary per article.
      expect(
        request.length,
        lessThanOrEqualTo(2 * ArticleContentProcessor.maxBatchArticles),
      );
    }
    for (var number = 1; number <= 25; number++) {
      expect(converter.sent('<p>content $number</p>'), 1);
      expect(converter.sent('<p>summary $number</p>'), 1);
    }

    final first = await article(1);
    expect(first.contentMarkdown, 'md <p>content 1</p>');
    expect(first.contentPlain, 'plain <p>content 1</p>');
    expect(first.summaryMarkdown, 'md <p>summary 1</p>');
    expect(first.summaryPlain, 'plain <p>summary 1</p>');
  });

  test('a batch is cut short by the size of its HTML', () async {
    // Two of these fit into one batch, three do not.
    final large = 'x' * (ArticleContentProcessor.maxBatchChars ~/ 3);
    await insert([1, 2, 3], content: (number) => '$number$large');

    processor.start();
    await settle();

    expect(converter.requests.map((request) => request.length), [4, 2]);
  });

  test('articles added during a conversion are converted once', () async {
    converter.gate = Completer();
    await insert([1, 2, 3]);

    processor.start();
    await eventually(() => converter.requests.isNotEmpty);
    // A feed refresh inserting while the first batch is out.
    await insert([4, 5, 6]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    converter.gate!.complete();
    await settle();

    expect(converter.maxInFlight, 1);
    for (var number = 1; number <= 6; number++) {
      expect(converter.sent('<p>content $number</p>'), 1);
    }
  });

  test('HTML replaced during its conversion is converted again', () async {
    converter.gate = Completer();
    await insert([1]);

    processor.start();
    await eventually(() => converter.requests.isNotEmpty);
    await (db.article.update()..where((row) => row.id.equals('article-1')))
        .write(const ArticleCompanion(contentHtml: Value('<p>revised</p>')));
    converter.gate!.complete();
    await settle();

    final revised = await article(1);
    expect(revised.contentHtml, '<p>revised</p>');
    expect(revised.contentMarkdown, 'md <p>revised</p>');
    expect(converter.sent('<p>content 1</p>'), 1);
  });

  test('waits for the extension when it is not listening yet', () async {
    var refusals = 2;
    converter.failure = (_) => refusals-- > 0
        ? PlatformException(
            code: GeckoBrowserExtensionService.unavailableErrorCode,
          )
        : null;
    await insert([1, 2]);

    processor.start();
    await settle();

    // Refused twice as a whole, never split up and blamed on the articles.
    expect(converter.requests.map((request) => request.length), [4, 4, 4]);
  });

  test('a request that fails blames none of its articles', () async {
    var timeouts = 1;
    converter.failure = (_) =>
        timeouts-- > 0 ? TimeoutException('no answer in time') : null;
    await insert([1, 2, 3]);

    processor.start();
    await settle();

    // The failed batch, then each of its articles on its own: all converted
    // once the extension answers again.
    expect(converter.requests.map((request) => request.length), [6, 2, 2, 2]);
  });

  test('a document that stalls the extension holds up only itself', () async {
    converter.failure = (html) =>
        html.contains('<p>stuck</p>') ? TimeoutException('stalled') : null;
    await insert(
      [1, 2, 3],
      content: (number) =>
          number == 2 ? '<p>stuck</p>' : '<p>content $number</p>',
    );

    processor.start();
    await eventually(() async => setEquals(await unprocessed(), {'article-2'}));

    // Work arriving meanwhile still gets through.
    await insert([4]);
    await eventually(() async => setEquals(await unprocessed(), {'article-2'}));
    expect((await article(4)).contentPlain, 'plain <p>content 4</p>');

    // The stalling article is still tried — after the batch it came in, on its
    // own.
    await eventually(() => converter.sent('<p>stuck</p>') >= 3);
    final stuck = converter.requests
        .where((request) => request.contains('<p>stuck</p>'))
        .toList();
    expect(stuck.first, hasLength(6));
    expect(stuck.skip(1), everyElement(hasLength(2)));
  });

  test(
    'a document that fails to convert is tried again after a restart',
    () async {
      converter.unconvertible = (document) => document == '<p>broken</p>';
      await insert(
        [1, 2, 3],
        content: (number) =>
            number == 2 ? '<p>broken</p>' : '<p>content $number</p>',
      );

      processor.start();
      await settle(leftOver: {'article-2'});

      // Nothing stored that would pass for converted text...
      final broken = await article(2);
      expect(broken.contentMarkdown, isNull);
      expect(broken.contentPlain, isNull);
      // ...while what did convert is kept.
      expect(broken.summaryPlain, 'plain <p>summary 2</p>');
      expect((await article(1)).contentPlain, 'plain <p>content 1</p>');

      // Further work does not try it again.
      await insert([4]);
      await settle(leftOver: {'article-2'});
      expect(converter.sent('<p>broken</p>'), 1);

      // A restart does.
      await processor.dispose();
      converter.unconvertible = null;
      processor = newProcessor()..start();
      await settle();

      expect((await article(2)).contentPlain, 'plain <p>broken</p>');
    },
  );

  test('a field without HTML is left as it is', () async {
    await insert([1], summary: (_) => null, summaryPlain: 'from the feed');

    processor.start();
    await settle();

    final converted = await article(1);
    expect(converted.contentPlain, 'plain <p>content 1</p>');
    expect(converted.summaryMarkdown, isNull);
    expect(converted.summaryPlain, 'from the feed');
  });
}
