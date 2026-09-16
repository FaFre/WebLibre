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

/// Target width of one tab preview tile. Columns are packed to fit.
const _targetTileWidth = 180.0;

/// Upper bound on columns.
///
/// Purely a packing calculation, an 1800dp window yields ten columns, and a
/// tab preview shrunk to a tenth of a desktop window is no longer a preview of
/// anything. Wider windows get wider tiles instead of more of them.
const _maxCrossAxisCount = 6;

/// Columns that fit in [availableWidth], at least one and at most
/// [_maxCrossAxisCount].
///
/// Callers must pass the width of the *grid*, not of the window: the tab tray
/// is shown both full-screen and inside a width-capped sheet, which can also
/// sit beside a side rail. Measuring the window there over-counts columns and
/// the tiles overflow.
int calculateCrossAxisItemCount({
  required double screenWidth,
  required double horizontalPadding,
  required double crossAxisSpacing,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final availableWidth =
      screenWidth - totalHorizontalPadding - crossAxisSpacing;

  final crossAxisCount = availableWidth ~/ _targetTileWidth;

  return crossAxisCount.clamp(1, _maxCrossAxisCount);
}

Size calculateItemSize({
  required double screenWidth,
  required double childAspectRatio,
  required double horizontalPadding,
  required double mainAxisSpacing,
  required double crossAxisSpacing,
  required int crossAxisCount,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final totalCrossAxisSpacing = crossAxisSpacing * (crossAxisCount - 1);
  final availableWidth =
      screenWidth - totalHorizontalPadding - totalCrossAxisSpacing;
  final itemWidth = availableWidth / crossAxisCount;
  final itemHeight = itemWidth / childAspectRatio;

  return Size(itemWidth, itemHeight + mainAxisSpacing);
}
