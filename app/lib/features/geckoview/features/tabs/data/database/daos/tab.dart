/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

import 'package:drift/drift.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with $TabDaoMixin {
  final _undoHistory = <String, TabData>{};
  Timer? _clearHistoryTimer;

  TabDao(super.db);

  UpdateStatement<Tab, TabData> _updateByIdStatement(String id) =>
      db.tab.update()..where((t) => t.id.equals(id));

  Selectable<TabData> allTabData() => db.tab.select();

  SingleOrNullSelectable<TabData> getTabDataById(String id) =>
      db.tab.select()..where((t) => t.id.equals(id));

  SingleOrNullSelectable<bool?> getTabIsPrivate(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.isPrivate])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.isPrivate));
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

  Future<String> _generateOrderKey({
    required Value<String?> parentId,
    required Value<String?> containerId,
  }) async {
    if (parentId.value.isNotEmpty) {
      return await db.containerDao
              .generateOrderKeyAfterTabId(containerId.value, parentId.value!)
              .getSingleOrNull() ??
          await db.containerDao
              .generateLeadingOrderKey(containerId.value)
              .getSingle();
    } else {
      return db.containerDao
          .generateLeadingOrderKey(containerId.value)
          .getSingle();
    }
  }

  Future<String> upsertTabTransactional(
    Future<String> Function() createTab, {
    required Value<bool?> isPrivate,
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
  }) {
    return db.transaction(() async {
      final tabId = await createTab();
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(parentId: parentId, containerId: containerId);

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          source: TabSource.manual,
          timestamp: DateTime.now(),
          containerId: containerId,
          url: url,
          title: title,
          isPrivate: isPrivate,
          orderKey: currentOrderKey,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            source: const Value(TabSource.manual),
            parentId: parentId,
            containerId: containerId,
            url: url,
            title: title,
            isPrivate: isPrivate,
            orderKey: Value.absentIfNull(orderKey.value),
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
    required Value<bool?> isPrivate,
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
  }) {
    return db.transaction(() async {
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(parentId: parentId, containerId: containerId);

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          source: source,
          timestamp: DateTime.now(),
          containerId: containerId,
          orderKey: currentOrderKey,
          isPrivate: isPrivate,
          url: url,
          title: title,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            source: Value(source),
            parentId: parentId,
            containerId: containerId,
            url: url,
            title: title,
            isPrivate: isPrivate,
            orderKey: Value.absentIfNull(orderKey.value),
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

  Future<void> assignOrderKey(String id, {required String orderKey}) {
    final statement = _updateByIdStatement(id);
    return statement.write(TabCompanion(orderKey: Value(orderKey)));
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
        extractedContentMarkdown: Value(extractedContentMarkdown),
        extractedContentPlain: Value(extractedContentPlain),
        fullContentMarkdown: Value(fullContentMarkdown),
        fullContentPlain: Value(fullContentPlain),
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

        if (previousState?.parentId != state.parentId && state.parentId != null) {
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
      final existingParentIds =
          await getExistingTabIds(parentIdsToValidate).get().then((ids) => ids.toSet());

      // Complete validation map
      for (final state in next.values) {
        final previousState = previous?[state.id];

        if (previousState?.parentId != state.parentId) {
          if (!validatedParentIds.containsKey(state.id)) {
            // This parent ID needed database validation
            if (state.parentId != null && existingParentIds.contains(state.parentId)) {
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
              previousState.parentId != state.parentId) {
            batch.update(
              db.tab,
              TabCompanion(
                parentId: validatedParentIds.containsKey(state.id)
                    ? Value(validatedParentIds[state.id])
                    : const Value.absent(),
                url: (previousState?.url != state.url)
                    ? Value(state.url)
                    : const Value.absent(),
                title: (previousState?.title != state.title)
                    ? Value(state.title)
                    : const Value.absent(),
              ),
              where: (t) => t.id.equals(state.id),
            );
          }
        }
      });
    });
  }

  Future<void> syncTabs({required List<String> retainTabIds}) {
    return db.transaction(() async {
      final deleted =
          await (db.tab.delete()..where((t) => t.id.isNotIn(retainTabIds)))
              .goAndReturn();

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
    });
  }

  Selectable<TabQueryResult> queryTabs({
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    required String searchString,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.definitionsDrift.queryTabsFullContent(
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
      );
    } else {
      return db.definitionsDrift.queryTabsBasic(
        query: db.buildLikeQuery(searchString),
      );
    }
  }
}
