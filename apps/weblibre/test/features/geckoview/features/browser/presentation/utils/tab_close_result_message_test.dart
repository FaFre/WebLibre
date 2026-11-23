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
import 'package:weblibre/features/geckoview/domain/entities/tab_close_result.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Undo is offered only when a close closed something, and a close a lock
/// refused says so.
void main() {
  late AppLocalizations l10n;

  Future<BuildContext> pump(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    l10n = AppLocalizations.of(captured);
    return captured;
  }

  Finder undo() => find.widgetWithText(SnackBarAction, l10n.common_undo);

  testWidgets('a close that closed tabs offers Undo', (tester) async {
    final context = await pump(tester);

    showTabCloseResult(context, CloseResult(removedTabIds: ['a', 'b']), () {});
    await tester.pump();

    expect(find.text(l10n.uiHelper_tabsClosedCount(2)), findsOneWidget);
    expect(undo(), findsOneWidget);
  });

  testWidgets('a single locked tab says it is locked, without Undo', (
    tester,
  ) async {
    final context = await pump(tester);

    showTabCloseResult(context, CloseResult(skippedLockedTabIds: ['a']), () {});
    await tester.pump();

    expect(find.text(l10n.browser_tabIsLocked), findsOneWidget);
    expect(undo(), findsNothing);
  });

  testWidgets('several locked tabs are counted, without Undo', (tester) async {
    final context = await pump(tester);

    showTabCloseResult(
      context,
      CloseResult(skippedLockedTabIds: ['a', 'b']),
      () {},
    );
    await tester.pump();

    expect(find.text(l10n.browser_lockedTabsKept(2)), findsOneWidget);
    expect(undo(), findsNothing);
  });

  testWidgets('a partly kept close counts both and offers Undo', (
    tester,
  ) async {
    final context = await pump(tester);

    showTabCloseResult(
      context,
      CloseResult(removedTabIds: ['a', 'b'], skippedLockedTabIds: ['c']),
      () {},
    );
    await tester.pump();

    expect(find.text(l10n.browser_tabsClosedKeptLocked(2, 1)), findsOneWidget);
    expect(undo(), findsOneWidget);
  });

  testWidgets('a close of tabs already gone shows nothing', (tester) async {
    final context = await pump(tester);

    showTabCloseResult(context, CloseResult(missingTabIds: ['a']), () {});
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('bulk closes report only what a lock kept', (tester) async {
    final context = await pump(tester);

    showLockedTabsKept(context, CloseResult(removedTabIds: ['a']), () {});
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);

    showLockedTabsKept(
      context,
      CloseResult(removedTabIds: ['a'], skippedLockedTabIds: ['b']),
      () {},
    );
    await tester.pump();
    expect(find.text(l10n.browser_tabsClosedKeptLocked(1, 1)), findsOneWidget);
  });
}
