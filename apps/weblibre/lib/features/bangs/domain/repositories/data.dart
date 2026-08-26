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
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/data/models/search_history_entry.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/features/bangs/domain/services/bang_resolution.dart';

part 'data.g.dart';

@Riverpod(keepAlive: true)
class BangDataRepository extends _$BangDataRepository {
  @override
  void build() {}

  Stream<BangData?> watchBang(BangKey? key) {
    if (key != null) {
      return ref
          .read(bangDatabaseProvider)
          .bangDao
          .getBangData(key.group, key.trigger)
          .watchSingleOrNull();
    } else {
      return Stream.value(null);
    }
  }

  Stream<Map<String, List<String>>> watchCategories() {
    return ref
        .read(bangDatabaseProvider)
        .definitionsDrift
        .categoriesJson()
        .watchSingle()
        .map((json) {
          final decoded = jsonDecode(json) as Map<String, dynamic>;
          return decoded.map(
            (key, value) => MapEntry(key, (value as List<dynamic>).cast()),
          );
        });
  }

  Stream<int> watchBangCount(BangGroup group) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangCount(groups: [group])
        .watchSingle();
  }

  Stream<List<BangData>> watchBangs({
    Iterable<String>? triggers,
    Iterable<BangGroup>? groups,
    String? domain,
    ({String category, String? subCategory})? categoryFilter,
    bool? orderMostFrequentFirst,
  }) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangDataList(
          triggers: triggers,
          groups: groups,
          domain: domain,
          category: categoryFilter?.category,
          subCategory: categoryFilter?.subCategory,
          orderMostFrequentFirst: orderMostFrequentFirst,
        )
        .watch();
  }

  /// Resolves [keys] to bangs, preserving the caller's order and silently
  /// dropping keys nothing answers to.
  Stream<List<BangData>> watchPinnedBangs(List<BangKey> keys) {
    if (keys.isEmpty) {
      return Stream.value(const []);
    }

    // One query over the triggers, then paired back up by full key — the
    // trigger alone is not unique across groups.
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangDataList(triggers: keys.map((key) => key.trigger).toSet())
        .watch()
        .map((bangs) {
          final byKey = {for (final bang in bangs) bang.toKey(): bang};
          return keys.map((key) => byKey[key]).nonNulls.toList();
        });
  }

  Stream<List<BangData>> watchFrequentBangs({Iterable<BangGroup>? groups}) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getFrequentBangDataList(groups: groups)
        .watch();
  }

  Stream<List<SearchHistoryEntry>> watchSearchHistory({required int limit}) {
    final query = ref
        .read(bangDatabaseProvider)
        .definitionsDrift
        .searchHistoryEntries(limit: limit);

    return () async* {
      // Emit a direct read first so Recent Searches is populated immediately
      // on app start instead of waiting for the next bang_history write.
      yield await query.get();
      yield* query.watch();
    }();
  }

  Future<void> increaseFrequency(BangKey key) {
    return ref.read(bangDatabaseProvider).bangDao.increaseBangFrequency(key);
  }

  Future<void> addSearchEntry(
    BangGroup group,
    String trigger,
    String searchQuery, {
    required int maxEntryCount,
  }) async {
    // Skip capturing history if maxEntryCount is 0
    if (maxEntryCount <= 0) {
      return;
    }

    final db = ref.read(bangDatabaseProvider);
    //Pack in a transaction to bundle rebuilds of watch() queries
    return db.transaction(() async {
      await db.bangDao.addSearchEntry(group, trigger, searchQuery);
      await db.definitionsDrift.evictHistoryEntries(limit: maxEntryCount);
    });
  }

  Future<void> removeSearchEntry(String searchQuery) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .removeSearchEntry(searchQuery);
  }

  Future<int> clearSearchHistory() {
    return ref.read(bangDatabaseProvider).bangHistory.deleteAll();
  }

  Future<int> resetFrequencies() {
    return ref.read(bangDatabaseProvider).bangFrequency.deleteAll();
  }

  /// Keyed by the full [BangKey], not by trigger alone: a user bang and the
  /// synced one it overrides share a trigger, and resetting one must not wipe
  /// the other's usage history.
  Future<int> resetFrequency(BangKey key) {
    return ref
        .read(bangDatabaseProvider)
        .bangFrequency
        .deleteWhere(
          (t) => t.trigger.equals(key.trigger) & t.group.equalsValue(key.group),
        );
  }

  /// Resolves a trigger the user wrote inline (`!g`) to a bang, across every
  /// group and including aliases.
  Future<BangData?> resolveTrigger(String trigger) async {
    final candidates = await ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangDataByTrigger(trigger)
        .get();

    return pickBangByPrecedence(candidates, trigger);
  }

  Future<BangData?> getBang(BangKey key) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangData(key.group, key.trigger)
        .getSingleOrNull();
  }

  Future<void> upsertBang(Bang bang) {
    return ref.read(bangDatabaseProvider).bangDao.upsertBang(bang);
  }

  Future<void> deleteBang(BangKey key) {
    return ref.read(bangDatabaseProvider).syncDao.deleteBangs(key.group, [
      key.trigger,
    ]);
  }
}
