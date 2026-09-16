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
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/design/display_features.dart';

const _unfolded = Size(1000, 800);

MediaQueryData withFeatures(List<DisplayFeature> features, {Size? size}) =>
    MediaQueryData(size: size ?? _unfolded, displayFeatures: features);

/// A horizontal crease across the middle — a foldable in tabletop posture.
DisplayFeature horizontalFold({
  double thickness = 20,
  Size size = _unfolded,
  double? centre,
}) {
  final middle = centre ?? size.height / 2;
  return DisplayFeature(
    bounds: Rect.fromLTRB(
      0,
      middle - thickness / 2,
      size.width,
      middle + thickness / 2,
    ),
    type: DisplayFeatureType.fold,
    state: DisplayFeatureState.postureHalfOpened,
  );
}

/// A vertical hinge down the middle — a foldable in book posture.
DisplayFeature verticalHinge({double thickness = 20, Size size = _unfolded}) {
  final middle = size.width / 2;
  return DisplayFeature(
    bounds: Rect.fromLTRB(
      middle - thickness / 2,
      0,
      middle + thickness / 2,
      size.height,
    ),
    type: DisplayFeatureType.hinge,
    state: DisplayFeatureState.postureHalfOpened,
  );
}

void main() {
  group('preferredAnchorPoint', () {
    test('returns null when there is no display feature', () {
      // Every ordinary phone, tablet and desktop window. Callers pass the null
      // straight through, so Flutter behaves exactly as it did before.
      expect(preferredAnchorPoint(withFeatures(const [])), isNull);
    });

    test('returns null for a flat fold that obstructs nothing', () {
      // An unfolded Galaxy/Pixel Fold still reports its crease, with zero-area
      // bounds and a flat posture. Splitting the window there would be wrong.
      const flat = DisplayFeature(
        bounds: Rect.fromLTRB(500, 0, 500, 800),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      );

      expect(preferredAnchorPoint(withFeatures([flat])), isNull);
    });

    test('picks the lower half of a horizontal fold', () {
      // The half lying flat under the user's hands, where the browser's own
      // bottom bar and sheets already live. Flutter's own default would take
      // the upper half, which on a tabletop foldable is standing up away from
      // the user.
      final anchor = preferredAnchorPoint(withFeatures([horizontalFold()]));

      expect(anchor, isNotNull);
      expect(anchor!.dy, greaterThan(_unfolded.height / 2));
    });

    test('picks the larger half when the fold is off-centre', () {
      // Size beats reachability: a modal squeezed into the smaller half loses
      // content.
      final anchor = preferredAnchorPoint(
        withFeatures([horizontalFold(centre: 600)]),
      );

      expect(anchor, isNotNull);
      expect(
        anchor!.dy,
        lessThan(600),
        reason: 'the taller half is above a fold at y=600',
      );
    });

    test('stays inside one half of a vertical hinge', () {
      final anchor = preferredAnchorPoint(withFeatures([verticalHinge()]));

      expect(anchor, isNotNull);
      // Never on the hinge itself, which is the whole point.
      expect((anchor!.dx - _unfolded.width / 2).abs(), greaterThan(10));
    });

    test('picks the larger half of an off-centre vertical hinge', () {
      const hinge = DisplayFeature(
        bounds: Rect.fromLTRB(300, 0, 320, 800),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );

      final anchor = preferredAnchorPoint(withFeatures([hinge]));

      expect(anchor, isNotNull);
      expect(
        anchor!.dx,
        greaterThan(320),
        reason: 'the wider pane is to the right of a hinge at x=300..320',
      );
    });

    test('the chosen point lands in a real sub-screen', () {
      // The contract Flutter relies on: it selects the sub-screen closest to
      // the anchor, so the anchor has to be inside the one intended.
      for (final feature in [horizontalFold(), verticalHinge()]) {
        final mediaQuery = withFeatures([feature]);
        final anchor = preferredAnchorPoint(mediaQuery)!;

        final subScreens = DisplayFeatureSubScreen.subScreensInBounds(
          Offset.zero & mediaQuery.size,
          DisplayFeatureSubScreen.avoidBounds(mediaQuery),
        );

        expect(
          subScreens.any((screen) => screen.contains(anchor)),
          isTrue,
          reason: 'anchor $anchor for $feature',
        );
      }
    });
  });
}
