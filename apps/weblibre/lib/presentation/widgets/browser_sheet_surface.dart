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
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/providers/navigation_bar.dart';
import 'package:weblibre/presentation/widgets/browser_system_bars_style.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

/// Shows the sheet [builder] returns in a modal bottom sheet route, for a
/// sheet drawn by a [BrowserSheetSurface] (inside a [PointerScrollableSheet]
/// that does not expand), so it behaves like the browser's own sheets:
/// draggable up to the window's full height, under the status bar.
///
/// The route's own sheet stays invisible behind the surface. Draw the drag
/// handle inside the surface ([SheetDragHandle]); the route's would float
/// above it.
Future<T?> showBrowserSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    shape: const RoundedRectangleBorder(),
    clipBehavior: Clip.none,
    builder: builder,
  );
}

/// The surface of a sheet over the browser, laid out as an M3 modal bottom
/// sheet in an edge-to-edge window: the tab tray and site settings, shown by
/// the browser's `BrowserSheetHost`, and the sheets shown by
/// [showBrowserSheet].
///
/// The surface runs behind the navigation bar to the window's bottom edge, and
/// keeps its content above the bar. Dragged all the way up it slides under the
/// status bar, as Material Components' expanded sheets do on Android: the
/// content stays below the bar, and the top corners straighten over the last
/// stretch, so a sheet that covers the window has none. Wherever the surface
/// is behind a system bar, it sets that bar's icon brightness. Its content
/// stays above the keyboard, too. A sheet that
/// reaches into a side inset (a navigation bar on a landscape phone) keeps its
/// content clear of it as well.
class BrowserSheetSurface extends ConsumerWidget {
  final Widget child;

  /// The surface's color, Material's for a modal bottom sheet by default.
  final Color? color;

  /// How [child] is clipped to the surface's rounded corners. [Clip.none] for
  /// content that must not be clipped, such as a native view: Android doesn't
  /// reliably apply a rounded clip to one rendered into its own surface.
  final Clip clipBehavior;

  const BrowserSheetSurface({
    required this.child,
    this.color,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  static const cornerRadius = 28.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color =
        this.color ?? Theme.of(context).colorScheme.surfaceContainerLow;
    // Above the navigation bar, or the keyboard while it covers the bar.
    // Neither the browser nor a sheet's route makes room for the keyboard.
    final bottomInset = math.max(
      MediaQuery.paddingOf(context).bottom,
      MediaQuery.viewInsetsOf(context).bottom,
    );
    final navigationBarOutsideFlutter = ref.watch(
      navigationBarLayoutControllerProvider.select(
        (layout) => layout.outsideFlutter,
      ),
    );
    // On a foldable, a modal bottom sheet route lays its sheet out on one side
    // of the fold, and leaves the window's size in the sheet's MediaQuery.
    final sheetRoute = switch (ModalRoute.of(context)) {
      final ModalBottomSheetRoute<Object?> route => route,
      _ => null,
    };
    final textDirection = Directionality.of(context);

    // Built once, outside the LayoutBuilder below: that one rebuilds on every
    // frame of a drag, and only the insets and corners change.
    final content = MediaQuery.removePadding(
      context: context,
      // The insets are applied below, so nothing inside adds them a second
      // time.
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: child,
    );

    // The window's own geometry, which the sheet's MediaQuery doesn't carry: a
    // modal bottom sheet route takes the status bar out of it, and on a
    // foldable the fold. Unlike the view's, this rebuilds when they change, a
    // page going fullscreen under a sheet, say.
    return MediaQuery.fromView(
      view: View.of(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final windowSize = MediaQuery.sizeOf(context);
          final windowInsets = MediaQuery.viewPaddingOf(context);
          final statusBarHeight = windowInsets.top;

          // Where in the window the sheet's container is, the sheet centered
          // at its bottom edge: the window, or the side of the fold its route
          // lays it out on.
          final container = sheetRoute == null
              ? Offset.zero & windowSize
              : modalSubScreen(
                  MediaQueryData(
                    size: windowSize,
                    displayFeatures: MediaQuery.displayFeaturesOf(context),
                  ),
                  anchorPoint: sheetRoute.anchorPoint,
                  textDirection: textDirection,
                );
          final sheet = Rect.fromLTRB(
            container.left + (container.width - constraints.maxWidth) / 2,
            container.bottom - constraints.maxHeight,
            container.right - (container.width - constraints.maxWidth) / 2,
            container.bottom,
          );

          final statusBarOverlap = (statusBarHeight - sheet.top).clamp(
            0.0,
            statusBarHeight,
          );
          final radius =
              cornerRadius *
              (sheet.top / math.max(statusBarHeight, cornerRadius)).clamp(
                0.0,
                1.0,
              );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: browserSystemBarsStyle(
              color,
              navigationBarOutsideFlutter: navigationBarOutsideFlutter,
            ),
            child: Material(
              color: color,
              // The corners follow the sheet's edge frame by frame. Material
              // would otherwise animate each change of shape over 200ms, and
              // a sheet pulled under the status bar would show the page
              // through its corners until they caught up.
              animationDuration: Duration.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
              ),
              clipBehavior: clipBehavior,
              child: Padding(
                padding: EdgeInsets.only(
                  left: math.max(0, windowInsets.left - sheet.left),
                  top: statusBarOverlap,
                  right: math.max(
                    0,
                    windowInsets.right - (windowSize.width - sheet.right),
                  ),
                  bottom: bottomInset,
                ),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
