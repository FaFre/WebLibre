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

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/tab_parent_change.dart';

class SyncTabsResult {
  final Set<String> deletedIsolationContextIds;
  final int deletedCount;

  const SyncTabsResult({
    required this.deletedIsolationContextIds,
    required this.deletedCount,
  });
}

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with $TabDaoMixin {
  final _undoHistory = <String, TabData>{};
  Timer? _clearHistoryTimer;

  static const closedTabTombstoneTtl = Duration(hours: 24);

  /// Soft cap for stored extracted/full content bytes (UTF-16 code units).
  /// The trigram FTS index expansion is roughly 5–10x the source size, so an
  /// uncapped multi-MB page DOM blows up the shadow tables disproportionately.
  /// Anything above the cap is truncated at write time; the tail is rarely
  /// useful for in-page text search anyway.
  static const _contentSizeCap = 256 * 1024;

  static String? _capContent(String? value) {
    if (value == null) return null;
    if (value.length <= _contentSizeCap) return value;
    return value.substring(0, _contentSizeCap);
  }

  TabDao(super.db);

  UpdateStatement<Tab, TabData> _updateByIdStatement(String id) =>
      db.tab.update()..where((t) => t.id.equals(id));

  Selectable<TabData> allTabData() => db.tab.select();

  SingleOrNullSelectable<TabData> getTabDataById(String id) =>
      db.tab.select()..where((t) => t.id.equals(id));

  SingleOrNullSelectable<TabMode> getTabMode(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.tabMode, db.tab.isolationContextId])
      ..where(db.tab.id.equals(tabId));

    return query.map(
      (row) => TabMode.fromDbValue(
        row.readWithConverter(db.tab.tabMode)!,
        isolationContextId: row.read(db.tab.isolationContextId),
      ),
    );
  }

  SingleOrNullSelectable<String?> getTabIsolationContextId(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.isolationContextId])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.isolationContextId));
  }

  Selectable<String> getAllTabIds() {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  /// Validates multiple tab IDs and returns only those that exist in the database.
  Selectable<String> getExistingTabIds(Iterable<String> tabIds) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(db.tab.id.isIn(tabIds));

    return query.map((row) => row.read(db.tab.id)!);
  }

  Selectable<TabData> getTabsFifo({int limit = 25}) {
    return select(db.tab)
      ..limit(limit)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
  }

  Selectable<TabData> getContainerTabsFifo(
    String? containerId, {
    int limit = 25,
  }) {
    return select(db.tab)
      ..where(
        (t) => containerId != null
            ? t.containerId.equals(containerId)
            : t.containerId.isNull(),
      )
      ..limit(limit)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
  }

  SingleOrNullSelectable<String?> getTabContainerId(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.containerId])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.containerId));
  }

  SingleOrNullSelectable<ContainerData?> getTabContainerData(String tabId) {
    final query = select(db.tab).join([
      innerJoin(db.container, db.container.id.equalsExp(db.tab.containerId)),
    ])..where(db.tab.id.equals(tabId));

    return query.map((row) => row.readTableOrNull(db.container));
  }

  Selectable<MapEntry<String, String?>> getTabsContainerId(
    Iterable<String> tabIds,
  ) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id, db.tab.containerId])
      ..where(db.tab.id.isIn(tabIds));

    return query.map(
      (row) => MapEntry(row.read(db.tab.id)!, row.read(db.tab.containerId)),
    );
  }

  Selectable<MapEntry<String, String>> getTabOrderKeys() {
    final query = selectOnly(db.tab)..addColumns([db.tab.id, db.tab.orderKey]);

    return query.map(
      (row) => MapEntry(row.read(db.tab.id)!, row.read(db.tab.orderKey)!),
    );
  }

  Future<String> _generateOrderKey({
    required Value<String?> parentId,
    required Value<String?> containerId,
    Value<String?> afterTabId = const Value.absent(),
  }) async {
    // Explicit "place after this tab" wins regardless of parent.
    if (afterTabId.present && afterTabId.value != null) {
      final key = await db.containerDao
          .generateOrderKeyAfterTabId(containerId.value, afterTabId.value!)
          .getSingleOrNull();
      if (key != null) {
        return key;
      }
    }

    if (parentId.value.isNotEmpty) {
      // Place new child after the last existing sibling, falling back to
      // immediately after the parent if there are none yet.
      final lastChildId = await db.containerDao
          .getLastChildTabId(containerId.value, parentId.value!)
          .getSingleOrNull();

      final lastChildSubtreeId = lastChildId == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
              lastChildId,
              containerId: containerId.value,
            ).getSingleOrNull();

      final anchorTabId = lastChildSubtreeId ?? lastChildId ?? parentId.value!;

      final key = await db.containerDao
          .generateOrderKeyAfterTabId(containerId.value, anchorTabId)
          .getSingleOrNull();
      if (key != null) {
        return key;
      }
      // Defensive fallback: covers both "parent row not present" *and* the
      // cross-container case where the parent lives in a different container
      // than `containerId.value` (then `getLastChildTabId` and
      // `generateOrderKeyAfterTabId` both yield null because they filter on
      // the new container). In either case append to the end.
    }

    // Root tabs (or unresolved parent) always append to the end of the list.
    // Display direction is applied at render time via TabListDirection /
    // TabBarDirection settings, so we never need to insert at the front.
    return db.containerDao
        .generateTrailingOrderKey(containerId.value)
        .getSingle();
  }

  Future<String> upsertTabTransactional(
    Future<String> Function() createTab, {
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
    Value<String?> afterTabId = const Value.absent(),
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<TabMode> tabMode = const Value.absent(),
  }) {
    return db.transaction(() async {
      final tabId = await createTab();
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(
            parentId: parentId,
            containerId: containerId,
            afterTabId: afterTabId,
          );
      final Value<TabModeDbValue> persistedTabMode = tabMode.present
          ? Value(tabMode.value.toDbValue())
          : const Value.absent();
      final Value<String?> isolationContextId = tabMode.present
          ? Value(tabMode.value.isolationContextId)
          : const Value.absent();

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          source: TabSource.manual,
          timestamp: DateTime.now(),
          containerId: containerId,
          url: url,
          title: title,
          orderKey: currentOrderKey,
          tabMode: persistedTabMode,
          isolationContextId: isolationContextId,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            source: const Value(TabSource.manual),
            parentId: parentId,
            containerId: containerId,
            url: url,
            title: title,
            orderKey: Value.absentIfNull(orderKey.value),
            tabMode: persistedTabMode,
            isolationContextId: isolationContextId,
          ),
        ),
      );

      return tabId;
    });
  }

  //Upsert an tab only if there is no container assigned yet
  Future<String> insertTab(
    String tabId, {
    required TabSource source,
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
    Value<String?> afterTabId = const Value.absent(),
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<TabMode> tabMode = const Value.absent(),
  }) {
    return db.transaction(() async {
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(
            parentId: parentId,
            containerId: containerId,
            afterTabId: afterTabId,
          );
      final Value<TabModeDbValue> persistedTabMode = tabMode.present
          ? Value(tabMode.value.toDbValue())
          : const Value.absent();
      final Value<String?> isolationContextId = tabMode.present
          ? Value(tabMode.value.isolationContextId)
          : const Value.absent();

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          source: source,
          timestamp: DateTime.now(),
          containerId: containerId,
          orderKey: currentOrderKey,
          url: url,
          title: title,
          tabMode: persistedTabMode,
          isolationContextId: isolationContextId,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            source: Value(source),
            parentId: parentId,
            containerId: containerId,
            url: url,
            title: title,
            orderKey: Value.absentIfNull(orderKey.value),
            tabMode: persistedTabMode,
            isolationContextId: isolationContextId,
          ),
          where: (old) => old.source.isSmallerThanValue(source.index),
        ),
      );

      return tabId;
    });
  }

  Future<void> assignContainer(String id, {required String? containerId}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(containerId: Value(containerId)));
  }

  Future<void> addClosedTabTombstones(
    Iterable<String> tabIds, {
    DateTime? closedAt,
  }) async {
    final uniqueIds = tabIds.toSet();
    if (uniqueIds.isEmpty) {
      return;
    }

    final effectiveClosedAt = closedAt ?? DateTime.now();

    await batch((batch) {
      for (final tabId in uniqueIds) {
        batch.insert(
          db.closedTabTombstone,
          ClosedTabTombstoneCompanion.insert(
            tabId: tabId,
            closedAt: effectiveClosedAt,
          ),
          onConflict: DoUpdate(
            (_) =>
                ClosedTabTombstoneCompanion(closedAt: Value(effectiveClosedAt)),
          ),
        );
      }
    });
  }

  Future<void> deleteClosedTabTombstones(Iterable<String> tabIds) {
    final uniqueIds = tabIds.toSet();
    if (uniqueIds.isEmpty) {
      return Future.value();
    }

    return (db.closedTabTombstone.delete()
          ..where((t) => t.tabId.isIn(uniqueIds)))
        .go();
  }

  Future<void> pruneExpiredClosedTabTombstones({
    Duration ttl = closedTabTombstoneTtl,
    DateTime? now,
  }) {
    final cutoff = (now ?? DateTime.now()).subtract(ttl);

    return (db.closedTabTombstone.delete()
          ..where((t) => t.closedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }

  Future<Set<String>> getStartupRestoredClosedTabIds(
    Iterable<String> tabIds, {
    required DateTime sessionStartedAt,
    Duration ttl = closedTabTombstoneTtl,
    DateTime? now,
  }) async {
    final uniqueIds = tabIds.toSet();
    if (uniqueIds.isEmpty) {
      return const <String>{};
    }

    final freshnessCutoff = (now ?? DateTime.now()).subtract(ttl);
    final query = selectOnly(db.closedTabTombstone)
      ..addColumns([db.closedTabTombstone.tabId])
      ..where(
        db.closedTabTombstone.tabId.isIn(uniqueIds) &
            db.closedTabTombstone.closedAt.isSmallerThanValue(
              sessionStartedAt,
            ) &
            db.closedTabTombstone.closedAt.isBiggerOrEqualValue(
              freshnessCutoff,
            ),
      );

    return query
        .map((row) => row.read(db.closedTabTombstone.tabId)!)
        .get()
        .then((rows) => rows.toSet());
  }

  Future<Map<String, String>> _containerIdsByContextualIdentity(
    Iterable<String> contextIds,
  ) async {
    final uniqueContextIds = contextIds.toSet();
    if (uniqueContextIds.isEmpty) {
      return const <String, String>{};
    }

    final rows = await db.definitionsDrift
        .containerIdsByContextualIdentities(
          contextIds: uniqueContextIds.toList(growable: false),
        )
        .get();

    return {for (final row in rows) row.contextualIdentity: row.id};
  }

  Future<void> reorderTabs({
    required List<String> movingTabIds,
    required String? previousTabId,
    required String? nextTabId,
    TabParentChange parentChange = const TabParentChange.unchanged(),
  }) {
    if (movingTabIds.isEmpty) {
      return Future.value();
    }

    return db.transaction(() async {
      final anchorIds = [
        if (previousTabId != null) previousTabId,
        if (nextTabId != null) nextTabId,
      ];

      final anchors = anchorIds.isEmpty
          ? const <String, TabData>{}
          : {
              for (final tab in await (select(
                db.tab,
              )..where((t) => t.id.isIn(anchorIds))).get())
                tab.id: tab,
            };

      final previousTab = previousTabId == null ? null : anchors[previousTabId];
      final nextTab = nextTabId == null ? null : anchors[nextTabId];
      final previousRank = previousTab == null
          ? null
          : LexoRank.parse(previousTab.orderKey);
      final nextRank = nextTab == null
          ? null
          : LexoRank.parse(nextTab.orderKey);

      final orderKeys = _generateOrderKeysBetween(
        count: movingTabIds.length,
        previousRank: previousRank,
        nextRank: nextRank,
      );

      // Resolve the parent_id / container_id companion values once.
      //
      // For a `TabParentToSpecific` whose target row is missing, fall back
      // to "unchanged" so we don't issue a parent_id FK violation — the
      // caller passed a stale id, but the order_key change is still
      // useful. The container cascade fires whenever the parent_id is
      // being assigned to a concrete tab (including unassigned parents,
      // container_id = null), since `tabsWithRootAndDepth` is
      // container-scoped and a divergent child would vanish from
      // hierarchical views.
      Value<String?> parentValue = const Value.absent();
      Value<String?> containerValue = const Value.absent();
      switch (parentChange) {
        case TabParentUnchanged():
          break;
        case TabParentDetach():
          parentValue = const Value(null);
        case TabParentToSpecific(:final parentTabId):
          final parent =
              anchors[parentTabId] ??
              await getTabDataById(parentTabId).getSingleOrNull();
          if (parent != null) {
            parentValue = Value(parentTabId);
            containerValue = Value(parent.containerId);
          }
      }

      await batch((batch) {
        for (var i = 0; i < movingTabIds.length; i++) {
          final isRoot = i == 0;
          batch.update(
            db.tab,
            TabCompanion(
              orderKey: Value(orderKeys[i]),
              // parent_id change applies only to the moving root;
              // descendants keep their existing parent_id pointers.
              parentId: isRoot ? parentValue : const Value.absent(),
              // Container cascade applies to the whole subtree.
              containerId: containerValue,
            ),
            where: (t) => t.id.equals(movingTabIds[i]),
          );
        }
      });
    });
  }

  /// Returns the recursive set of [tabId] and its descendants.
  Future<Set<String>> _collectSubtreeIds(String tabId) async {
    final rows = await db.definitionsDrift
        .unorderedTabDescendants(tabId: tabId)
        .get();
    return {for (final r in rows) r.id};
  }

  /// Re-parents [tabId] to [newParentId] (or detaches when null).
  ///
  /// Returns `true` on success, `false` when the move was rejected
  /// (cycle, unknown tab, or no-op).
  ///
  /// - Cycle-safe: rejects when [newParentId] is the moving tab itself or
  ///   any of its descendants.
  /// - When attaching to a non-null parent, the whole moving subtree adopts
  ///   the new parent's `container_id` (otherwise the row vanishes from
  ///   hierarchical views, which are container-scoped).
  /// - Slots the moving subtree immediately after the new parent's last
  ///   existing child (or after the parent itself if it has none), as an
  ///   atomic order_key block. When detaching, order_keys are left
  ///   untouched — the tab simply becomes a root in its current slot.
  Future<bool> setTabParent({
    required String tabId,
    required String? newParentId,
  }) {
    if (tabId == newParentId) {
      return Future.value(false);
    }

    return db.transaction(() async {
      final movingTab = await getTabDataById(tabId).getSingleOrNull();
      if (movingTab == null) {
        return false;
      }
      if (movingTab.parentId == newParentId) {
        return false;
      }

      final subtreeIds = await _collectSubtreeIds(tabId);

      String? targetContainerId;
      if (newParentId != null) {
        if (subtreeIds.contains(newParentId)) {
          return false;
        }
        final newParent = await getTabDataById(newParentId).getSingleOrNull();
        if (newParent == null) {
          return false;
        }
        targetContainerId = newParent.containerId;
      } else {
        targetContainerId = movingTab.containerId;
      }

      // Cascade container update for the whole subtree when crossing
      // container boundaries. `tabsWithRootAndDepth` is container-scoped
      // — a child whose `container_id` differs from its parent's would
      // vanish from hierarchical views.
      if (targetContainerId != movingTab.containerId) {
        await (update(db.tab)..where((t) => t.id.isIn(subtreeIds))).write(
          TabCompanion(containerId: Value(targetContainerId)),
        );
      }

      if (newParentId == null) {
        // Detach: keep existing order_keys. The row becomes a root in its
        // current slot and the subtree under it stays intact.
        await _updateByIdStatement(
          tabId,
        ).write(const TabCompanion(parentId: Value(null)));
        return true;
      }

      // Pull the (now container-adjusted) subtree rows so we can re-rank
      // them as an atomic block. We must compute anchors BEFORE writing
      // the new parent_id, otherwise `getLastChildTabId(newParentId)`
      // would pick up the moving root itself as a sibling.
      final subtreeRows =
          await (select(db.tab)
                ..where((t) => t.id.isIn(subtreeIds))
                ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]))
              .get();
      final orderedIds = subtreeRows.map((r) => r.id).toList();
      if (orderedIds.isEmpty) {
        return true;
      }

      final lastSiblingId = await db.containerDao
          .getLastChildTabId(targetContainerId, newParentId)
          .getSingleOrNull();
      final lastSiblingSubtreeId = lastSiblingId == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
              lastSiblingId,
              containerId: targetContainerId,
            ).getSingleOrNull();
      final anchorId = lastSiblingSubtreeId ?? lastSiblingId ?? newParentId;

      final anchorRow = await getTabDataById(anchorId).getSingleOrNull();
      if (anchorRow == null) {
        return false;
      }
      final previousRank = LexoRank.parse(anchorRow.orderKey);

      // Next-rank = first non-subtree tab in the destination container with
      // order_key strictly greater than the anchor. Skipping subtree members
      // keeps the moved block compact even when the subtree's old keys
      // sat near the anchor in storage.
      final nextRow =
          await (select(db.tab)
                ..where((t) {
                  final containerEq = targetContainerId != null
                      ? t.containerId.equals(targetContainerId)
                      : t.containerId.isNull();
                  return containerEq &
                      t.orderKey.isBiggerThanValue(anchorRow.orderKey) &
                      t.id.isNotIn(subtreeIds);
                })
                ..orderBy([(t) => OrderingTerm.asc(t.orderKey)])
                ..limit(1))
              .getSingleOrNull();
      final nextRank = nextRow == null
          ? null
          : LexoRank.parse(nextRow.orderKey);

      final orderKeys = _generateOrderKeysBetween(
        count: orderedIds.length,
        previousRank: previousRank,
        nextRank: nextRank,
      );

      await batch((batch) {
        // parent_id change is applied on the moving root only; subtree
        // descendants keep their existing parent_id pointers.
        batch.update(
          db.tab,
          TabCompanion(
            parentId: Value(newParentId),
            orderKey: Value(orderKeys[0]),
          ),
          where: (t) => t.id.equals(orderedIds[0]),
        );
        for (var i = 1; i < orderedIds.length; i++) {
          batch.update(
            db.tab,
            TabCompanion(orderKey: Value(orderKeys[i])),
            where: (t) => t.id.equals(orderedIds[i]),
          );
        }
      });

      return true;
    });
  }

  /// Swaps a direct child with its parent: the child takes the parent's
  /// slot in the tree (parent_id + order_key), and the parent becomes a
  /// child of the (formerly) child, placed after its existing siblings.
  ///
  /// Returns `false` when [childId] has no parent or the tabs cross a
  /// container boundary (which would imply data corruption).
  Future<bool> promoteChildToParent(String childId) {
    return db.transaction(() async {
      final child = await getTabDataById(childId).getSingleOrNull();
      if (child == null || child.parentId == null) {
        return false;
      }
      final parentId = child.parentId!;
      final parent = await getTabDataById(parentId).getSingleOrNull();
      if (parent == null) {
        return false;
      }
      if (parent.containerId != child.containerId) {
        return false;
      }

      final containerId = child.containerId;

      // The (about-to-be-demoted) parent gets placed after the new
      // parent's (= former child's) existing other children. We read the
      // anchor's order_key BEFORE any writes — `generateOrderKeyAfterTabId`
      // reads from storage, so the captured key reflects pre-swap state.
      final lastChildOfChild = await db.containerDao
          .getLastChildTabId(containerId, childId)
          .getSingleOrNull();
      final lastChildSubtreeId = lastChildOfChild == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
              lastChildOfChild,
              containerId: containerId,
            ).getSingleOrNull();
      final anchorId = lastChildSubtreeId ?? lastChildOfChild ?? childId;
      final newParentOrderKey = await db.containerDao
          .generateOrderKeyAfterTabId(containerId, anchorId)
          .getSingleOrNull();
      if (newParentOrderKey == null) {
        return false;
      }

      await batch((batch) {
        batch.update(
          db.tab,
          TabCompanion(
            parentId: Value(parent.parentId),
            orderKey: Value(parent.orderKey),
          ),
          where: (t) => t.id.equals(childId),
        );
        batch.update(
          db.tab,
          TabCompanion(
            parentId: Value(childId),
            orderKey: Value(newParentOrderKey),
          ),
          where: (t) => t.id.equals(parentId),
        );
      });

      return true;
    });
  }

  /// Moves [tabId] one sibling slot up (or down) within its parent scope,
  /// carrying its whole subtree as an atomic block.
  ///
  /// Returns `false` when the tab is unknown or already at the relevant
  /// end of its sibling list.
  Future<bool> moveTabAmongSiblings(String tabId, {required bool down}) {
    // Transactional so the sibling-list read, subtree resolution, and the
    // anchor lookup all observe the same DB snapshot. `reorderTabs` opens
    // a nested savepoint internally, which is fine.
    return db.transaction(() async {
      final tab = await getTabDataById(tabId).getSingleOrNull();
      if (tab == null) {
        return false;
      }

      final siblings =
          await (select(db.tab)
                ..where((t) {
                  final containerEq = tab.containerId != null
                      ? t.containerId.equals(tab.containerId!)
                      : t.containerId.isNull();
                  final parentEq = tab.parentId != null
                      ? t.parentId.equals(tab.parentId!)
                      : t.parentId.isNull();
                  return containerEq & parentEq;
                })
                ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]))
              .get();

      final idx = siblings.indexWhere((s) => s.id == tabId);
      if (idx < 0) {
        return false;
      }
      final newIdx = down ? idx + 1 : idx - 1;
      if (newIdx < 0 || newIdx >= siblings.length) {
        return false;
      }

      final reordered = siblings.toList()..removeAt(idx);
      reordered.insert(newIdx, tab);

      final previousIdx = newIdx - 1;
      final nextIdx = newIdx + 1;
      final previousSiblingId = previousIdx >= 0
          ? reordered[previousIdx].id
          : null;
      final previousTabId = previousSiblingId == null
          ? null
          : await lastSubtreeTabIdByOrderKey(
                  previousSiblingId,
                  containerId: tab.containerId,
                ).getSingleOrNull() ??
                previousSiblingId;
      final nextTabId = nextIdx < reordered.length
          ? reordered[nextIdx].id
          : null;

      final subtreeIds = await _collectSubtreeIds(tabId);
      final subtreeRows =
          await (select(db.tab)
                ..where((t) => t.id.isIn(subtreeIds))
                ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]))
              .get();
      final movingTabIds = subtreeRows.map((r) => r.id).toList();

      await reorderTabs(
        movingTabIds: movingTabIds,
        previousTabId: previousTabId,
        nextTabId: nextTabId,
      );
      return true;
    });
  }

  List<String> _generateOrderKeysBetween({
    required int count,
    required LexoRank? previousRank,
    required LexoRank? nextRank,
  }) {
    if (count <= 0) {
      return const [];
    }

    if (previousRank == null && nextRank == null) {
      var rank = LexoRank.middle();
      return [
        for (var i = 0; i < count; i++)
          () {
            final value = rank.value;
            rank = rank.genNext();
            return value;
          }(),
      ];
    }

    if (nextRank == null) {
      var rank = previousRank!.genNext();
      return [
        for (var i = 0; i < count; i++)
          () {
            final value = rank.value;
            rank = rank.genNext();
            return value;
          }(),
      ];
    }

    if (previousRank == null) {
      var rank = nextRank;
      final reversed = <String>[];
      for (var i = 0; i < count; i++) {
        rank = rank.genPrev();
        reversed.add(rank.value);
      }
      return reversed.reversed.toList();
    }

    var upperBound = nextRank;
    final reversed = <String>[];
    for (var i = 0; i < count; i++) {
      upperBound = previousRank.genBetween(upperBound);
      reversed.add(upperBound.value);
    }
    return reversed.reversed.toList();
  }

  /// Reassigns `order_key` for grandchildren whose parent is being closed so
  /// they slot into the closing scope at the position previously occupied by
  /// their (closing) parent. Run *before* the close itself.
  ///
  /// Edge cases worth knowing about:
  ///
  /// - When the first batch of pending grandchildren has no surviving sibling
  ///   strictly before them, [previousRank] is `null` (rather than a tab in
  ///   the parent of the scope's parent). The assigned keys are correct
  ///   relative to siblings in this scope, but in a flat-by-order_key view
  ///   (e.g. the tab bar) the promoted children may now sort before unrelated
  ///   tabs from other scopes that originally sat before the closing tab in
  ///   storage. Hierarchical views mask this via `tabsWithRootAndDepth`.
  ///
  /// - Within a scope, grandchildren are emitted in DFS order through the
  ///   closing chain (`childrenByParent[closingId]` recursively), not by raw
  ///   storage order. If a user manually reordered a grandchild to sit after
  ///   one of its uncles in storage and the uncle is also closing, the DFS
  ///   walk will re-emit them in tree order — silently overriding the manual
  ///   key. This is treated as "rebuild the scope on close".
  ///
  /// - Only `order_key` is rewritten. `parent_id` is left untouched and is
  ///   normalised lazily by the `tab_maintain_parent_chain_on_delete` trigger
  ///   when the close itself runs.
  Future<void> preservePromotedChildOrderOnClose(Iterable<String> tabIds) {
    final closingIds = tabIds.toSet();
    if (closingIds.isEmpty) {
      return Future.value();
    }

    return db.transaction(() async {
      final closingTabs = await (select(
        db.tab,
      )..where((t) => t.id.isIn(closingIds))).get();

      if (closingTabs.isEmpty) {
        return;
      }

      final directChildren =
          await (select(db.tab)
                ..where((t) => t.parentId.isIn(closingIds))
                ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]))
              .get();

      final closingTabById = {for (final tab in closingTabs) tab.id: tab};
      final childrenByParent = <String, List<TabData>>{};
      for (final child in directChildren) {
        final parentId = child.parentId;
        if (parentId == null) continue;
        childrenByParent.putIfAbsent(parentId, () => []).add(child);
      }

      final promotedBoundaryCache = <String, List<TabData>>{};
      List<TabData> promotedBoundaryChildren(String closingTabId) {
        return promotedBoundaryCache.putIfAbsent(closingTabId, () {
          final result = <TabData>[];
          for (final child
              in childrenByParent[closingTabId] ?? const <TabData>[]) {
            if (closingIds.contains(child.id)) {
              result.addAll(promotedBoundaryChildren(child.id));
            } else {
              result.add(child);
            }
          }
          return result;
        });
      }

      final representativeClosingTabs = closingTabs.where(
        (tab) => !closingTabById.containsKey(tab.parentId),
      );

      final closingTabsByScope = groupBy(
        representativeClosingTabs,
        (TabData tab) => (containerId: tab.containerId, parentId: tab.parentId),
      );

      for (final entry in closingTabsByScope.entries) {
        final scope = entry.key;
        final scopedClosingTabs = entry.value.sorted(
          (a, b) => a.orderKey.compareTo(b.orderKey),
        );

        final sameScopeTabs =
            await (select(db.tab)
                  ..where((t) {
                    final sameContainer = scope.containerId != null
                        ? t.containerId.equals(scope.containerId!)
                        : t.containerId.isNull();
                    final sameParent = scope.parentId != null
                        ? t.parentId.equals(scope.parentId!)
                        : t.parentId.isNull();

                    return sameContainer &
                        sameParent &
                        t.id.isNotIn(closingIds);
                  })
                  ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]))
                .get();

        var closingIndex = 0;
        var survivorIndex = 0;
        LexoRank? previousRank;
        final pendingChildren = <TabData>[];

        Future<void> assignPendingChildren(LexoRank? nextRank) async {
          if (pendingChildren.isEmpty) {
            return;
          }

          final orderKeys = _generateOrderKeysBetween(
            count: pendingChildren.length,
            previousRank: previousRank,
            nextRank: nextRank,
          );

          for (var i = 0; i < pendingChildren.length; i++) {
            await _updateByIdStatement(
              pendingChildren[i].id,
            ).write(TabCompanion(orderKey: Value(orderKeys[i])));
          }

          pendingChildren.clear();
        }

        while (closingIndex < scopedClosingTabs.length ||
            survivorIndex < sameScopeTabs.length) {
          final nextClosing = closingIndex < scopedClosingTabs.length
              ? scopedClosingTabs[closingIndex]
              : null;
          final nextSurvivor = survivorIndex < sameScopeTabs.length
              ? sameScopeTabs[survivorIndex]
              : null;

          final takeClosing =
              nextClosing != null &&
              (nextSurvivor == null ||
                  nextClosing.orderKey.compareTo(nextSurvivor.orderKey) < 0);

          if (takeClosing) {
            pendingChildren.addAll(promotedBoundaryChildren(nextClosing.id));
            closingIndex++;
            continue;
          }

          final survivor = nextSurvivor!;
          final survivorRank = LexoRank.parse(survivor.orderKey);
          await assignPendingChildren(survivorRank);
          previousRank = survivorRank;
          survivorIndex++;
        }

        await assignPendingChildren(null);
      }
    });
  }

  Future<void> touchTab(String id, {required DateTime timestamp}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(timestamp: Value(timestamp)));
  }

  Future<void> updateTabContent(
    String id, {
    required bool isProbablyReaderable,
    required String? extractedContentMarkdown,
    required String? extractedContentPlain,
    required String? fullContentMarkdown,
    required String? fullContentPlain,
  }) async {
    final statement = _updateByIdStatement(id);

    await statement.write(
      TabCompanion(
        isProbablyReaderable: Value(isProbablyReaderable),
        extractedContentMarkdown: Value(_capContent(extractedContentMarkdown)),
        extractedContentPlain: Value(_capContent(extractedContentPlain)),
        fullContentMarkdown: Value(_capContent(fullContentMarkdown)),
        fullContentPlain: Value(_capContent(fullContentPlain)),
      ),
    );
  }

  Future<void> updateTabs(
    Map<String, TabState>? previous,
    Map<String, TabState> next,
  ) {
    return db.transaction(() async {
      // Collect parent IDs that need database validation
      final parentIdsToValidate = <String>{};
      final validatedParentIds = <String, String?>{};

      for (final state in next.values) {
        final previousState = previous?[state.id];

        if (previousState?.parentId != state.parentId &&
            state.parentId != null) {
          if (next.containsKey(state.parentId)) {
            // Parent exists in current state
            validatedParentIds[state.id] = state.parentId;
          } else {
            // Need to validate against database
            parentIdsToValidate.add(state.parentId!);
          }
        }
      }

      // Batch validate parent IDs that aren't in the current state
      final existingParentIds = await getExistingTabIds(
        parentIdsToValidate,
      ).get().then((ids) => ids.toSet());

      final containerRepairCandidates = {
        for (final state in next.values)
          if (state.contextId != null &&
              (previous?[state.id]?.contextId != state.contextId ||
                  previous?[state.id] == null))
            state.id: state.contextId!,
      };
      final currentContainerIds = containerRepairCandidates.isEmpty
          ? const <String, String?>{}
          : await getTabsContainerId(
              containerRepairCandidates.keys,
            ).get().then(Map.fromEntries);
      final repairableContexts = containerRepairCandidates.entries
          .where((entry) => currentContainerIds[entry.key] == null)
          .map((entry) => entry.value)
          .toSet();
      final containerIdsByContext = await _containerIdsByContextualIdentity(
        repairableContexts,
      );
      final repairedContainerIds = <String, String>{
        for (final entry in containerRepairCandidates.entries)
          if (currentContainerIds[entry.key] == null)
            if (containerIdsByContext[entry.value] case final containerId?)
              entry.key: containerId,
      };

      // Complete validation map
      for (final state in next.values) {
        final previousState = previous?[state.id];

        if (previousState?.parentId != state.parentId) {
          if (!validatedParentIds.containsKey(state.id)) {
            // This parent ID needed database validation
            if (state.parentId != null &&
                existingParentIds.contains(state.parentId)) {
              validatedParentIds[state.id] = state.parentId;
            } else {
              validatedParentIds[state.id] = null;
            }
          }
        }
      }

      await batch((batch) {
        for (final state in next.values) {
          final previousState = previous?[state.id];

          if (previousState == null ||
              previousState.url != state.url ||
              previousState.title != state.title ||
              previousState.parentId != state.parentId ||
              previousState.tabMode != state.tabMode ||
              repairedContainerIds.containsKey(state.id)) {
            batch.update(
              db.tab,
              TabCompanion(
                parentId: validatedParentIds.containsKey(state.id)
                    ? Value(validatedParentIds[state.id])
                    : const Value.absent(),
                containerId:
                    repairedContainerIds[state.id].mapNotNull(Value.new) ??
                    const Value.absent(),
                url: (previousState?.url != state.url)
                    ? Value(state.url)
                    : const Value.absent(),
                title: (previousState?.title != state.title)
                    ? Value(state.title)
                    : const Value.absent(),
                tabMode: (previousState?.tabMode != state.tabMode)
                    ? Value(state.tabMode.toDbValue())
                    : const Value.absent(),
                isolationContextId: (previousState?.tabMode != state.tabMode)
                    ? Value(state.isolationContextId)
                    : const Value.absent(),
              ),
              where: (t) => t.id.equals(state.id),
            );
          }
        }
      });
    });
  }

  /// Syncs DB tab rows with the engine's active tab list.
  /// Returns metadata about deleted rows for follow-up cleanup.
  Future<SyncTabsResult> syncTabs({required List<String> retainTabIds}) {
    return db.transaction(() async {
      final deleted =
          await (db.tab.delete()..where((t) => t.id.isNotIn(retainTabIds)))
              .goAndReturn();

      final deletedIsolationContextIds = <String>{
        for (final tab in deleted)
          if (tab.isolationContextId != null) tab.isolationContextId!,
      };

      if (deleted.isNotEmpty) {
        _clearHistoryTimer?.cancel();

        _undoHistory.addAll({for (final tab in deleted) tab.id: tab});

        _clearHistoryTimer = Timer(const Duration(seconds: 5), () {
          //Dont keep things in memory
          _undoHistory.clear();
        });
      }

      var currentOrderKey = await db.containerDao
          .generateLeadingOrderKey(null)
          .getSingle();

      await db.tab.insertAll(
        retainTabIds.map((id) {
          final insertable =
              _undoHistory[id] ??
              TabCompanion.insert(
                id: id,
                source: TabSource.syncEvent,
                orderKey: currentOrderKey,
                timestamp: DateTime.now(),
              );

          currentOrderKey = LexoRank.parse(currentOrderKey).genPrev().value;

          return insertable;
        }),
        onConflict: DoNothing(),
      );

      return SyncTabsResult(
        deletedIsolationContextIds: deletedIsolationContextIds,
        deletedCount: deleted.length,
      );
    });
  }

  Selectable<TabQueryResult> queryTabs({
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    required String searchString,
    int limit = 25,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.definitionsDrift.queryTabsFullContent(
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
        limit: limit,
      );
    } else {
      return db.definitionsDrift.queryTabsBasic(
        query: db.buildLikeQuery(searchString),
        limit: limit,
      );
    }
  }

  SingleSelectable<int> tabsInIsolationGroup(String contextId) {
    return db.definitionsDrift.tabsInIsolationGroup(contextId: contextId);
  }

  Selectable<String?> allIsolationContextIds() {
    return db.definitionsDrift.allIsolationContextIds();
  }

  Selectable<IsolatedContextContainerPairsResult>
  isolatedContextContainerPairs() {
    return db.definitionsDrift.isolatedContextContainerPairs();
  }

  Future<void> setPinned(String id, {required bool pinned}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(isPinned: Value(pinned)));
  }

  Selectable<String> getPinnedTabIds() {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(db.tab.isPinned.equals(true));

    return query.map((row) => row.read(db.tab.id)!);
  }

  Selectable<MapEntry<String, DateTime>> getTabTimestamps() {
    final query = selectOnly(db.tab)..addColumns([db.tab.id, db.tab.timestamp]);

    return query.map(
      (row) => MapEntry(row.read(db.tab.id)!, row.read(db.tab.timestamp)!),
    );
  }

  SingleOrNullSelectable<String> lastSubtreeTabIdByOrderKey(
    String tabId, {
    required String? containerId,
  }) {
    return db.definitionsDrift.lastSubtreeTabIdByOrderKey(
      tabId: tabId,
      containerId: containerId,
    );
  }

  Future<List<String>> getUnassignedRegularTabsOlderThan(DateTime threshold) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        db.tab.containerId.isNull() &
            db.tab.timestamp.isSmallerThanValue(threshold) &
            db.tab.tabMode.equalsValue(TabModeDbValue.regular),
      );

    return query.map((row) => row.read(db.tab.id)!).get();
  }
}
