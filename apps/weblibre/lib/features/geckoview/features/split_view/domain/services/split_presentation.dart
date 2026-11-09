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
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/painting.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';

/// Split view's layout constants, shared with native through the state.
abstract final class SplitMetrics {
  /// The gap between the panes.
  static const dividerDp = 8.0;

  /// On Automatic (and across a hinge), the split is shown only when two
  /// panes this size fit; below that the other axis is tried, then the
  /// focused page alone. Tuned on devices in Phase 4.
  static const minPaneWidthDp = 280.0;
  static const minPaneHeightDp = 200.0;

  /// With an explicit Side by side or Stacked, the split is shown when two
  /// panes this size fit: small, but still usable, so a portrait phone gets
  /// side by side.
  static const explicitMinPaneWidthDp = 120.0;
  static const explicitMinPaneHeightDp = 100.0;

  /// How small the divider may make a pane once the split is shown: a sliver
  /// parked beside the page the user works in, still a touch target that
  /// brings it back. A release past half of it toward the edge puts that pane
  /// away ("Show only this page") instead.
  static const dragMinPaneWidthDp = 48.0;
  static const dragMinPaneHeightDp = 48.0;
}

/// The smallest panes [layout] is shown with at all.
///
/// Automatic picks what suits the window, so it asks for comfortable panes.
/// An explicit Side by side or Stacked is the user's call, so it is shown
/// down to smaller panes, which works in a phone's portrait width too.
Size splitShowMinPane(SplitLayoutPreference layout) => switch (layout) {
  SplitLayoutPreference.automatic => const Size(
    SplitMetrics.minPaneWidthDp,
    SplitMetrics.minPaneHeightDp,
  ),
  SplitLayoutPreference.sideBySide ||
  SplitLayoutPreference.stacked => const Size(
    SplitMetrics.explicitMinPaneWidthDp,
    SplitMetrics.explicitMinPaneHeightDp,
  ),
};

/// The arrangement that is actually shown, resolved and never stored.
enum SplitMode { sideBySide, stacked, focusedOnly }

/// What `resolveSplitPresentation` decided for the current content size.
class SplitPresentation with FastEquatable {
  final SplitMode mode;

  /// The first pane's share on [mode]'s axis.
  final double ratio;

  final double dividerDp;

  /// False when the divider sits on a hinge.
  final bool draggable;

  SplitPresentation({
    required this.mode,
    required this.ratio,
    this.dividerDp = SplitMetrics.dividerDp,
    this.draggable = true,
  });

  @override
  List<Object?> get hashParameters => [mode, ratio, dividerDp, draggable];
}

/// Resolves how [pair] is shown in a content area of [content] (the platform
/// view's size in dp, after bars, rail, safe areas and keyboard).
///
/// Pure. It never rewrites the preference: only the user does (sheet,
/// divider). Each axis keeps its own ratio. [hinge] is a separating display
/// feature in content-local coordinates, if one crosses the content.
SplitPresentation resolveSplitPresentation({
  required SplitPair pair,
  required Size? content,
  required bool keyboardVisible,
  Rect? hinge,
}) {
  const d = SplitMetrics.dividerDp;
  final minPane = splitShowMinPane(pair.layout);
  final minW = minPane.width;
  final minH = minPane.height;

  final preferredAxis = _preferredAxis(pair.layout, content);

  if (content == null || content.isEmpty || pair.focusedOnly) {
    return SplitPresentation(
      mode: SplitMode.focusedOnly,
      ratio: pair.ratioFor(preferredAxis),
    );
  }

  final w = content.width;
  final h = content.height;

  if (hinge != null) {
    return _resolveAroundHinge(
      pair: pair,
      w: w,
      h: h,
      hinge: hinge,
      keyboardVisible: keyboardVisible,
    );
  }

  bool fits(SplitRatioAxis axis) => switch (axis) {
    SplitRatioAxis.sideBySide => 2 * minW + d <= w && h >= minH,
    SplitRatioAxis.stacked => 2 * minH + d <= h && w >= minW,
  };

  // Typing into a pane a couple of hundred dp tall is poor, and the other
  // page is irrelevant while typing.
  bool blockedByKeyboard(SplitRatioAxis axis) =>
      keyboardVisible && axis == SplitRatioAxis.stacked;

  SplitPresentation shown(SplitRatioAxis axis) => SplitPresentation(
    mode: switch (axis) {
      SplitRatioAxis.sideBySide => SplitMode.sideBySide,
      SplitRatioAxis.stacked => SplitMode.stacked,
    },
    ratio: _clampRatio(
      pair.ratioFor(axis),
      available: (axis == SplitRatioAxis.sideBySide ? w : h) - d,
      minimum: axis == SplitRatioAxis.sideBySide
          ? SplitMetrics.dragMinPaneWidthDp
          : SplitMetrics.dragMinPaneHeightDp,
    ),
  );

  if (blockedByKeyboard(preferredAxis)) {
    return SplitPresentation(
      mode: SplitMode.focusedOnly,
      ratio: pair.ratioFor(preferredAxis),
    );
  }
  if (fits(preferredAxis)) {
    return shown(preferredAxis);
  }

  // Temporarily the other axis, without touching the preference.
  final other = preferredAxis == SplitRatioAxis.sideBySide
      ? SplitRatioAxis.stacked
      : SplitRatioAxis.sideBySide;
  if (!blockedByKeyboard(other) && fits(other)) {
    return shown(other);
  }

  return SplitPresentation(
    mode: SplitMode.focusedOnly,
    ratio: pair.ratioFor(preferredAxis),
  );
}

SplitRatioAxis _preferredAxis(SplitLayoutPreference layout, Size? content) =>
    switch (layout) {
      SplitLayoutPreference.sideBySide => SplitRatioAxis.sideBySide,
      SplitLayoutPreference.stacked => SplitRatioAxis.stacked,
      SplitLayoutPreference.automatic =>
        content == null || content.width >= content.height
            ? SplitRatioAxis.sideBySide
            : SplitRatioAxis.stacked,
    };

/// A pane is never placed across a separating hinge: the hinge's axis is the
/// only one used, the divider is the hinge, and if either side is too small
/// the focused page is shown alone. The preference does not pick the axis
/// here, so the Automatic minimum applies whatever it is.
SplitPresentation _resolveAroundHinge({
  required SplitPair pair,
  required double w,
  required double h,
  required Rect hinge,
  required bool keyboardVisible,
}) {
  const minW = SplitMetrics.minPaneWidthDp;
  const minH = SplitMetrics.minPaneHeightDp;

  // A hinge running top to bottom separates left from right.
  final vertical = hinge.height >= hinge.width;
  final axis = vertical ? SplitRatioAxis.sideBySide : SplitRatioAxis.stacked;

  SplitPresentation alone() => SplitPresentation(
    mode: SplitMode.focusedOnly,
    ratio: pair.ratioFor(axis),
  );

  if (keyboardVisible && axis == SplitRatioAxis.stacked) {
    return alone();
  }

  final length = vertical ? w : h;
  final start = vertical ? hinge.left : hinge.top;
  final end = vertical ? hinge.right : hinge.bottom;
  final thickness = math.max(end - start, SplitMetrics.dividerDp);
  final center = (start + end) / 2;
  final first = center - thickness / 2;
  final second = length - (center + thickness / 2);

  final regionsFit = vertical
      ? first >= minW && second >= minW && h >= minH
      : first >= minH && second >= minH && w >= minW;
  if (!regionsFit) {
    return alone();
  }

  return SplitPresentation(
    mode: vertical ? SplitMode.sideBySide : SplitMode.stacked,
    ratio: first / (length - thickness),
    dividerDp: thickness,
    draggable: false,
  );
}

double _clampRatio(
  double ratio, {
  required double available,
  required double minimum,
}) {
  if (available <= 0) return 0.5;
  final low = math.min(minimum / available, 0.5);
  final high = math.max(1 - minimum / available, 0.5);
  return ratio.clamp(low, high);
}

/// The separating display feature that crosses the browser content, in
/// content-local coordinates, for [resolveSplitPresentation]'s `hinge`.
///
/// Separating means a pane must not span it: a hinge (a physical gap), or a
/// fold while the device is half open. A flat fold and a cutout do not count.
/// [features] and [content] are in window coordinates (logical pixels), as in
/// `MediaQueryData.displayFeatures`. Only a feature that runs across the whole
/// content and lies strictly inside it counts; one along an edge does not
/// divide it.
Rect? separatingHingeInContent({
  required Iterable<DisplayFeature> features,
  required Rect content,
}) {
  for (final feature in features) {
    final separating =
        feature.type == DisplayFeatureType.hinge ||
        (feature.type == DisplayFeatureType.fold &&
            feature.state == DisplayFeatureState.postureHalfOpened);
    if (!separating) continue;

    final bounds = feature.bounds;
    final vertical = bounds.height >= bounds.width;
    final crosses = vertical
        ? bounds.left > content.left &&
              bounds.right < content.right &&
              bounds.top <= content.top &&
              bounds.bottom >= content.bottom
        : bounds.top > content.top &&
              bounds.bottom < content.bottom &&
              bounds.left <= content.left &&
              bounds.right >= content.right;
    if (!crosses) continue;

    return bounds.intersect(content).shift(-content.topLeft);
  }
  return null;
}
