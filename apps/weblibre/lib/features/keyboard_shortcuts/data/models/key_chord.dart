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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_chord.g.dart';

/// One key combination a keyboard shortcut is bound to.
///
/// Matched by logical key — what the key means on the active layout — and an
/// exact set of modifiers, so Ctrl+Tab and Ctrl+Shift+Tab are different chords.
@JsonSerializable()
class KeyChord with FastEquatable {
  /// [LogicalKeyboardKey.keyId] of the non-modifier key.
  final int keyId;
  final bool control;
  final bool alt;
  final bool shift;
  final bool meta;

  KeyChord(
    this.keyId, {
    this.control = false,
    this.alt = false,
    this.shift = false,
    this.meta = false,
  });

  KeyChord.of(
    LogicalKeyboardKey key, {
    bool control = false,
    bool alt = false,
    bool shift = false,
    bool meta = false,
  }) : this(key.keyId, control: control, alt: alt, shift: shift, meta: meta);

  /// The chord [event] completes, or null when [event] only presses a
  /// modifier (the recorder is still waiting for the actual key).
  static KeyChord? fromKeyEvent(KeyEvent event, HardwareKeyboard keyboard) {
    final key = event.logicalKey;
    if (_modifierKeys.contains(key)) return null;

    return KeyChord.of(
      key,
      control: keyboard.isControlPressed,
      alt: keyboard.isAltPressed,
      shift: keyboard.isShiftPressed,
      meta: keyboard.isMetaPressed,
    );
  }

  factory KeyChord.fromJson(Map<String, dynamic> json) =>
      _$KeyChordFromJson(json);

  Map<String, dynamic> toJson() => _$KeyChordToJson(this);

  LogicalKeyboardKey get key =>
      LogicalKeyboardKey.findKeyByKeyId(keyId) ?? LogicalKeyboardKey(keyId);

  SingleActivator toActivator({required bool includeRepeats}) =>
      SingleActivator(
        key,
        control: control,
        alt: alt,
        shift: shift,
        meta: meta,
        includeRepeats: includeRepeats,
      );

  /// Whether the chord can be bound without taking a key away from web
  /// content.
  ///
  /// The browser keeps a bound chord even while a page has focus, so a plain
  /// letter, Tab, an arrow or Escape would stop working on every site. Function
  /// keys are the exception pages rarely rely on, and Firefox binds several of
  /// them (F3, F5).
  bool get isAssignable =>
      control || alt || meta || _functionKeys.contains(key);

  /// Whether a focused text field would use this chord for editing.
  ///
  /// The browser's shortcuts are consulted before Flutter's default text
  /// editing shortcuts, so a chord like this must be left to a focused text
  /// field or the address bar would, say, navigate back on Alt+Left instead of
  /// moving the caret. Web content is not a Flutter text field and still gets
  /// the browser command.
  bool get isTextEditing {
    if (!control && !alt && !meta && !_functionKeys.contains(key)) return true;
    if (_caretKeys.contains(key)) return true;
    // Shift+Page Up/Down extends a selection; Ctrl+Page Up/Down is tab cycling.
    if (_pageKeys.contains(key)) return !control;
    if (control && !alt && !meta) return _editingLetterKeys.contains(key);
    return false;
  }

  /// A human-readable form, such as `Ctrl+Shift+T`.
  String get label => [
    if (control) 'Ctrl',
    if (alt) 'Alt',
    if (shift) 'Shift',
    if (meta) 'Meta',
    _keyName(key),
  ].join('+');

  @override
  List<Object?> get hashParameters => [keyId, control, alt, shift, meta];

  @override
  String toString() => 'KeyChord($label)';

  static String _keyName(LogicalKeyboardKey key) {
    final label = key.keyLabel;
    if (label.isEmpty) {
      return key.debugName ?? '0x${key.keyId.toRadixString(16)}';
    }
    return label.startsWith('Arrow ') ? label.substring(6) : label;
  }

  static final _modifierKeys = {
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.meta,
    ...LogicalKeyboardKey.expandSynonyms({
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.alt,
      LogicalKeyboardKey.meta,
    }),
    LogicalKeyboardKey.altGraph,
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.numLock,
    LogicalKeyboardKey.scrollLock,
    LogicalKeyboardKey.fn,
    LogicalKeyboardKey.fnLock,
  };

  static final _functionKeys = {
    LogicalKeyboardKey.f1,
    LogicalKeyboardKey.f2,
    LogicalKeyboardKey.f3,
    LogicalKeyboardKey.f4,
    LogicalKeyboardKey.f5,
    LogicalKeyboardKey.f6,
    LogicalKeyboardKey.f7,
    LogicalKeyboardKey.f8,
    LogicalKeyboardKey.f9,
    LogicalKeyboardKey.f10,
    LogicalKeyboardKey.f11,
    LogicalKeyboardKey.f12,
  };

  static final _caretKeys = {
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.backspace,
    LogicalKeyboardKey.delete,
  };

  static final _pageKeys = {
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
  };

  static final _editingLetterKeys = {
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyZ,
  };
}
