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
import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/unlock_incomplete_tabs.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_summary.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/search/util/tokenized_filter.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'providers.g.dart';

/// Drift re-runs a watched query on every write to the tables it reads, and
/// emits a new collection each time even when the rows are unchanged. Riverpod
/// compares collections by identity, so without this every such write (the
/// tab table is written on each debounced tab update) would notify every
/// consumer of these streams.
bool _sameContent(Object? previous, Object? next) =>
    const DeepCollectionEquality().equals(previous, next);

/// [_sameContent] for drift's query result classes, which have no `==`.
bool _sameTabsWithRootAndDepth(
  List<TabsWithRootAndDepthResult> previous,
  List<TabsWithRootAndDepthResult> next,
) {
  if (previous.length != next.length) return false;
  for (var i = 0; i < previous.length; i++) {
    final a = previous[i];
    final b = next[i];
    if (a.id != b.id ||
        a.parentId != b.parentId ||
        a.orderKey != b.orderKey ||
        a.rootId != b.rootId ||
        a.depth != b.depth) {
      return false;
    }
  }
  return true;
}

/// [_sameContent] for drift's query result classes, which have no `==`.
bool _sameTabTrees(List<TabTreesResult> previous, List<TabTreesResult> next) {
  if (previous.length != next.length) return false;
  for (var i = 0; i < previous.length; i++) {
    final a = previous[i];
    final b = next[i];
    if (a.rootTabId != b.rootTabId ||
        a.latestTabId != b.latestTabId ||
        a.latestTimestamp != b.latestTimestamp ||
        a.totalTabs != b.totalTabs) {
      return false;
    }
  }
  return true;
}

@Riverpod(keepAlive: true)
Stream<List<ContainerDataWithCount>> watchContainersWithCount(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.definitionsDrift.containersWithCount().watch().distinct(
    _sameContent,
  );
}

/// The containers without their tab counts. Unlike [watchContainersWithCount],
/// its query does not re-run on every write to a tab, so it suits work too
/// costly to repeat that often.
@Riverpod()
Stream<List<ContainerData>> watchContainers(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.allContainers().watch().distinct(_sameContent);
}

/// When each container was last used, keyed by container id. See
/// `ContainerDao.getContainerLastUsed`.
///
/// Kept alive like [watchContainersWithCount]: the accordion leaves the tree
/// whenever a sheet hides the switcher, and an auto-disposed stream would
/// leave it without an order for a frame each time it comes back.
@Riverpod(keepAlive: true)
Stream<Map<String, DateTime>> watchContainerLastUsed(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao
      .getContainerLastUsed()
      .watch()
      .map(Map.fromEntries)
      .distinct(_sameContent);
}

/// Which container each closed tab ran in, for the recently closed list.
@Riverpod()
Stream<List<ClosedTabContainerData>> watchClosedTabContainers(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.watchClosedTabContainers();
}

/// The destinations a container-cycling gesture steps through, in the order
/// the container chips render them: the unassigned pseudo-container (`null`)
/// first, then the containers themselves.
///
/// Synced tabs and the group-suggestions chip are deliberately left out — they
/// are not containers, and landing on them mid-swipe would be a dead end.
@Riverpod()
List<ContainerData?> containerCycleOrder(Ref ref) {
  final containers = ref.watch(
    watchContainersWithCountProvider.select((value) => value.value),
  );

  return [null, ...?containers];
}

@Riverpod()
AsyncValue<List<ContainerDataWithCount>> matchSortedContainersWithCount(
  Ref ref,
  String? searchText,
) {
  return ref.watch(
    watchContainersWithCountProvider.select((value) {
      if (searchText.isEmpty) {
        return value;
      }

      return value.whenData(
        (cb) => TokenizedFilter.sort(
          items: cb,
          toString: (item) => item.name,
          query: searchText!,
        ).filtered,
      );
    }),
  );
}

@Riverpod()
Stream<List<String>> watchContainerTabIds(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final db = ref.watch(tabDatabaseProvider);

  switch (containerFilter) {
    case ContainerFilterById(:final containerId):
      return db.containerDao
          .getContainerTabIds(containerId)
          .watch()
          .distinct(_sameContent);
    case ContainerFilterDisabled():
      return db.tabDao.getAllTabIds().watch().distinct(_sameContent);
  }
}

@Riverpod(keepAlive: true)
Stream<List<TabSummary>> watchTabsFifo(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);

  return db.tabDao.getTabsFifo().watch().distinct(_sameContent);
}

@Riverpod()
Future<int> containerTabCount(Ref ref, ContainerFilter containerFilter) {
  return ref.watch(
    watchContainerTabIdsProvider(
      containerFilter,
    ).selectAsync((tabs) => tabs.length),
  );
}

@Riverpod()
Stream<List<TabTreesResult>> watchTabTrees(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final db = ref.watch(tabDatabaseProvider);

  return switch (containerFilter) {
    ContainerFilterById(:final containerId) =>
      db.definitionsDrift
          .tabTrees(containerId: containerId, skipContainerCheck: false)
          .watch()
          .distinct(_sameTabTrees),
    ContainerFilterDisabled() =>
      db.definitionsDrift
          .tabTrees(containerId: null, skipContainerCheck: true)
          .watch()
          .distinct(_sameTabTrees),
  };
}

@Riverpod()
Stream<List<TabsWithRootAndDepthResult>> watchTabsWithRootAndDepth(
  Ref ref,
  String? containerId,
) {
  final db = ref.watch(tabDatabaseProvider);
  return db.definitionsDrift
      .tabsWithRootAndDepth(containerId: containerId)
      .watch()
      .distinct(_sameTabsWithRootAndDepth);
}

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.
@Riverpod()
Stream<TabSummary?> watchTabDbData(Ref ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.getTabSummaryById(tabId).watchSingleOrNull();
}

@Riverpod()
Stream<Map<String, String?>> watchTabDescendants(Ref ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.definitionsDrift
      .unorderedTabDescendants(tabId: tabId)
      .watch()
      .map((results) {
        return Map.fromEntries(
          results.map((pair) => MapEntry(pair.id, pair.parentId)),
        );
      })
      .distinct(_sameContent);
}

@Riverpod()
Stream<List<TabSummary>> watchContainerTabsData(Ref ref, String? containerId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao
      .getContainerTabsData(containerId)
      .watch()
      .distinct(_sameContent);
}

/// Whether a container menu for [containerId] offers closing its isolated
/// tabs. Closing them is a way out, not creation: it stays while the scope
/// still holds isolated tabs, even with isolated tabs hidden (P5).
///
/// The tab stream is watched only while isolated tabs are hidden: a container
/// menu is built for every container chip, and the stream is only needed then.
@Riverpod()
bool closeIsolatedTabsShown(Ref ref, String? containerId) {
  final isolatedTabsShown = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.isolatedTabEntryPointsShown,
    ),
  );
  if (isolatedTabsShown) return true;

  return ref.watch(
    watchContainerTabsDataProvider(containerId).select(
      (tabs) =>
          tabs.value?.any((tab) => tab.tabMode == TabModeDbValue.isolated) ??
          false,
    ),
  );
}

/// What a tab's menu needs to keep the ways out of a container while
/// containers are hidden (P5): whether [tabId] is in a container, and whether
/// its site is assigned to one. Neither applies while containers are shown,
/// or for a menu without container rows ([enabled]): every tab's menu would
/// otherwise hold two database streams open for nothing.
@Riverpod()
({bool inContainer, bool siteAssigned}) hiddenContainerWayOut(
  Ref ref,
  String tabId, {
  required bool enabled,
}) {
  const none = (inContainer: false, siteAssigned: false);
  if (!enabled) return none;

  final containersShown = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.containerEntryPointsShown,
    ),
  );
  if (containersShown) return none;

  final inContainer = ref.watch(
    watchContainerTabIdProvider(tabId).select((value) => value.value != null),
  );
  final siteAssigned = ref.watch(
    watchIsSiteAssignedToContainerProvider(
      tabId,
    ).select((value) => value.value ?? false),
  );
  return (inContainer: inContainer, siteAssigned: siteAssigned);
}

@Riverpod(keepAlive: true)
Stream<Set<String>> watchPinnedTabIds(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getPinnedTabIds()
      .watch()
      .map((ids) => ids.toSet())
      .distinct(_sameContent);
}

/// Every "Keep awake" tab (D30), by the database.
@Riverpod(keepAlive: true)
Stream<Set<String>> watchSleepExemptTabIds(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getSleepExemptTabIds()
      .watch()
      .map((ids) => ids.toSet())
      .distinct(_sameContent);
}

/// Whether [tabId] is kept awake: automatic sleep leaves it alone.
@Riverpod()
bool isTabSleepExempt(Ref ref, String tabId) {
  return ref.watch(
    watchSleepExemptTabIdsProvider.select(
      (value) => value.value?.contains(tabId) ?? false,
    ),
  );
}

/// The containers that freeze automatically now (phase C2): with a schedule
/// and a context of their own, while the freeze feature is shown
/// ([containerAutoFreezeSchedules]). Empty until those are known.
@Riverpod()
EquatableValue<Set<String>> autoFreezingContainerIds(Ref ref) => ref.watch(
  containerAutoFreezeSchedulesProvider.select(
    (schedules) => EquatableValue({
      for (final schedule in schedules?.value ?? const <ContainerAutoFreeze>[])
        schedule.ownerId,
    }),
  ),
);

/// The containers native watches for an automatic freeze (phase C2): those
/// with a schedule and a context of their own, each with its own context and
/// those of its isolated tabs, while the freeze feature is shown (hidden
/// means no automatic freeze, H1). Null until the containers and isolated
/// tabs are known.
///
/// The contexts are for detection only. A due container goes to Dart, whose
/// gated preflight reads its members afresh (D21), so a list that lags a
/// move by a moment only delays or wastes one due event.
@Riverpod(keepAlive: true)
EquatableValue<List<ContainerAutoFreeze>>? containerAutoFreezeSchedules(
  Ref ref,
) {
  final shown = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.isFeatureShown(FeatureId.containerFreeze),
    ),
  );
  if (!shown) return EquatableValue(const []);

  // The keepAlive list, which the container UI keeps running anyway; the
  // select drops the re-emissions its tab counts cause.
  final scheduled = ref
      .watch(
        watchContainersWithCountProvider.select((value) {
          if (!value.hasValue) return null;
          return EquatableValue([
            for (final container in value.requireValue)
              if ((
                    container.metadata.contextualIdentity,
                    container.metadata.autoFreezeAfterMinutes,
                  )
                  case (final identity?, final minutes?))
                (id: container.id, identity: identity, minutes: minutes),
          ]);
        }),
      )
      ?.value;
  if (scheduled == null) return null;
  if (scheduled.isEmpty) return EquatableValue(const []);

  final isolation = ref
      .watch(
        watchIsolatedContextContainerMapProvider.select(
          (value) => value.hasValue ? EquatableValue(value.requireValue) : null,
        ),
      )
      ?.value;
  if (isolation == null) return null;

  return EquatableValue([
    for (final container in scheduled)
      ContainerAutoFreeze(
        ownerId: container.id,
        contextIds: [
          container.identity,
          ...[
            for (final MapEntry(key: contextId, value: owners)
                in isolation.entries)
              if (owners.contains(container.id)) contextId,
          ]..sort(),
        ],
        afterMinutes: container.minutes,
      ),
  ]);
}

/// Whether [tabId]'s "Keep awake" changes anything now (D30): the tab is
/// kept awake, and automatic sleep is on or its container freezes
/// automatically. With automatic sleep off, the shared container list is read
/// while container freeze is shown; the kept-awake tabs only while some
/// container freezes automatically, and a tab's container only for a
/// kept-awake tab.
@Riverpod()
bool isTabKeptAwakeShown(Ref ref, String tabId) {
  final autoSleep = ref.watch(
    generalSettingsWithDefaultsProvider.select((s) => s.autoSleepTabs),
  );
  if (autoSleep) return ref.watch(isTabSleepExemptProvider(tabId));

  final freezing = ref.watch(autoFreezingContainerIdsProvider).value;
  if (freezing.isEmpty) return false;
  if (!ref.watch(isTabSleepExemptProvider(tabId))) return false;
  final containerId = ref.watch(
    watchContainerTabIdProvider(tabId).select((value) => value.value),
  );
  return freezing.contains(containerId);
}

/// Whether the tab menu offers "Keep awake" for [tabId]: where it changes
/// something (automatic sleep is on, or the tab's container freezes
/// automatically), and for a tab already kept awake, so it can be allowed to
/// sleep again. [isTabKeptAwakeShown] is the badge: it also needs the tab to
/// be kept awake.
@Riverpod()
bool isTabKeepAwakeOffered(Ref ref, String tabId) {
  final autoSleep = ref.watch(
    generalSettingsWithDefaultsProvider.select((s) => s.autoSleepTabs),
  );
  if (autoSleep) return true;
  if (ref.watch(isTabSleepExemptProvider(tabId))) return true;

  final freezing = ref.watch(autoFreezingContainerIdsProvider).value;
  if (freezing.isEmpty) return false;
  final containerId = ref.watch(
    watchContainerTabIdProvider(tabId).select((value) => value.value),
  );
  return freezing.contains(containerId);
}

/// Every locked tab, by the database. A tab whose unlock did not finish is
/// not in it; [effectivelyLockedTabIds] adds those.
@Riverpod(keepAlive: true)
Stream<Set<String>> watchLockedTabIds(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getLockedTabIds()
      .watch()
      .map((ids) => ids.toSet())
      .distinct(_sameContent);
}

/// The tabs that count as locked: locked in the database, or unlocked there by
/// an unlock that did not finish natively ([UnlockIncompleteTabs]). What every
/// lock indicator and close control follows.
@Riverpod(keepAlive: true)
EquatableValue<Set<String>> effectivelyLockedTabIds(Ref ref) {
  final locked = ref.watch(
    watchLockedTabIdsProvider.select(
      (value) => EquatableValue(value.value ?? const <String>{}),
    ),
  );
  final unlockIncomplete = ref.watch(unlockIncompleteTabsProvider);
  return EquatableValue({...locked.value, ...unlockIncomplete.value});
}

/// Whether [tabId] counts as locked; see [effectivelyLockedTabIds]. False
/// for no tab, without following the locks: a preview's or an empty slot's.
@Riverpod()
bool isTabLocked(Ref ref, String? tabId) {
  if (tabId == null) return false;
  return ref.watch(
    effectivelyLockedTabIdsProvider.select((ids) => ids.value.contains(tabId)),
  );
}

/// Whether [tabId]'s unlock did not finish, so it keeps its lock with a
/// warning and offers to retry.
@Riverpod()
bool isTabUnlockIncomplete(Ref ref, String tabId) {
  return ref.watch(
    unlockIncompleteTabsProvider.select((ids) => ids.value.contains(tabId)),
  );
}

@Riverpod()
Stream<Map<String, DateTime>> watchTabTimestamps(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getTabTimestamps()
      .watch()
      .map(Map.fromEntries)
      .distinct(_sameContent);
}

@Riverpod(keepAlive: true)
Stream<Map<String, String>> watchTabOrderKeys(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getTabOrderKeys()
      .watch()
      .map(Map.fromEntries)
      .distinct(_sameContent);
}

@Riverpod()
Stream<ContainerData?> watchContainerData(Ref ref, String containerId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.getContainerData(containerId).watchSingleOrNull();
}

@Riverpod()
Stream<String?> watchContainerTabId(Ref ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.getTabContainerId(tabId).watchSingleOrNull();
}

@Riverpod()
Stream<ContainerData?> watchTabContainerData(Ref ref, String? tabId) {
  if (tabId == null) {
    return const Stream.empty();
  }

  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.getTabContainerData(tabId).watchSingleOrNull();
}

@Riverpod()
Stream<Map<String, String?>> watchTabsContainerId(
  Ref ref,
  EquatableValue<List<String>> tabIds,
) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .getTabsContainerId(tabIds.value)
      .watch()
      .map(Map.fromEntries)
      .distinct(_sameContent);
}

@Riverpod(keepAlive: true)
Stream<List<SiteAssignment>> watchAllAssignedSites(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.allAssignedSites().watch().distinct(_sameContent);
}

/// Strict-mode enforcement map: each Gecko cookie-store context that must be
/// enforced (a strict container's base context, plus the isolation contexts of
/// its isolated tabs) mapped to the base contextualIdentities its site
/// assignments are keyed on. Replicated to the container-proxy extension by
/// ProxySettingsReplication.
///
/// Empty while strict mode is hidden (`container.strict_mode`): the
/// containers keep the option, and it applies again once shown. Watching the
/// switch re-sends the policies whenever it changes.
@Riverpod(keepAlive: true)
Stream<Map<String, List<String>>> watchStrictContextAssignments(Ref ref) {
  final strictModeShown = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.isFeatureShown(FeatureId.containerStrictMode),
    ),
  );
  if (!strictModeShown) return Stream.value(const {});

  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao
      .strictContextAssignments()
      .watch()
      .map((rows) {
        final assignments = <String, Set<String>>{};
        for (final row in rows) {
          final contextId = row.contextId;
          final assignmentContextId = row.assignmentContextId;
          if (contextId == null || assignmentContextId == null) continue;

          assignments
              .putIfAbsent(contextId, () => <String>{})
              .add(assignmentContextId);
        }

        return {
          for (final entry in assignments.entries)
            entry.key: entry.value.toList()..sort(),
        };
      })
      .distinct(_sameContent);
}

/// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
/// assigned to containers. Used by ProxySettingsReplication to manage proxy
/// aliases for isolated contexts.
///
/// Returns a map from isolation context ID to the set of container IDs it
/// appears in. An isolation context needs an explicit routing alias if any
/// associated container has a proxy connection or bypasses global routing.
@Riverpod(keepAlive: true)
Stream<Map<String, Set<String>>> watchIsolatedContextContainerMap(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao
      .isolatedContextContainerPairs()
      .watch()
      .map((pairs) {
        final map = <String, Set<String>>{};
        for (final p in pairs) {
          map.putIfAbsent(p.isolationContextId!, () => {}).add(p.containerId!);
        }
        return map;
      })
      .distinct(_sameContent);
}

/// Whether the site [tabId] shows is assigned to a container. Keyed by tab, so
/// a menu opened for a tab other than the selected one asks about its own.
@Riverpod()
Stream<bool> watchIsSiteAssignedToContainer(Ref ref, String tabId) {
  final currentUri = ref.watch(
    tabStateProvider(
      tabId,
    ).select((value) => value?.url ?? TabState.$default('').url),
  );

  final db = ref.watch(tabDatabaseProvider);
  return db.containerDao.allAssignedSites().watch().map((assignments) {
    return assignments.any(
      (a) => siteAssignmentMatches(a.assignedSite, currentUri),
    );
  });
}

/// The tabs of the container [tabId] is in. Loading until [tabId] itself is
/// read, so they are never those of another container.
@Riverpod()
AsyncValue<List<TabSummary>> watchTabContainerTabsData(Ref ref, String tabId) {
  final tab = ref.watch(watchTabDbDataProvider(tabId));
  if (!tab.hasValue) return const AsyncLoading();

  return ref.watch(watchContainerTabsDataProvider(tab.value?.containerId));
}

/// Whether a tab preview draws the pin badge on [tabId]: where it shows one
/// at all ([enabled]) and the tab is pinned. Previews without the badge do
/// not follow the pinned tabs.
@Riverpod()
bool tabPinBadgeShown(Ref ref, String tabId, {required bool enabled}) {
  if (!enabled) return false;
  return ref.watch(
    watchPinnedTabIdsProvider.select((v) => v.value?.contains(tabId) ?? false),
  );
}

/// How many tabs are in no container, for a chip that counts them itself
/// ([enabled]); 0 without reading them for one given its count.
@Riverpod()
int unassignedTabCount(Ref ref, {required bool enabled}) {
  if (!enabled) return 0;
  return ref.watch(
    containerTabCountProvider(
      // ignore: provider_parameters
      ContainerFilterById(containerId: null),
    ).select((value) => value.value ?? 0),
  );
}
