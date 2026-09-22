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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/presentation/widgets/single_finger_horizontal_drag.dart';

/// How far a card moves when its swipe direction does nothing: enough to show
/// the finger was read, never enough to look like it will do something.
const _rubberBandLimit = 32.0;

/// Share of the finger's travel a card follows in a direction that does
/// nothing.
const _rubberBandFactor = 0.25;

/// Where a swipe on [child] stands.
typedef _SwipeState = ({double offset, bool armed});

/// Swipe left or right on a tab's card to run the action bound to that
/// direction ([BuiltInGesture.tabSwipeLeft] / [BuiltInGesture.tabSwipeRight])
/// on this tab.
///
/// The card follows the finger and the bound action's icon shows in the space
/// it leaves; past [threshold] the icon lights up and letting go runs it.
/// Closing fades the card out as it goes, the way swipe-to-close always did.
/// Every other action springs the card back, and so does a direction bound to
/// nothing — the card only gives a little there, so the swipe is visibly
/// noticed but reads as inert.
///
/// Uses [SingleFingerHorizontalDrag] so a two-finger container swipe in the
/// tray never lands on a tab (see `TabTrayGestures`).
class TabSwipeActions extends HookConsumerWidget {
  const TabSwipeActions({
    required this.tabId,
    required this.child,
    this.threshold = 100,
    super.key,
  });

  final String tabId;
  final Widget child;

  /// Travel at which letting go runs the action.
  final double threshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leftAction = ref.watch(
      builtInGestureBindingProvider(BuiltInGesture.tabSwipeLeft),
    );
    final rightAction = ref.watch(
      builtInGestureBindingProvider(BuiltInGesture.tabSwipeRight),
    );

    final dragStart = useRef(0.0);
    // A ValueNotifier rather than useState: the drag fires per pointer event,
    // and rebuilding the card — thumbnail, favicon, menus — for each one
    // inside a scrolling list is what the old swipe avoided too.
    final state = useValueNotifier<_SwipeState>((offset: 0, armed: false));
    final springBack = useAnimationController(
      duration: const Duration(milliseconds: 220),
    );
    final springFrom = useRef(0.0);

    useEffect(() {
      void tick() {
        final t = Curves.easeOutCubic.transform(springBack.value);
        state.value = (offset: springFrom.value * (1 - t), armed: false);
      }

      springBack.addListener(tick);
      return () => springBack.removeListener(tick);
    }, [springBack]);

    BrowserAction? actionFor(double offset) =>
        offset < 0 ? leftAction : (offset > 0 ? rightAction : null);

    double displacementFor(double travel) {
      final action = actionFor(travel);
      if (action == null) {
        return (travel * _rubberBandFactor).clamp(
          -_rubberBandLimit,
          _rubberBandLimit,
        );
      }
      return travel.clamp(-threshold, threshold);
    }

    void release() {
      springFrom.value = state.value.offset;
      springBack.forward(from: 0);
    }

    Future<void> run(BrowserAction action) async {
      if (action == BrowserAction.closeTab) {
        // Same confirmation for an isolated group's last tab, and the same
        // undo, as closing it any other way. Declining leaves the tab here,
        // so the card has to come back.
        await closeTabWithConfirmationAndUndoUsing(context, ref.read, tabId);
        if (context.mounted) release();
        return;
      }

      release();
      await ref
          .read(browserActionDispatcherProvider.notifier)
          .run(action, tabId: tabId);
    }

    return SingleFingerHorizontalDrag(
      onStart: (details) {
        springBack.stop();
        dragStart.value = details.globalPosition.dx - state.value.offset;
      },
      onUpdate: (details) {
        final travel = details.globalPosition.dx - dragStart.value;
        final armed = actionFor(travel) != null && travel.abs() >= threshold;
        if (armed && !state.value.armed) {
          unawaited(HapticFeedback.selectionClick());
        }
        state.value = (offset: displacementFor(travel), armed: armed);
      },
      onEnd: (details) async {
        final action = actionFor(state.value.offset);
        if (state.value.armed && action != null) {
          await run(action);
        } else {
          release();
        }
      },
      onCancel: release,
      child: ValueListenableBuilder<_SwipeState>(
        valueListenable: state,
        // Kept unconditionally (rather than skipping it at rest) so the element
        // tree doesn't reshape on drag start/end. A zero offset and full
        // opacity push no layer, so this costs nothing when not dragging.
        builder: (context, swipe, child) {
          final action = actionFor(swipe.offset);
          final progress = action == null
              ? 0.0
              : math.min(swipe.offset.abs() / threshold, 1.0);
          final fades = action == BrowserAction.closeTab;

          return Stack(
            // The card keeps exactly the constraints it had before the swipe
            // wrapped it: a grid cell sizes it tightly, and loosening that
            // would shrink it.
            fit: StackFit.passthrough,
            children: [
              // Always present, so the card keeps its slot in the stack and
              // its subtree is never rebuilt when a drag starts or ends.
              Positioned.fill(
                child: action == null
                    ? const SizedBox.shrink()
                    : _SwipeActionHint(
                        action: action,
                        // The card moves away from this side, uncovering it.
                        alignment: swipe.offset < 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        progress: progress,
                        armed: swipe.armed,
                      ),
              ),
              Transform.translate(
                offset: Offset(swipe.offset, 0),
                child: Opacity(
                  opacity: fades ? 1.0 - progress * 0.7 : 1.0,
                  child: child,
                ),
              ),
            ],
          );
        },
        child: child,
      ),
    );
  }
}

/// The icon of the action a swipe is about to run, in the space the card left.
class _SwipeActionHint extends StatelessWidget {
  const _SwipeActionHint({
    required this.action,
    required this.alignment,
    required this.progress,
    required this.armed,
  });

  final BrowserAction action;
  final Alignment alignment;
  final double progress;
  final bool armed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final destructive = action == BrowserAction.closeTab;
    final activeColor = destructive ? colorScheme.error : colorScheme.primary;

    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Opacity(
            opacity: progress,
            child: AnimatedScale(
              scale: armed ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Icon(
                action.icon,
                color: armed ? activeColor : colorScheme.onSurfaceVariant,
                semanticLabel: action.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
