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
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// How long an item has to be held before it is "picked up": the context menu
/// opens and the item becomes draggable. Matches the platform long-press
/// timeout so it feels native.
const kItemLongPressDelay = kLongPressTimeout;

/// When during the press a partially scrolled-out item is nudged fully into
/// view. Early enough that the scroll has settled before the context menu
/// anchors to the item, and before the drag can capture the item's rect.
const _kRevealDelay = Duration(milliseconds: 250);

const _kRevealDuration = Duration(milliseconds: 180);

/// Keeps the revealed item this far inside the viewport so the drag rect can't
/// land exactly on the edge and re-trigger the auto scroller through rounding.
const _kRevealSlack = 1.0;

/// Sub-pixel corrections aren't worth an animation.
const _kMinRevealDelta = 0.5;

/// Long-press-to-drag handle for reorderable lists, with two fixes over
/// Flutter's [ReorderableDelayedDragStartListener]:
///
///  * the drag only *starts* once the finger moves after the long press, so a
///    plain long press stays available for a context menu, and
///  * an item that is clipped by the viewport edge is scrolled fully into view
///    before the drag can start.
///
/// The second point is what makes edge items usable at all.
/// `SliverReorderableList` feeds the *item's own rect* to
/// [EdgeDraggingAutoScroller], and the stock delayed drag starts without any
/// finger movement — so starting a drag on a half-scrolled-out item
/// immediately reports "the drag target sticks out past the viewport edge".
/// Because the proxy is pinned to the stationary finger, that condition never
/// clears again and the list auto-scrolls all the way to its min/max extent,
/// dragging the item along with it (WebLibre issue #579).
class ReorderableHoldDragListener extends HookWidget {
  /// Index of the item in the enclosing reorderable list.
  final int index;

  /// Whether this item can be dragged at all. Disabled items also skip the
  /// reveal nudge.
  final bool enabled;

  /// Hold duration before the item is picked up.
  final Duration delay;

  final Widget child;

  const ReorderableHoldDragListener({
    required this.index,
    required this.child,
    this.enabled = true,
    this.delay = kItemLongPressDelay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final revealTimer = useRef<Timer?>(null);
    final downPosition = useRef(Offset.zero);

    useEffect(
      () =>
          () => revealTimer.value?.cancel(),
      const [],
    );

    void cancelReveal() {
      revealTimer.value?.cancel();
      revealTimer.value = null;
    }

    return Listener(
      onPointerDown: enabled
          ? (event) {
              downPosition.value = event.position;
              cancelReveal();
              revealTimer.value = Timer(_kRevealDelay, () {
                revealTimer.value = null;
                _revealFully(context);
              });
            }
          : null,
      onPointerMove: (event) {
        // A moving finger is either a scroll or an already-armed drag; in both
        // cases nudging the viewport would fight the user.
        if ((event.position - downPosition.value).distance > kTouchSlop) {
          cancelReveal();
        }
      },
      onPointerUp: (_) => cancelReveal(),
      onPointerCancel: (_) => cancelReveal(),
      child: _DelayedDragStartListener(
        index: index,
        enabled: enabled,
        delay: delay,
        child: child,
      ),
    );
  }
}

/// The other half of the [ReorderableHoldDragListener] contract: opens
/// [controller]'s menu once the finger has been held for [kItemLongPressDelay],
/// and closes it again as soon as the finger moves past [kTouchSlop] — the very
/// movement that makes the enclosing drag listener pick the item up. So a plain
/// long press leaves the menu open, and long press + move reorders instead.
///
/// [claimGesture] selects how the press is detected, and the choice is not
/// cosmetic:
///
///  * `false` — for items inside a reorderable list. Detection stays passive (a
///    raw [Listener]) so the pointer is left to
///    [ReorderableHoldDragListener]'s recognizer, which claims the gesture
///    arena at the same delay and thereby suppresses the item's own tap.
///  * `true` — when there is no drag to coordinate with. An [InkWell] long
///    press claims the arena itself; without it nothing would reject the item's
///    tap recognizer and a long press would open the menu *and* activate the
///    item on release.
class HoldMenuListener extends HookWidget {
  final MenuController controller;

  /// Whether the long press should claim the gesture arena. See the class
  /// docs — pass false only when an enclosing drag recognizer does it instead.
  final bool claimGesture;

  final bool enabled;

  /// Ink splash clipping for the [claimGesture] path.
  final BorderRadius? borderRadius;

  final Widget child;

  const HoldMenuListener({
    required this.controller,
    required this.child,
    this.claimGesture = true,
    this.enabled = true,
    this.borderRadius,
    super.key,
  });

  void _toggle() {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    final holdTimer = useRef<Timer?>(null);
    final downPosition = useRef(Offset.zero);

    useEffect(
      () =>
          () => holdTimer.value?.cancel(),
      const [],
    );

    if (!enabled) {
      return child;
    }

    if (claimGesture) {
      return InkWell(
        onLongPress: _toggle,
        borderRadius: borderRadius,
        child: child,
      );
    }

    void cancelHold() {
      holdTimer.value?.cancel();
      holdTimer.value = null;
    }

    return Listener(
      onPointerDown: (event) {
        downPosition.value = event.position;
        cancelHold();
        holdTimer.value = Timer(kItemLongPressDelay, () {
          holdTimer.value = null;
          controller.open();
        });
      },
      onPointerMove: (event) {
        if ((event.position - downPosition.value).distance > kTouchSlop) {
          // The finger is on its way into a drag (or a scroll) — hand the
          // gesture over.
          cancelHold();
          if (controller.isOpen) {
            controller.close();
          }
        }
      },
      onPointerUp: (_) => cancelHold(),
      onPointerCancel: (_) => cancelHold(),
      child: child,
    );
  }
}

class _DelayedDragStartListener extends ReorderableDragStartListener {
  final Duration delay;

  const _DelayedDragStartListener({
    required super.index,
    required super.child,
    required super.enabled,
    required this.delay,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return _HoldThenMoveMultiDragGestureRecognizer(
      delay: delay,
      debugOwner: this,
    );
  }
}

/// Recognizes a drag that begins with a long press **and** a following finger
/// movement.
///
/// [DelayedMultiDragGestureRecognizer] can't express this: it starts the drag
/// the instant its delay elapses even if the finger never moved (so the long
/// press is consumed by the drag and a context menu never gets a turn), and it
/// rejects outright if the finger moves during the delay (so simply stretching
/// the delay to make room for a menu means moving the finger cancels the drag
/// instead of starting it).
///
/// Here the pointer has to stay put for [delay] — a flick is still a scroll —
/// after which the gesture is claimed from the arena immediately (so the item's
/// own tap handler and the enclosing scrollable are out of the running, just
/// like the stock recognizer) but the drag itself is held back until the finger
/// moves past the touch slop.
class _HoldThenMoveMultiDragGestureRecognizer
    extends MultiDragGestureRecognizer {
  final Duration delay;

  _HoldThenMoveMultiDragGestureRecognizer({
    required this.delay,
    super.debugOwner,
  });

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    return _HoldThenMovePointerState(
      event.position,
      delay,
      event.kind,
      gestureSettings,
    );
  }

  @override
  String get debugDescription => 'hold then move multidrag';
}

class _HoldThenMovePointerState extends MultiDragPointerState {
  _HoldThenMovePointerState(
    super.initialPosition,
    Duration delay,
    super.kind,
    super.gestureSettings,
  ) {
    _timer = Timer(delay, _onDelayPassed);
  }

  Timer? _timer;
  bool _delayPassed = false;
  bool _movedPastSlop = false;

  /// Set once the arena has granted this pointer to us; invoked as soon as the
  /// finger actually moves.
  GestureMultiDragStartCallback? _starter;

  void _onDelayPassed() {
    _timer = null;
    _delayPassed = true;
    // Claim the gesture now so the item's tap handler and the surrounding
    // scrollable can no longer act on this pointer, but leave the drag itself
    // dormant until the finger moves.
    resolve(GestureDisposition.accepted);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startDragIfReady() {
    if (!_delayPassed || !_movedPastSlop) {
      return;
    }
    final starter = _starter;
    if (starter == null) {
      return;
    }
    _starter = null;
    starter(initialPosition);
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    assert(_starter == null);
    _starter = starter;
    _startDragIfReady();
  }

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);
    if (_movedPastSlop) {
      return;
    }
    if (pendingDelta!.distance <= computeHitSlop(kind, gestureSettings)) {
      return;
    }
    if (!_delayPassed) {
      // Moving before the long press completed: the user is scrolling.
      _stopTimer();
      resolve(GestureDisposition.rejected);
      return;
    }
    _movedPastSlop = true;
    _startDragIfReady();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

/// Scrolls the enclosing viewport by the smallest amount that makes
/// [context]'s render box fully visible. No-op when it already is, when it is
/// bigger than the viewport, or while the list is scrolling on its own.
void _revealFully(BuildContext context) {
  if (!context.mounted) {
    return;
  }

  final renderObject = context.findRenderObject();
  if (renderObject == null || !renderObject.attached) {
    return;
  }

  final position = Scrollable.maybeOf(context)?.position;
  if (position == null ||
      !position.hasPixels ||
      !position.hasContentDimensions ||
      position.isScrollingNotifier.value) {
    return;
  }

  final viewport = RenderAbstractViewport.maybeOf(renderObject);
  if (viewport == null) {
    return;
  }

  // Scroll offsets that put the item flush against the viewport's leading and
  // trailing edge. Anything between the two shows the item in full; if the
  // item is larger than the viewport the range is inverted and there is
  // nothing sensible to reveal.
  var lower = viewport.getOffsetToReveal(renderObject, 1.0).offset;
  var upper = viewport.getOffsetToReveal(renderObject, 0.0).offset;
  if (lower > upper) {
    return;
  }
  if (upper - lower > 2 * _kRevealSlack) {
    lower += _kRevealSlack;
    upper -= _kRevealSlack;
  }

  final target = position.pixels
      .clamp(lower, upper)
      .clamp(position.minScrollExtent, position.maxScrollExtent);
  if ((target - position.pixels).abs() < _kMinRevealDelta) {
    return;
  }

  unawaited(
    position.animateTo(
      target,
      duration: _kRevealDuration,
      curve: Curves.easeOutCubic,
    ),
  );
}
