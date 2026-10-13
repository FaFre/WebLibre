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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/recently_closed_tabs.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

/// The engine's recently closed list, set by the test.
class _FakeRecentlyClosedTabsService extends GeckoRecentlyClosedTabsService {
  List<RecentlyClosedTab> tabs = [];
  int reads = 0;

  @override
  Future<List<RecentlyClosedTab>> getTabs() async {
    reads++;
    return tabs;
  }
}

void main() {
  late TabDatabase db;
  late _FakeRecentlyClosedTabsService engine;
  late ProviderContainer container;

  setUp(() async {
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
    await db.containerDao.addContainer(
      ContainerData(
        id: 'work',
        name: 'Work',
        color: Colors.blue,
        orderKey: 'a',
        metadata: ContainerMetadata.withDefaults(),
      ),
    );
    engine = _FakeRecentlyClosedTabsService();
    container = ProviderContainer(
      overrides: [
        tabDatabaseProvider.overrideWith((ref) => db),
        recentlyClosedTabsRepositoryProvider.overrideWith(
          () => RecentlyClosedTabsRepository(service: engine),
        ),
      ],
    );
    // As the History screen does, for the whole test.
    final subscription = container.listen(
      recentlyClosedTabsRepositoryProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<List<RecentlyClosedTabEntry>> entries() =>
      container.read(recentlyClosedTabsRepositoryProvider.future);

  /// Closes [id], a tab of the "work" container: the row goes and its close
  /// is recorded, as when the engine's tab list reaches Dart.
  Future<void> closeWorkTab(String id) async {
    await db.tabDao.insertTab(
      id,
      source: TabSource.manual,
      parentId: const Value(null),
      containerId: const Value('work'),
    );
    await db.tabDao.syncTabs(retainTabIds: const []);
  }

  test(
    'a close recorded after the list was read still gets its container',
    () async {
      expect(await entries(), isEmpty);

      // The engine lists the tab before Dart has recorded its close.
      engine.tabs = [
        RecentlyClosedTab(
          id: 'closed',
          url: 'https://a.example/',
          title: 'A',
          lastAccess: 0,
        ),
      ];
      await closeWorkTab('closed');
      await pumpEventQueue();

      final entry = (await entries()).single;
      expect(entry.tab.id, 'closed');
      expect(entry.container?.id, 'work');
    },
  );

  test('sweeping old records does not read the list over and over', () async {
    await db.customStatement(
      'INSERT INTO closed_tab_container (tab_id, container_id, closed_at) '
      "VALUES ('undone', 'work', 0)",
    );

    expect(await entries(), isEmpty);
    await pumpEventQueue();

    // The first read swept the old record, which rebuilt the list once.
    expect(engine.reads, 2);
    expect(await db.tabDao.closedTabContainers(['undone']), isEmpty);
  });
}
