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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

/// Places, as far as deleting a page reaches it: its addresses.
class _FakeHistoryRepository extends HistoryRepository {
  _FakeHistoryRepository(this.urls);

  final Set<String> urls;
  final deleted = <String>[];

  @override
  Future<List<String>> getVisitedUrlsContaining(String text) async => [
    for (final url in urls)
      if (url.contains(text)) url,
  ];

  @override
  Future<void> deleteVisitsFor(String url) async {
    deleted.add(url);
    urls.remove(url);
  }
}

void main() {
  late TabDatabase db;
  late ProviderContainer container;
  late _FakeHistoryRepository history;

  setUp(() {
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
    history = _FakeHistoryRepository({
      'https://en.wikipedia.org/wiki/Foo',
      'https://en.wikipedia.org/wiki/Foo#History',
      'https://en.wikipedia.org/wiki/Foobar',
      'https://en.wikipedia.org/wiki/Bar',
    });
    container = ProviderContainer(
      overrides: [
        tabDatabaseProvider.overrideWith((ref) => db),
        historyRepositoryProvider.overrideWith(() => history),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> deleteUrl(String url) => container
      .read(containerHistoryRepositoryProvider.notifier)
      .deleteUrl(url);

  test('deletes every spelling of the page, and only of that page', () async {
    await deleteUrl('https://en.wikipedia.org/wiki/Foo');

    expect(history.urls, {
      'https://en.wikipedia.org/wiki/Foobar',
      'https://en.wikipedia.org/wiki/Bar',
    });
  });

  test('a fragment spelling takes the page with it', () async {
    await deleteUrl('https://en.wikipedia.org/wiki/Foo#History');

    expect(history.urls, isNot(contains('https://en.wikipedia.org/wiki/Foo')));
  });

  test('an IPv6 address goes with its other spellings', () async {
    history.urls
      ..clear()
      ..addAll({
        'https://[::1]/page',
        'https://[::1]/page#section',
        'https://[::1]/other',
      });

    await deleteUrl('https://[::1]/page');

    expect(history.urls, {'https://[::1]/other'});
  });

  test('an address with userinfo goes with its other spellings', () async {
    history.urls
      ..clear()
      ..addAll({
        'https://user@example.org/page',
        'https://user@example.org/page#section',
        'https://example.org/other',
      });

    await deleteUrl('https://user@example.org/page');

    expect(history.urls, {'https://example.org/other'});
  });

  test('a spelling only a container tag knows goes with its tag', () async {
    await db.customStatement(
      'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
      "VALUES ('work', 0, 'work', 0, '{}')",
    );
    await db.visitContainerDao.insertRelation(
      rawUrl: 'https://en.wikipedia.org/wiki/Foo#Tagged',
      urlCanonical: 'https://en.wikipedia.org/wiki/Foo',
      visitTime: 1,
      containerId: 'work',
    );

    // Not among the addresses the history lookup finds.
    await deleteUrl('https://en.wikipedia.org/wiki/Foo');

    expect(
      history.deleted,
      contains('https://en.wikipedia.org/wiki/Foo#Tagged'),
    );
    expect(await db.visitContainerDao.relationsForContainer('work'), isEmpty);
  });
}
