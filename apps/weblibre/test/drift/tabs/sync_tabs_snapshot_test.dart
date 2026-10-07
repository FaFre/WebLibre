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
import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<List<String>> rowIds() async =>
      (await db.select(db.tab).get()).map((row) => row.id).toList();

  group('syncTabsToSnapshot', () {
    test(
      'a tab being created while the snapshot is taken keeps its row',
      () async {
        // An empty session comes back while a shared link opens a tab: the
        // native creation is under way, its row not yet inserted.
        final nativeTabs = <String>[];
        final creationStarted = Completer<void>();
        final finishCreation = Completer<void>();

        final creation = db.tabDao.upsertTabTransactional(() async {
          creationStarted.complete();
          await finishCreation.future;
          nativeTabs.add('shared');
          return 'shared';
        }, parentId: const Value(null));
        await creationStarted.future;

        final sync = db.tabDao.syncTabsToSnapshot(() async => [...nativeTabs]);
        finishCreation.complete();
        await creation;
        final result = await sync;

        expect(await rowIds(), ['shared']);
        expect(result.deletedCount, 0);
      },
    );

    test('removes the rows of tabs the snapshot does not hold', () async {
      await db.tabDao.syncTabs(retainTabIds: const ['stale', 'kept']);

      await db.tabDao.syncTabsToSnapshot(() async => const ['kept']);

      expect(await rowIds(), ['kept']);
    });

    test('an empty snapshot removes every row', () async {
      // A Quit deleted every tab natively before the process ended.
      await db.tabDao.syncTabs(retainTabIds: const ['stale']);

      await db.tabDao.syncTabsToSnapshot(() async => const []);

      expect(await rowIds(), isEmpty);
    });

    test('a failed snapshot read removes nothing', () async {
      await db.tabDao.syncTabs(retainTabIds: const ['kept']);

      await expectLater(
        db.tabDao.syncTabsToSnapshot(
          () async => throw Exception('simulated native failure'),
        ),
        throwsException,
      );

      expect(await rowIds(), ['kept']);
    });
  });
}
