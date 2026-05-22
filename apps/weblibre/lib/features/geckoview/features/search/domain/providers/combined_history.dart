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
import 'dart:typed_data';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/history_query_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/history_search.dart';
import 'package:weblibre/utils/url_canonical.dart';

part 'combined_history.g.dart';

/// Single row in the combined history section.
///
/// Items come from one of two sources and are deduplicated by canonical
/// URL. The engine ordering is preserved; local-only matches are appended
/// after, so the user keeps their familiar frecency-ranked top of list and
/// content-search hits flesh out the long tail.
class CombinedHistoryItem {
  final Uri uri;
  final String? title;
  final Uint8List? engineIcon;

  /// Raw highlight markers (`***foo***`) from FTS5 over `extracted_content`
  /// or `full_content`. Renderer in `text_highlight.dart` converts them into
  /// styled spans. `null` for engine-only items.
  final String? highlightedTitle;
  final String? snippet;

  /// Bookkeeping for the renderer / future "Engine"/"Local" badges.
  final CombinedHistorySource source;

  const CombinedHistoryItem({
    required this.uri,
    required this.title,
    required this.engineIcon,
    required this.highlightedTitle,
    required this.snippet,
    required this.source,
  });
}

enum CombinedHistorySource { engine, local }

/// Engine suggestions, augmented per-row with local snippet/highlight when
/// available, then padded with local-only matches.
///
/// Implementation note: kept as a synchronous Riverpod provider that derives
/// its data from `engineSuggestionsProvider` + `historySearchRepositoryProvider`.
/// Both upstream providers are responsible for kicking off their own queries
/// when the search text changes; this one just reacts.
@Riverpod()
List<CombinedHistoryItem> combinedHistorySuggestions(Ref ref) {
  final engineAsync = ref.watch(engineSuggestionsProvider);
  final localAsync = ref.watch(historySearchRepositoryProvider);

  final engineSuggestions =
      engineAsync.value ?? const <GeckoSuggestion>[];
  final localResults = localAsync.value?.results ?? const <HistoryQueryResult>[];

  // Index the local rows by canonical URL so engine items can pick up
  // snippet/title-highlight without an N×M scan.
  final localByCanonical = <String, HistoryQueryResult>{};
  for (final hit in localResults) {
    localByCanonical[hit.urlCanonical] = hit;
  }

  final emitted = <String>{};
  final out = <CombinedHistoryItem>[];

  // 1. Engine suggestions in their existing order, enriched where possible.
  //    Single-pass filter+emit: skip suggestions that aren't usable history
  //    items, deduplicate by canonical URL.
  for (final suggestion in engineSuggestions) {
    if (suggestion.type != GeckoSuggestionType.history) continue;
    if (suggestion.title?.isEmpty ?? true) continue;
    if (suggestion.description?.isEmpty ?? true) continue;

    final uri = suggestion.description.mapNotNull(Uri.tryParse);
    if (uri == null) continue;
    final canonical = canonicalizeUrl(uri.toString())?.canonical;
    if (canonical == null) continue;
    if (!emitted.add(canonical)) continue;

    final local = localByCanonical[canonical];
    out.add(
      CombinedHistoryItem(
        uri: uri,
        title: suggestion.title,
        engineIcon: suggestion.icon,
        highlightedTitle: local?.title,
        snippet: _pickSnippet(local),
        source: CombinedHistorySource.engine,
      ),
    );
  }

  // 2. Local-only matches: URLs the engine didn't surface (typically because
  //    the user's query matched only in extracted/full content rather than
  //    title/url, which is exactly where the local FTS earns its keep).
  for (final hit in localResults) {
    if (!emitted.add(hit.urlCanonical)) continue;
    final uri = Uri.tryParse(hit.urlCanonical);
    if (uri == null) continue;

    out.add(
      CombinedHistoryItem(
        uri: uri,
        title: hit.title,
        engineIcon: null,
        highlightedTitle: hit.title,
        snippet: _pickSnippet(hit),
        source: CombinedHistorySource.local,
      ),
    );
  }

  return out;
}

/// Prefer the extracted-content snippet (reader text) when it carries a
/// match, falling back to full content otherwise. Mirrors the heuristic in
/// the existing tab/local-history widgets.
String? _pickSnippet(HistoryQueryResult? hit) {
  if (hit == null) return null;
  if (hit.extractedContent?.contains(historyHighlightPrefix) ?? false) {
    return hit.extractedContent;
  }
  return hit.fullContent;
}
