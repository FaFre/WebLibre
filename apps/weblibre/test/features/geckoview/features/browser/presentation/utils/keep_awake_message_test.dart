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
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_sleep_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FakeTabData extends TabDataRepository {
  final exempted = <(String, bool)>[];

  @override
  void build() {}

  @override
  Future<void> setSleepExempt(String tabId, {required bool exempt}) async {
    exempted.add((tabId, exempt));
  }
}

void main() {
  late _FakeTabData tabData;
  late ProviderContainer container;

  Future<BuildContext> pump(WidgetTester tester) async {
    tabData = _FakeTabData();
    container = ProviderContainer(
      overrides: [tabDataRepositoryProvider.overrideWith(() => tabData)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SizedBox()),
        ),
      ),
    );
    return tester.element(find.byType(Scaffold));
  }

  final description = find.text(
    'Automatic sleep and automatic freeze skip a tab that is kept awake. '
    'You can still put it to sleep or freeze its container yourself.',
  );

  testWidgets('turning Keep awake on stores it and says what it covers', (
    tester,
  ) async {
    final context = await pump(tester);

    await setTabKeptAwakeFromMenu(context, container.read, 'tab', exempt: true);
    await tester.pumpAndSettle();

    expect(tabData.exempted, [('tab', true)]);
    expect(description, findsOneWidget);
  });

  testWidgets('allowing sleep again stores it without a message', (
    tester,
  ) async {
    final context = await pump(tester);

    await setTabKeptAwakeFromMenu(
      context,
      container.read,
      'tab',
      exempt: false,
    );
    await tester.pumpAndSettle();

    expect(tabData.exempted, [('tab', false)]);
    expect(description, findsNothing);
  });
}
