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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'history_exclusion_replication.g.dart';

/// The exclude-from-history state native needs to decide, per session, whether a
/// visit may reach Mozilla Places.
///
/// Keyed on tabs rather than Gecko contextIds: a container without cookie
/// isolation shares the default context with every other uncontained tab, so a
/// contextId cannot tell its sessions apart — the tab always can.
/// [knownTabIds] is what lets native distinguish "WebLibre says this tab is not
/// excluded" from "WebLibre hasn't seen this tab yet" (a `window.open` child),
/// where it falls back to inheriting the opener's exclusion.
class HistoryExclusionSnapshot with FastEquatable {
  /// Tabs whose container has exclude-from-history enabled.
  final List<String> excludedTabIds;

  /// Every tab WebLibre holds a row for, excluded or not.
  final List<String> knownTabIds;

  /// Gecko contextual identities of excluded containers. Only cookie-isolated
  /// containers have one; native uses these before the first snapshot lands
  /// (cold start, headless path).
  final List<String> excludedContextIds;

  /// The same projection as a tab → container map, for [VisitContainerRecorder],
  /// which has to resolve a tab the instant a visit is reported. Absent key = a
  /// tab WebLibre holds no row for; present with a null value = uncontained.
  ///
  /// Carried here rather than in a provider of its own so the underlying join is
  /// watched once. It participates in equality, so a tab moving between two
  /// containers with the same exclusion state re-emits (and re-pushes an
  /// identical snapshot to native) — rare, and cheaper than a second
  /// subscription to the same query.
  final Map<String, String?> tabContainerIds;

  HistoryExclusionSnapshot({
    required this.excludedTabIds,
    required this.knownTabIds,
    required this.excludedContextIds,
    required this.tabContainerIds,
  });

  @override
  List<Object?> get hashParameters => [
    excludedTabIds,
    knownTabIds,
    excludedContextIds,
    tabContainerIds,
  ];
}

/// Read the snapshot once, outside the provider graph. Used at startup, before
/// the engine is initialized, where awaiting the streams below would be circular.
Future<HistoryExclusionSnapshot> readHistoryExclusionSnapshot(
  TabDatabase db,
) async {
  final tabs = await db.tabDao.historyExclusionTabs().get();
  final contextIds = await db.containerDao.excludedHistoryContextIds().get();

  return _buildSnapshot(tabs, contextIds);
}

/// The tab → container map from the latest snapshot, for consumers that need to
/// resolve a tab synchronously.
@Riverpod(keepAlive: true)
Map<String, String?> tabContainerIds(Ref ref) {
  return ref
          .watch(watchHistoryExclusionSnapshotProvider)
          .value
          ?.tabContainerIds ??
      const {};
}

HistoryExclusionSnapshot _buildSnapshot(
  List<HistoryExclusionTabsResult> tabs,
  List<String?> contextIds,
) {
  final knownTabIds = <String>[];
  final excludedTabIds = <String>[];
  final tabContainerIds = <String, String?>{};

  for (final tab in tabs) {
    knownTabIds.add(tab.tabId);
    tabContainerIds[tab.tabId] = tab.containerId;
    if (tab.excluded != 0) {
      excludedTabIds.add(tab.tabId);
    }
  }

  return HistoryExclusionSnapshot(
    // Sorted so an unchanged set compares equal and doesn't re-push.
    excludedTabIds: excludedTabIds..sort(),
    knownTabIds: knownTabIds..sort(),
    excludedContextIds: contextIds.whereType<String>().toList(growable: false)
      ..sort(),
    tabContainerIds: tabContainerIds,
  );
}

/// The single subscription to the tab↔container projection; both the native
/// snapshot and [tabContainerIds] are derived from it.
///
/// Emits on every tab or container change, skipping repeats — the tab table is
/// written far more often (content, timestamps) than any of this changes. The
/// underlying query joins `container`, so flipping the setting on a container
/// re-runs it without touching any tab.
///
/// The wasted scans are deliberate. Coalescing tab writes (throttled table-update
/// ticks instead of `watch()`) does cut them, but a tab's `container_id` moving
/// into an excluded container *is* one of those writes, and it is indistinguishable
/// from a title or timestamp write until the projection has been read. Any delay
/// is therefore a window in which native still holds the pre-move exclusion state
/// and a load in that tab reaches Places — paying for a background query with a
/// leak, which is the wrong trade for this projection.
@Riverpod(keepAlive: true)
Stream<HistoryExclusionSnapshot> watchHistoryExclusionSnapshot(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);

  return db.tabDao.historyExclusionTabs().watch().asyncMap((tabs) async {
    final contextIds = await db.containerDao.excludedHistoryContextIds().get();
    return _buildSnapshot(tabs, contextIds);
  }).distinct();
}

/// Keeps native's exclude-from-history snapshot in sync with WebLibre's
/// containers and tabs. Activated eagerly at startup (and pushed once more
/// before engine init) so an excluded container never leaks a restored tab's
/// visit to Places.
@Riverpod(keepAlive: true)
Future<void> historyExclusionReplication(Ref ref) async {
  final snapshot = await ref.watch(
    watchHistoryExclusionSnapshotProvider.future,
  );

  await GeckoEngineSettingsService().setHistoryExclusions(
    excludedTabIds: snapshot.excludedTabIds,
    knownTabIds: snapshot.knownTabIds,
    excludedContextIds: snapshot.excludedContextIds,
  );
}
