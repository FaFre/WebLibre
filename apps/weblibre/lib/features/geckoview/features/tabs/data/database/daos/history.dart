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
import 'package:drift/drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/history.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/history_query_result.dart';

@DriftAccessor()
class HistoryDao extends DatabaseAccessor<TabDatabase> with $HistoryDaoMixin {
  HistoryDao(super.db);

  /// Search the local history index. If the FTS query is empty (e.g. all
  /// tokens were below the minimum trigram length), falls back to a host
  /// prefix scan so very short user input still returns something useful.
  Selectable<HistoryQueryResult> queryHistory({
    required String searchString,
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    int limit = 25,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.definitionsDrift.queryHistoryFullContent(
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
        limit: limit,
      );
    }

    final trimmed = searchString.trim();
    if (trimmed.isEmpty) {
      // Empty query → no results. Caller should not invoke us in this case
      // but the guard avoids surfacing every host on the device.
      return _emptyHistorySelectable();
    }

    return db.definitionsDrift.queryHistoryByHostPrefix(
      hostPrefix: '$trimmed%',
      limit: limit,
    );
  }

  /// Hydrate canonical URLs (e.g. from Places' `getSuggestions`) with the
  /// local content rows. Returns rows in arbitrary order; callers are
  /// expected to preserve their own ordering.
  Selectable<HistoryQueryResult> hydrateByCanonicalUrls(
    Iterable<String> canonicalUrls,
  ) {
    final urls = canonicalUrls.toList(growable: false);
    if (urls.isEmpty) {
      return _emptyHistorySelectable();
    }
    return db.definitionsDrift.historyByCanonicalUrls(canonicalUrls: urls);
  }

  Future<int> countRows() {
    return db.definitionsDrift.countHistoryRows().getSingle();
  }

  Future<void> clear() {
    return db.definitionsDrift.clearHistory();
  }

  /// Returns a stable page over the local index, ordered oldest-first.
  ///
  /// The pruner advances [offset] by the number of rows that survived each
  /// batch, so it can delete rows while still scanning the full table exactly
  /// once.
  Future<List<String>> urlsPage({int limit = 200, int offset = 0}) {
    return db.definitionsDrift
        .historyUrlsPage(limit: limit, offset: offset)
        .get();
  }

  Future<int> deleteByCanonicalUrls(Iterable<String> canonicalUrls) {
    final urls = canonicalUrls.toList(growable: false);
    if (urls.isEmpty) return Future.value(0);
    return db.definitionsDrift.deleteHistoryByCanonicalUrls(
      canonicalUrls: urls,
    );
  }

  /// Mirror a `local_index_setting` value from the user-facing settings.
  Future<void> upsertSetting(String key, bool value) {
    return db.definitionsDrift.upsertLocalIndexSetting(
      key: key,
      value: value ? 1 : 0,
    );
  }

  /// Sentinel that cannot match any real row in `history.url_canonical`.
  ///
  /// Canonical URLs come from `canonicalizeUrl()` / `url_canonical()` which
  /// require `uri.hasScheme` — every canonical form therefore contains a
  /// `:`. The sentinel below starts with a space and contains no `:`, so
  /// no canonicalization output can collide with it. Used by
  /// [_emptyHistorySelectable] to coerce the IN-list query into a
  /// guaranteed-empty result without inventing a new query shape.
  ///
  /// Note: the schema is `url_canonical TEXT PRIMARY KEY NOT NULL` with no
  /// CHECK constraint, so the empty string `''` is technically a valid
  /// value at the SQL level. The write path's `url_indexable()` gate
  /// rejects schemeless input (including `''`), so in practice we never
  /// see one — but this sentinel doesn't rely on that invariant.
  static const _impossibleCanonicalUrlSentinel = ' __no_match__ ';

  Selectable<HistoryQueryResult> _emptyHistorySelectable() =>
      // `IN ()` is not valid SQL — substitute a sentinel that cannot
      // match any real row. See [_impossibleCanonicalUrlSentinel].
      db.definitionsDrift.historyByCanonicalUrls(
        canonicalUrls: const [_impossibleCanonicalUrlSentinel],
      );
}
