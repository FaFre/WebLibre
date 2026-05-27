import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';

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

  test('content-state sync seeds parent for an unclaimed engine row', () async {
    await _insertTabs(db, const [
      _TabFixture('gecko-parent', source: TabSource.addedEvent),
      _TabFixture('child', source: TabSource.addedEvent),
    ]);

    await db.tabDao.updateTabs(null, {
      'child': _tabState('child', parentId: 'gecko-parent'),
    });

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(child, isNotNull);
    expect(child!.parentId, 'gecko-parent');
    expect(child.source, TabSource.manual);
  });

  test(
    'content-state sync retries an unresolved engine parent when the row arrives later',
    () async {
      await _insertTabs(db, const [
        _TabFixture('child', source: TabSource.addedEvent),
      ]);

      final initialState = {
        'child': _tabState('child', parentId: 'late-parent'),
      };

      await db.tabDao.updateTabs(null, initialState);

      final unresolvedChild = await db.tabDao
          .getTabDataById('child')
          .getSingleOrNull();
      expect(unresolvedChild, isNotNull);
      expect(unresolvedChild!.parentId, isNull);
      expect(unresolvedChild.source, TabSource.addedEvent);

      await _insertTabs(db, const [
        _TabFixture('late-parent', source: TabSource.addedEvent),
      ]);

      await db.tabDao.updateTabs(initialState, {
        'child': _tabState('child', parentId: 'late-parent'),
        'late-parent': _tabState('late-parent'),
      });

      final resolvedChild = await db.tabDao
          .getTabDataById('child')
          .getSingleOrNull();
      expect(resolvedChild, isNotNull);
      expect(resolvedChild!.parentId, 'late-parent');
      expect(resolvedChild.source, TabSource.manual);
    },
  );

  test(
    'tab-list sync resolves an unresolved engine parent after inserting the parent row',
    () async {
      await _insertTabs(db, const [
        _TabFixture('child', source: TabSource.addedEvent),
      ]);

      await db.tabDao.updateTabs(null, {
        'child': _tabState('child', parentId: 'late-parent'),
      });

      final unresolvedChild = await db.tabDao
          .getTabDataById('child')
          .getSingleOrNull();
      expect(unresolvedChild, isNotNull);
      expect(unresolvedChild!.parentId, isNull);
      expect(unresolvedChild.source, TabSource.addedEvent);

      await db.tabDao.syncTabs(retainTabIds: const ['late-parent', 'child']);

      final resolvedChild = await db.tabDao
          .getTabDataById('child')
          .getSingleOrNull();
      expect(resolvedChild, isNotNull);
      expect(resolvedChild!.parentId, 'late-parent');
      expect(resolvedChild.source, TabSource.manual);
    },
  );

  test(
    'content-state sync ignores parent-only changes with unresolved parents',
    () async {
      await _insertTabs(db, const [
        _TabFixture('child', source: TabSource.addedEvent),
      ]);

      final previousState = _tabState('child');

      await db.tabDao.updateTabs(
        {'child': previousState},
        {'child': previousState.copyWith(parentId: 'missing-parent')},
      );

      final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
      expect(child, isNotNull);
      expect(child!.parentId, isNull);
      expect(child.source, TabSource.addedEvent);
    },
  );

  test(
    'content-state sync does not overwrite a locally managed parent',
    () async {
      await _insertTabs(db, const [
        _TabFixture('local-parent'),
        _TabFixture('gecko-parent', source: TabSource.addedEvent),
        _TabFixture('child', parentId: 'local-parent'),
      ]);

      await db.tabDao.updateTabs(null, {
        'child': _tabState('child', parentId: 'gecko-parent'),
      });

      final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
      expect(child, isNotNull);
      expect(child!.parentId, 'local-parent');
      expect(child.source, TabSource.manual);
    },
  );

  test(
    'content-state sync ignores parent-only changes for locally managed rows',
    () async {
      await _insertTabs(db, const [
        _TabFixture('local-parent'),
        _TabFixture('gecko-parent', source: TabSource.addedEvent),
        _TabFixture('child', parentId: 'local-parent'),
      ]);

      final previousState = _tabState('child', parentId: 'local-parent');

      await db.tabDao.updateTabs(
        {'child': previousState},
        {'child': previousState.copyWith(parentId: 'gecko-parent')},
      );

      final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
      expect(child, isNotNull);
      expect(child!.parentId, 'local-parent');
      expect(child.source, TabSource.manual);
    },
  );

  test(
    'content-state sync preserves an existing parent on engine rows',
    () async {
      await _insertTabs(db, const [
        _TabFixture('existing-parent', source: TabSource.addedEvent),
        _TabFixture('gecko-parent', source: TabSource.addedEvent),
        _TabFixture(
          'child',
          parentId: 'existing-parent',
          source: TabSource.addedEvent,
        ),
      ]);

      await db.tabDao.updateTabs(null, {
        'child': _tabState('child', parentId: 'gecko-parent'),
      });

      final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
      expect(child, isNotNull);
      expect(child!.parentId, 'existing-parent');
      expect(child.source, TabSource.addedEvent);
    },
  );

  test('reorder-only moves do not claim manual hierarchy authority', () async {
    await _insertTabs(db, const [
      _TabFixture('other'),
      _TabFixture('child', source: TabSource.addedEvent),
      _TabFixture('gecko-parent', source: TabSource.addedEvent),
    ]);

    await db.tabDao.reorderTabs(
      movingTabIds: const ['child'],
      previousTabId: null,
      nextTabId: 'other',
    );

    final reorderedChild = await db.tabDao
        .getTabDataById('child')
        .getSingleOrNull();
    expect(reorderedChild, isNotNull);
    expect(reorderedChild!.source, TabSource.addedEvent);
    expect(reorderedChild.parentId, isNull);

    await db.tabDao.updateTabs(null, {
      'child': _tabState('child', parentId: 'gecko-parent'),
    });

    final seededChild = await db.tabDao
        .getTabDataById('child')
        .getSingleOrNull();
    expect(seededChild, isNotNull);
    expect(seededChild!.parentId, 'gecko-parent');
    expect(seededChild.source, TabSource.manual);
  });

  test('tab-list sync preserves an existing local parent', () async {
    await _insertTabs(db, const [
      _TabFixture('parent'),
      _TabFixture('child', parentId: 'parent'),
    ]);

    await db.tabDao.syncTabs(retainTabIds: const ['parent', 'child']);

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(child, isNotNull);
    expect(child!.parentId, 'parent');
  });

  test('deleting a parent rewires children to the grandparent', () async {
    await _insertTabs(db, const [
      _TabFixture('grandparent'),
      _TabFixture('parent', parentId: 'grandparent'),
      _TabFixture('child', parentId: 'parent'),
    ]);

    await db.customStatement("DELETE FROM tab WHERE id = 'parent'");

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(child, isNotNull);
    expect(child!.parentId, 'grandparent');
  });
}

Future<void> _insertTabs(TabDatabase db, List<_TabFixture> tabs) async {
  final orderKeys = _spacedOrderKeys(tabs.length);

  for (final (index, tab) in tabs.indexed) {
    await db.tabDao.insertTab(
      tab.id,
      source: tab.source,
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
  final TabSource source;

  const _TabFixture(this.id, {this.parentId, this.source = TabSource.manual});
}

TabState _tabState(String id, {String? parentId}) {
  return TabState.$default(id).copyWith(
    parentId: parentId,
    url: Uri.parse('https://$id.example/'),
    title: id,
  );
}
