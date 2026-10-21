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
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

Future<void> _addContainer(TabDatabase db, String id) {
  return db.containerDao.addContainer(
    ContainerData(
      id: id,
      name: id,
      color: Colors.blue,
      orderKey: id,
      metadata: ContainerMetadata.withDefaults(contextualIdentity: id),
    ),
  );
}

DateTime _minute(int minute) => DateTime(2026, 10, 21, 12, minute);

/// Inserts [id] and stamps it, so "last used" is explicit rather than
/// dependent on insertion timing.
Future<void> _addTab(
  TabDatabase db,
  String id, {
  String? containerId,
  required int minuteOfUse,
}) async {
  await db.tabDao.insertTab(
    id,
    source: TabSource.manual,
    parentId: const Value(null),
    containerId: Value(containerId),
  );
  await db.tabDao.touchTab(id, timestamp: _minute(minuteOfUse));
}

Future<Map<String, DateTime>> _lastUsed(TabDatabase db) async =>
    Map.fromEntries(await db.containerDao.getContainerLastUsed().get());

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

  group('getContainerLastUsed', () {
    test('reports the newest tab timestamp of each container', () async {
      await _addContainer(db, 'work');
      await _addContainer(db, 'news');
      await _addTab(db, 'w1', containerId: 'work', minuteOfUse: 3);
      await _addTab(db, 'w2', containerId: 'work', minuteOfUse: 7);
      await _addTab(db, 'n1', containerId: 'news', minuteOfUse: 5);

      expect(await _lastUsed(db), {'work': _minute(7), 'news': _minute(5)});
    });

    test('leaves out containers without tabs and unassigned tabs', () async {
      await _addContainer(db, 'work');
      await _addContainer(db, 'empty');
      await _addTab(db, 'w1', containerId: 'work', minuteOfUse: 3);
      await _addTab(db, 'loose', minuteOfUse: 9);

      expect(await _lastUsed(db), {'work': _minute(3)});
    });

    test('follows a tab being selected again', () async {
      await _addContainer(db, 'work');
      await _addContainer(db, 'news');
      await _addTab(db, 'w1', containerId: 'work', minuteOfUse: 3);
      await _addTab(db, 'n1', containerId: 'news', minuteOfUse: 5);

      await db.tabDao.touchTab('w1', timestamp: _minute(8));

      expect(await _lastUsed(db), {'work': _minute(8), 'news': _minute(5)});
    });
  });
}
