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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/providers.dart';
import 'package:weblibre/features/quotes/domain/providers.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';

part 'empty_state_content.g.dart';

/// How many shortcuts the top sites module asks for. Shared so
/// [moduleSurfaceSettled] watches the same `topSiteListProvider` instance the
/// module does rather than starting a second query.
const searchEmptyTopSitesLimit = 25;

@Riverpod()
Future<List<HistoryHighlight>> searchEmptyHistoryHighlights(
  Ref ref, {
  int count = 25,
}) async {
  final highlights = await ref
      .read(historyRepositoryProvider.notifier)
      .getHistoryHighlights(limit: count);

  if (!ref.mounted) return [];

  return highlights.where((h) => Uri.tryParse(h.url) != null).toList();
}

@Riverpod()
Future<List<VisitInfo>> searchEmptyRecentHistory(
  Ref ref, {
  int count = 25,
}) async {
  final visits = await ref
      .read(historyRepositoryProvider.notifier)
      .getVisitsPaginated(count: count);

  if (!ref.mounted) return [];

  return visits.where((v) => Uri.tryParse(v.url) != null).toList();
}

@Riverpod()
AsyncValue<List<FeedArticleSummary>> searchEmptyRecentFeedArticles(
  Ref ref, {
  int count = 25,
}) {
  final feeds = ref.watch(feedListProvider);

  // Still loading until the feed list is known: an empty result here would
  // tell [moduleSurfaceSettled] the section is settled as hidden, and it would
  // then appear once the feeds arrive.
  if (!feeds.hasValue && !feeds.hasError) {
    return const AsyncValue.loading();
  }

  final hasFeeds = feeds.value?.isNotEmpty ?? false;
  if (!hasFeeds) {
    return const AsyncValue.data([]);
  }

  return ref.watch(recentFeedArticlesProvider(count));
}

@Riverpod()
List<TabStateWithContainer> searchEmptyRecentTabs(Ref ref, {int count = 25}) {
  final tabs = ref.watch(fifoTabStatesProvider).value;

  return tabs.take(count).toList();
}

bool _isPending(AsyncValue<Object?> value) =>
    !value.hasValue && !value.hasError;

/// Whether every visible module on [surface] that loads its content
/// asynchronously has received its first value.
///
/// Those modules either hide while their list is empty (recent history,
/// highlights, articles, recent tabs) or change height once their content lands
/// (shortcuts, quote). Home centres its content as one block, so each late
/// arrival shifted the whole page a few frames after it first showed (#665).
/// Its host holds the page back until this is true. An error counts as
/// settled, since waiting will not resolve it.
///
/// Watching the module providers here keeps them alive alongside the modules'
/// own subscriptions; the arguments must match the modules' exactly, or this
/// would wait on a separate query.
@Riverpod()
bool moduleSurfaceSettled(Ref ref, ModuleSurface surface) {
  final order = ref.watch(searchModuleOrderProvider(surface));

  var settled = true;
  for (final entry in order) {
    if (!entry.visible) continue;

    final pending = switch (entry.type) {
      SearchModuleType.topSites => ref.watch(
        topSiteListProvider(limit: searchEmptyTopSitesLimit).select(_isPending),
      ),
      SearchModuleType.quote => ref.watch(
        randomQuoteProvider.select(_isPending),
      ),
      SearchModuleType.recentHistory => ref.watch(
        searchEmptyRecentHistoryProvider().select(_isPending),
      ),
      SearchModuleType.historyHighlights => ref.watch(
        searchEmptyHistoryHighlightsProvider().select(_isPending),
      ),
      SearchModuleType.recentArticles => _isPending(
        ref.watch(searchEmptyRecentFeedArticlesProvider()),
      ),
      // [fifoTabStatesProvider] is synchronous but lists nothing until the
      // tab database stream behind it first emits.
      SearchModuleType.recentTabs => ref.watch(
        watchTabsFifoProvider.select(_isPending),
      ),
      _ => false,
    };

    if (pending) settled = false;
  }

  return settled;
}
