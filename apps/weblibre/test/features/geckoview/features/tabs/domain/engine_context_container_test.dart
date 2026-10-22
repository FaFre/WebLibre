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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/proxy/domain/providers/effective_tab_routing.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_context.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';

/// What decides a tab's cookies and route is the context the engine runs it
/// in. These cover the places that used to read that off the tab's container
/// row instead, and went wrong for every tab while that lookup read null.
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
    await db.containerDao.addContainer(
      ContainerData(
        id: 'work',
        name: 'Work',
        color: Colors.blue,
        orderKey: 'work',
        metadata: ContainerMetadata.withDefaults(contextualIdentity: 'work'),
      ),
    );
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

  TabState engineState(
    String id, {
    String? contextId,
    TabMode tabMode = TabMode.regular,
    bool reported = true,
  }) {
    return TabState.$default(id).copyWith(
      contextId: contextId,
      tabMode: tabMode,
      hasContentState: reported,
    );
  }

  ProviderContainer containerFor(Map<String, TabState> engineStates) {
    final container = ProviderContainer(
      overrides: [
        tabDatabaseProvider.overrideWith((ref) => db),
        for (final MapEntry(key: id, value: state) in engineStates.entries)
          tabStateProvider(id).overrideWithValue(state),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final refProvider = Provider<Ref>((ref) => ref);

  group('a copy of a tab', () {
    test('goes into the container the tab is listed under', () async {
      await addTab('t', containerId: 'work');
      final container = containerFor({
        't': engineState('t', contextId: 'work'),
      });

      final copyContainer = await container
          .read(tabDataRepositoryProvider.notifier)
          .getContainerForCopy('t');

      expect(copyContainer?.id, 'work');
    });

    test(
      'goes into the container the tab runs in when none is listed',
      () async {
        // Listed under none, running in "work": a copy opened in no container
        // would load on general cookies over the general route.
        await addTab('t');
        final container = containerFor({
          't': engineState('t', contextId: 'work'),
        });

        final copyContainer = await container
            .read(tabDataRepositoryProvider.notifier)
            .getContainerForCopy('t');

        expect(copyContainer?.id, 'work');
      },
    );

    test('of a tab in no container goes into none', () async {
      await addTab('t');
      final container = containerFor({'t': engineState('t')});

      expect(
        await container
            .read(tabDataRepositoryProvider.notifier)
            .getContainerForCopy('t'),
        isNull,
      );
    });
  });

  group('requests made on behalf of a tab', () {
    test('take the context the engine runs the tab in', () async {
      // The row says no container; the engine says "work", and the engine is
      // what the extension routes the page itself by.
      await addTab('t');
      final container = containerFor({});
      final ref = container.read(refProvider);

      expect(
        await routingContextIdForTab(ref, engineState('t', contextId: 'work')),
        'work',
      );
      expect(
        await routingContextIdForTab(ref, engineState('t')),
        generalContextId,
      );
      expect(
        await routingContextIdForTab(
          ref,
          engineState('t', tabMode: TabMode.private),
        ),
        privateContextId,
      );
    });

    test(
      'fall back to the container row before the engine reports the tab',
      () async {
        // A tab opened a moment ago: what is typed into it must not go out
        // over the general route because the engine has not answered yet.
        await addTab('t', containerId: 'work');
        final container = containerFor({});
        final ref = container.read(refProvider);

        expect(
          await routingContextIdForTab(ref, engineState('t', reported: false)),
          'work',
        );
      },
    );
  });

  group('the tunneled indicator', () {
    Future<bool> tunneledFor(TabRoutingStatus status) async {
      final container = ProviderContainer(
        overrides: [
          effectiveTabRoutingProvider('t').overrideWithValue(
            TabRouting(
              status: status,
              isContextMismatch: false,
              contextId: 'work',
              proxyConnectionId: null,
              proxyTitle: null,
              containerName: null,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(isTabTunneledProvider('t'), (_, _) {});
      return await container.read(isTabTunneledProvider('t').future);
    }

    test('shows a route through a proxy, running or not', () async {
      expect(await tunneledFor(TabRoutingStatus.active), isTrue);
      // Blocked, never direct: the extension refuses rather than falling back.
      expect(await tunneledFor(TabRoutingStatus.blocked), isTrue);
    });

    test('never claims what is not confirmed', () async {
      expect(await tunneledFor(TabRoutingStatus.direct), isFalse);
      expect(await tunneledFor(TabRoutingStatus.pending), isFalse);
      expect(await tunneledFor(TabRoutingStatus.unknown), isFalse);
    });
  });
}
