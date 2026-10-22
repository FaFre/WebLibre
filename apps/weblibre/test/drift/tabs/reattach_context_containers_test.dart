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
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

void main() {
  late TabDatabase db;

  setUp(() async {
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );

    for (final id in ['work', 'home']) {
      await db.containerDao.addContainer(
        ContainerData(
          id: id,
          name: id,
          color: Colors.blue,
          orderKey: id,
          metadata: ContainerMetadata.withDefaults(contextualIdentity: id),
        ),
      );
    }
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> addTab(String id, {String? containerId}) {
    return db.tabDao.insertTab(
      id,
      source: TabSource.manual,
      parentId: const Value(null),
      containerId: Value(containerId),
    );
  }

  Future<String?> containerOf(String id) =>
      db.tabDao.getTabContainerId(id).getSingleOrNull();

  test(
    'a tab listed under no container but running in one goes back into it',
    () async {
      // Taken out of "work" while the container lookup read null: the row was
      // cleared, the tab never left the container's context.
      await addTab('moved-out');

      final reattached = await db.tabDao.reattachTabsToContextContainers({
        'moved-out': 'work',
      });

      expect(reattached, ['moved-out']);
      expect(await containerOf('moved-out'), 'work');
    },
  );

  test('a tab that already has a container keeps it', () async {
    await addTab('in-home', containerId: 'home');

    final reattached = await db.tabDao.reattachTabsToContextContainers({
      'in-home': 'work',
    });

    expect(reattached, isEmpty);
    expect(await containerOf('in-home'), 'home');
  });

  test('a context no container owns moves nothing', () async {
    await addTab('isolated');
    await addTab('of-deleted-container');

    final reattached = await db.tabDao.reattachTabsToContextContainers({
      'isolated': 'isolated:3f2a',
      'of-deleted-container': 'gone',
    });

    expect(reattached, isEmpty);
    expect(await containerOf('isolated'), isNull);
    expect(await containerOf('of-deleted-container'), isNull);
  });

  test('a tab the engine does not name is left alone', () async {
    await addTab('general');

    final reattached = await db.tabDao.reattachTabsToContextContainers({});

    expect(reattached, isEmpty);
    expect(await containerOf('general'), isNull);
  });
}
