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

/// Styles the system bars over [child] with [browserSystemBarsStyle], for a
/// surface of [color] drawn behind them.
class BrowserSystemBarsRegion extends ConsumerWidget {
  final Color color;
  final Widget child;

  const BrowserSystemBarsRegion({
    required this.color,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationBarOutsideFlutter = ref.watch(
      navigationBarLayoutControllerProvider.select(
        (layout) => layout.outsideFlutter,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: browserSystemBarsStyle(
        color,
        navigationBarOutsideFlutter: navigationBarOutsideFlutter,
      ),
      child: child,
    );
  }
}

/// The system bar style for a browser surface of [background] that is drawn
/// behind the status and navigation bars: `BrowserSystemBars`, or a sheet
/// covering them.
///
/// The bars stay transparent, so the surface behind them is their background,
/// and their icons contrast with it. MainActivity makes the native bars
/// transparent at startup; restating it here keeps them that way whatever
/// another route last asked for.
///
/// Where the navigation bar lies outside the Flutter UI, no surface can reach
/// it and the transparent bar would show the native window background, which
/// follows the system theme rather than the app's (#657). There the bar
/// carries [background] itself.
SystemUiOverlayStyle browserSystemBarsStyle(
  Color background, {
  required bool navigationBarOutsideFlutter,
}) {
  final iconBrightness =
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Brightness.light
      : Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: navigationBarOutsideFlutter
        ? background
        : Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
    statusBarIconBrightness: iconBrightness,
    systemNavigationBarIconBrightness: iconBrightness,
    // iOS reports the bar's own brightness rather than the icons'.
    statusBarBrightness: iconBrightness == Brightness.light
        ? Brightness.dark
        : Brightness.light,
  );
}
