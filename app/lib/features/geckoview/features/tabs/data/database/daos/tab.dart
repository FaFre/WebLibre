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
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';

part 'tab.g.dart';

@DriftAccessor()
class TabDao extends DatabaseAccessor<TabDatabase> with _$TabDaoMixin {
  TabDao(super.db);

  UpdateStatement<Tab, TabData> _updateByIdStatement(String id) =>
      db.tab.update()..where((t) => t.id.equals(id));

  Selectable<TabData> allTabData() => db.tab.select();

  SingleOrNullSelectable<TabData> getTabDataById(String id) =>
      db.tab.select()..where((t) => t.id.equals(id));

  Selectable<String> getAllTabIds() {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  SingleOrNullSelectable<String?> getTabContainerId(String tabId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.containerId])
      ..where(db.tab.id.equals(tabId));

    return query.map((row) => row.read(db.tab.containerId));
  }

  Future<String> _generateOrderKey({
    required Value<String?> parentId,
    required Value<String?> containerId,
  }) {
    if (parentId.value.isNotEmpty) {
      return db.containerDao
          .generateOrderKeyAfterTabId(containerId.value, parentId.value!)
          .getSingle();
    } else {
      return db.containerDao
          .generateLeadingOrderKey(containerId.value)
          .getSingle();
    }
  }

  Future<String> upsertContainerTabTransactional(
    Future<String> Function() createTab, {
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
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
          timestamp: DateTime.now(),
          containerId: containerId,
          orderKey: currentOrderKey,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            parentId: parentId,
            containerId: containerId,
            orderKey: Value.absentIfNull(orderKey.value),
          ),
        ),
      );

      return tabId;
    });
  }

  //Upsert an tab only if there is no container assigned yet
  Future<String> upsertUnassignedTab(
    String tabId, {
    required Value<String?> parentId,
    Value<String?> containerId = const Value.absent(),
    Value<String?> orderKey = const Value.absent(),
  }) {
    return db.transaction(() async {
      final currentOrderKey =
          orderKey.value ??
          await _generateOrderKey(parentId: parentId, containerId: containerId);

      await db.tab.insertOne(
        TabCompanion.insert(
          id: tabId,
          parentId: parentId,
          timestamp: DateTime.now(),
          containerId: containerId,
          orderKey: currentOrderKey,
        ),
        onConflict: DoUpdate(
          (old) => TabCompanion(
            parentId: parentId,
            containerId: containerId,
            orderKey: Value.absentIfNull(orderKey.value),
          ),
          where: (old) => old.containerId.isNull(),
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
  ) async {
    await batch((batch) {
      for (final state in next.values) {
        final previousState = previous?[state.id];

        if (previousState == null ||
            previousState.url != state.url ||
            previousState.title != state.title) {
          batch.update(
            db.tab,
            TabCompanion(
              parentId: (previousState?.parentId != state.parentId)
                  ? Value(state.parentId)
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
  }

  Future<void> syncTabs({required List<String> retainTabIds}) {
    return db.transaction(() async {
      await (db.tab.delete()..where((t) => t.id.isNotIn(retainTabIds))).go();

      var currentOrderKey = await db.containerDao
          .generateLeadingOrderKey(null)
          .getSingle();

      await db.tab.insertAll(
        retainTabIds.map((id) {
          final insertable = TabCompanion.insert(
            id: id,
            orderKey: currentOrderKey,
            timestamp: DateTime.now(),
          );

          currentOrderKey = LexoRank.parse(currentOrderKey).genPrev().value;

          return insertable;
        }),
        mode: InsertMode.insertOrIgnore,
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
      return db.queryTabsFullContent(
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
      );
    } else {
      return db.queryTabsBasic(query: db.buildLikeQuery(searchString));
    }
  }
}
