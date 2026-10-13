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

  Future<Map<String, String?>> recorded(List<String> ids) async => {
    for (final MapEntry(:key, :value) in (await db.tabDao.closedTabContainers(
      ids,
    )).entries)
      key: value.containerId,
  };

  test('a closed regular tab keeps the container it ran in', () async {
    await db.containerDao.addContainer(
      ContainerData(
        id: 'work',
        name: 'Work',
        color: Colors.blue,
        orderKey: 'a',
        metadata: ContainerMetadata.withDefaults(),
      ),
    );
    await addTab('in-work', containerId: 'work');
    await addTab('loose');
    await addTab('open');

    await db.tabDao.syncTabs(retainTabIds: ['open']);

    expect(await recorded(['in-work', 'loose', 'open']), {
      'in-work': 'work',
      'loose': null,
    });
  });

  test('private and isolated tabs are never recorded', () async {
    await addTab('private', mode: TabMode.private);
    await addTab('isolated', mode: TabMode.isolated('iso1_test'));

    await db.tabDao.syncTabs(retainTabIds: const []);

    expect(await recorded(['private', 'isolated']), isEmpty);
  });

  test('only the tabs still on the recently closed list are kept', () async {
    await addTab('kept');
    await addTab('undone');

    await db.tabDao.syncTabs(retainTabIds: const []);
    await db.tabDao.retainClosedTabContainers(['kept']);

    expect((await recorded(['kept', 'undone'])).keys, ['kept']);
  });

  test('a close the list may still get is kept until it is old', () async {
    await addTab('pending');

    await db.tabDao.syncTabs(retainTabIds: const []);
    await db.tabDao.retainClosedTabContainers(
      const [],
      recordedSince: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    expect((await recorded(['pending'])).keys, ['pending']);

    await db.tabDao.retainClosedTabContainers(
      const [],
      recordedSince: DateTime.now().add(const Duration(minutes: 1)),
    );
    expect(await recorded(['pending']), isEmpty);
  });
}
