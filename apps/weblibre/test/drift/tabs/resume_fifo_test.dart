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

/// Inserts [id] and stamps it, so "most recently used" ordering is explicit
/// rather than dependent on insertion timing.
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
  await db.tabDao.touchTab(
    id,
    timestamp: DateTime(2026, 8, 1, 12, minuteOfUse),
  );
}

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

  group('getTabsFifo', () {
    test('returns the most recently used tab first', () async {
      await _addTab(db, 'older', minuteOfUse: 1);
      await _addTab(db, 'newer', minuteOfUse: 5);

      final tabs = await db.tabDao.getTabsFifo(limit: 1).get();

      expect(tabs.single.id, 'newer');
    });

    test('skips excluded tabs', () async {
      // The regression this guards: tab rows are deleted only after the next
      // selection is made, so the tab being closed is still here — and having
      // just been active it sorts first, so an unfiltered query resumes the
      // very tab that is about to disappear.
      await _addTab(db, 'closing', minuteOfUse: 9);
      await _addTab(db, 'survivor', minuteOfUse: 1);

      final tabs = await db.tabDao
          .getTabsFifo(limit: 1, excludedTabIds: {'closing'})
          .get();

      expect(tabs.single.id, 'survivor');
    });

    test('returns nothing when every candidate is excluded', () async {
      await _addTab(db, 'closing', minuteOfUse: 1);

      final tabs = await db.tabDao
          .getTabsFifo(limit: 1, excludedTabIds: {'closing'})
          .get();

      expect(tabs, isEmpty);
    });
  });

  group('getContainerTabsFifo', () {
    test('stays within the requested container', () async {
      await _addContainer(db, 'a');
      await _addContainer(db, 'b');
      await _addTab(db, 'other-container', containerId: 'b', minuteOfUse: 9);
      await _addTab(db, 'wanted', containerId: 'a', minuteOfUse: 1);

      final tabs = await db.tabDao.getContainerTabsFifo('a', limit: 1).get();

      expect(tabs.single.id, 'wanted');
    });

    test('skips the closing tab within a container', () async {
      await _addContainer(db, 'a');
      await _addTab(db, 'closing', containerId: 'a', minuteOfUse: 9);
      await _addTab(db, 'survivor', containerId: 'a', minuteOfUse: 1);

      final tabs = await db.tabDao
          .getContainerTabsFifo('a', limit: 1, excludedTabIds: {'closing'})
          .get();

      expect(tabs.single.id, 'survivor');
    });

    test('a null container means unassigned, not any container', () async {
      await _addContainer(db, 'a');
      await _addTab(db, 'in-container', containerId: 'a', minuteOfUse: 9);
      await _addTab(db, 'unassigned', minuteOfUse: 1);

      final tabs = await db.tabDao.getContainerTabsFifo(null, limit: 1).get();

      expect(tabs.single.id, 'unassigned');
    });

    test('skips the closing tab in the unassigned container', () async {
      // Closing the last unassigned tab must not resume that same tab, nor
      // fall through into a container.
      await _addContainer(db, 'a');
      await _addTab(db, 'in-container', containerId: 'a', minuteOfUse: 5);
      await _addTab(db, 'closing', minuteOfUse: 9);

      final tabs = await db.tabDao
          .getContainerTabsFifo(null, limit: 1, excludedTabIds: {'closing'})
          .get();

      expect(tabs, isEmpty);
    });
  });
}
