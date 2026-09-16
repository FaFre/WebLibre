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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/default_keyboard_shortcuts.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/widgets/browser_keyboard_shortcuts.dart';
import 'package:weblibre/presentation/widgets/web_content_keyboard.dart';

Future<bool> pressCtrlT(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  final handled = await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  return handled;
}

/// Focus can leave the shortcut subtree without the user touching the page:
/// the focused page view is replaced (a tab switch), something calls
/// `unfocus()`, or a route above the browser pops back to a stale history.
/// Shortcuts must keep working in all of these, since only tapping web content
/// would bring focus back.
void main() {
  late FocusNode firstPage;
  late FocusNode secondPage;
  final selectedTab = ValueNotifier(1);

  setUp(() {
    firstPage = FocusNode(debugLabel: 'page 1');
    secondPage = FocusNode(debugLabel: 'page 2');
    selectedTab.value = 1;
  });
  tearDown(() {
    firstPage.dispose();
    secondPage.dispose();
  });

  Future<List<BrowserAction>> pumpBrowser(
    WidgetTester tester, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    final fired = <BrowserAction>[];
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: BrowserKeyboardShortcuts(
          bindings: defaultKeyboardShortcuts,
          onAction: fired.add,
          child: Column(
            children: [
              TextButton(onPressed: () {}, child: const Text('chrome')),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: selectedTab,
                  builder: (context, tab, _) => WebContentKeyPassthrough(
                    child: Focus(
                      key: ValueKey(tab),
                      focusNode: tab == 1 ? firstPage : secondPage,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    firstPage.requestFocus();
    await tester.pump();
    return fired;
  }

  testWidgets('after the focused page view is replaced', (tester) async {
    final fired = await pumpBrowser(tester);

    selectedTab.value = 2;
    await tester.pump();

    expect(await pressCtrlT(tester), isTrue);
    expect(fired, [BrowserAction.newTab]);
  });

  testWidgets('after the page is unfocused', (tester) async {
    final fired = await pumpBrowser(tester);

    firstPage.unfocus();
    await tester.pump();

    expect(await pressCtrlT(tester), isTrue);
    expect(fired, [BrowserAction.newTab]);
  });

  testWidgets('after a route above pops back to a replaced page', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final fired = await pumpBrowser(tester, navigatorKey: navigatorKey);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: TextField(autofocus: true)),
      ),
    );
    await tester.pumpAndSettle();
    selectedTab.value = 2;
    await tester.pump();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(await pressCtrlT(tester), isTrue);
    expect(fired, [BrowserAction.newTab]);
  });

  testWidgets('not while a route covers the browser', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final fired = await pumpBrowser(tester, navigatorKey: navigatorKey);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();

    await pressCtrlT(tester);
    expect(fired, isEmpty);
  });
}
