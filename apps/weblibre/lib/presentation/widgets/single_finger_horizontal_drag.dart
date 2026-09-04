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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Pointers currently down, and how many callers asked to know.
final Set<int> _pointersDown = <int>{};
int _multiPointerSubscribers = 0;

/// Whether more than one pointer is currently on screen.
///
/// Only meaningful while something holds a [startMultiPointerTracking]
/// subscription; with none, this is always false and the widgets that consult
/// it keep their plain single-finger behaviour.
bool get isMultitouchActive => _pointersDown.length > 1;

/// Starts counting pointers, and returns the callback that stops this
/// subscription.
///
/// A global pointer route is the only way to see this: the gesture arena tells
/// a recognizer nothing about fingers that landed on other widgets, and a
/// recognizer competing for one pointer cannot ask how many others are down.
/// The route is installed only while someone is subscribed.
VoidCallback startMultiPointerTracking() {
  if (_multiPointerSubscribers == 0) {
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }
  _multiPointerSubscribers++;

  var released = false;
  return () {
    if (released) {
      return;
    }
    released = true;

    _multiPointerSubscribers--;
    if (_multiPointerSubscribers == 0) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(
        _handlePointerEvent,
      );
      // Pointers that go up after the last unsubscribe are never seen, so drop
      // what is left rather than leaking a permanent "multitouch".
      _pointersDown.clear();
    }
  };
}

void _handlePointerEvent(PointerEvent event) {
  if (event is PointerDownEvent) {
    _pointersDown.add(event.pointer);
  } else if (event is PointerUpEvent || event is PointerCancelEvent) {
    _pointersDown.remove(event.pointer);
  }
}

/// A horizontal drag detector that stands down while a second finger is on the
/// screen.
///
/// Nothing else can arbitrate this. A drag recognizer accepts as soon as its
/// own pointer passes [kTouchSlop], and it sits deeper in the tree than any
/// tray-level multitouch recognizer, so on a quick two-finger swipe it would
/// win the arena before the multitouch gesture had moved far enough to claim
/// it — the finger that happened to land on a tab would close it. Declining to
/// accept (rather than rejecting outright) keeps the drag alive: lift the
/// second finger and the one that is left can still take the gesture.
///
/// Falls back to a plain horizontal drag whenever nothing is tracking pointers
/// (see [startMultiPointerTracking]).
class SingleFingerHorizontalDrag extends StatelessWidget {
  final GestureDragStartCallback? onStart;
  final GestureDragUpdateCallback? onUpdate;
  final GestureDragEndCallback? onEnd;
  final Widget child;

  const SingleFingerHorizontalDrag({
    required this.child,
    this.onStart,
    this.onUpdate,
    this.onEnd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _SingleFingerHorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              _SingleFingerHorizontalDragGestureRecognizer
            >(
              () => _SingleFingerHorizontalDragGestureRecognizer(
                debugOwner: this,
              ),
              (recognizer) {
                recognizer
                  ..onStart = onStart
                  ..onUpdate = onUpdate
                  ..onEnd = onEnd
                  ..gestureSettings = MediaQuery.maybeGestureSettingsOf(
                    context,
                  );
              },
            ),
      },
      child: child,
    );
  }
}

class _SingleFingerHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  _SingleFingerHorizontalDragGestureRecognizer({super.debugOwner});

  @override
  void resolve(GestureDisposition disposition) {
    if (disposition == GestureDisposition.accepted && isMultitouchActive) {
      return;
    }

    super.resolve(disposition);
  }
}
