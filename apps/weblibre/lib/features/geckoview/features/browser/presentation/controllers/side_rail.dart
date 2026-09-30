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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'side_rail.g.dart';

/// How close to the docked window edge the cursor has to come to reveal an
/// auto-hiding side panel.
const sideRailRevealEdgeWidth = 8.0;

/// Whether a cursor at [dx] in a region [width] wide is at the edge the side
/// panel is docked to.
bool isAtSideRailEdge({
  required double dx,
  required double width,
  required bool railOnLeft,
}) => railOnLeft
    ? dx <= sideRailRevealEdgeWidth
    : dx >= width - sideRailRevealEdgeWidth;

/// Whether the auto-hiding side panel is currently slid in over the page.
@riverpod
class SideRailRevealed extends _$SideRailRevealed {
  @override
  bool build() => false;

  void reveal() {
    if (!state) state = true;
  }

  void hide() {
    if (state) state = false;
  }
}
