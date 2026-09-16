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

/// Where a modal should sit on a device whose screen is split by a hinge or a
/// fold.
///
/// Flutter already keeps dialogs and sheets clear of a display feature: every
/// modal route builds a [DisplayFeatureSubScreen], which divides the window
/// into sub-screens around the obstruction and places the child in one of
/// them. What it does *not* do well is choose which one — with no
/// `anchorPoint` it falls back to the top-left sub-screen in LTR.
///
/// On a foldable held half-open in tabletop posture that is the upper half:
/// the part standing up away from the user, while their hands and the browser's
/// own bottom bar are on the half lying flat. On an asymmetric split it can
/// also pick the smaller half and shrink a sheet for no reason.
///
/// [preferredAnchorPoint] returns a point inside the sub-screen a modal should
/// prefer instead, or null when there is nothing to avoid — in which case
/// callers should pass null through and leave Flutter's own behaviour alone.
///
/// The sub-screens are computed with Flutter's own [DisplayFeatureSubScreen]
/// helpers rather than re-derived here, so the choice cannot disagree with the
/// layout that is actually produced.
Offset? preferredAnchorPoint(MediaQueryData mediaQuery) {
  final avoidBounds = DisplayFeatureSubScreen.avoidBounds(mediaQuery).toList();
  if (avoidBounds.isEmpty) return null;

  final screen = Offset.zero & mediaQuery.size;
  final subScreens = DisplayFeatureSubScreen.subScreensInBounds(
    screen,
    avoidBounds,
  ).toList();

  // One sub-screen means the feature does not actually divide the window (a
  // fold along an edge, say). Nothing to choose between.
  if (subScreens.length < 2) return null;

  var best = subScreens.first;
  for (final candidate in subScreens.skip(1)) {
    if (_isPreferredOver(candidate, best)) {
      best = candidate;
    }
  }

  // Any point inside the winning sub-screen selects it: Flutter picks the
  // sub-screen closest to the anchor, and a rect is at distance zero from its
  // own centre.
  return best.center;
}

/// Whether [candidate] is a better home for a modal than [incumbent].
///
/// Bigger wins, because a modal squeezed into the smaller half loses content.
/// Between halves of the same size — the common case, since a fold is usually
/// down the middle — the lower one wins: on a half-opened foldable that is the
/// half lying flat under the user's hands, and it is also the half the
/// browser's own bottom bar and sheets occupy.
bool _isPreferredOver(Rect candidate, Rect incumbent) {
  final candidateArea = candidate.width * candidate.height;
  final incumbentArea = incumbent.width * incumbent.height;

  // Tolerance rather than equality: the two halves of a fold differ by a
  // fraction of a pixel often enough that an exact test would make the
  // tie-break unreachable.
  if ((candidateArea - incumbentArea).abs() > 1.0) {
    return candidateArea > incumbentArea;
  }

  return candidate.top > incumbent.top;
}
