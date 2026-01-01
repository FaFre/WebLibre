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
import 'package:flutter/material.dart';

/// Centralized helper for container color display and theming.
///
/// This class handles the conversion of stored container colors (full opacity)
/// to their display variants (with transparency) for consistent appearance
/// across the application.
class ContainerColors {
  ContainerColors._();

  /// Default alpha value for container color display (33% opacity)
  static const double defaultAlpha = 0.33;

  /// Returns the display color for container chips and backgrounds.
  ///
  /// Applies semi-transparent overlay that works well for backgrounds
  /// while maintaining color distinction between containers.
  ///
  /// [baseColor] The stored container color (typically full opacity)
  static Color forChip(Color baseColor) {
    return baseColor.withValues(alpha: defaultAlpha);
  }

  /// Returns the display color for container app bar backgrounds.
  ///
  /// Uses the same transparency as chips for visual consistency.
  ///
  /// [baseColor] The stored container color (typically full opacity)
  static Color forAppBar(Color baseColor) {
    return baseColor.withValues(alpha: defaultAlpha);
  }

  /// Returns the display color with theme-aware blending.
  ///
  /// Uses Material Design's color blending algorithm for proper color mixing
  /// with the surface color, ensuring better visual appearance across themes.
  ///
  /// [baseColor] The stored container color (typically full opacity)
  /// [surface] The surface color to blend with (typically from theme)
  static Color forSurface(Color baseColor, Color surface) {
    return Color.alphaBlend(
      baseColor.withValues(alpha: defaultAlpha),
      surface,
    );
  }

  /// Returns the preview color showing how the color will appear in the UI.
  ///
  /// This is useful in color pickers to show users the actual appearance
  /// before they confirm their selection.
  ///
  /// [baseColor] The color being previewed
  static Color preview(Color baseColor) {
    return baseColor.withValues(alpha: defaultAlpha);
  }

  /// Returns the full opacity version of a container color.
  ///
  /// Useful when you need the original color for comparison or display
  /// in contexts where full opacity is needed.
  ///
  /// [baseColor] The color to ensure has full opacity
  static Color fullOpacity(Color baseColor) {
    return baseColor.withValues(alpha: 1.0);
  }
}
