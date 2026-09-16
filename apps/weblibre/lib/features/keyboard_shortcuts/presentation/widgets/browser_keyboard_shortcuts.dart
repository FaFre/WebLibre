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
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/default_keyboard_shortcuts.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';

/// [BrowserKeyboardShortcuts] with the user's shortcuts, carried out by the
/// [BrowserActionDispatcher].
class BrowserKeyboardShortcutScope extends HookConsumerWidget {
  final Widget child;

  const BrowserKeyboardShortcutScope({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindings = ref.watch(effectiveKeyboardShortcutsProvider);

    return BrowserKeyboardShortcuts(
      bindings: bindings,
      onAction: (action) => unawaited(
        ref.read(browserActionDispatcherProvider.notifier).run(action),
      ),
      child: child,
    );
  }
}

typedef _Shortcut = ({
  SingleActivator activator,
  BrowserAction action,
  KeyChord chord,
});

/// Makes [bindings] work while the route holding [child] is on top, wherever
/// focus is inside it — including while web content has focus.
///
/// Registered as an early key event handler rather than built from
/// [Shortcuts]: a [Shortcuts] widget only sees keys that travel up the focus
/// tree through it, and focus leaves this subtree without the user noticing.
/// A plain `unfocus()` of the focused page parks primary focus on the route's
/// scope, *above* this widget, and from there no chord would arrive until a tap
/// on the page gave focus back — tapping Flutter chrome does not, because
/// buttons do not take focus on touch.
///
/// A handled chord never reaches the focus tree, so the page never sees it;
/// every other key goes on as usual (see [WebContentKeyPassthrough]).
///
/// Scoped to its route by [ModalRoute.isCurrent]: with settings, a dialog or a
/// modal sheet on top, Ctrl+W does nothing rather than closing a tab behind it.
class BrowserKeyboardShortcuts extends HookWidget {
  final Map<BrowserAction, List<KeyChord>> bindings;
  final ValueChanged<BrowserAction> onAction;
  final Widget child;

  const BrowserKeyboardShortcuts({
    required this.bindings,
    required this.onAction,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shortcuts = useMemoized(
      () => <_Shortcut>[
        for (final MapEntry(key: action, value: chords) in bindings.entries)
          for (final chord in chords)
            (
              activator: chord.toActivator(
                includeRepeats: repeatableKeyboardActions.contains(action),
              ),
              action: action,
              chord: chord,
            ),
      ],
      [bindings],
    );

    // The handler is registered once; these hand it the latest build's values.
    final latestShortcuts = useRef(shortcuts)..value = shortcuts;
    final latestRoute = useRef(ModalRoute.of(context))
      ..value = ModalRoute.of(context);
    final latestOnAction = useRef(onAction)..value = onAction;

    useEffect(() {
      KeyEventResult handleKeyEvent(KeyEvent event) {
        if (latestRoute.value?.isCurrent == false) {
          return KeyEventResult.ignored;
        }

        for (final shortcut in latestShortcuts.value) {
          if (!shortcut.activator.accepts(event, HardwareKeyboard.instance)) {
            continue;
          }

          // Ignored rather than handled-and-dropped, so the text field's own
          // editing shortcut still gets the key.
          if (shortcut.chord.isTextEditing && _textFieldFocused()) {
            return KeyEventResult.ignored;
          }

          latestOnAction.value(shortcut.action);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      }

      FocusManager.instance.addEarlyKeyEventHandler(handleKeyEvent);
      return () =>
          FocusManager.instance.removeEarlyKeyEventHandler(handleKeyEvent);
    }, const []);

    return child;
  }

  static bool _textFieldFocused() =>
      primaryFocus?.context?.findAncestorStateOfType<EditableTextState>() !=
      null;
}
