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
import 'dart:math' as math;

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show HistoryMetadata;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/history_query_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'history_search.g.dart';

/// Canonical highlight markers wrapped around FTS5 snippet matches.
///
/// `historyHighlightPrefix` and `historyHighlightSuffix` are baked into the
/// `snippet()` text returned by [HistorySearchRepository.addQuery]; the
/// search UI scans for these exact strings to convert them into styled
/// spans (see `utils/text_highlight.dart`). Producer and consumers MUST
/// reference the same constants — if the strings ever diverge, highlight
/// rendering silently breaks (no error, just plain text).
///
/// The two are intentionally identical today (`***` on both sides). They
/// are kept as two constants so a future change can use distinct
/// open/close markers without rewriting every call site.
const historyHighlightPrefix = '***';
const historyHighlightSuffix = '***';

// Tunables for the frecency-aware re-rank. Smaller `weighted_rank` is more
// relevant (BM25 convention). Frecency boosts subtract from the rank so a
// frequently-/recently-visited page floats up.

/// Weight on log-scaled total view time (seconds).
const double _viewTimeRankWeight = 0.5;

/// Weight on the recency decay term.
const double _recencyRankWeight = 0.5;

/// Half-life for the recency decay (days).
const double _recencyHalfLifeDays = 14;

/// Search the local history content index. Mirrors `TabSearchRepository`'s
/// shape so the two integrate symmetrically into the search UI.
///
/// Visit metadata is fetched from Places at query time and folded into the
/// score before emitting state. The DAO returns rows ordered by raw BM25;
/// Places adds the frecency / recency signal we don't track locally.
@Riverpod()
class HistorySearchRepository extends _$HistorySearchRepository {
  Future<void> addQuery(
    String input, {
    int snippetLength = 120,
    int maxResults = 25,
    String matchPrefix = historyHighlightPrefix,
    String matchSuffix = historyHighlightSuffix,
    String ellipsis = '…',
  }) async {
    if (input.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    final result = await AsyncValue.guard(() async {
      final localHits = await ref
          .read(tabDatabaseProvider)
          .historyDao
          .queryHistory(
            searchString: input,
            matchPrefix: matchPrefix,
            matchSuffix: matchSuffix,
            ellipsis: ellipsis,
            snippetLength: snippetLength,
            limit: maxResults,
          )
          .get();

      // Drop rows Places has forgotten (deleted via "Clear browsing data",
      // expired by the engine's pruner, etc.). Local index can outlive
      // Places' record for the same URL; this keeps the visible results
      // aligned with what the engine considers "visited".
      final filtered = await _filterByPlacesVisited(localHits);

      // Hydrate per-URL frecency signal from Places and re-rank in place.
      final reranked = await _rerankWithPlacesMetadata(filtered);

      return (query: input, results: reranked);
    });

    if (!ref.mounted) return;

    state = result;
  }

  Future<List<HistoryQueryResult>> _filterByPlacesVisited(
    List<HistoryQueryResult> hits,
  ) async {
    if (hits.isEmpty) return hits;
    final urls = hits.map((h) => h.urlCanonical).toList(growable: false);
    final visited = await ref
        .read(historyRepositoryProvider.notifier)
        .getVisited(urls);
    if (visited.length != hits.length) {
      // Bridge contract violation: getVisited is supposed to return
      // exactly one bool per input URL. Surface all hits rather than
      // dropping them silently (better UX = the user still sees results),
      // but log loudly so the regression doesn't go unnoticed in the
      // wild — searches would otherwise stop being filtered against the
      // engine's view of "did I visit this?" with no symptom.
      logger.e(
        'PlacesHistory.getVisited contract violation: returned '
        '${visited.length} bools for ${hits.length} URLs; falling back '
        'to unfiltered results.',
      );
      return hits;
    }
    return [
      for (var i = 0; i < hits.length; i++)
        if (visited[i]) hits[i],
    ];
  }

  /// For each hit, fetches the latest Places metadata, computes a combined
  /// score, and returns hits ordered ascending (smallest = most relevant).
  /// Metadata is fetched in a single bulk call to keep the IPC cost flat.
  /// On bridge error, falls back to the raw BM25 ordering for the whole set.
  Future<List<HistoryQueryResult>> _rerankWithPlacesMetadata(
    List<HistoryQueryResult> hits,
  ) async {
    if (hits.isEmpty) return hits;

    final urls = hits.map((h) => h.urlCanonical).toList(growable: false);
    final List<HistoryMetadata?> metadata;
    try {
      metadata = await ref
          .read(historyRepositoryProvider.notifier)
          .getLatestHistoryMetadataForUrls(urls);
    } catch (e, s) {
      // Places bridge failure (IPC error, etc.) — fall back to the raw
      // BM25 ordering rather than blanking the search results. Log
      // loudly so a transport-level regression doesn't quietly silence
      // every frecency re-rank in the app.
      logger.e(
        'PlacesHistory.getLatestHistoryMetadataForUrls threw; '
        'falling back to BM25-only ordering.',
        error: e,
        stackTrace: s,
      );
      return hits;
    }
    if (metadata.length != hits.length) {
      logger.e(
        'PlacesHistory.getLatestHistoryMetadataForUrls contract '
        'violation: returned ${metadata.length} entries for '
        '${hits.length} URLs; falling back to BM25-only ordering.',
      );
      return hits;
    }

    final now = DateTime.now();
    final scored = <(double, HistoryQueryResult)>[
      for (var i = 0; i < hits.length; i++)
        (_combinedScore(hits[i], metadata[i], now), hits[i]),
    ];
    scored.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final entry in scored) entry.$2];
  }

  double _combinedScore(
    HistoryQueryResult hit,
    HistoryMetadata? metadata,
    DateTime now,
  ) {
    var score = hit.weightedRank;

    if (metadata != null) {
      // ln(1 + viewTime_seconds): heavy reading dominates lookup-style hits.
      final viewSeconds = metadata.totalViewTime / 1000.0;
      score -= _viewTimeRankWeight * math.log(1 + viewSeconds);

      // Exponential recency decay anchored on Places' updatedAt — i.e. the
      // last time the engine observed *anything* about this URL.
      final updatedAt = DateTime.fromMillisecondsSinceEpoch(metadata.updatedAt);
      final ageDays = now.difference(updatedAt).inHours / 24.0;
      final decay = math.exp(-math.max(0.0, ageDays) / _recencyHalfLifeDays);
      score -= _recencyRankWeight * decay;
    }

    return score;
  }

  @override
  Future<({String query, List<HistoryQueryResult> results})?> build() {
    return Future.value();
  }
}
