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
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/wallpaper/domain/entities/home_wallpaper.dart';
import 'package:weblibre/features/wallpaper/domain/providers.dart';

/// Draws the resolved home wallpaper behind [child].
///
/// Only the wallpaper providers are watched here, and [child] is passed in
/// already built, so changing a wallpaper — or dragging a slider on the
/// settings screen — repaints the backdrop without rebuilding the home
/// surface's module list underneath it.
class HomeWallpaperBackdrop extends ConsumerWidget {
  final Widget child;

  const HomeWallpaperBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarPosition),
    );

    return WallpaperBackdrop(
      wallpaper: ref.watch(resolvedHomeWallpaperProvider),
      // The home surface's box is not the screen: `browser.dart` positions the
      // browser with offsets that appear and disappear with the toolbar, so
      // showing or hiding the tab bar resizes this box and moves one of its
      // edges. Left to fit that box, the wallpaper would re-derive its cover
      // scale on every such change and visibly zoom.
      //
      // The edge that moves is the one the tab bar is docked to, so anchoring
      // to the opposite corner holds the picture still against the screen.
      screenAnchor: switch (tabBarPosition) {
        TabBarPosition.top => Alignment.bottomLeft,
        TabBarPosition.bottom => Alignment.topLeft,
        TabBarPosition.left => Alignment.topRight,
        TabBarPosition.right => Alignment.topLeft,
      },
      child: child,
    );
  }
}

/// [HomeWallpaperBackdrop] without the provider lookup, so the settings screen
/// can preview a wallpaper it has not saved yet.
class WallpaperBackdrop extends StatelessWidget {
  final HomeWallpaper? wallpaper;

  /// When set, the image is laid out at the size of the whole screen and
  /// anchored to it by this corner, rather than fitted to whatever box this
  /// widget was given; the box merely clips it.
  ///
  /// Null fits the box, which is what a preview wants — its box *is* the whole
  /// of what it represents.
  final Alignment? screenAnchor;

  final Widget child;

  const WallpaperBackdrop({
    super.key,
    required this.wallpaper,
    this.screenAnchor,
    this.child = const SizedBox.expand(),
  });

  @override
  Widget build(BuildContext context) {
    final wallpaper = this.wallpaper;

    // No wallpaper is the default state, and it costs nothing: the surface
    // beneath (the aura backdrop, on the home page) shows through untouched.
    if (wallpaper == null) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The image never animates and never scrolls, so isolating it lets the
        // raster cache keep the decoded — and, when set, blurred — result while
        // the content above it scrolls.
        RepaintBoundary(
          child: _WallpaperLayer(
            wallpaper: wallpaper,
            screenAnchor: screenAnchor,
          ),
        ),
        child,
      ],
    );
  }
}

class _WallpaperLayer extends StatelessWidget {
  final HomeWallpaper wallpaper;
  final Alignment? screenAnchor;

  const _WallpaperLayer({required this.wallpaper, this.screenAnchor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    // Decode to the width it is drawn at rather than the file's own: a phone
    // wallpaper is routinely a camera photo several times the size of the
    // screen, and the full-resolution bitmap would sit in the image cache for
    // as long as the home surface lives.
    final decodeWidth =
        (mediaQuery.size.width *
                mediaQuery.devicePixelRatio /
                _decodeDivisor(wallpaper.blur))
            .round()
            .clamp(_minDecodeWidth, _maxDecodeWidth);

    Widget image = Image(
      image: ResizeImage(
        FileImage(wallpaper.file),
        width: decodeWidth,
        allowUpscaling: false,
      ),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      // The wallpaper survives a theme change or a settings write without
      // flashing back to nothing while the (already cached) image resolves.
      gaplessPlayback: true,
      // A wallpaper can go missing — a profile restored from an archive older
      // than the setting, or storage cleared underneath us. Falling through to
      // the surface below is the graceful outcome, and the next sweep drops the
      // dangling reference anyway.
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );

    if (wallpaper.blur > 0) {
      image = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: wallpaper.blur,
          sigmaY: wallpaper.blur,
          // Without clamping, the blur samples past the image and fades the
          // screen edges out to transparent — a visible frame around the
          // wallpaper rather than a blurred picture.
          tileMode: TileMode.clamp,
        ),
        child: image,
      );
    }

    final Widget layer = Stack(
      fit: StackFit.expand,
      children: [
        image,
        // The scrim follows the theme's own background rather than always
        // darkening: the home surface draws its header and section titles in
        // theme colours directly on top, so in a light theme the image has to
        // be washed lighter — not darker — for them to stay readable.
        if (wallpaper.dim > 0)
          ColoredBox(
            color: colorScheme.surface.withValues(alpha: wallpaper.dim),
          ),
      ],
    );

    final screenAnchor = this.screenAnchor;
    if (screenAnchor == null) return layer;

    // Laid out at the screen's size whatever box this got, so the cover fit is
    // computed once against a size that does not change. The clip is not
    // optional: the overflow would otherwise paint over the toolbar sitting
    // beside this box.
    final screen = mediaQuery.size;

    return ClipRect(
      child: OverflowBox(
        alignment: screenAnchor,
        minWidth: screen.width,
        maxWidth: screen.width,
        minHeight: screen.height,
        maxHeight: screen.height,
        child: layer,
      ),
    );
  }
}

/// Guards against decoding a one-pixel image on a hidden surface, and against
/// asking for more than any phone display can show.
const _minDecodeWidth = 360;
const _maxDecodeWidth = 2560;

/// How much smaller than the display the decode may be.
///
/// Detail that a blur is about to destroy does not need to be decoded first, so
/// a heavily blurred wallpaper is read at a fraction of the resolution a sharp
/// one needs. The blur sigma itself is unaffected — it is applied in logical
/// pixels, after the image has been scaled to fill the screen.
double _decodeDivisor(double blur) =>
    math.max(1, 1 + blur / (maxHomeWallpaperBlur / 3));
