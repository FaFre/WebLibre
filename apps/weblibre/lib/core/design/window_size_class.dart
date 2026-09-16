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
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Material 3 window width classes.
///
/// Material defines five (600 / 840 / 1200 / 1600). The last two are folded
/// into [expanded] because nothing in this app has a third layout tier: above
/// 840 the only thing that changes is how much empty gutter sits beside a
/// width-capped surface, and the content-width tokens below already handle
/// that. Add the missing classes when a layout actually needs them.
enum WindowWidthClass {
  /// `< 600` — phones in portrait, narrow split-screen and pop-up windows.
  compact,

  /// `600 – 839` — small tablets, phones in landscape, half-screen windows.
  medium,

  /// `>= 840` — tablets, desktop windowing, DeX, ChromeOS.
  expanded,
}

/// Material 3 window height classes.
///
/// Height carries as much weight as width here. A phone in landscape is
/// roughly 840x390: [WindowWidthClass.expanded] by width, yet a wide tab panel
/// with per-chip titles is exactly the wrong thing to show in 390dp of height.
/// The same applies to a wide, short freeform/DeX strip.
enum WindowHeightClass {
  /// `< 480` — landscape phones, short freeform strips.
  compact,

  /// `480 – 899` — the common case.
  medium,

  /// `>= 900` — tablets in portrait, large desktop windows.
  expanded,
}

/// The size class of the **window**, never the device.
///
/// This is the whole point of the abstraction: under freeform/multi-window the
/// app is handed an arbitrary rectangle that says nothing about the hardware
/// it is running on, so a 700dp window on a 1600dp DeX desktop must behave
/// exactly like a 7" tablet. Nothing here may consult `Display`,
/// `physicalSize`, smallest-width resource qualifiers or
/// `Configuration.smallestScreenWidthDp`.
///
/// Layout decisions are driven by the discrete classes and never by the raw
/// width. That is not only a tidiness rule: a freeform window being dragged
/// emits a metrics change every frame, and quantising to an enum means the
/// rest of the app sees at most a couple of transitions per resize gesture
/// instead of hundreds. It is the primary defence against re-laying out the
/// GeckoView platform view mid-drag.
@immutable
class WindowSizeClass {
  final WindowWidthClass width;
  final WindowHeightClass height;

  const WindowSizeClass({required this.width, required this.height});

  /// The conservative default: what a phone in portrait resolves to.
  ///
  /// Used as the default argument of the `effective…` resolvers on
  /// `GeneralSettings`, so a caller that has no window information (a unit
  /// test, a pure model test) gets today's phone behaviour rather than a
  /// large-screen layout.
  static const compact = WindowSizeClass(
    width: WindowWidthClass.compact,
    height: WindowHeightClass.medium,
  );

  // Material 3 breakpoints, exact. Deliberately no hysteresis band: a margin
  // would make classification depend on which direction the window was
  // resized from, so the same 576dp window could be `compact` or `medium`
  // depending on its history. If real-world jitter ever justifies one, add it
  // as explicitly-labelled application policy — not as "the M3 breakpoints".
  static const widthMediumBreakpoint = 600.0;
  static const widthExpandedBreakpoint = 840.0;
  static const heightMediumBreakpoint = 480.0;
  static const heightExpandedBreakpoint = 900.0;

  factory WindowSizeClass.fromSize(Size size) => WindowSizeClass(
    width: widthClassFor(size.width),
    height: heightClassFor(size.height),
  );

  static WindowWidthClass widthClassFor(double width) {
    if (width < widthMediumBreakpoint) return WindowWidthClass.compact;
    if (width < widthExpandedBreakpoint) return WindowWidthClass.medium;
    return WindowWidthClass.expanded;
  }

  static WindowHeightClass heightClassFor(double height) {
    if (height < heightMediumBreakpoint) return WindowHeightClass.compact;
    if (height < heightExpandedBreakpoint) return WindowHeightClass.medium;
    return WindowHeightClass.expanded;
  }

  /// Whether an unconfigured tab bar should dock to a vertical side edge
  /// rather than the bottom.
  ///
  /// Only consulted for the `auto` tab bar position; an explicit choice is
  /// never overridden.
  ///
  /// Requires height as well as width. A phone in landscape is wide enough by
  /// width, but it is still a phone: rotating it must not move the bar from
  /// the bottom to the side, re-lay out the page and switch off the bar's
  /// auto-hide on the way.
  bool get prefersSideRail =>
      width != WindowWidthClass.compact && height != WindowHeightClass.compact;

  /// Whether the side rail has room to become a real tab panel — titled,
  /// closable chips and an upright address field — rather than a strip of
  /// icons.
  ///
  /// Requires height as well as width: see [WindowHeightClass].
  bool get allowsWideRail =>
      width == WindowWidthClass.expanded && height != WindowHeightClass.compact;

  /// Whether stacked toolbar rows have to be thinned out.
  ///
  /// The tab bar stacks up to `kToolbarHeight` (56) + a 54dp contextual bar +
  /// two 48dp switcher rows = 206dp. In a 480dp-tall window that is over 40%
  /// of the viewport spent on chrome.
  bool get isHeightConstrained => height == WindowHeightClass.compact;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowSizeClass &&
          other.width == width &&
          other.height == height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'WindowSizeClass(${width.name}, ${height.name})';
}

/// Maximum widths for content that becomes unreadable when stretched.
///
/// These replace the three ad-hoc clamps that grew independently in the app
/// (560 in `browser_page.dart` and the onboarding toolbar page, 520 across the
/// startup screens). Everything else — roughly fifty settings and list screens
/// — had no clamp at all and ran edge to edge.
abstract final class ContentWidth {
  /// Forms, prose and settings rows: prose stops being comfortable to read
  /// much past this, and a switch stranded 900dp from its label is worse.
  static const form = 560.0;

  /// Lists and grids, which carry their own internal structure and tolerate
  /// more width than a form row does.
  static const list = 720.0;

  /// Material 3's maximum width for a bottom sheet.
  static const sheet = 640.0;

  /// Material 3's maximum width for a dialog. Flutter does not apply this on
  /// its own, so a dialog with long content stretches to the window.
  static const dialog = 560.0;
}

/// Extra horizontal padding that centres content of at most [maxWidth] inside
/// [availableWidth].
///
/// Returns 0 whenever the content already fits, so it is additive: callers keep
/// whatever padding they already had and gain centring only on a window wide
/// enough to need it. That leaves phone layouts untouched.
double centeringInset(double availableWidth, {required double maxWidth}) {
  final inset = (availableWidth - maxWidth) / 2;
  return inset > 0 ? inset : 0;
}

extension WindowSizeClassLayout on WindowSizeClass {
  /// Width cap for modal and in-stack bottom sheets.
  ///
  /// Compact keeps today's behaviour exactly — a sheet spans the window, which
  /// is right on a phone — so this only changes what a large window does.
  double get sheetMaxWidth =>
      width == WindowWidthClass.compact ? double.infinity : ContentWidth.sheet;

  /// Width cap for dialogs. Compact is left alone for the same reason.
  double get dialogMaxWidth =>
      width == WindowWidthClass.compact ? double.infinity : ContentWidth.dialog;
}
