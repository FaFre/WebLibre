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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';

class BrowserPage extends ConsumerWidget {
  final Widget child;

  const BrowserPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColors.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // The aura backdrop is static: it only changes when the theme does.
        // Isolating it in a repaint boundary keeps it out of the scrolling
        // content's repaints, and the picture itself is raster-cacheable.
        RepaintBoundary(
          child: CustomPaint(
            painter: _AuraBackdropPainter(
              colorScheme: colorScheme,
              appColors: appColors,
            ),
            isComplex: true,
            willChange: false,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// The decorative background shared by the browser home and the onboarding
/// pages: a diagonal wash with three soft coloured orbs bleeding in from the
/// edges.
///
/// This used to be three solid circles under a full-viewport
/// `BackdropFilter(ImageFilter.blur(sigma: 72))`. That cost a save-layer plus a
/// multi-pass gaussian blur of the entire screen *on every frame* —
/// `BackdropFilter` re-reads and re-blurs its backdrop unconditionally and is
/// never raster-cached — to soften artwork that never moves. Above the GeckoView
/// platform view it was worse still, forcing the Android external view embedder
/// to split the frame into extra overlay surfaces.
///
/// A blurred disc is, to the eye, exactly a radial gradient, so the orbs are
/// drawn as gradients directly. No save-layers, no blur passes, and the whole
/// backdrop reduces to four shader-filled rects.
class _AuraBackdropPainter extends CustomPainter {
  final ColorScheme colorScheme;
  final AppColors appColors;

  const _AuraBackdropPainter({
    required this.colorScheme,
    required this.appColors,
  });

  /// Sigma the orbs were previously blurred with. Retained as the falloff width
  /// so the gradients match the look the blur produced.
  static const _sigma = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              appColors.auraPurple.withValues(alpha: 0.38),
              colorScheme.surfaceContainerLowest,
            ),
            Color.alphaBlend(
              appColors.auraShadow.withValues(alpha: 0.72),
              colorScheme.surface,
            ),
            Color.alphaBlend(
              appColors.auraGold.withValues(alpha: 0.34),
              colorScheme.surfaceContainerHigh,
            ),
          ],
        ).createShader(bounds),
    );

    // Centres and radii are the previous `Positioned` orbs resolved against the
    // viewport: 400² at (top: -70, left: -120), 340² at (top: 220, right: -150)
    // and 320² at (bottom: 18, left: -8).
    _paintOrb(canvas, bounds, const Offset(80, 130), 200, appColors.auraPurple);
    _paintOrb(
      canvas,
      bounds,
      Offset(size.width - 20, 390),
      170,
      appColors.auraGold,
    );
    _paintOrb(
      canvas,
      bounds,
      Offset(152, size.height - 178),
      160,
      appColors.auraShadowHighlight,
    );

    canvas.drawRect(
      bounds,
      Paint()..color = appColors.auraTint.withValues(alpha: 0.12),
    );
  }

  void _paintOrb(
    Canvas canvas,
    Rect bounds,
    Offset center,
    double radius,
    Color color,
  ) {
    // Blur energy is spent by 2σ past the edge, so that is where the gradient
    // ends.
    final gradientRadius = radius + 2 * _sigma;

    // A gaussian-blurred disc holds an alpha of `1 - exp(-r²/2σ²)` at its
    // centre and falls off across the edge along the blur's error function,
    // which is ~0.98/0.84/0.5/0.16/0 at -2σ/-σ/0/+σ/+2σ relative to the edge.
    // Sampling those five points reproduces the blur closely enough that the
    // difference is invisible at this scale.
    final centerAlpha =
        1 - math.exp(-(radius * radius) / (2 * _sigma * _sigma));
    const falloff = <double>[0.977, 0.841, 0.5, 0.159, 0.0];

    final colors = <Color>[color.withValues(alpha: centerAlpha)];
    final stops = <double>[0.0];

    for (var i = 0; i < falloff.length; i++) {
      final sampleRadius = radius + (i - 2) * _sigma;
      if (sampleRadius <= 0) {
        // The disc is smaller than the blur reaches inward; the samples that
        // fall inside the centre are already covered by [centerAlpha].
        continue;
      }

      colors.add(
        // Clamped so the profile stays monotonically fading outward for small
        // discs, where the edge samples would otherwise exceed the centre.
        color.withValues(alpha: math.min(falloff[i], centerAlpha)),
      );
      stops.add(sampleRadius / gradientRadius);
    }

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: colors,
          stops: stops,
        ).createShader(Rect.fromCircle(center: center, radius: gradientRadius)),
    );
  }

  @override
  bool shouldRepaint(_AuraBackdropPainter oldDelegate) =>
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.appColors != appColors;
}

class BrowserPageContent extends StatelessWidget {
  final double bottomViewportInset;
  final Widget child;

  const BrowserPageContent({
    super.key,
    this.bottomViewportInset = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 32, 24, 32 + bottomViewportInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(
                0,
                constraints.maxHeight - 64 - bottomViewportInset,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BrandHeader extends StatelessWidget {
  final ColorScheme colorScheme;

  const BrandHeader({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        // Enough tint to read as brand colours: below roughly a quarter the
        // blend lands on a neutral grey and the mark looks like a placeholder.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              AppColors.brandPurple.withValues(alpha: 0.28),
              colorScheme.surfaceContainerHighest,
            ),
            Color.alphaBlend(
              AppColors.brandYellow.withValues(alpha: 0.20),
              colorScheme.surfaceContainer,
            ),
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      // 56 inside a 112 tile with 20 of padding: at 72 the mark exactly fills
      // the content box and its arms touch the tile edge, which reads as a
      // cropped image rather than a logo.
      child: Center(
        child: SvgPicture.asset('assets/icon/icon.svg', width: 56, height: 56),
      ),
    );
  }
}
