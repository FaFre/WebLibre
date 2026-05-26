import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';

void main() {
  late TabDatabase db;

  setUp(() {
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('setTabParent appends after the existing last child subtree', () async {
    await _insertTabs(db, const [
      _TabFixture('parent'),
      _TabFixture('existing-child', parentId: 'parent'),
      _TabFixture('existing-grandchild', parentId: 'existing-child'),
      _TabFixture('moving'),
      _TabFixture('moving-child', parentId: 'moving'),
    ]);

    final moved = await db.tabDao.setTabParent(
      tabId: 'moving',
      newParentId: 'parent',
    );

    expect(moved, isTrue);
    expect(await _orderedTabIds(db), [
      'parent',
      'existing-child',
      'existing-grandchild',
      'moving',
      'moving-child',
    ]);
  });

  test(
    'promoteChildToParent demotes after the promoted child subtree',
    () async {
      await _insertTabs(db, const [
        _TabFixture('parent'),
        _TabFixture('child', parentId: 'parent'),
        _TabFixture('grandchild', parentId: 'child'),
        _TabFixture('great-grandchild', parentId: 'grandchild'),
      ]);

      final promoted = await db.tabDao.promoteChildToParent('child');

      expect(promoted, isTrue);
      expect(await _orderedTabIds(db), [
        'child',
        'grandchild',
        'great-grandchild',
        'parent',
      ]);
    },
  );

  test(
    'moveTabAmongSiblings moves down after the target sibling subtree',
    () async {
      await _insertTabs(db, const [
        _TabFixture('parent'),
        _TabFixture('first', parentId: 'parent'),
        _TabFixture('first-child', parentId: 'first'),
        _TabFixture('second', parentId: 'parent'),
        _TabFixture('second-child', parentId: 'second'),
      ]);

      final moved = await db.tabDao.moveTabAmongSiblings('first', down: true);

      expect(moved, isTrue);
      expect(await _orderedTabIds(db), [
        'parent',
        'second',
        'second-child',
        'first',
        'first-child',
      ]);
    },
  );
}

Future<void> _insertTabs(TabDatabase db, List<_TabFixture> tabs) async {
  final orderKeys = _spacedOrderKeys(tabs.length);

  for (final (index, tab) in tabs.indexed) {
    await db.tabDao.upsertTabTransactional(
      () async => tab.id,
      parentId: Value(tab.parentId),
      orderKey: Value(orderKeys[index]),
    );
  }
}

Future<List<String>> _orderedTabIds(TabDatabase db) {
  return db.tabDao.getAllTabIds().get();
}

List<String> _spacedOrderKeys(int count) {
  var rank = LexoRank.middle();
  final orderKeys = <String>[];

  for (var i = 0; i < count; i++) {
    orderKeys.add(rank.value);
    for (var gap = 0; gap < 4; gap++) {
      rank = rank.genNext();
    }
  }

  return orderKeys;
}

class _TabFixture {
  final String id;
  final String? parentId;

  const _TabFixture(this.id, {this.parentId});
}
