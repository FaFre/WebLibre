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
import 'package:material_color_utilities/material_color_utilities.dart';

class ContainerColorPalette {
  const ContainerColorPalette({
    required this.accentColor,
    required this.onAccentColor,
    required this.containerColor,
    required this.onContainerColor,
    required this.surfaceColor,
    required this.surfaceHighColor,
    required this.outlineColor,
    required this.backgroundColor,
    required this.selectedBackgroundColor,
    required this.borderSide,
    required this.selectedBorderSide,
    required this.foregroundColor,
    required this.selectedForegroundColor,
    required this.badgeBackgroundColor,
    required this.badgeForegroundColor,
    required this.avatarColor,
    required this.selectedAvatarColor,
    required this.avatarBackgroundColor,
    required this.avatarForegroundColor,
  });

  final Color accentColor;
  final Color onAccentColor;
  final Color containerColor;
  final Color onContainerColor;
  final Color surfaceColor;
  final Color surfaceHighColor;
  final Color outlineColor;
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final BorderSide borderSide;
  final BorderSide selectedBorderSide;
  final Color foregroundColor;
  final Color selectedForegroundColor;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;
  final Color avatarColor;
  final Color selectedAvatarColor;
  final Color avatarBackgroundColor;
  final Color avatarForegroundColor;
}

/// Centralized helper for container color display and theming.
///
/// Converts the stored container color into Material 3 roles used
/// consistently across the application. Supports two modes:
///
/// - **Seed mode** (default): the color is treated as a seed and fed through
///   [ColorScheme.fromSeed], yielding an M3-harmonized palette. The actual
///   container background depends on the theme brightness (T90 light / T30
///   dark) — picking a dark seed does not produce a dark container.
/// - **Custom mode** (`useCustomColor: true`): the color is used directly as
///   `primaryContainer`. Accent/outline are derived via HCT tone shifts and
///   on-colors via WCAG contrast. Enables true any-color choice (including
///   black/dark grey) at the cost of strict M3 harmonization.
class ContainerColors {
  ContainerColors._();

  static const double surfaceAlpha = 0.18;
  static const double surfaceHighAlpha = 0.28;
  static const double outlineBorderAlpha = 0.5;

  static ContainerColorPalette palette(
    BuildContext context,
    Color color, {
    bool useCustomColor = false,
  }) {
    final theme = Theme.of(context);
    final appScheme = theme.colorScheme;
    final fullColor = fullOpacity(color);

    final containerColor = useCustomColor
        ? fullColor
        : ColorScheme.fromSeed(
            seedColor: fullColor,
            brightness: theme.brightness,
          ).primaryContainer;
    final accentColor = useCustomColor
        ? _shiftTone(fullColor, theme.brightness)
        : ColorScheme.fromSeed(
            seedColor: fullColor,
            brightness: theme.brightness,
          ).primary;
    final onContainerColor = useCustomColor
        ? _contrastingForeground(containerColor)
        : ColorScheme.fromSeed(
            seedColor: fullColor,
            brightness: theme.brightness,
          ).onPrimaryContainer;
    final onAccentColor = useCustomColor
        ? _contrastingForeground(accentColor)
        : ColorScheme.fromSeed(
            seedColor: fullColor,
            brightness: theme.brightness,
          ).onPrimary;

    final surfaceColor = Color.alphaBlend(
      containerColor.withValues(alpha: surfaceAlpha),
      appScheme.surfaceContainer,
    );
    final surfaceHighColor = Color.alphaBlend(
      containerColor.withValues(alpha: surfaceHighAlpha),
      appScheme.surfaceContainerHighest,
    );
    final outlineColor = accentColor.withValues(alpha: outlineBorderAlpha);

    return ContainerColorPalette(
      accentColor: accentColor,
      onAccentColor: onAccentColor,
      containerColor: containerColor,
      onContainerColor: onContainerColor,
      surfaceColor: surfaceColor,
      surfaceHighColor: surfaceHighColor,
      outlineColor: outlineColor,
      backgroundColor: surfaceColor,
      selectedBackgroundColor: containerColor,
      borderSide: BorderSide(color: outlineColor),
      selectedBorderSide: const BorderSide(color: Colors.transparent),
      foregroundColor: appScheme.onSurfaceVariant,
      selectedForegroundColor: onContainerColor,
      badgeBackgroundColor: accentColor,
      badgeForegroundColor: onAccentColor,
      avatarColor: accentColor,
      selectedAvatarColor: onContainerColor,
      avatarBackgroundColor: surfaceHighColor,
      avatarForegroundColor: accentColor,
    );
  }

  /// Returns the full opacity version of a container color.
  static Color fullOpacity(Color baseColor) {
    return baseColor.withValues(alpha: 1.0);
  }

  /// Shifts the color in HCT to a tone suitable for use as an accent against
  /// the theme surface. Light theme uses T40 (darker); dark theme uses T80
  /// (lighter). Mirrors M3's primary tone targets.
  static Color _shiftTone(Color color, Brightness brightness) {
    final hct = Hct.fromInt(color.toARGB32());
    final targetTone = brightness == Brightness.light ? 40.0 : 80.0;
    return Color(Hct.from(hct.hue, hct.chroma, targetTone).toInt());
  }

  /// Picks whichever of black or white has higher contrast against
  /// [background].
  static Color _contrastingForeground(Color background) {
    final blackContrast = _contrastRatio(background, Colors.black);
    final whiteContrast = _contrastRatio(background, Colors.white);
    return blackContrast >= whiteContrast ? Colors.black : Colors.white;
  }

  static double _contrastRatio(Color a, Color b) {
    final aLuminance = a.computeLuminance();
    final bLuminance = b.computeLuminance();
    final lighter = aLuminance > bLuminance ? aLuminance : bLuminance;
    final darker = aLuminance > bLuminance ? bLuminance : aLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
