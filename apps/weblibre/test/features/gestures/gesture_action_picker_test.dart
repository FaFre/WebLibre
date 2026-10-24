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
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_action_picker.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const UnsetActionOption _greyOut = (
  title: 'Grey out',
  description: 'Keep this button in place, greyed out',
  icon: Icons.block,
);

/// Opens the picker over a page and hands what it returns to [onPicked].
Future<void> _openPicker(
  WidgetTester tester, {
  required ValueChanged<({BrowserAction? action})?> onPicked,
  List<BrowserAction> actions = BrowserAction.values,
  BrowserAction? selected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => onPicked(
                await showOptionalBrowserActionPicker(
                  context,
                  title: 'If unavailable',
                  selected: selected,
                  unsetOption: _greyOut,
                  actions: actions,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search narrows the list to the matching actions', (
    tester,
  ) async {
    await _openPicker(tester, onPicked: (_) {});

    expect(find.text('If unavailable'), findsOne);
    expect(find.text('Grey out'), findsOne);
    expect(find.text('Address Bar'), findsOne);

    await tester.enterText(find.byType(TextField), 'qr');
    await tester.pumpAndSettle();

    expect(find.text('Scan QR Code'), findsOne);
    expect(find.text('Address Bar'), findsNothing);
    expect(find.text('Grey out'), findsNothing);
  });

  testWidgets('every word of the search has to match', (tester) async {
    await _openPicker(tester, onPicked: (_) {});

    await tester.enterText(find.byType(TextField), 'page font');
    await tester.pumpAndSettle();

    expect(find.text('Increase Font'), findsOne);
    // Its description mentions the page, but not the font.
    expect(find.text('Print'), findsNothing);
  });

  testWidgets('a search that matches nothing says so', (tester) async {
    await _openPicker(tester, onPicked: (_) {});

    await tester.enterText(find.byType(TextField), 'xyzzy');
    await tester.pumpAndSettle();

    expect(find.text('No matching actions.'), findsOne);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('the unset entry is found by its own words', (tester) async {
    ({BrowserAction? action})? picked;
    await _openPicker(
      tester,
      onPicked: (result) => picked = result,
      selected: BrowserAction.sharePage,
    );

    await tester.enterText(find.byType(TextField), 'grey');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grey out'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.action, isNull);
  });

  testWidgets('a found action is returned when tapped', (tester) async {
    ({BrowserAction? action})? picked;
    await _openPicker(
      tester,
      onPicked: (result) => picked = result,
      actions: const [BrowserAction.sharePage, BrowserAction.showBrowserMenu],
    );

    expect(find.text('Back'), findsNothing);

    await tester.enterText(find.byType(TextField), 'menu');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    expect(picked?.action, BrowserAction.showBrowserMenu);
  });
}
