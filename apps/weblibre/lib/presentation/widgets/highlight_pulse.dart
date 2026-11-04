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
import 'package:flutter_hooks/flutter_hooks.dart';

/// Scrolls [child] into view and briefly pulses a tint behind it once
/// [active] turns true: where a link into a long screen lands.
///
/// [onStarted] runs when the pulse starts, before anything else, so whoever
/// asked for it can forget the request and the pulse does not replay on a
/// rebuild or after going back.
class HighlightPulse extends HookWidget {
  const HighlightPulse({
    super.key,
    required this.active,
    this.onStarted,
    required this.child,
  });

  final bool active;
  final VoidCallback? onStarted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // With reduced motion the scroll jumps and the tint holds steady, then
    // goes, with no fades. The controller keeps its full duration either
    // way: by default it would shorten itself to a flash nobody sees.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1500),
      animationBehavior: AnimationBehavior.preserve,
    );

    final animation = useMemoized(
      () => TweenSequence<double>(
        reduceMotion
            ? [
                TweenSequenceItem(tween: ConstantTween(1.0), weight: 99),
                TweenSequenceItem(tween: ConstantTween(0.0), weight: 1),
              ]
            : [
                TweenSequenceItem(
                  tween: Tween(
                    begin: 0.0,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                  weight: 20,
                ),
                TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
                TweenSequenceItem(
                  tween: Tween(
                    begin: 1.0,
                    end: 0.0,
                  ).chain(CurveTween(curve: Curves.easeIn)),
                  weight: 50,
                ),
              ],
      ).animate(controller),
      [controller, reduceMotion],
    );

    useEffect(() {
      if (!active) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        onStarted?.call();
        if (!context.mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
        controller.forward(from: 0);
      });

      return null;
    }, [active]);

    final highlightColor = Theme.of(context).colorScheme.secondaryContainer;

    // A Material rather than a ColoredBox: a ListTile draws its ink on the
    // nearest Material, which a colored box would cover. Always there, so
    // the child keeps its state when the pulse starts and ends.
    //
    // Tinted only while a pulse runs. The reduced-motion sequence holds 1.0
    // from its start, so a controller resting at 0 (every row nobody linked
    // to) would otherwise stay tinted for good.
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Material(
        color: highlightColor.withValues(
          alpha: controller.isAnimating ? animation.value * 0.7 : 0.0,
        ),
        child: child,
      ),
      child: child,
    );
  }
}
