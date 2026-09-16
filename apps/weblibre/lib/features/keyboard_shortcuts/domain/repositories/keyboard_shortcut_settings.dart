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
import 'dart:convert';

import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'keyboard_shortcut_settings.g.dart';

@Riverpod(keepAlive: true)
class KeyboardShortcutSettingsRepository
    extends _$KeyboardShortcutSettingsRepository {
  void setEnabled(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  void addChord(BrowserAction action, KeyChord chord) {
    state = state.withChordAdded(action, chord);
  }

  void replaceChord(BrowserAction action, KeyChord previous, KeyChord next) {
    state = state.withChordReplaced(action, previous, next);
  }

  void removeChord(BrowserAction action, KeyChord chord) {
    state = state.withChordRemoved(action, chord);
  }

  void resetAction(BrowserAction action) {
    state = state.withActionReset(action);
  }

  void resetAll() {
    state = state.withAllReset();
  }

  /// Takes over [settings] wholesale, as restoring synced settings does.
  // ignore: use_setters_to_change_properties api decision
  void replace(KeyboardShortcutSettings settings) {
    state = settings;
  }

  @override
  KeyboardShortcutSettings build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'KeyboardShortcutSettings',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => jsonEncode(state.toJson()),
      decode: (encoded) {
        try {
          return KeyboardShortcutSettings.fromJson(
            jsonDecode(encoded) as Map<String, dynamic>,
          );
        } catch (_) {
          return KeyboardShortcutSettings.withDefaults();
        }
      },
    );

    return stateOrNull ?? KeyboardShortcutSettings.withDefaults();
  }
}

/// The chords the browser currently reserves, by action; empty while keyboard
/// shortcuts are switched off.
///
/// Kept as its own provider so the map is only rebuilt when the settings
/// change, which is what lets the shortcut widgets memoize on it.
@Riverpod(keepAlive: true)
Map<BrowserAction, List<KeyChord>> effectiveKeyboardShortcuts(Ref ref) {
  final settings = ref.watch(keyboardShortcutSettingsRepositoryProvider);
  return settings.enabled ? settings.bindings : const {};
}
