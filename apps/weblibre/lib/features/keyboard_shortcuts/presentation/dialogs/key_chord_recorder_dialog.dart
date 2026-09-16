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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';

/// Asks for a key combination for [action] and returns it, or null when
/// cancelled.
///
/// [replacing] is the chord being changed, if any. The returned chord may
/// belong to another action; the caller's settings update takes it from there.
Future<KeyChord?> showKeyChordRecorderDialog(
  BuildContext context, {
  required BrowserAction action,
  required KeyboardShortcutSettings settings,
  KeyChord? replacing,
}) {
  return showDialog<KeyChord>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => KeyChordRecorderDialog(
      action: action,
      settings: settings,
      replacing: replacing,
    ),
  );
}

class KeyChordRecorderDialog extends HookWidget {
  final BrowserAction action;
  final KeyboardShortcutSettings settings;
  final KeyChord? replacing;

  const KeyChordRecorderDialog({
    required this.action,
    required this.settings,
    this.replacing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recorded = useState<KeyChord?>(null);

    final chord = recorded.value;
    final owner = chord == null ? null : settings.actionFor(chord);

    final problem = switch (chord) {
      null => null,
      _ when !chord.isAssignable =>
        'Web pages need this key. Hold Ctrl, Alt or Meta with it, or use a '
            'function key.',
      _ when owner == action => 'This is already a shortcut for this action.',
      _ => null,
    };
    final takesFromOther = problem == null && owner != null;
    final canSave = chord != null && problem == null;

    void save() => Navigator.of(context).pop(chord);

    KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
      // Everything is handled, so no key reaches the dialog's own shortcuts:
      // Tab would move focus away and stop the recording.
      if (event is KeyUpEvent) return KeyEventResult.handled;

      final next = KeyChord.fromKeyEvent(event, HardwareKeyboard.instance);
      if (next == null) return KeyEventResult.handled;

      // Plain Escape and Enter drive the dialog instead of being recorded;
      // neither could be bound without a modifier anyway.
      if (!next.control && !next.alt && !next.meta && !next.shift) {
        if (next.key == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        if (next.key == LogicalKeyboardKey.enter ||
            next.key == LogicalKeyboardKey.numpadEnter) {
          if (canSave) save();
          return KeyEventResult.handled;
        }
      }

      if (event is KeyDownEvent) recorded.value = next;
      return KeyEventResult.handled;
    }

    return Focus(
      autofocus: true,
      onKeyEvent: onKeyEvent,
      child: AlertDialog(
        title: Text(replacing == null ? 'Add shortcut' : 'Change shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Press the key combination for "${action.title}".',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                chord?.label ?? 'Waiting for keys…',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: chord == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (problem != null) ...[
              const SizedBox(height: 12),
              Text(
                problem,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ] else if (takesFromOther) ...[
              const SizedBox(height: 12),
              Text(
                'Currently used by "${owner.title}". Saving moves it here.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: canSave ? save : null,
            child: Text(takesFromOther ? 'Reassign' : 'Save'),
          ),
        ],
      ),
    );
  }
}
