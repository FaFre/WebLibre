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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_cycle.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chip_content.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/single_finger_horizontal_drag.dart';

/// Which of the two multitouch gestures a pointer sequence turned out to be.
///
/// Latched on the first threshold crossed and kept for the rest of the
/// sequence, so a swipe that drifts into a slight pinch (or the reverse) does
/// not change its mind halfway through.
enum _TrayGestureIntent { pan, pinch }

/// How far the tray is currently pushed aside by a container swipe, and
/// whether getting there should be animated — true only on release, so the
/// tray follows the fingers directly but springs back smoothly.
typedef _FollowOffset = ({double distance, bool animated});

/// The container a swipe in progress would land on, and how close it is to
/// committing: 0 when the swipe has only just been recognised, 1 once letting
/// go would switch. [armed] is that same threshold, kept separately so the
/// indicator can latch its "release now" look (and its haptic) exactly once.
typedef _SwipeTarget = ({
  ContainerData? container,
  ContainerCycleDirection direction,
  double progress,
  bool armed,
});

/// Density order for the pinch gesture. Pinching apart moves toward the mode
/// that shows more per tab, pinching together toward the denser one; both ends
/// clamp, so a pinch never wraps around to the opposite extreme.
const _viewModeDensityOrder = [
  TabsViewMode.grid,
  TabsViewMode.list,
  TabsViewMode.tree,
];

/// Movement of two pointers — of their focal point, or of the fingers relative
/// to it — after which [_MultitouchScaleGestureRecognizer] claims the sequence.
/// Below [kTouchSlop] on purpose; see that class.
const _multitouchSlop = kTouchSlop * 2 / 3;

/// Focal-point travel, measured from where the gesture was claimed, before a
/// two-finger drag is read as a container swipe rather than a pinch.
const _panSlop = 12.0;

/// Travel that commits the swipe on release when the fling was too slow.
const _panCommitDistance = 72.0;

/// Fling speed (px/s) that commits a shorter swipe.
const _panCommitVelocity = 400.0;

/// Scale change before a two-finger gesture is read as a pinch.
const _pinchSlop = 0.08;

/// Scale factors at which a pinch commits a view mode change.
const _pinchExpandScale = 1.25;
const _pinchCompactScale = 0.8;

/// Damping of the tray's follow-the-fingers offset: a hint that the gesture
/// landed, not a full page transition.
const _panFollowFactor = 0.35;
const _panFollowMax = 56.0;

double _followDistance(double distance) {
  return distance.sign *
      math.min(distance.abs() * _panFollowFactor, _panFollowMax);
}

/// Multitouch gestures for the tab tray: two fingers dragged horizontally
/// switch containers, a two-finger pinch changes the view mode.
///
/// Both are deliberately multi-pointer. Every single-finger gesture in the tray
/// is already spoken for — vertical drags scroll, horizontal drags close a tab
/// (see `SingleListTabPreview`) — and the innermost recognizer wins the arena,
/// so a tray-level single-finger gesture could never fire without taking one of
/// those away.
///
/// Keeping both worlds apart takes two halves that meet in the middle:
/// [_MultitouchScaleGestureRecognizer] enters the arena only for the two
/// gestures below — never for a lone finger, and never for a two-finger
/// vertical drag, which stays the tab list's to scroll — and
/// [SingleFingerHorizontalDrag], which the tab items use for swipe-to-close,
/// stands down while a second finger is down, for as long as this widget is
/// mounted. Without that second half a quick two-finger swipe would close
/// whichever tab a finger happened to land on.
///
/// While a swipe is in flight the tray shifts under the fingers and a
/// [_SwipeTargetIndicator] names the container it would land on, since the
/// destination is otherwise only visible after the fact, in the chip row.
class TabTrayGestures extends HookConsumerWidget {
  final Widget child;

  const TabTrayGestures({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final containerUiEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.showContainerUi,
      ),
    );
    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );

    // Watched rather than read on release so the container stream is warm when
    // a swipe ends — a cold read right after startup can still be loading.
    final cycleOrder = ref.watch(containerCycleOrderProvider);
    final canSwitchContainer = containerUiEnabled && cycleOrder.length >= 2;

    final cycleIds = useMemoized(
      () => cycleOrder.map((container) => container?.id).toList(),
      [cycleOrder],
    );

    // Lets the tab items' swipe-to-close stand down for as long as the tray is
    // on screen, so a second finger reliably means "tray gesture".
    useEffect(startMultiPointerTracking, const []);

    final intent = useRef<_TrayGestureIntent?>(null);
    final startFocalPoint = useRef(Offset.zero);
    final panDistance = useRef(0.0);
    final lastScale = useRef(1.0);

    // A ValueNotifier rather than useState: the focal point moves on every
    // pointer event, and a rebuild would walk the whole tray — list, previews,
    // header — on each one. Only the builder below reruns.
    final followOffset = useValueNotifier<_FollowOffset>((
      distance: 0.0,
      animated: false,
    ));

    // Null between gestures: the indicator is only up while fingers are down.
    final swipeTarget = useValueNotifier<_SwipeTarget?>(null);

    /// The container [distance] would land on, or null while the swipe is too
    /// short to have a direction — or when it has nowhere to go.
    _SwipeTarget? resolveSwipeTarget(double distance) {
      if (!canSwitchContainer || distance.abs() < _panSlop) {
        return null;
      }

      final direction = distance < 0
          ? ContainerCycleDirection.next
          : ContainerCycleDirection.previous;

      final index = adjacentContainerIndex(
        cycleIds,
        ref.read(selectedContainerProvider),
        direction,
      );
      if (index == null) {
        return null;
      }

      final progress =
          ((distance.abs() - _panSlop) / (_panCommitDistance - _panSlop)).clamp(
            0.0,
            1.0,
          );

      return (
        container: cycleOrder[index],
        direction: direction,
        progress: progress,
        armed: progress >= 1.0,
      );
    }

    Future<void> switchContainer(ContainerCycleDirection direction) async {
      final index = adjacentContainerIndex(
        cycleIds,
        ref.read(selectedContainerProvider),
        direction,
      );
      if (index == null) {
        return;
      }

      unawaited(HapticFeedback.lightImpact());

      // Swiping out of the synced list lands on a container, so the tray has to
      // come back to the local scope with it — same as tapping a chip.
      ref.read(tabsTrayScopeControllerProvider.notifier).showLocal();

      final container = cycleOrder[index];
      if (container == null) {
        ref.read(selectedContainerProvider.notifier).clearContainer();
        return;
      }

      // The rest mirrors the container chips, so a swipe onto a proxied
      // container offers to start its proxy instead of quietly refusing.
      final result = await ref
          .read(selectedContainerProvider.notifier)
          .setContainerId(container.id);

      if (context.mounted && result == SetContainerResult.success) {
        await ensureProxyStartedForContainer(context, ref, container);
      }
    }

    void cycleViewMode({required bool expand}) {
      // The synced list forces list mode, so a mode change there would only
      // take effect once the user leaves it — surprising, so ignore it.
      if (isSyncedScope) {
        return;
      }

      final currentIndex = _viewModeDensityOrder.indexOf(
        ref.read(tabsViewModeControllerProvider),
      );
      if (currentIndex < 0) {
        return;
      }

      final index = currentIndex + (expand ? 1 : -1);
      if (index < 0 || index >= _viewModeDensityOrder.length) {
        return;
      }

      unawaited(HapticFeedback.lightImpact());
      ref
          .read(tabsViewModeControllerProvider.notifier)
          .set(_viewModeDensityOrder[index]);
    }

    void handleScaleStart(ScaleStartDetails details) {
      intent.value = null;
      startFocalPoint.value = details.focalPoint;
      panDistance.value = 0.0;
      lastScale.value = 1.0;
      followOffset.value = (distance: 0.0, animated: false);
    }

    void handleScaleUpdate(ScaleUpdateDetails details) {
      // Winning the arena needs two fingers, but one of them may be lifted
      // before the sequence ends; ignore whatever the remaining one does.
      if (details.pointerCount < 2) {
        return;
      }

      lastScale.value = details.scale;
      final delta = details.focalPoint - startFocalPoint.value;

      if (intent.value == null) {
        if ((details.scale - 1.0).abs() > _pinchSlop) {
          intent.value = _TrayGestureIntent.pinch;
        } else if (canSwitchContainer &&
            delta.dx.abs() > _panSlop &&
            delta.dx.abs() > delta.dy.abs()) {
          intent.value = _TrayGestureIntent.pan;
        }
      }

      if (intent.value == _TrayGestureIntent.pan) {
        panDistance.value = delta.dx;
        followOffset.value = (
          distance: _followDistance(delta.dx),
          animated: false,
        );

        final target = resolveSwipeTarget(delta.dx);
        // Crossing the commit distance is the one moment worth feeling: it is
        // the difference between letting go and getting the container, and
        // letting go and getting nothing.
        if (target != null &&
            target.armed &&
            !(swipeTarget.value?.armed ?? false)) {
          unawaited(HapticFeedback.selectionClick());
        }
        swipeTarget.value = target;
      }
    }

    void handleScaleEnd(ScaleEndDetails details) {
      final gestureIntent = intent.value;
      intent.value = null;
      followOffset.value = (distance: 0.0, animated: !disableAnimations);
      swipeTarget.value = null;

      switch (gestureIntent) {
        case _TrayGestureIntent.pan:
          final distance = panDistance.value;
          final velocity = details.velocity.pixelsPerSecond.dx;
          final committed =
              distance.abs() >= _panCommitDistance ||
              (distance.abs() >= _panSlop &&
                  velocity.abs() >= _panCommitVelocity &&
                  velocity.sign == distance.sign);
          if (!committed) {
            return;
          }

          // Dragging the tray left brings the next container in from the right,
          // the direction the chip row runs.
          unawaited(
            switchContainer(
              distance < 0
                  ? ContainerCycleDirection.next
                  : ContainerCycleDirection.previous,
            ),
          );
        case _TrayGestureIntent.pinch:
          final scale = lastScale.value;
          if (scale >= _pinchExpandScale) {
            cycleViewMode(expand: true);
          } else if (scale <= _pinchCompactScale) {
            cycleViewMode(expand: false);
          }
        case null:
          break;
      }
    }

    return RawGestureDetector(
      gestures: {
        _MultitouchScaleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              _MultitouchScaleGestureRecognizer
            >(() => _MultitouchScaleGestureRecognizer(debugOwner: this), (
              recognizer,
            ) {
              recognizer
                ..onStart = handleScaleStart
                ..onUpdate = handleScaleUpdate
                ..onEnd = handleScaleEnd;
            }),
      },
      // Expanded so the tray keeps the tight constraints it had before this
      // stack was between it and its parent.
      child: Stack(
        fit: StackFit.expand,
        children: [
          ValueListenableBuilder<_FollowOffset>(
            valueListenable: followOffset,
            builder: (context, offset, trayChild) =>
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: offset.distance),
                  duration: offset.animated
                      ? const Duration(milliseconds: 200)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  // Kept out of the tree at rest: a zero translation still
                  // pushes a transform layer over the whole tray on every frame
                  // otherwise.
                  builder: (context, distance, animatedChild) => distance == 0.0
                      ? animatedChild!
                      : Transform.translate(
                          offset: Offset(distance, 0),
                          child: animatedChild,
                        ),
                  child: trayChild,
                ),
            child: child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<_SwipeTarget?>(
                valueListenable: swipeTarget,
                builder: (context, target, _) {
                  final duration = disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 120);

                  // An AnimatedSwitcher so releasing fades the indicator out
                  // over the container it was showing and then takes it out of
                  // the tree — an opacity left at zero would keep announcing a
                  // container the user is no longer heading for.
                  return AnimatedSwitcher(
                    duration: duration,
                    child: target == null
                        ? const SizedBox.shrink()
                        : Center(
                            key: const ValueKey('swipe-target-indicator'),
                            child: AnimatedScale(
                              scale: 0.92 + 0.08 * target.progress,
                              duration: duration,
                              child: Opacity(
                                opacity: 0.55 + 0.45 * target.progress,
                                child: _SwipeTargetIndicator(target: target),
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The container a two-finger swipe is heading for, shown over the tray while
/// the fingers are down.
///
/// Reuses the container chip's avatar and label so the thing under the fingers
/// looks like the chip the swipe is moving to, and takes the container's own
/// palette so the colour reads before the name does. The outline thickens once
/// the swipe is [_SwipeTarget.armed], which is the only state worth spelling
/// out: below it, letting go does nothing.
class _SwipeTargetIndicator extends StatelessWidget {
  final _SwipeTarget target;

  const _SwipeTargetIndicator({required this.target});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final container = target.container;
    final palette = container.mapNotNull(
      (container) => ContainerColors.palette(
        context,
        container.color,
        useCustomColor: container.metadata.useCustomColor,
      ),
    );

    final foregroundColor =
        palette?.selectedForegroundColor ?? colorScheme.onSurface;
    final borderSide = target.armed
        ? palette?.selectedBorderSide ??
              BorderSide(color: colorScheme.primary, width: 2)
        : palette?.borderSide ?? BorderSide(color: colorScheme.outlineVariant);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color:
            palette?.selectedBackgroundColor ??
            colorScheme.surfaceContainerHigh,
        shape: StadiumBorder(side: borderSide),
        shadows: target.armed ? kElevationToShadow[3] : kElevationToShadow[1],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (target.direction) {
                ContainerCycleDirection.next => Icons.arrow_forward,
                ContainerCycleDirection.previous => Icons.arrow_back,
              },
              size: 16,
              color: foregroundColor,
            ),
            const SizedBox(width: 10),
            if (container == null) ...[
              Icon(MdiIcons.folderHidden, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                'Unassigned',
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              ?buildContainerChipAvatar(context, container, true),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: buildContainerChipLabel(context, container, true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A [ScaleGestureRecognizer] that claims only the two gestures this layer
/// implements, and claims them earlier than the superclass would.
///
/// Every acceptance goes through [_canClaim], the superclass's own included:
/// [ScaleGestureRecognizer] accepts any two-pointer focal travel past its pan
/// slop, so left to itself it would win a two-finger *vertical* drag and hand
/// it to a layer that does nothing with it — swallowing the tab list's
/// scrolling. It also accepts a *single*-pointer pan, which would take
/// scrolling and swipe-to-close from the tab list one finger at a time.
///
/// The threshold moves the other way. Twice [kTouchSlop] of focal travel is far
/// too late for a two-finger swipe: the tab items' horizontal drag recognizers
/// sit deeper in the tree, see the same move events first, and would have closed
/// a tab long before. [_multitouchSlop] claims a genuine two-finger sequence
/// below the slop those recognizers wait for.
///
/// Trackpad pan/zoom sequences carry no pointer positions of their own, so they
/// never satisfy [_canClaim] — a trackpad keeps its ordinary scrolling, at the
/// price of no pinch there. Fine for a phone browser.
class _MultitouchScaleGestureRecognizer extends ScaleGestureRecognizer {
  _MultitouchScaleGestureRecognizer({super.debugOwner});

  /// Live pointer positions, mirroring the ones the superclass keeps privately.
  final Map<int, Offset> _positions = <int, Offset>{};

  /// Focal point and mean spread when the current set of pointers was last
  /// completed, i.e. what [_multitouchSlop] is measured against. Reset whenever
  /// a pointer joins or leaves, so adding a finger is not read as movement.
  Offset? _origin;
  double _originSpan = 0.0;

  /// Whether this sequence has already been claimed. Once it has, the
  /// superclass's repeated acceptances pass straight through: the arena is won,
  /// and re-testing a gesture that has since turned vertical would say no.
  bool _claimed = false;

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      _positions[event.pointer] = event.position;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _positions.remove(event.pointer);
    }

    if (event is! PointerMoveEvent) {
      _resetOrigin();
    }

    // Runs first so the superclass has updated its own geometry, and so a
    // claim below lands on a fully initialised state machine.
    super.handleEvent(event);

    if (event is PointerMoveEvent) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void rejectGesture(int pointer) {
    _positions.remove(pointer);
    _resetOrigin();
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _positions.clear();
    _resetOrigin();
    _claimed = false;
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (disposition == GestureDisposition.accepted && !_claimed) {
      if (!_canClaim) {
        return;
      }
      _claimed = true;
    }

    super.resolve(disposition);
  }

  void _resetOrigin() {
    if (_positions.length < 2) {
      _origin = null;
      return;
    }

    final focalPoint = _focalPoint();
    _origin = focalPoint;
    _originSpan = _span(focalPoint);
  }

  /// Whether the pointers are doing one of the two things this layer handles:
  /// spreading or closing, or moving sideways together. A two-finger *vertical*
  /// drag is neither, and is left to the tab list's scroll recognizer.
  bool get _canClaim {
    final origin = _origin;
    if (origin == null || _positions.length < 2 || pointerCount < 2) {
      return false;
    }

    final focalPoint = _focalPoint();
    final travelled = focalPoint - origin;

    // A pinch holds its focal point while the fingers move relative to it. The
    // second half of that test is what keeps a two-finger scroll with uneven
    // fingers — which also spreads them — out of here.
    final spanDelta = (_span(focalPoint) - _originSpan).abs();
    final isPinch =
        spanDelta > _multitouchSlop && spanDelta > travelled.distance;

    final isHorizontalPan =
        travelled.dx.abs() > _multitouchSlop &&
        travelled.dx.abs() > travelled.dy.abs();

    return isPinch || isHorizontalPan;
  }

  Offset _focalPoint() {
    return _positions.values.reduce((a, b) => a + b) /
        _positions.length.toDouble();
  }

  double _span(Offset focalPoint) {
    return _positions.values
            .map((position) => (position - focalPoint).distance)
            .reduce((a, b) => a + b) /
        _positions.length;
  }
}
