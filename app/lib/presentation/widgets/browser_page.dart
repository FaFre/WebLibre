import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BrowserPage extends ConsumerWidget {
  final double bottomViewportInset;
  final Widget child;

  const BrowserPage({super.key, this.bottomViewportInset = 0, required this.child});

  static const brandPurple = Color(0xFF9C83F8);
  static const brandYellow = Color(0xFFFBDC6B);
  static const brandGrey = Color(0xFFA7A7A7);

  static const auraPurple = Color(0xFF2C2543);
  static const auraGold = Color(0xFF3C3827);
  static const auraShadow = Color(0xFF222224);
  static const auraShadowHighlight = Color(0xFF2D2D31);
  static const auraTint = Color(0xFF000000);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              auraPurple.withValues(alpha: 0.38),
              colorScheme.surfaceContainerLowest,
            ),
            Color.alphaBlend(
              auraShadow.withValues(alpha: 0.72),
              colorScheme.surface,
            ),
            Color.alphaBlend(
              auraGold.withValues(alpha: 0.34),
              colorScheme.surfaceContainerHigh,
            ),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -70,
            left: -120,
            child: _BackdropOrb(width: 400, height: 400, color: auraPurple),
          ),
          const Positioned(
            top: 220,
            right: -150,
            child: _BackdropOrb(width: 340, height: 340, color: auraGold),
          ),
          const Positioned(
            bottom: 18,
            left: -8,
            child: _BackdropOrb(
              width: 320,
              height: 320,
              color: auraShadowHighlight,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
                  child: ColoredBox(color: auraTint.withValues(alpha: 0.12)),
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
              BrowserPage.brandPurple.withValues(alpha: 0.18),
              colorScheme.surfaceContainerHighest,
            ),
            Color.alphaBlend(
              BrowserPage.brandYellow.withValues(alpha: 0.12),
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
