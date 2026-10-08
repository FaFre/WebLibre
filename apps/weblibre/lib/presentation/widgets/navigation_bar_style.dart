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

/// The navigation bar style for every screen that doesn't set its own.
///
/// Wraps an app shell's routes. Flutter takes the navigation bar style from the
/// topmost [AnnotatedRegion] at the bottom edge, so the browser's
/// `BrowserSystemBars` overrides this while it is painted, and this applies on
/// every other route, including those pushed over the browser.
///
/// Where the navigation bar lies outside the Flutter UI, the bar takes the
/// scaffold background; left transparent, it would show the native window
/// background, which follows the system theme rather than the app's (#657).
class NavigationBarStyle extends ConsumerWidget {
  final Widget child;

  const NavigationBarStyle({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    final navigationBarOutsideFlutter = ref.watch(
      navigationBarOutsideFlutterProvider,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Only navigation bar fields: the status bar stays with whatever the
      // route's app bar asks for.
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navigationBarOutsideFlutter
            ? background
            : Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness:
            ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: child,
    );
  }
}
