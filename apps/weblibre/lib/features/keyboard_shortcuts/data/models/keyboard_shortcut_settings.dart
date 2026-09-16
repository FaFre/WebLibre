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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/default_keyboard_shortcuts.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';

part 'keyboard_shortcut_settings.g.dart';

/// The user's keyboard shortcuts.
///
/// Stored as changes on top of [defaultKeyboardShortcuts] rather than as a full
/// table, so a default added in a later version still reaches someone who has
/// customised other shortcuts. Every edit goes through the `with…` methods,
/// which keep two invariants: a chord runs at most one action, and an action
/// whose chords equal its defaults has no override.
@CopyWith()
class KeyboardShortcutSettings with FastEquatable {
  /// Master switch. When false the browser reserves no chords at all and every
  /// key goes to the page or the focused text field.
  final bool enabled;

  /// Per-action replacements for the defaults. An empty list unbinds the
  /// action; an action not listed keeps its defaults.
  final Map<BrowserAction, List<KeyChord>> overrides;

  KeyboardShortcutSettings({required this.enabled, required this.overrides});

  KeyboardShortcutSettings.withDefaults({
    bool? enabled,
    Map<BrowserAction, List<KeyChord>>? overrides,
  }) : enabled = enabled ?? true,
       overrides = overrides ?? const {};

  /// Reads what [toJson] wrote. Actions this version does not know (renamed or
  /// removed) and chords that fail to parse are dropped rather than failing
  /// the whole settings object.
  factory KeyboardShortcutSettings.fromJson(Map<String, dynamic> json) {
    final actions = BrowserAction.values.asNameMap();
    final rawOverrides = json['overrides'];

    final overrides = <BrowserAction, List<KeyChord>>{};
    if (rawOverrides is Map<String, dynamic>) {
      for (final MapEntry(:key, :value) in rawOverrides.entries) {
        final action = actions[key];
        if (action == null || value is! List) continue;

        overrides[action] = [
          for (final chord in value)
            if (chord is Map<String, dynamic>) ?_tryParseChord(chord),
        ];
      }
    }

    return KeyboardShortcutSettings.withDefaults(
      enabled: json['enabled'] as bool?,
      overrides: overrides,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'overrides': {
      for (final MapEntry(:key, :value) in overrides.entries)
        key.name: [for (final chord in value) chord.toJson()],
    },
  };

  /// The chords that currently run [action].
  List<KeyChord> chordsFor(BrowserAction action) =>
      overrides[action] ?? defaultKeyboardShortcuts[action] ?? const [];

  /// Every action with at least one chord, mapped to its chords.
  Map<BrowserAction, List<KeyChord>> get bindings => {
    for (final action in BrowserAction.values)
      if (chordsFor(action) case final chords when chords.isNotEmpty)
        action: chords,
  };

  /// The action [chord] currently runs, if any.
  BrowserAction? actionFor(KeyChord chord) {
    for (final action in BrowserAction.values) {
      if (chordsFor(action).contains(chord)) return action;
    }
    return null;
  }

  /// Whether [action]'s chords differ from its defaults.
  bool isCustomized(BrowserAction action) => overrides.containsKey(action);

  /// Whether any action's chords differ from its defaults.
  bool get hasCustomizations => overrides.isNotEmpty;

  /// Adds [chord] to [action], taking it from whichever action had it.
  KeyboardShortcutSettings withChordAdded(
    BrowserAction action,
    KeyChord chord,
  ) => _withChords({
    action: [...chordsFor(action).where((c) => c != chord), chord],
  });

  /// Swaps [previous] for [next] in [action], in place, taking [next] from
  /// whichever action had it.
  KeyboardShortcutSettings withChordReplaced(
    BrowserAction action,
    KeyChord previous,
    KeyChord next,
  ) => _withChords({
    action: [
      for (final chord in chordsFor(action))
        if (chord == previous) next else if (chord != next) chord,
    ],
  });

  KeyboardShortcutSettings withChordRemoved(
    BrowserAction action,
    KeyChord chord,
  ) => _withChords({
    action: chordsFor(action).where((c) => c != chord).toList(),
  });

  /// Restores [action]'s default chords, taking them from any action the user
  /// has since given them to.
  KeyboardShortcutSettings withActionReset(BrowserAction action) =>
      _withChords({action: defaultKeyboardShortcuts[action] ?? const []});

  /// Discards every customisation.
  KeyboardShortcutSettings withAllReset() => copyWith(overrides: const {});

  /// Sets the chords of the actions in [changed] and removes those chords from
  /// every other action, then stores only what differs from the defaults.
  KeyboardShortcutSettings _withChords(
    Map<BrowserAction, List<KeyChord>> changed,
  ) {
    final claimed = {for (final chords in changed.values) ...chords};

    final nextOverrides = <BrowserAction, List<KeyChord>>{};
    for (final action in BrowserAction.values) {
      final chords =
          changed[action]?.toSet().toList() ??
          chordsFor(action).where((c) => !claimed.contains(c)).toList();

      if (!listEquals(chords, defaultKeyboardShortcuts[action] ?? const [])) {
        nextOverrides[action] = chords;
      }
    }

    return copyWith(overrides: nextOverrides);
  }

  static KeyChord? _tryParseChord(Map<String, dynamic> json) {
    try {
      return KeyChord.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get hashParameters => [enabled, overrides];
}
