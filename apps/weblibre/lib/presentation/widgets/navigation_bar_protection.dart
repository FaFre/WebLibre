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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/navigation_bar.dart';
import 'package:weblibre/core/routing/routes.dart';

/// Ends a screen above a navigation bar of buttons and fills the bar with the
/// screen's background (#651).
///
/// The app draws behind the system bars, which stay transparent (MainActivity).
/// Behind a gesture handle that is the intended look, but navigation buttons
/// sit on top of whatever scrolls under them. Android's own remedy, the
/// translucent scrim of navigation bar contrast enforcement, is drawn by the
/// system above the whole window: a Flutter dialog's barrier cannot dim it, so
/// in the light theme it shows as a bright band under every dimmed dialog.
///
/// [SafeArea] pads by the padding that is left, which is none while the
/// keyboard is up, so a screen still ends right on top of the keyboard.
class NavigationBarProtection extends ConsumerWidget {
  final Widget child;

  const NavigationBarProtection({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonsAtBottom = ref.watch(
      navigationBarLayoutControllerProvider.select(
        (layout) => layout.buttonsAtBottom,
      ),
    );

    // The same widgets either way, so a change (a rotation, another navigation
    // mode) keeps the screen's state.
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        left: false,
        top: false,
        right: false,
        bottom: buttonsAtBottom,
        child: child,
      ),
    );
  }
}

/// A [PageTransitionsTheme] that wraps every page route in
/// [NavigationBarProtection], except the browser, which fills its system bar
/// regions itself (`BrowserSystemBars`).
///
/// The transitions theme is the one place every page route passes through,
/// GoRouter pages and plain [MaterialPageRoute]s alike. Dialogs and sheets
/// don't, so they still reach under the bar and their barrier still dims it.
class NavigationBarProtectedPageTransitionsTheme extends PageTransitionsTheme {
  const NavigationBarProtectedPageTransitionsTheme({super.builders});

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      route.settings.name == BrowserRoute.name
          ? child
          : NavigationBarProtection(child: child),
    );
  }
}
