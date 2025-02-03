import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:exceptions/exceptions.dart';
import 'package:lensai/domain/services/generic_website.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/data/models/search_history_entry.dart';
import 'package:lensai/features/bangs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data.g.dart';

@Riverpod(keepAlive: true)
class BangDataRepository extends _$BangDataRepository {
  @override
  void build() {}

  Stream<BangData?> watchBang(String? trigger) {
    if (trigger != null) {
      return ref
          .read(bangDatabaseProvider)
          .bangDao
          .getBangData(trigger)
          .watchSingleOrNull();
    } else {
      return Stream.value(null);
    }
  }

  Stream<Map<String, List<String>>> watchCategories() {
    return ref
        .read(bangDatabaseProvider)
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
        .getBangCount(groups: [group]).watchSingle();
  }

  Stream<List<BangData>> watchBangs({
    Iterable<BangGroup>? groups,
    String? domain,
    ({String category, String? subCategory})? categoryFilter,
    bool? orderMostFrequentFirst,
  }) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getBangDataList(
          groups: groups,
          domain: domain,
          category: categoryFilter?.category,
          subCategory: categoryFilter?.subCategory,
          orderMostFrequentFirst: orderMostFrequentFirst,
        )
        .watch();
  }

  Stream<List<BangData>> watchFrequentBangs({Iterable<BangGroup>? groups}) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .getFrequentBangDataList(groups: groups)
        .watch();
  }

  Stream<List<SearchHistoryEntry>> watchSearchHistory({required int limit}) {
    return ref
        .read(bangDatabaseProvider)
        .searchHistoryEntries(limit: limit)
        .watch();
  }

  Future<void> increaseFrequency(String trigger) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .increaseBangFrequency(trigger);
  }

  Future<void> addSearchEntry(
    String trigger,
    String searchQuery, {
    required int maxEntryCount,
  }) {
    final db = ref.read(bangDatabaseProvider);
    //Pack in a transaction to bundle rebuilds of watch() queries
    return db.transaction(
      () async {
        await db.bangDao.addSearchEntry(trigger, searchQuery);
        await db.evictHistoryEntries(limit: maxEntryCount);
      },
    );
  }

  Future<void> removeSearchEntry(String searchQuery) {
    return ref
        .read(bangDatabaseProvider)
        .bangDao
        .removeSearchEntry(searchQuery);
  }

  Future<Result<BangData>> ensureIconAvailable(BangData bang) async {
    if (bang.icon != null) {
      return Result.success(bang);
    }

    final url = bang.getUrl('');

    final websiteProvider = ref.read(genericWebsiteServiceProvider.notifier);
    final cachedIcon = await websiteProvider.getCachedIcon(url);

    if (cachedIcon != null) {
      return Result.success(bang.copyWith.icon(cachedIcon));
    }

    return websiteProvider.fetchPageInfo(url).then(
          (result) => result
              .flatMap((pageInfo) => bang.copyWith.icon(pageInfo.favicon)),
        );
  }

  Future<int> resetFrequencies() {
    return ref.read(bangDatabaseProvider).bangFrequency.deleteAll();
  }

  Future<int> resetFrequency(String trigger) {
    return ref
        .read(bangDatabaseProvider)
        .bangFrequency
        .deleteWhere((t) => t.trigger.equals(trigger));
  }
}
