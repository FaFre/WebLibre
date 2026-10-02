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
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/providers.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';

final _feedUrl = Uri.parse('https://example.invalid/feed.xml');

void main() {
  late FeedDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = FeedDatabase(NativeDatabase.memory());
    await db.feedDao.upsertFeed(
      FeedData(url: _feedUrl, title: 'Example', lastFetched: DateTime(2026)),
    );
    await db.articleDao.upsertArticles([
      FeedArticle(
        id: 'fox',
        feedId: _feedUrl,
        fetched: DateTime(2026),
        title: 'The quick brown fox',
        summaryPlain: 'jumps over the lazy dog',
      ),
    ]);
    container = ProviderContainer(
      overrides: [feedDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// The result lists the search publishes, as article ids.
  List<List<String>> listen() {
    final published = <List<String>>[];
    container.listen(articleSearchProvider(null), (_, next) {
      if (next case AsyncData(:final value)) {
        published.add([for (final article in value) article.id]);
      }
    }, fireImmediately: true);
    return published;
  }

  Future<void> pause() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  test('searches once typing pauses, and only when the text changes', () async {
    final published = listen();
    final search = container.read(articleSearchProvider(null).notifier);

    for (final text in ['f', 'fo', 'fox', 'foxe', 'fox']) {
      search.search(text);
    }
    await pause();

    // A caret or selection move reports the same text again.
    search.search('fox');
    await pause();

    expect(published, [
      <String>[],
      ['fox'],
    ]);
  });

  test('a new query replaces the one still waiting to run', () async {
    final published = listen();
    final search = container.read(articleSearchProvider(null).notifier)
      ..search('fox');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    search.search('zebra');
    await pause();

    expect(published, [<String>[], <String>[]]);
  });
}
