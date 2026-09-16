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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/providers.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/widgets/key_chord_label.dart';

/// The first key combination that runs [action], as a small keycap beside a
/// menu row.
///
/// Draws nothing when no key runs the action, shortcuts are off, or hints are
/// not shown on this device (see [showKeyboardShortcutHints]).
class KeyboardShortcutHint extends HookConsumerWidget {
  final BrowserAction action;

  const KeyboardShortcutHint(this.action, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showKeyboardShortcutHintsProvider)) {
      return const SizedBox.shrink();
    }

    final chord = ref.watch(
      effectiveKeyboardShortcutsProvider.select(
        (bindings) => bindings[action]?.firstOrNull,
      ),
    );
    if (chord == null) return const SizedBox.shrink();

    return KeyChordLabel(chord, dense: true);
  }
}
