import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/bangs/data/database/database.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

part 'bang.g.dart';

@DriftAccessor()
class BangDao extends DatabaseAccessor<BangDatabase> with _$BangDaoMixin {
  BangDao(super.db);

  Selectable<Bang> getBangList({Iterable<BangGroup>? groups}) {
    final selectable = select(db.bang);
    if (groups != null) {
      selectable.where((t) => t.group.isInValues(groups));
    }

    return selectable;
  }

  SingleSelectable<int> getBangCount({Iterable<BangGroup>? groups}) {
    return db.bang.count(
      where: groups.mapNotNull(
        (groups) =>
            (t) => t.group.isInValues(groups),
      ),
    );
  }

  SingleOrNullSelectable<BangData> getBangData(String trigger) {
    return select(db.bangDataView)..where((t) => t.trigger.equals(trigger));
  }

  Selectable<BangData> getBangDataList({
    Iterable<String>? triggers,
    Iterable<BangGroup>? groups,
    String? domain,
    String? category,
    String? subCategory,
    bool? orderMostFrequentFirst,
  }) {
    final selectable = select(db.bangDataView);
    if (triggers != null) {
      selectable.where((t) => t.trigger.isIn(triggers));
    }
    if (groups != null) {
      selectable.where((t) => t.group.isInValues(groups));
    }
    if (domain != null) {
      selectable.where((t) => t.domain.equals(domain));
    }
    if (category != null) {
      selectable.where((t) => t.category.equals(category));

      if (subCategory != null) {
        selectable.where((t) => t.subCategory.equals(subCategory));
      }
    }

    selectable.orderBy([
      if (orderMostFrequentFirst == true) (t) => OrderingTerm.desc(t.frequency),
      (t) => OrderingTerm.asc(t.websiteName),
    ]);

    return selectable;
  }

  Selectable<BangData> getFrequentBangDataList({Iterable<BangGroup>? groups}) {
    final selectable = select(db.bangDataView)
      ..where((t) => t.frequency.isBiggerThanValue(0));

    if (groups != null) {
      selectable.where((t) => t.group.isInValues(groups));
    }

    selectable.orderBy([
      (t) => OrderingTerm.desc(t.frequency),
      (t) => OrderingTerm.desc(t.lastUsed),
    ]);

    return selectable;
  }

  Future<int> increaseBangFrequency(String trigger) {
    return db.bangFrequency.insertOne(
      BangFrequencyCompanion.insert(
        trigger: trigger,
        frequency: 1,
        lastUsed: DateTime.now(),
      ),
      onConflict: DoUpdate(
        (old) => BangFrequencyCompanion.custom(
          frequency: old.frequency + const Constant(1),
          lastUsed: Variable(DateTime.now()),
        ),
      ),
    );
  }

  Selectable<BangData> queryBangs(String searchString) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.queryBangs(query: ftsQuery);
    } else {
      return db.queryBangsBasic(query: db.buildLikeQuery(searchString));
    }
  }

  Future<int> addSearchEntry(String trigger, String searchQuery) {
    return db.bangHistory.insertOne(
      BangHistoryCompanion.insert(
        searchQuery: searchQuery,
        trigger: trigger,
        searchDate: DateTime.now(),
      ),
      onConflict: DoUpdate(
        target: [db.bangHistory.searchQuery],
        (old) => BangHistoryCompanion(
          trigger: Value(trigger),
          searchDate: Value(DateTime.now()),
        ),
      ),
    );
  }

  Future<int> removeSearchEntry(String searchQuery) {
    return db.bangHistory.deleteWhere((t) => t.searchQuery.equals(searchQuery));
  }
}
