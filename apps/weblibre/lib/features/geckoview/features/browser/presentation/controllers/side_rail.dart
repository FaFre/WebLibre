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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

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

/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.
@riverpod
class SideRailDragWidth extends _$SideRailDragWidth {
  var _dragging = false;

  @override
  double? build() {
    ref.listen(
      generalSettingsWithDefaultsProvider.select((s) => s.sideRailWidth),
      (previous, next) {
        if (!_dragging && state == next) {
          state = null;
        }
      },
    );

    return null;
  }

  void update(double width) {
    _dragging = true;
    state = width;
  }

  /// Ends the drag and returns the width to save, or null if there is nothing
  /// to save.
  ///
  /// A release at the width already saved clears immediately: saving an
  /// unchanged value reports nothing back, so waiting for it would hold the
  /// drag width forever and hide any later change to the setting.
  double? end() {
    _dragging = false;

    final width = state;
    if (width == null) return null;

    if (width == ref.read(generalSettingsWithDefaultsProvider).sideRailWidth) {
      state = null;
      return null;
    }
    return width;
  }

  /// Drops the drag without saving, for a save that failed.
  void cancel() {
    _dragging = false;
    state = null;
  }
}

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
