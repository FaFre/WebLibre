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
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/delete_container_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  /// Opens the dialog and returns what confirming it with Delete decides.
  Future<DeleteContainerDecision?> open(
    WidgetTester tester, {
    required bool hasOwnStorage,
    required bool frozen,
    Future<void> Function()? interact,
  }) async {
    DeleteContainerDecision? decision;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                decision = await showDeleteContainerDialog(
                  context,
                  hasOwnStorage: hasOwnStorage,
                  frozen: frozen,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await interact?.call();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    return decision;
  }

  final siteData = find.widgetWithText(
    CheckboxListTile,
    'Also delete site data',
  );

  testWidgets('site data is kept unless chosen for an ordinary '
      'container', (tester) async {
    final kept = await open(tester, hasOwnStorage: true, frozen: false);
    expect(kept?.deleteSiteData, isFalse);

    final deleted = await open(
      tester,
      hasOwnStorage: true,
      frozen: false,
      interact: () async {
        await tester.tap(siteData);
        await tester.pumpAndSettle();
      },
    );
    expect(deleted?.deleteSiteData, isTrue);
  });

  testWidgets('a frozen container deletes its site data, and says '
      'why', (tester) async {
    final decision = await open(
      tester,
      hasOwnStorage: true,
      frozen: true,
      interact: () async {
        final tile = tester.widget<CheckboxListTile>(siteData);
        expect(tile.value, isTrue);
        expect(tile.onChanged, isNull);
        expect(
          find.textContaining("A frozen container's data is deleted"),
          findsOneWidget,
        );
      },
    );
    expect(decision?.deleteSiteData, isTrue);
  });

  testWidgets('a container without its own storage has no site-data '
      'choice', (tester) async {
    final decision = await open(
      tester,
      hasOwnStorage: false,
      frozen: false,
      interact: () async => expect(siteData, findsNothing),
    );
    expect(decision?.deleteSiteData, isFalse);
  });
}
