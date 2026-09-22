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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/services/toolbar_button_resolution.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;

/// Builds the widget for one resolved toolbar slot: the button itself, greyed
/// out when its primary action is unavailable and no fallback took over, and
/// with its long press replaced when the user bound one to it.
///
/// The long press belongs to the button that is actually shown, so a slot that
/// fell back to another button uses that button's binding.
Widget buildResolvedToolbarButton(
  ContextualToolbarScope scope,
  BuildContext context,
  WidgetRef ref,
  ContextualToolbarButtonResolution button,
  Map<String, ToolbarButtonConfig> configById,
) {
  final def = toolbarButtonRegistryById[button.buttonId];
  if (def == null) return const SizedBox.shrink();

  final child = def.builder(scope, context, ref);
  final built = button.isEnabled
      ? child
      : Opacity(opacity: 0.38, child: IgnorePointer(child: child));

  final longPressAction = scope.isPreview
      ? null
      : configById[button.buttonId]?.longPressAction;
  if (longPressAction == null) return built;

  return ToolbarLongPressOverride(
    onLongPress: () => unawaited(
      ref.read(browserActionDispatcherProvider.notifier).run(longPressAction),
    ),
    child: built,
  );
}

/// Runs [onLongPress] when [child] is held, in place of whatever long press the
/// button builds for itself.
///
/// Toolbar buttons wire their own long press (history menus, new-tab menus,
/// tooltips) deep inside their widgets, and a plain outer detector would lose
/// the gesture arena to them: every one of them waits out [kLongPressTimeout],
/// and the innermost registers its timer first. This detector waits slightly
/// less, so it accepts first and the button's own long press, tooltip and tap
/// are all rejected for that pointer. A short tap never reaches the deadline
/// and still goes to the button.
///
/// It also catches the hold on a greyed-out button, whose pointer events are
/// ignored: the bound action does not depend on the button's own action being
/// available, which is what makes it useful on the home screen.
class ToolbarLongPressOverride extends StatelessWidget {
  const ToolbarLongPressOverride({
    super.key,
    required this.onLongPress,
    required this.child,
  });

  /// Short enough to fire before any [kLongPressTimeout] recognizer below it,
  /// long enough that the hold feels the same.
  static final timeout = kLongPressTimeout - const Duration(milliseconds: 50);

  final VoidCallback onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: timeout,
                debugOwner: this,
              ),
              (instance) => instance.onLongPress = () {
                unawaited(Feedback.forLongPress(context));
                onLongPress();
              },
            ),
      },
      child: child,
    );
  }
}
