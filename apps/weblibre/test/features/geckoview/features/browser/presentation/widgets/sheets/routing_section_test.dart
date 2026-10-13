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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/routing_section.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/effective_tab_routing.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _tabId = 'tab';

TabRouting _routing(
  TabRoutingStatus status, {
  ProxyConnectionId? proxyConnectionId,
  String? proxyTitle,
  bool isContextMismatch = false,
}) => TabRouting(
  status: status,
  isContextMismatch: isContextMismatch,
  contextId: generalContextId,
  proxyConnectionId: proxyConnectionId,
  proxyTitle: proxyTitle,
  containerName: null,
);

ContainerRoutingSnapshot _snapshot(Map<String, List<String>> relations) =>
    ContainerRoutingSnapshot(
      proxies: const [],
      relations: relations,
      directScopes: const {},
      siteAssignments: const {},
      strictContexts: const {},
    );

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> pumpSection(
    WidgetTester tester, {
    required TabRouting routing,
    required ContainerRoutingSnapshot? snapshot,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectiveTabRoutingProvider(_tabId).overrideWithValue(routing),
          containerRoutingSnapshotProvider.overrideWithValue(snapshot),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RoutingSection(tabId: _tabId, onClose: () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('stays out of the way of someone without any proxy route', (
    tester,
  ) async {
    await pumpSection(
      tester,
      routing: _routing(TabRoutingStatus.direct),
      snapshot: _snapshot({generalContextId: const []}),
    );

    expect(find.text(l10n.proxy_tabRoutingTitle), findsNothing);
  });

  testWidgets('says a tab is direct once any route exists', (tester) async {
    await pumpSection(
      tester,
      routing: _routing(TabRoutingStatus.direct),
      snapshot: _snapshot({
        'container-a': const ['tor'],
      }),
    );

    expect(find.text(l10n.proxy_tabRoutingDirect), findsOneWidget);
  });

  testWidgets('offers to start the proxy a blocked tab is waiting for', (
    tester,
  ) async {
    await pumpSection(
      tester,
      routing: _routing(
        TabRoutingStatus.blocked,
        proxyConnectionId: const TorProxyConnectionId(),
        proxyTitle: 'Tor',
      ),
      snapshot: _snapshot({
        generalContextId: const ['tor'],
      }),
    );

    expect(
      find.text(l10n.proxy_tabRoutingBlockedNotRunning('Tor')),
      findsOneWidget,
    );
    expect(find.text(l10n.proxy_actionStart), findsOneWidget);
  });

  testWidgets('shows routing that is still starting to everyone', (
    tester,
  ) async {
    await pumpSection(
      tester,
      routing: _routing(TabRoutingStatus.pending),
      snapshot: null,
    );

    expect(find.text(l10n.proxy_tabRoutingStarting), findsOneWidget);
  });
}
