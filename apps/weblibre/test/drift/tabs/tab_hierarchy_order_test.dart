import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/child_tab_placement.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

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

  test('a new child defaults to the position behind its opener', () async {
    await _insertTabs(db, const [
      _TabFixture('parent'),
      _TabFixture('existing-child', parentId: 'parent'),
      _TabFixture('existing-grandchild', parentId: 'existing-child'),
      _TabFixture('unrelated'),
    ]);

    await db.tabDao.insertTab(
      'new-child',
      source: TabSource.manual,
      parentId: const Value('parent'),
    );

    expect(await _orderedTabIds(db), [
      'parent',
      'existing-child',
      'existing-grandchild',
      'new-child',
      'unrelated',
    ]);
  });

  test('ChildTabPlacement.endOfList appends a new child to the end', () async {
    await _insertTabs(db, const [
      _TabFixture('parent'),
      _TabFixture('existing-child', parentId: 'parent'),
      _TabFixture('unrelated'),
    ]);

    await db.tabDao.insertTab(
      'new-child',
      source: TabSource.manual,
      parentId: const Value('parent'),
      childPlacement: ChildTabPlacement.endOfList,
    );

    expect(await _orderedTabIds(db), [
      'parent',
      'existing-child',
      'unrelated',
      'new-child',
    ]);
    // The opener is still recorded, so hierarchical views keep nesting it.
    final newChild = await db.tabDao
        .getTabDataById('new-child')
        .getSingleOrNull();
    expect(newChild?.parentId, 'parent');
  });

  test('an explicit anchor outranks ChildTabPlacement.endOfList', () async {
    // What a duplicated tab does: it must land beside its source whatever the
    // setting says about new children.
    await _insertTabs(db, const [
      _TabFixture('parent'),
      _TabFixture('source', parentId: 'parent'),
      _TabFixture('unrelated'),
    ]);

    await db.tabDao.insertTab(
      'duplicate',
      source: TabSource.manual,
      parentId: const Value('parent'),
      afterTabId: const Value('source'),
      childPlacement: ChildTabPlacement.endOfList,
    );

    expect(await _orderedTabIds(db), [
      'parent',
      'source',
      'duplicate',
      'unrelated',
    ]);
  });

  test('an engine-opened tab lands behind its opener at insert', () async {
    await _insertTabs(db, const [
      _TabFixture('opener'),
      _TabFixture('existing-child', parentId: 'opener'),
      _TabFixture('unrelated'),
    ]);

    await db.tabDao.insertTab(
      'engine-tab',
      source: TabSource.addedEvent,
      parentId: const Value.absent(),
      openerId: const Value('opener'),
    );

    expect(await _orderedTabIds(db), [
      'opener',
      'existing-child',
      'engine-tab',
      'unrelated',
    ]);
    // The opener is recorded at insert, but the row stays unclaimed so that
    // seeding still claims it — without moving it.
    final inserted = await db.tabDao
        .getTabDataById('engine-tab')
        .getSingleOrNull();
    expect(inserted?.parentId, 'opener');
    expect(inserted?.source, TabSource.addedEvent);

    final seeded = await db.tabDao.seedParentFromEngineState(
      childId: 'engine-tab',
      parentId: 'opener',
      contextId: null,
    );
    expect(seeded, isTrue);
    final claimed = await db.tabDao
        .getTabDataById('engine-tab')
        .getSingleOrNull();
    expect(claimed?.source, TabSource.manual);
    expect(await _orderedTabIds(db), [
      'opener',
      'existing-child',
      'engine-tab',
      'unrelated',
    ]);
  });

  test('ChildTabPlacement.endOfList ignores the opener at insert', () async {
    await _insertTabs(db, const [
      _TabFixture('opener'),
      _TabFixture('unrelated'),
    ]);

    await db.tabDao.insertTab(
      'engine-tab',
      source: TabSource.addedEvent,
      parentId: const Value.absent(),
      openerId: const Value('opener'),
      childPlacement: ChildTabPlacement.endOfList,
    );

    expect(await _orderedTabIds(db), ['opener', 'unrelated', 'engine-tab']);
    final inserted = await db.tabDao
        .getTabDataById('engine-tab')
        .getSingleOrNull();
    expect(inserted?.parentId, 'opener');
  });

  test(
    'engine-opened siblings keep their opening order before seeding',
    () async {
      // Two tabs from one opener can both arrive before either is seeded. Each
      // must see the previous one as a sibling, or the second anchors on the
      // opener itself and lands in front of the first.
      await _insertTabs(db, const [
        _TabFixture('opener'),
        _TabFixture('existing-child', parentId: 'opener'),
        _TabFixture('unrelated'),
      ]);

      for (final id in ['first', 'second', 'third']) {
        await db.tabDao.insertTab(
          id,
          source: TabSource.addedEvent,
          parentId: const Value.absent(),
          openerId: const Value('opener'),
        );
      }

      expect(await _orderedTabIds(db), [
        'opener',
        'existing-child',
        'first',
        'second',
        'third',
        'unrelated',
      ]);
    },
  );

  test('seeding does not override a different local parent', () async {
    await _insertTabs(db, const [
      _TabFixture('opener'),
      _TabFixture('local-parent'),
      _TabFixture(
        'child',
        parentId: 'local-parent',
        source: TabSource.addedEvent,
      ),
    ]);

    final seeded = await db.tabDao.seedParentFromEngineState(
      childId: 'child',
      parentId: 'opener',
      contextId: null,
    );

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(seeded, isFalse);
    expect(child?.parentId, 'local-parent');
    expect(child?.source, TabSource.addedEvent);
  });

  group('an opener without a row at insert', () {
    // The tab appends (a dangling parent_id would violate the FK) and is
    // moved behind its opener by whichever path links the parent later.

    /// `[unrelated, engine-tab, opener]`: the engine tab appended while its
    /// opener had no row, and the opener's row arrived after it.
    Future<void> arrangeLateOpener() async {
      await _insertTabs(db, const [_TabFixture('unrelated')]);
      await db.tabDao.insertTab(
        'engine-tab',
        source: TabSource.addedEvent,
        parentId: const Value.absent(),
        openerId: const Value('opener'),
      );
      expect(await _orderedTabIds(db), ['unrelated', 'engine-tab']);
      final inserted = await db.tabDao
          .getTabDataById('engine-tab')
          .getSingleOrNull();
      expect(inserted?.parentId, isNull);

      await db.tabDao.insertTab(
        'opener',
        source: TabSource.syncEvent,
        parentId: const Value.absent(),
      );
      expect(await _orderedTabIds(db), ['unrelated', 'engine-tab', 'opener']);
    }

    test('engine seeding moves it behind the opener', () async {
      await arrangeLateOpener();

      final seeded = await db.tabDao.seedParentFromEngineState(
        childId: 'engine-tab',
        parentId: 'opener',
        contextId: null,
      );

      expect(seeded, isTrue);
      expect(await _orderedTabIds(db), ['unrelated', 'opener', 'engine-tab']);
      final child = await db.tabDao
          .getTabDataById('engine-tab')
          .getSingleOrNull();
      expect(child?.parentId, 'opener');
      expect(child?.source, TabSource.manual);
    });

    test('the content-state sync moves it behind the opener', () async {
      await arrangeLateOpener();

      await db.tabDao.updateTabs(null, {
        'engine-tab': _tabState('engine-tab', parentId: 'opener'),
      });

      expect(await _orderedTabIds(db), ['unrelated', 'opener', 'engine-tab']);
      final child = await db.tabDao
          .getTabDataById('engine-tab')
          .getSingleOrNull();
      expect(child?.parentId, 'opener');
      expect(child?.source, TabSource.manual);
    });

    test('ChildTabPlacement.endOfList links it without moving it', () async {
      await arrangeLateOpener();

      await db.tabDao.seedParentFromEngineState(
        childId: 'engine-tab',
        parentId: 'opener',
        contextId: null,
        childPlacement: ChildTabPlacement.endOfList,
      );

      expect(await _orderedTabIds(db), ['unrelated', 'engine-tab', 'opener']);
      final child = await db.tabDao
          .getTabDataById('engine-tab')
          .getSingleOrNull();
      expect(child?.parentId, 'opener');
    });

    /// A late-linked tab that already has a child: anything opened from it
    /// since its own insert recorded it as the parent.
    Future<void> insertWithGrandchild({String? containerId}) async {
      await db.tabDao.insertTab(
        'child',
        source: TabSource.addedEvent,
        parentId: const Value.absent(),
        openerId: const Value('opener'),
        containerId: Value(containerId),
      );
      await db.tabDao.insertTab(
        'grandchild',
        source: TabSource.addedEvent,
        parentId: const Value.absent(),
        openerId: const Value('child'),
        containerId: Value(containerId),
      );
    }

    test('a late link moves the tab with its subtree as one block', () async {
      await _insertTabs(db, const [_TabFixture('unrelated')]);
      await insertWithGrandchild();
      await db.tabDao.insertTab(
        'opener',
        source: TabSource.syncEvent,
        parentId: const Value.absent(),
      );
      expect(await _orderedTabIds(db), [
        'unrelated',
        'child',
        'grandchild',
        'opener',
      ]);

      await db.tabDao.seedParentFromEngineState(
        childId: 'child',
        parentId: 'opener',
        contextId: null,
      );

      expect(await _orderedTabIds(db), [
        'unrelated',
        'opener',
        'child',
        'grandchild',
      ]);
      final grandchild = await db.tabDao
          .getTabDataById('grandchild')
          .getSingleOrNull();
      expect(grandchild?.parentId, 'child');
    });

    test('a parent in another container leaves the block in place', () async {
      await _insertContainers(db, const [
        _ContainerFixture('home', 'home-context'),
        _ContainerFixture('work', 'work-context'),
      ]);
      // The opener's key sorts *before* home-root. Order keys are only
      // comparable within a container, so ranking against it would drag the
      // block in front of home-root.
      await _insertTabs(db, const [
        _TabFixture('opener', containerId: 'work'),
        _TabFixture('home-root', containerId: 'home'),
      ]);
      // Appended with no parent (as if the opener had no row at the time),
      // then a grandchild opened from it.
      await db.tabDao.insertTab(
        'child',
        source: TabSource.addedEvent,
        parentId: const Value.absent(),
        containerId: const Value('home'),
      );
      await db.tabDao.insertTab(
        'grandchild',
        source: TabSource.addedEvent,
        parentId: const Value.absent(),
        openerId: const Value('child'),
        containerId: const Value('home'),
      );

      await db.tabDao.seedParentFromEngineState(
        childId: 'child',
        parentId: 'opener',
        contextId: null,
      );

      expect(await _orderedTabIdsInContainer(db, 'home'), [
        'home-root',
        'child',
        'grandchild',
      ]);
      final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
      expect(child?.parentId, 'opener');
      expect(child?.containerId, 'home');
    });

    test('a repaired container follows the moved block', () async {
      await _insertContainers(db, const [
        _ContainerFixture('work', 'work-context'),
      ]);
      await _insertTabs(db, const [_TabFixture('unassigned-root')]);
      // Inserted with no container selected; the engine reports the work
      // context, so seeding repairs the container.
      await insertWithGrandchild();
      await db.tabDao.insertTab(
        'opener',
        source: TabSource.syncEvent,
        parentId: const Value.absent(),
        containerId: const Value('work'),
      );

      await db.tabDao.seedParentFromEngineState(
        childId: 'child',
        parentId: 'opener',
        contextId: 'work-context',
      );

      expect(await _orderedTabIdsInContainer(db, 'work'), [
        'opener',
        'child',
        'grandchild',
      ]);
      final grandchild = await db.tabDao
          .getTabDataById('grandchild')
          .getSingleOrNull();
      expect(grandchild?.containerId, 'work');
    });

    test(
      'the pending-parent pass moves each behind the opener in order',
      () async {
        await _insertTabs(db, const [_TabFixture('unrelated')]);
        for (final id in ['first', 'second']) {
          await db.tabDao.insertTab(
            id,
            source: TabSource.addedEvent,
            parentId: const Value.absent(),
            openerId: const Value('opener'),
          );
          // No opener row yet, so seeding parks the link as pending.
          final seeded = await db.tabDao.seedParentFromEngineState(
            childId: id,
            parentId: 'opener',
            contextId: null,
          );
          expect(seeded, isFalse);
        }

        // The opener's row arrives through the tab-list sync (leading key), and
        // the same transaction resolves the pending links.
        await db.tabDao.syncTabs(
          retainTabIds: const ['unrelated', 'first', 'second', 'opener'],
        );

        expect(await _orderedTabIds(db), [
          'opener',
          'first',
          'second',
          'unrelated',
        ]);
        for (final id in ['first', 'second']) {
          final child = await db.tabDao.getTabDataById(id).getSingleOrNull();
          expect(child?.parentId, 'opener');
          expect(child?.source, TabSource.manual);
        }
      },
    );
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

  test('setTabParent leaves cross-container descendants in place', () async {
    await _insertContainers(db, const [
      _ContainerFixture('home', 'home-context'),
      _ContainerFixture('work', 'work-context'),
    ]);
    await _insertTabs(db, const [
      _TabFixture('parent', containerId: 'home'),
      _TabFixture('moving', containerId: 'home'),
      _TabFixture('moving-child', parentId: 'moving', containerId: 'home'),
      _TabFixture('foreign-child', parentId: 'moving', containerId: 'work'),
      _TabFixture('work-root', containerId: 'work'),
    ]);
    final foreignOrderKey = await _orderKeyOf(db, 'foreign-child');

    final moved = await db.tabDao.setTabParent(
      tabId: 'moving',
      newParentId: 'parent',
    );

    expect(moved, isTrue);
    expect(await _orderedTabIdsInContainer(db, 'home'), [
      'parent',
      'moving',
      'moving-child',
    ]);
    final foreignChild = await db.tabDao
        .getTabDataById('foreign-child')
        .getSingleOrNull();
    expect(foreignChild, isNotNull);
    expect(foreignChild!.parentId, 'moving');
    expect(foreignChild.containerId, 'work');
    expect(foreignChild.orderKey, foreignOrderKey);
  });

  test('setTabParent detects cycles through another container', () async {
    await _insertContainers(db, const [
      _ContainerFixture('home', 'home-context'),
      _ContainerFixture('work', 'work-context'),
    ]);
    await _insertTabs(db, const [
      _TabFixture('moving', containerId: 'home'),
      _TabFixture('foreign-child', parentId: 'moving', containerId: 'work'),
    ]);

    final moved = await db.tabDao.setTabParent(
      tabId: 'moving',
      newParentId: 'foreign-child',
    );

    expect(moved, isFalse);
    final moving = await db.tabDao.getTabDataById('moving').getSingleOrNull();
    expect(moving, isNotNull);
    expect(moving!.parentId, isNull);
    expect(moving.containerId, 'home');
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

  test(
    'moveTabAmongSiblings toEdge moves the subtree to either end of its siblings',
    () async {
      await _insertTabs(db, const [
        _TabFixture('parent'),
        _TabFixture('first', parentId: 'parent'),
        _TabFixture('first-child', parentId: 'first'),
        _TabFixture('second', parentId: 'parent'),
        _TabFixture('third', parentId: 'parent'),
      ]);

      expect(
        await db.tabDao.moveTabAmongSiblings('first', down: true, toEdge: true),
        isTrue,
      );
      expect(await _orderedTabIds(db), [
        'parent',
        'second',
        'third',
        'first',
        'first-child',
      ]);

      expect(
        await db.tabDao.moveTabAmongSiblings(
          'third',
          down: false,
          toEdge: true,
        ),
        isTrue,
      );
      expect(await _orderedTabIds(db), [
        'parent',
        'third',
        'second',
        'first',
        'first-child',
      ]);

      // Already there: nothing to move.
      expect(
        await db.tabDao.moveTabAmongSiblings(
          'third',
          down: false,
          toEdge: true,
        ),
        isFalse,
      );
    },
  );

  test(
    'moveTabAmongSiblings uses the rendered cross-container root scope',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('home', 'home-context'),
        _ContainerFixture('work', 'work-context'),
      ]);
      await _insertTabs(db, const [
        _TabFixture('opener', containerId: 'home'),
        _TabFixture('work-first', containerId: 'work'),
        _TabFixture('reopened', parentId: 'opener', containerId: 'work'),
        _TabFixture(
          'reopened-child',
          parentId: 'reopened',
          containerId: 'work',
        ),
        _TabFixture('work-last', containerId: 'work'),
        _TabFixture('foreign-child', parentId: 'reopened', containerId: 'home'),
      ]);
      final foreignOrderKey = await _orderKeyOf(db, 'foreign-child');

      final moved = await db.tabDao.moveTabAmongSiblings(
        'reopened',
        down: true,
      );

      expect(moved, isTrue);
      expect(await _orderedTabIdsInContainer(db, 'work'), [
        'work-first',
        'work-last',
        'reopened',
        'reopened-child',
      ]);
      expect(await _orderKeyOf(db, 'foreign-child'), foreignOrderKey);
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

  test('engine parent seeding immediately claims an unclaimed row', () async {
    await _insertTabs(db, const [
      _TabFixture('gecko-parent', source: TabSource.addedEvent),
      _TabFixture('child', source: TabSource.addedEvent),
    ]);

    final seeded = await db.tabDao.seedParentFromEngineState(
      childId: 'child',
      parentId: 'gecko-parent',
      contextId: null,
    );

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(seeded, isTrue);
    expect(child, isNotNull);
    expect(child!.parentId, 'gecko-parent');
    expect(child.source, TabSource.manual);
  });

  test('engine parent seeding rejects a self-referential parent', () async {
    await _insertTabs(db, const [
      _TabFixture('tab', source: TabSource.addedEvent),
    ]);

    final seeded = await db.tabDao.seedParentFromEngineState(
      childId: 'tab',
      parentId: 'tab',
      contextId: null,
    );

    final tab = await db.tabDao.getTabDataById('tab').getSingleOrNull();
    expect(seeded, isFalse);
    expect(tab, isNotNull);
    expect(tab!.parentId, isNull);
    expect(tab.source, TabSource.addedEvent);
  });

  test('engine parent seeding keeps cross-container parents', () async {
    await _insertContainers(db, const [
      _ContainerFixture('parent-container', 'parent-context'),
      _ContainerFixture('child-container', 'child-context'),
    ]);
    await _insertTabs(db, const [
      _TabFixture(
        'gecko-parent',
        source: TabSource.addedEvent,
        containerId: 'parent-container',
      ),
      _TabFixture(
        'child',
        source: TabSource.addedEvent,
        containerId: 'child-container',
      ),
    ]);

    final seeded = await db.tabDao.seedParentFromEngineState(
      childId: 'child',
      parentId: 'gecko-parent',
      contextId: 'child-context',
    );

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(seeded, isTrue);
    expect(child, isNotNull);
    expect(child!.parentId, 'gecko-parent');
    expect(child.containerId, 'child-container');
    expect(child.source, TabSource.manual);
  });

  test('content-state sync keeps cross-container parents', () async {
    await _insertContainers(db, const [
      _ContainerFixture('parent-container', 'parent-context'),
      _ContainerFixture('child-container', 'child-context'),
    ]);
    await _insertTabs(db, const [
      _TabFixture(
        'gecko-parent',
        source: TabSource.addedEvent,
        containerId: 'parent-container',
      ),
      _TabFixture(
        'child',
        source: TabSource.addedEvent,
        containerId: 'child-container',
      ),
    ]);

    await db.tabDao.updateTabs(null, {
      'child': _tabState(
        'child',
        parentId: 'gecko-parent',
        contextId: 'child-context',
      ),
    });

    final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
    expect(child, isNotNull);
    expect(child!.parentId, 'gecko-parent');
    expect(child.containerId, 'child-container');
    expect(child.source, TabSource.manual);
  });

  test(
    'a cross-container child is a local root in its own container view',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('parent-container', 'parent-context'),
        _ContainerFixture('child-container', 'child-context'),
      ]);
      await _insertTabs(db, const [
        _TabFixture('opener', containerId: 'parent-container'),
        _TabFixture(
          'reopened',
          parentId: 'opener',
          containerId: 'child-container',
        ),
      ]);

      final childContainerRows = await db.definitionsDrift
          .tabsWithRootAndDepth(containerId: 'child-container')
          .get();

      expect(childContainerRows.map((row) => row.id), ['reopened']);
      expect(childContainerRows.single.rootId, 'reopened');
      expect(childContainerRows.single.depth, 0);

      // The opener's own container keeps its tree — the tab that was pulled
      // into another container neither joins it nor takes it over.
      final openerTrees = await db.definitionsDrift
          .tabTrees(containerId: 'parent-container', skipContainerCheck: false)
          .get();

      expect(openerTrees.map((tree) => tree.rootTabId), ['opener']);
      expect(openerTrees.single.latestTabId, 'opener');
      expect(openerTrees.single.totalTabs, 1);

      final reopenedTrees = await db.definitionsDrift
          .tabTrees(containerId: 'child-container', skipContainerCheck: false)
          .get();

      expect(reopenedTrees.map((tree) => tree.rootTabId), ['reopened']);
      expect(reopenedTrees.single.totalTabs, 1);
    },
  );

  test('unscoped tab trees still span every container', () async {
    await _insertContainers(db, const [
      _ContainerFixture('parent-container', 'parent-context'),
      _ContainerFixture('child-container', 'child-context'),
    ]);
    await _insertTabs(db, const [
      _TabFixture('opener', containerId: 'parent-container'),
      _TabFixture(
        'reopened',
        parentId: 'opener',
        containerId: 'child-container',
      ),
    ]);

    final trees = await db.definitionsDrift
        .tabTrees(containerId: null, skipContainerCheck: true)
        .get();

    expect(trees.map((tree) => tree.rootTabId).toSet(), {'opener'});
    expect(trees.map((tree) => tree.totalTabs).toSet(), {2});
  });

  test(
    'content-state sync validates parent against same-batch container repairs',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('container', 'context'),
      ]);
      await _insertTabs(db, const [
        _TabFixture('gecko-parent', source: TabSource.addedEvent),
        _TabFixture('child', source: TabSource.addedEvent),
      ]);

      await db.tabDao.updateTabs(null, {
        'gecko-parent': _tabState('gecko-parent', contextId: 'context'),
        'child': _tabState(
          'child',
          parentId: 'gecko-parent',
          contextId: 'context',
        ),
      });

      final parent = await db.tabDao
          .getTabDataById('gecko-parent')
          .getSingleOrNull();
      final child = await db.tabDao.getTabDataById('child').getSingleOrNull();
      expect(parent, isNotNull);
      expect(parent!.containerId, 'container');
      expect(child, isNotNull);
      expect(child!.containerId, 'container');
      expect(child.parentId, 'gecko-parent');
      expect(child.source, TabSource.manual);
    },
  );

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

  test(
    'deleting the throwaway tab of a container hand-off keeps the opener reachable',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('parent-container', 'parent-context'),
        _ContainerFixture('child-container', 'child-context'),
      ]);
      // The shape the site-assignment listener produces: a link is followed
      // into a container-assigned site, the blocked tab is thrown away and the
      // site is reopened in its own container.
      await _insertTabs(db, const [
        _TabFixture('opener', containerId: 'parent-container'),
        _TabFixture(
          'blocked',
          parentId: 'opener',
          containerId: 'parent-container',
        ),
        _TabFixture(
          'reopened',
          parentId: 'blocked',
          containerId: 'child-container',
        ),
      ]);

      await db.customStatement("DELETE FROM tab WHERE id = 'blocked'");

      final reopened = await db.tabDao
          .getTabDataById('reopened')
          .getSingleOrNull();
      expect(reopened, isNotNull);
      expect(reopened!.parentId, 'opener');
      expect(reopened.containerId, 'child-container');
    },
  );

  test('subtree collection stops at the container boundary', () async {
    await _insertContainers(db, const [
      _ContainerFixture('parent-container', 'parent-context'),
      _ContainerFixture('child-container', 'child-context'),
    ]);
    await _insertTabs(db, const [
      _TabFixture('opener', containerId: 'parent-container'),
      _TabFixture(
        'local-child',
        parentId: 'opener',
        containerId: 'parent-container',
      ),
      _TabFixture(
        'reopened',
        parentId: 'opener',
        containerId: 'child-container',
      ),
      _TabFixture(
        'reopened-child',
        parentId: 'reopened',
        containerId: 'child-container',
      ),
    ]);

    final scoped = await db.definitionsDrift
        .unorderedContainerTabDescendants(tabId: 'opener')
        .get();

    expect(scoped.map((row) => row.id).toSet(), {'opener', 'local-child'});

    // The seed's own container is what bounds the walk, so starting at the
    // reopened tab still yields its whole subtree over there.
    final scopedFromReopened = await db.definitionsDrift
        .unorderedContainerTabDescendants(tabId: 'reopened')
        .get();

    expect(scopedFromReopened.map((row) => row.id).toSet(), {
      'reopened',
      'reopened-child',
    });

    // Cycle detection and the hierarchy pickers still see everything.
    final unscoped = await db.definitionsDrift
        .unorderedTabDescendants(tabId: 'opener')
        .get();

    expect(unscoped.map((row) => row.id).toSet(), {
      'opener',
      'local-child',
      'reopened',
      'reopened-child',
    });
  });

  test(
    'closing a parent leaves a cross-container child in its own order',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('parent-container', 'parent-context'),
        _ContainerFixture('child-container', 'child-context'),
      ]);
      await _insertTabs(db, const [
        _TabFixture('closing', containerId: 'parent-container'),
        _TabFixture(
          'foreign-child',
          parentId: 'closing',
          containerId: 'child-container',
        ),
        _TabFixture('foreign-sibling', containerId: 'child-container'),
      ]);

      final orderKeyBefore = await _orderKeyOf(db, 'foreign-child');

      await db.tabDao.preservePromotedChildOrderOnClose(const ['closing']);

      // `order_key` only orders tabs within one container; re-slotting the
      // child into the closing tab's list would drop a foreign rank into it.
      expect(await _orderKeyOf(db, 'foreign-child'), orderKeyBefore);
    },
  );

  test(
    'closing a tab with an out-of-container parent hands its slot to its child',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('home', 'home-context'),
        _ContainerFixture('work', 'work-context'),
      ]);
      // `reopened` stores a parent in `home` but is drawn as a root of `work`,
      // between the two plain roots — that rendered scope is the slot its
      // promoted child has to inherit.
      await _insertTabs(db, const [
        _TabFixture('opener', containerId: 'home'),
        _TabFixture('work-first', containerId: 'work'),
        _TabFixture('reopened', parentId: 'opener', containerId: 'work'),
        _TabFixture(
          'reopened-child',
          parentId: 'reopened',
          containerId: 'work',
        ),
        _TabFixture('work-last', containerId: 'work'),
      ]);

      await db.tabDao.preservePromotedChildOrderOnClose(const ['reopened']);
      await db.customStatement("DELETE FROM tab WHERE id = 'reopened'");

      expect(await _orderedTabIdsInContainer(db, 'work'), [
        'work-first',
        'reopened-child',
        'work-last',
      ]);
    },
  );

  test(
    'a closing parent in another container does not swallow the local pass',
    () async {
      await _insertContainers(db, const [
        _ContainerFixture('home', 'home-context'),
        _ContainerFixture('work', 'work-context'),
      ]);
      // The child trails `work-last` in storage, so only an actual re-ranking
      // pass over `work` can put it back into the slot `reopened` vacates.
      await _insertTabs(db, const [
        _TabFixture('opener', containerId: 'home'),
        _TabFixture('work-first', containerId: 'work'),
        _TabFixture('reopened', parentId: 'opener', containerId: 'work'),
        _TabFixture('work-last', containerId: 'work'),
        _TabFixture(
          'reopened-child',
          parentId: 'reopened',
          containerId: 'work',
        ),
      ]);

      // The opener closes too. Its pass only re-ranks `home`, so `reopened`
      // still has to stand in for its own scope rather than be absorbed.
      await db.tabDao.preservePromotedChildOrderOnClose(const [
        'opener',
        'reopened',
      ]);
      await db.customStatement(
        "DELETE FROM tab WHERE id IN ('opener', 'reopened')",
      );

      expect(await _orderedTabIdsInContainer(db, 'work'), [
        'work-first',
        'reopened-child',
        'work-last',
      ]);
    },
  );
}

Future<String> _orderKeyOf(TabDatabase db, String tabId) async {
  final tab = await db.tabDao.getTabDataById(tabId).getSingleOrNull();
  return tab!.orderKey;
}

Future<List<String>> _orderedTabIdsInContainer(
  TabDatabase db,
  String containerId,
) async {
  final tabs = await db.containerDao.getContainerTabsData(containerId).get();

  return (tabs.toList()..sort((a, b) => a.orderKey.compareTo(b.orderKey)))
      .map((tab) => tab.id)
      .toList();
}

Future<void> _insertTabs(TabDatabase db, List<_TabFixture> tabs) async {
  final orderKeys = _spacedOrderKeys(tabs.length);

  for (final (index, tab) in tabs.indexed) {
    await db.tabDao.insertTab(
      tab.id,
      source: tab.source,
      parentId: Value(tab.parentId),
      containerId: Value(tab.containerId),
      orderKey: Value(orderKeys[index]),
    );
  }
}

Future<void> _insertContainers(
  TabDatabase db,
  List<_ContainerFixture> containers,
) async {
  for (final container in containers) {
    await db.containerDao.addContainer(
      ContainerData(
        id: container.id,
        name: container.id,
        color: Colors.blue,
        orderKey: container.id,
        metadata: ContainerMetadata.withDefaults(
          contextualIdentity: container.contextId,
        ),
      ),
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
  final String? containerId;
  final TabSource source;

  const _TabFixture(
    this.id, {
    this.parentId,
    this.containerId,
    this.source = TabSource.manual,
  });
}

class _ContainerFixture {
  final String id;
  final String contextId;

  const _ContainerFixture(this.id, this.contextId);
}

TabState _tabState(String id, {String? parentId, String? contextId}) {
  return TabState.$default(id).copyWith(
    parentId: parentId,
    contextId: contextId,
    url: Uri.parse('https://$id.example/'),
    title: id,
  );
}
