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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'local_index_pruner.g.dart';

/// Drops local history rows that the engine no longer remembers (the user
/// cleared browsing data, the engine's own retention pruned them, etc.).
///
/// Triggered manually — call `prune()` from a periodic timer (cold-start
/// once per app launch is enough). The sweep walks the whole table in batches
/// so stale rows don't get stranded behind an always-valid oldest page.
@Riverpod(keepAlive: true)
class LocalIndexPruner extends _$LocalIndexPruner {
  /// Examines the whole local index in [batchSize] chunks. Anything Places
  /// returns `false` for via `getVisited` is removed. Returns the total
  /// number of deleted rows.
  ///
  /// A single batch failing (DB hiccup, Places bridge transient) is
  /// logged and skipped — the sweep advances by `batchSize` so a stuck
  /// page can't block later pages from being pruned. A contract
  /// violation (getVisited returning a different list length than asked
  /// for) stops the sweep, because under that condition we can no
  /// longer trust the per-row visited bits.
  Future<int> prune({int batchSize = 200}) async {
    final dao = ref.read(tabDatabaseProvider).historyDao;
    var totalDeleted = 0;
    var offset = 0;

    while (true) {
      final List<String> candidates;
      try {
        candidates = await dao.urlsPage(limit: batchSize, offset: offset);
      } catch (e, s) {
        logger.e(
          'Local index pruner: urlsPage failed at offset=$offset',
          error: e,
          stackTrace: s,
        );
        return totalDeleted;
      }

      if (candidates.isEmpty) {
        return totalDeleted;
      }

      final int deleted;
      try {
        final visited = await ref
            .read(historyRepositoryProvider.notifier)
            .getVisited(candidates);
        if (visited.length != candidates.length) {
          // Bridge contract violation — see history_search.dart for the
          // same shape. Bail instead of advancing offset: the visited
          // bits no longer line up with `candidates`.
          logger.e(
            'Local index pruner: getVisited returned ${visited.length} '
            'for ${candidates.length} URLs — stopping after deleting '
            '$totalDeleted rows',
          );
          return totalDeleted;
        }

        final toDelete = <String>[
          for (var i = 0; i < candidates.length; i++)
            if (!visited[i]) candidates[i],
        ];

        deleted = toDelete.isEmpty
            ? 0
            : await dao.deleteByCanonicalUrls(toDelete);
        totalDeleted += deleted;
      } catch (e, s) {
        // Transient failure for this batch (Places bridge IPC error,
        // SQLite hiccup, etc.). Skip the batch and continue — advance by
        // a full `batchSize` so we don't re-examine the same page on
        // the next iteration.
        logger.e(
          'Local index pruner: batch at offset=$offset failed; skipping',
          error: e,
          stackTrace: s,
        );
        offset += batchSize;
        continue;
      }

      if (candidates.length < batchSize) {
        return totalDeleted;
      }

      // We processed `candidates.length` rows; `deleted` of them were
      // removed, so the table shrunk by `deleted`. The next page should
      // start at `offset + candidates.length - deleted` to skip exactly
      // the rows we kept. SQLite re-numbers OFFSET against the
      // post-delete row positions, so this lands at the first row we
      // haven't seen yet.
      offset += candidates.length - deleted;

      // Yield to the event loop between batches so a large sweep
      // doesn't monopolise the main isolate.
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  void build() {}
}
