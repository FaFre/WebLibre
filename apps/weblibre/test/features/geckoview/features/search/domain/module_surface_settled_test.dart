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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/empty_state_content.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_summary.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_item.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/providers.dart';
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart';
import 'package:weblibre/features/quotes/domain/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';

void main() {
  // Home's default layout shows top sites, recent tabs and the quote, and
  // hides recent history and articles.
  late StreamController<List<TopSiteItem>> topSites;
  late StreamController<List<TabSummary>> tabs;
  late Completer<Quote?> quote;
  late Completer<List<VisitInfo>> recentHistory;
  late StreamController<List<FeedData>> feeds;
  late ProviderContainer container;

  setUp(() {
    topSites = StreamController();
    tabs = StreamController();
    quote = Completer();
    recentHistory = Completer();
    feeds = StreamController();
    container = ProviderContainer(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith(
          (ref) => Storage.inMemory(),
        ),
        topSiteListProvider(
          limit: searchEmptyTopSitesLimit,
        ).overrideWith((ref) => topSites.stream),
        watchTabsFifoProvider.overrideWith((ref) => tabs.stream),
        randomQuoteProvider.overrideWith((ref) => quote.future),
        feedListProvider.overrideWith((ref) => feeds.stream),
        searchEmptyRecentHistoryProvider().overrideWith(
          (ref) => recentHistory.future,
        ),
      ],
    );
    addTearDown(container.dispose);
    // Not awaited: closing a controller nobody listened to (feeds, while
    // articles are hidden) never completes.
    addTearDown(() {
      for (final controller in [topSites, tabs, feeds]) {
        unawaited(controller.close());
      }
    });
    container.listen(
      moduleSurfaceSettledProvider(ModuleSurface.home),
      (_, _) {},
    );
  });

  bool settled() =>
      container.read(moduleSurfaceSettledProvider(ModuleSurface.home));

  /// Lets stream events and future callbacks reach their providers, then
  /// lets the container rebuild. Two turns: a stream's first event can land a
  /// turn after a completer's callback.
  Future<void> flush() async {
    for (var i = 0; i < 2; i++) {
      await Future<void>.delayed(Duration.zero);
      await container.pump();
    }
  }

  /// Resolves home's default visible modules.
  Future<void> loadDefaults() async {
    topSites.add(const []);
    tabs.add(const []);
    quote.complete(null);
    await flush();
  }

  void show(SearchModuleType module) => container
      .read(searchModuleOrderProvider(ModuleSurface.home).notifier)
      .toggleVisibility(module);

  test('waits for every visible module and ignores hidden ones', () async {
    expect(settled(), isFalse);

    topSites.add(const []);
    tabs.add(const []);
    await flush();
    expect(settled(), isFalse, reason: 'the quote is still loading');

    quote.complete(null);
    await flush();
    expect(
      settled(),
      isTrue,
      reason: 'recent history is hidden, so its pending query does not count',
    );
  });

  test('recent tabs wait for the tab database stream', () async {
    topSites.add(const []);
    quote.complete(null);
    await flush();
    expect(
      settled(),
      isFalse,
      reason: 'the recent tabs list is empty only because nothing arrived yet',
    );

    tabs.add(const []);
    await flush();
    expect(settled(), isTrue);
  });

  test('a module switched on waits for its own data', () async {
    await loadDefaults();
    expect(settled(), isTrue);

    show(SearchModuleType.recentHistory);
    await flush();
    expect(settled(), isFalse);

    recentHistory.complete(const []);
    await flush();
    expect(settled(), isTrue);
  });

  test('recent articles wait for the feed list', () async {
    await loadDefaults();
    show(SearchModuleType.recentArticles);
    await flush();
    expect(
      settled(),
      isFalse,
      reason: 'without the feed list, no feeds and not loaded look the same',
    );

    feeds.add(const []);
    await flush();
    expect(settled(), isTrue);
  });

  test('a failed module does not hold the surface back', () async {
    topSites.add(const []);
    tabs.add(const []);
    quote.completeError(StateError('no quotes database'));
    await flush();

    expect(settled(), isTrue);
  });
}
