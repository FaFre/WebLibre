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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/default_keyboard_shortcuts.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';

final ctrlT = KeyChord.of(LogicalKeyboardKey.keyT, control: true);
final ctrlN = KeyChord.of(LogicalKeyboardKey.keyN, control: true);
final ctrlL = KeyChord.of(LogicalKeyboardKey.keyL, control: true);

void main() {
  group('defaultKeyboardShortcuts', () {
    test('binds every chord to at most one action', () {
      final seen = <KeyChord, BrowserAction>{};
      for (final MapEntry(key: action, value: chords)
          in defaultKeyboardShortcuts.entries) {
        for (final chord in chords) {
          expect(
            seen[chord],
            isNull,
            reason:
                '${chord.label} is bound to both ${seen[chord]} and $action',
          );
          seen[chord] = action;
        }
      }
    });

    test('only uses chords that leave the page its keys', () {
      for (final chords in defaultKeyboardShortcuts.values) {
        for (final chord in chords) {
          expect(chord.isAssignable, isTrue, reason: chord.label);
        }
      }
    });
  });

  group('KeyChord', () {
    test('labels modifiers in a fixed order', () {
      expect(
        KeyChord.of(LogicalKeyboardKey.tab, shift: true, control: true).label,
        'Ctrl+Shift+Tab',
      );
      expect(
        KeyChord.of(LogicalKeyboardKey.arrowLeft, alt: true).label,
        'Alt+Left',
      );
    });

    test('survives a JSON round trip', () {
      final chord = KeyChord.of(
        LogicalKeyboardKey.pageDown,
        control: true,
        shift: true,
      );
      expect(KeyChord.fromJson(chord.toJson()), chord);
    });

    group('isAssignable', () {
      test('refuses keys a page needs', () {
        for (final key in [
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.tab,
          LogicalKeyboardKey.escape,
          LogicalKeyboardKey.arrowDown,
        ]) {
          expect(KeyChord.of(key).isAssignable, isFalse, reason: key.keyLabel);
          expect(
            KeyChord.of(key, shift: true).isAssignable,
            isFalse,
            reason: 'Shift+${key.keyLabel}',
          );
        }
      });

      test('accepts modified keys and function keys', () {
        expect(ctrlT.isAssignable, isTrue);
        expect(KeyChord.of(LogicalKeyboardKey.f3).isAssignable, isTrue);
        expect(
          KeyChord.of(LogicalKeyboardKey.f3, shift: true).isAssignable,
          isTrue,
        );
      });
    });

    group('isTextEditing', () {
      test('covers caret movement and clipboard chords', () {
        for (final chord in [
          KeyChord.of(LogicalKeyboardKey.arrowLeft, alt: true),
          KeyChord.of(LogicalKeyboardKey.arrowRight, control: true),
          KeyChord.of(LogicalKeyboardKey.home, control: true, shift: true),
          KeyChord.of(LogicalKeyboardKey.backspace, control: true),
          KeyChord.of(LogicalKeyboardKey.pageDown, shift: true),
          KeyChord.of(LogicalKeyboardKey.keyC, control: true),
          KeyChord.of(LogicalKeyboardKey.keyZ, control: true, shift: true),
        ]) {
          expect(chord.isTextEditing, isTrue, reason: chord.label);
        }
      });

      test('leaves browser chords to the browser', () {
        for (final chord in [
          ctrlT,
          KeyChord.of(LogicalKeyboardKey.pageDown, control: true),
          KeyChord.of(LogicalKeyboardKey.tab, control: true),
          KeyChord.of(LogicalKeyboardKey.f5),
          KeyChord.of(LogicalKeyboardKey.keyR, control: true, alt: true),
        ]) {
          expect(chord.isTextEditing, isFalse, reason: chord.label);
        }
      });
    });
  });

  group('KeyboardShortcutSettings', () {
    final defaults = KeyboardShortcutSettings.withDefaults();

    test('starts from the defaults', () {
      expect(defaults.chordsFor(BrowserAction.newTab), [ctrlT]);
      expect(defaults.actionFor(ctrlT), BrowserAction.newTab);
      expect(defaults.hasCustomizations, isFalse);
    });

    test('adding a chord takes it from the action that had it', () {
      final settings = defaults.withChordAdded(
        BrowserAction.duplicateTab,
        ctrlT,
      );

      expect(settings.actionFor(ctrlT), BrowserAction.duplicateTab);
      expect(settings.chordsFor(BrowserAction.newTab), isEmpty);
      expect(settings.isCustomized(BrowserAction.newTab), isTrue);
      expect(settings.bindings.containsKey(BrowserAction.newTab), isFalse);
    });

    test('replacing keeps the chord position', () {
      final previous = defaults.chordsFor(BrowserAction.focusAddressBar);
      final settings = defaults.withChordReplaced(
        BrowserAction.focusAddressBar,
        ctrlL,
        ctrlN,
      );

      expect(settings.chordsFor(BrowserAction.focusAddressBar), [
        ctrlN,
        ...previous.skip(1),
      ]);
    });

    test('an edit that lands back on the defaults stores nothing', () {
      final settings = defaults
          .withChordRemoved(BrowserAction.newTab, ctrlT)
          .withChordAdded(BrowserAction.newTab, ctrlT);

      expect(settings.overrides, isEmpty);
    });

    test('resetting an action reclaims its defaults from other actions', () {
      final settings = defaults
          .withChordAdded(BrowserAction.duplicateTab, ctrlT)
          .withActionReset(BrowserAction.newTab);

      expect(settings.actionFor(ctrlT), BrowserAction.newTab);
      expect(settings.chordsFor(BrowserAction.duplicateTab), isEmpty);
      expect(settings.overrides, isEmpty);
    });

    test('resetting everything drops every override', () {
      final settings = defaults
          .withChordAdded(BrowserAction.duplicateTab, ctrlN)
          .withChordRemoved(BrowserAction.reload, ctrlT)
          .withAllReset();

      expect(settings.overrides, isEmpty);
    });

    test('survives a JSON round trip, including an unbound action', () {
      final settings = defaults
          .copyWith(enabled: false)
          .withChordAdded(BrowserAction.duplicateTab, ctrlT);

      expect(KeyboardShortcutSettings.fromJson(settings.toJson()), settings);
    });

    test('drops actions and chords it cannot read', () {
      final settings = KeyboardShortcutSettings.fromJson({
        'enabled': true,
        'overrides': {
          'noLongerAnAction': [ctrlT.toJson()],
          'newTab': [
            {'keyId': 'broken'},
            ctrlN.toJson(),
          ],
        },
      });

      expect(settings.overrides, {
        BrowserAction.newTab: [ctrlN],
      });
    });
  });
}
