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
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/navigation_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/browser_bar_tint.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/presentation/widgets/browser_system_bars_style.dart';

/// The color the browser chrome fills the system bar insets with: the active
/// container's surface color, or the tab bar's surfaceContainer fallback when
/// no container is active.
///
/// The tab bar computes the same color for its background, so everything that
/// borders it — the [BrowserSystemBars] strips, the bottom bar's safe-area
/// padding, the side rail's outer fill — reads it from here to stay seamless.
/// [tint] is [browserBarTintProvider].
Color browserBarTintColor(BuildContext context, BrowserBarTint? tint) =>
    tint != null
    ? ContainerColors.palette(
        context,
        tint.color,
        useCustomColor: tint.useCustomColor,
      ).surfaceColor
    : Theme.of(context).colorScheme.surfaceContainer;

/// Tints the status-bar (top) and navigation-bar (bottom) inset regions with
/// the active container's surface color, mirroring how the tab bar
/// ([BrowserBottomAppBar]) tints itself, and drives the system bar icon
/// brightness so the icons stay legible against the tint.
///
/// The app runs edge-to-edge on every Android version (MainActivity enables
/// it; Android 15+ would enforce it anyway), so the system bars are
/// transparent and content draws behind them. The inset regions are therefore
/// filled in Flutter, and the platform is only told to keep the bars
/// transparent and which icon brightness to use, through
/// [SystemUiOverlayStyle]. The one exception is a navigation bar Flutter isn't
/// laid out behind (detected natively by MainActivity): no strip can reach it,
/// so the tint goes into the bar's own color through [SystemUiOverlayStyle].
///
/// Designed to be placed as a full-bleed ([Positioned.fill]) layer in the
/// browser [Stack], above the browser content but below the toolbars. The
/// bottom strip stays visible when the bottom toolbar hides; while it shows,
/// the bar's safe-area padding covers the strip in the same color (see
/// [BrowserBottomAppBar] for why it isn't left transparent).
class BrowserSystemBars extends HookConsumerWidget {
  final double topInset;
  final double bottomInset;

  const BrowserSystemBars({
    super.key,
    required this.topInset,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = ref.watch(browserBarTintProvider);
    final tintColor = browserBarTintColor(context, tint);

    // Where the navigation bar lies outside the Flutter UI, the strip below
    // can't reach it (see [browserSystemBarsStyle]). The bottom strip is
    // dropped there: any inset Flutter still sees isn't the bar, and a strip
    // would stack a second band of the same color on top of it.
    final navigationBarOutsideFlutter = ref.watch(
      navigationBarLayoutControllerProvider.select(
        (layout) => layout.outsideFlutter,
      ),
    );

    return IgnorePointer(
      child: BrowserSystemBarsRegion(
        color: tintColor,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: ColoredBox(color: tintColor),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: navigationBarOutsideFlutter ? 0 : bottomInset,
              child: ColoredBox(color: tintColor),
            ),
          ],
        ),
      ),
    );
  }
}
