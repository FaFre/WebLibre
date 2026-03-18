import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';

class BrowserPage extends ConsumerWidget {
  final double bottomViewportInset;
  final Widget child;

  const BrowserPage({super.key, this.bottomViewportInset = 0, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -70,
            left: -120,
            child: _BackdropOrb(width: 400, height: 400, color: appColors.auraPurple),
          ),
          Positioned(
            top: 220,
            right: -150,
            child: _BackdropOrb(width: 340, height: 340, color: appColors.auraGold),
          ),
          Positioned(
            bottom: 18,
            left: -8,
            child: _BackdropOrb(
              width: 320,
              height: 320,
              color: appColors.auraShadowHighlight,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
                  child: ColoredBox(color: appColors.auraTint.withValues(alpha: 0.12)),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
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
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            32 + bottomViewportInset,
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              AppColors.brandPurple.withValues(alpha: 0.18),
              colorScheme.surfaceContainerHighest,
            ),
            Color.alphaBlend(
              AppColors.brandYellow.withValues(alpha: 0.12),
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
      child: Center(
        child: SvgPicture.asset('assets/icon/icon.svg', width: 72, height: 72),
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _BackdropOrb({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
