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
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

/// `tab.is_locked` (v20): what the user asked for with "Lock tab".
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

  Future<void> addTab(String id, {String? containerId, TabMode? mode}) async {
    await db.tabDao.insertTab(
      id,
      source: TabSource.manual,
      parentId: const Value(null),
      containerId: Value(containerId),
      tabMode: mode == null ? const Value.absent() : Value(mode),
    );
  }

  Future<void> addContainer(String id) => db.containerDao.addContainer(
    ContainerData(
      id: id,
      name: id,
      color: Colors.blue,
      orderKey: 'a',
      metadata: ContainerMetadata.withDefaults(),
    ),
  );

  Future<Set<String>> lockedIds() async =>
      (await db.tabDao.getLockedTabIds().get()).toSet();

  test('locking and unlocking a regular tab', () async {
    await addTab('a');

    expect(await db.tabDao.lockTab('a'), 1);
    expect(await lockedIds(), {'a'});
    expect(await db.tabDao.lockedTabIdsAmong(['a', 'b']), {'a'});

    expect(await db.tabDao.unlockTab('a'), 1);
    expect(await lockedIds(), isEmpty);
  });

  test('a private tab cannot be locked, by the DAO or by the table', () async {
    await addTab('p', mode: TabMode.private);

    expect(await db.tabDao.lockTab('p'), 0);
    expect(await lockedIds(), isEmpty);

    await expectLater(
      db.customStatement("UPDATE tab SET is_locked = 1 WHERE id = 'p'"),
      throwsA(isA<SqliteException>()),
    );
  });

  test('an isolated tab can be locked', () async {
    await addTab('iso', mode: TabMode.isolated('iso1_test'));

    expect(await db.tabDao.lockTab('iso'), 1);
  });

  test('a tab without a row locks nothing', () async {
    expect(await db.tabDao.lockTab('missing'), 0);
  });

  test("locking deletes the tab's tombstone", () async {
    await addTab('a');
    await db.tabDao.addClosedTabTombstones(['a']);

    await db.tabDao.lockTab('a');

    final restored = await db.tabDao.getStartupRestoredClosedTabIds([
      'a',
    ], sessionStartedAt: DateTime.now().add(const Duration(minutes: 1)));
    expect(restored, isEmpty);
  });

  test('upserting a tab keeps its lock', () async {
    await addTab('a');
    await db.tabDao.lockTab('a');

    await db.tabDao.upsertTabTransactional(
      () async => 'a',
      parentId: const Value(null),
      title: const Value('Again'),
    );
    await db.tabDao.insertTab(
      'a',
      source: TabSource.syncEvent,
      parentId: const Value(null),
    );

    expect(await lockedIds(), {'a'});
  });

  test('a container with a locked tab is not deleted', () async {
    await addContainer('work');
    await addTab('locked', containerId: 'work');
    await addTab('other', containerId: 'work');
    await db.tabDao.lockTab('locked');

    expect(
      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: {'locked', 'other'},
      ),
      0,
    );
    expect(
      await db.containerDao.getContainerData('work').getSingleOrNull(),
      isNotNull,
    );

    await db.tabDao.unlockTab('locked');
    expect(
      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: {'locked', 'other'},
      ),
      1,
    );
    // The cascade took the rows with it.
    expect(await db.tabDao.getExistingTabIds(['locked', 'other']).get(), []);
  });

  test('a container with a row of a tab that was not closed is not deleted, '
      'so the cascade cannot take it', () async {
    await addContainer('work');
    await addTab('closed', containerId: 'work');
    // Joined after the deletion last looked.
    await addTab('late', containerId: 'work');

    expect(
      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: {'closed'},
      ),
      0,
    );
    expect(await db.tabDao.getExistingTabIds(['late']).get(), ['late']);
  });

  test('an empty container is deleted', () async {
    await addContainer('empty');

    expect(
      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'empty',
        closedTabIds: const {},
      ),
      1,
    );
  });

  test('the automatic cleanup of unassigned tabs leaves locked ones', () async {
    await addTab('old');
    await addTab('old-locked');
    await db.tabDao.lockTab('old-locked');

    final candidates = await db.tabDao.getUnassignedRegularTabsOlderThan(
      DateTime.now().add(const Duration(days: 1)),
    );

    expect(candidates, ['old']);
  });
}
