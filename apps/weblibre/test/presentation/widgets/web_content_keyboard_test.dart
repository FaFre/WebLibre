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
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/widgets/browser_keyboard_shortcuts.dart';
import 'package:weblibre/presentation/widgets/web_content_keyboard.dart';

/// Stands in for a platform view: a focus node the way `PlatformViewLink`
/// creates one, focused the way native focus moves it.
class _FakePage extends StatelessWidget {
  final FocusNode focusNode;

  const _FakePage({required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Focus(focusNode: focusNode, child: const SizedBox.expand());
  }
}

/// The page beside a focusable chrome control, as in the browser.
///
/// The control matters: Tab is only reported handled when focus has somewhere
/// to go, so a page alone on screen would pass Tab through with or without a
/// passthrough and prove nothing.
Widget _pageWithChrome(Widget page) {
  return Column(
    children: [
      TextButton(onPressed: () {}, child: const Text('chrome')),
      Expanded(child: page),
    ],
  );
}

/// Sends [key] with [modifiers] held and returns whether Flutter handled it,
/// which on Android is what decides whether the page gets it instead.
Future<bool> press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  List<LogicalKeyboardKey> modifiers = const [],
}) async {
  for (final modifier in modifiers) {
    await tester.sendKeyDownEvent(modifier);
  }
  final handled = await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  for (final modifier in modifiers.reversed) {
    await tester.sendKeyUpEvent(modifier);
  }
  return handled;
}

void main() {
  late FocusNode page;

  setUp(() => page = FocusNode(debugLabel: 'page'));
  tearDown(() => page.dispose());

  Future<List<BrowserAction>> pumpBrowser(WidgetTester tester) async {
    final fired = <BrowserAction>[];
    await tester.pumpWidget(
      MaterialApp(
        home: BrowserKeyboardShortcuts(
          bindings: defaultKeyboardShortcuts,
          onAction: fired.add,
          child: _pageWithChrome(
            WebContentKeyPassthrough(child: _FakePage(focusNode: page)),
          ),
        ),
      ),
    );
    page.requestFocus();
    await tester.pump();
    return fired;
  }

  group('without the passthrough', () {
    testWidgets('Flutter takes Tab from a focused page', (tester) async {
      // The reason the passthrough exists: WidgetsApp's default shortcuts
      // consume focus traversal keys, so on a device the page never gets them.
      await tester.pumpWidget(
        MaterialApp(home: _pageWithChrome(_FakePage(focusNode: page))),
      );
      page.requestFocus();
      await tester.pump();

      expect(await press(tester, LogicalKeyboardKey.tab), isTrue);
      // And focus left the page, which on a device clears native focus too.
      expect(page.hasPrimaryFocus, isFalse);
    });
  });

  group('WebContentKeyPassthrough', () {
    for (final key in [
      LogicalKeyboardKey.tab,
      LogicalKeyboardKey.escape,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.pageDown,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.keyA,
    ]) {
      testWidgets('leaves ${key.keyLabel} unhandled for the page', (
        tester,
      ) async {
        await pumpBrowser(tester);
        expect(await press(tester, key), isFalse);
      });
    }

    testWidgets('leaves editing chords to the page', (tester) async {
      await pumpBrowser(tester);
      expect(
        await press(
          tester,
          LogicalKeyboardKey.keyC,
          modifiers: [LogicalKeyboardKey.controlLeft],
        ),
        isFalse,
      );
    });

    testWidgets('keeps page focus on Tab', (tester) async {
      await pumpBrowser(tester);
      await press(tester, LogicalKeyboardKey.tab);
      expect(page.hasPrimaryFocus, isTrue);
    });
  });

  group('BrowserKeyboardShortcuts', () {
    final cases =
        <(String, LogicalKeyboardKey, List<LogicalKeyboardKey>, BrowserAction)>[
          (
            'Ctrl+L',
            LogicalKeyboardKey.keyL,
            [LogicalKeyboardKey.controlLeft],
            BrowserAction.focusAddressBar,
          ),
          (
            'Ctrl+T',
            LogicalKeyboardKey.keyT,
            [LogicalKeyboardKey.controlLeft],
            BrowserAction.newTab,
          ),
          (
            'Ctrl+W',
            LogicalKeyboardKey.keyW,
            [LogicalKeyboardKey.controlLeft],
            BrowserAction.closeTab,
          ),
          (
            'Ctrl+Shift+T',
            LogicalKeyboardKey.keyT,
            [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft],
            BrowserAction.reopenClosedTab,
          ),
          (
            'Ctrl+R',
            LogicalKeyboardKey.keyR,
            [LogicalKeyboardKey.controlLeft],
            BrowserAction.reload,
          ),
          ('F5', LogicalKeyboardKey.f5, [], BrowserAction.reload),
          (
            'Ctrl+F',
            LogicalKeyboardKey.keyF,
            [LogicalKeyboardKey.controlLeft],
            BrowserAction.findInPage,
          ),
          (
            'Ctrl+Tab',
            LogicalKeyboardKey.tab,
            [LogicalKeyboardKey.controlLeft],
            BrowserAction.nextTab,
          ),
          (
            'Ctrl+Shift+Tab',
            LogicalKeyboardKey.tab,
            [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft],
            BrowserAction.previousTab,
          ),
          (
            'Alt+Left',
            LogicalKeyboardKey.arrowLeft,
            [LogicalKeyboardKey.altLeft],
            BrowserAction.back,
          ),
          (
            'Alt+Right',
            LogicalKeyboardKey.arrowRight,
            [LogicalKeyboardKey.altLeft],
            BrowserAction.forward,
          ),
        ];

    for (final (label, key, modifiers, expected) in cases) {
      testWidgets('$label reaches the browser from a focused page', (
        tester,
      ) async {
        final fired = await pumpBrowser(tester);

        expect(await press(tester, key, modifiers: modifiers), isTrue);
        expect(fired, [expected]);
      });
    }

    testWidgets('works with nothing inside focused', (tester) async {
      final fired = <BrowserAction>[];
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserKeyboardShortcuts(
            bindings: defaultKeyboardShortcuts,
            onAction: fired.add,
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();

      await press(
        tester,
        LogicalKeyboardKey.keyT,
        modifiers: [LogicalKeyboardKey.controlLeft],
      );
      expect(fired, [BrowserAction.newTab]);
    });

    group('with a focused text field', () {
      late FocusNode field;
      late TextEditingController controller;

      Future<List<BrowserAction>> pumpField(WidgetTester tester) async {
        field = FocusNode(debugLabel: 'field');
        addTearDown(field.dispose);
        controller = TextEditingController(text: 'hello');
        addTearDown(controller.dispose);

        final fired = <BrowserAction>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: BrowserKeyboardShortcuts(
                bindings: defaultKeyboardShortcuts,
                onAction: fired.add,
                child: TextField(controller: controller, focusNode: field),
              ),
            ),
          ),
        );
        field.requestFocus();
        await tester.pump();
        controller.selection = const TextSelection.collapsed(offset: 2);
        await tester.pump();
        return fired;
      }

      testWidgets('Alt+Left and Alt+Right move the caret, not the page', (
        tester,
      ) async {
        final fired = await pumpField(tester);

        await press(
          tester,
          LogicalKeyboardKey.arrowLeft,
          modifiers: [LogicalKeyboardKey.altLeft],
        );
        await tester.pump();
        expect(controller.selection.isCollapsed, isTrue);
        expect(controller.selection.baseOffset, 0);

        await press(
          tester,
          LogicalKeyboardKey.arrowRight,
          modifiers: [LogicalKeyboardKey.altLeft],
        );
        await tester.pump();
        expect(controller.selection.baseOffset, 5);

        expect(fired, isEmpty);
      });

      testWidgets('other chords still reach the browser', (tester) async {
        final fired = await pumpField(tester);

        await press(
          tester,
          LogicalKeyboardKey.keyT,
          modifiers: [LogicalKeyboardKey.controlLeft],
        );
        expect(fired, [BrowserAction.newTab]);
      });
    });

    testWidgets('holding Ctrl+W closes one tab', (tester) async {
      final fired = await pumpBrowser(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(fired, [BrowserAction.closeTab]);
    });
  });

  group('with customised bindings', () {
    Future<List<BrowserAction>> pumpWith(
      WidgetTester tester,
      Map<BrowserAction, List<KeyChord>> bindings,
    ) async {
      final fired = <BrowserAction>[];
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserKeyboardShortcuts(
            bindings: bindings,
            onAction: fired.add,
            child: _pageWithChrome(
              WebContentKeyPassthrough(child: _FakePage(focusNode: page)),
            ),
          ),
        ),
      );
      page.requestFocus();
      await tester.pump();
      return fired;
    }

    testWidgets(
      'a rebound chord reaches the browser and the old one the page',
      (tester) async {
        final fired = await pumpWith(tester, {
          BrowserAction.newTab: [
            KeyChord.of(LogicalKeyboardKey.keyN, control: true),
          ],
        });

        expect(
          await press(
            tester,
            LogicalKeyboardKey.keyN,
            modifiers: [LogicalKeyboardKey.controlLeft],
          ),
          isTrue,
        );
        expect(
          await press(
            tester,
            LogicalKeyboardKey.keyT,
            modifiers: [LogicalKeyboardKey.controlLeft],
          ),
          isFalse,
        );
        expect(fired, [BrowserAction.newTab]);
      },
    );

    testWidgets('with shortcuts switched off every chord goes to the page', (
      tester,
    ) async {
      final fired = await pumpWith(tester, const {});

      expect(
        await press(
          tester,
          LogicalKeyboardKey.keyT,
          modifiers: [LogicalKeyboardKey.controlLeft],
        ),
        isFalse,
      );
      expect(fired, isEmpty);
    });

    testWidgets('picks up new bindings without a remount', (tester) async {
      await pumpWith(tester, defaultKeyboardShortcuts);
      final fired = await pumpWith(tester, {
        BrowserAction.newTab: [
          KeyChord.of(LogicalKeyboardKey.keyN, control: true),
        ],
      });

      expect(
        await press(
          tester,
          LogicalKeyboardKey.keyT,
          modifiers: [LogicalKeyboardKey.controlLeft],
        ),
        isFalse,
      );
      expect(fired, isEmpty);
    });
  });
}
