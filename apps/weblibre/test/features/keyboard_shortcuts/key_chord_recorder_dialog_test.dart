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
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/dialogs/key_chord_recorder_dialog.dart';

Future<void> press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  List<LogicalKeyboardKey> modifiers = const [],
}) async {
  for (final modifier in modifiers) {
    await tester.sendKeyDownEvent(modifier);
  }
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  for (final modifier in modifiers.reversed) {
    await tester.sendKeyUpEvent(modifier);
  }
  await tester.pump();
}

void main() {
  /// Opens the recorder for [action] and returns a getter for its result.
  Future<({bool closed, KeyChord? chord}) Function()> openRecorder(
    WidgetTester tester,
    BrowserAction action,
  ) async {
    var closed = false;
    KeyChord? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showKeyChordRecorderDialog(
                context,
                action: action,
                settings: KeyboardShortcutSettings.withDefaults(),
              );
              closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    return () => (closed: closed, chord: result);
  }

  FilledButton confirmButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('records a chord and returns it on save', (tester) async {
    final result = await openRecorder(tester, BrowserAction.duplicateTab);

    await press(
      tester,
      LogicalKeyboardKey.keyU,
      modifiers: [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft],
    );
    expect(find.text('Ctrl+Shift+U'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      result().chord,
      KeyChord.of(LogicalKeyboardKey.keyU, control: true, shift: true),
    );
  });

  testWidgets('waits through modifier presses', (tester) async {
    await openRecorder(tester, BrowserAction.duplicateTab);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(find.text('Waiting for keys…'), findsOneWidget);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  });

  testWidgets('refuses a key a page needs', (tester) async {
    await openRecorder(tester, BrowserAction.duplicateTab);

    await press(tester, LogicalKeyboardKey.keyU);

    expect(find.textContaining('Web pages need this key'), findsOneWidget);
    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('offers to take a chord from the action using it', (
    tester,
  ) async {
    final result = await openRecorder(tester, BrowserAction.duplicateTab);

    await press(
      tester,
      LogicalKeyboardKey.keyT,
      modifiers: [LogicalKeyboardKey.controlLeft],
    );

    expect(find.textContaining('"New Tab"'), findsOneWidget);
    await tester.tap(find.text('Reassign'));
    await tester.pumpAndSettle();

    expect(result().chord, KeyChord.of(LogicalKeyboardKey.keyT, control: true));
  });

  testWidgets('a chord the action already has cannot be added again', (
    tester,
  ) async {
    await openRecorder(tester, BrowserAction.newTab);

    await press(
      tester,
      LogicalKeyboardKey.keyT,
      modifiers: [LogicalKeyboardKey.controlLeft],
    );

    expect(find.textContaining('already a shortcut'), findsOneWidget);
    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('Escape cancels and Enter saves', (tester) async {
    var result = await openRecorder(tester, BrowserAction.duplicateTab);
    await press(tester, LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(result(), (closed: true, chord: null));

    result = await openRecorder(tester, BrowserAction.duplicateTab);
    await press(
      tester,
      LogicalKeyboardKey.keyU,
      modifiers: [LogicalKeyboardKey.altLeft],
    );
    await press(tester, LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(result().chord, KeyChord.of(LogicalKeyboardKey.keyU, alt: true));
  });

  testWidgets('Tab is recorded and refused rather than moving focus', (
    tester,
  ) async {
    await openRecorder(tester, BrowserAction.duplicateTab);

    await press(tester, LogicalKeyboardKey.tab);
    expect(find.text('Tab'), findsOneWidget);

    // Still recording after it.
    await press(
      tester,
      LogicalKeyboardKey.keyU,
      modifiers: [LogicalKeyboardKey.controlLeft],
    );
    expect(find.text('Ctrl+U'), findsOneWidget);
  });
}
