/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

int calculateCrossAxisItemCount({
  required double screenWidth,
  required double horizontalPadding,
  required double crossAxisSpacing,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final availableWidth =
      screenWidth - totalHorizontalPadding - crossAxisSpacing;

  final crossAxisCount = availableWidth ~/ 180.0;

  return crossAxisCount;
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
