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
/// This class converts the stored container seed color into Material 3 roles
/// used consistently across the application.
class ContainerColors {
  ContainerColors._();

  static const double surfaceAlpha = 0.18;
  static const double surfaceHighAlpha = 0.28;
  static const double outlineBorderAlpha = 0.5;

  static ContainerColorPalette palette(BuildContext context, Color seedColor) {
    final theme = Theme.of(context);
    final appScheme = theme.colorScheme;
    final containerScheme = ColorScheme.fromSeed(
      seedColor: fullOpacity(seedColor),
      brightness: theme.brightness,
    );
    final surfaceColor = Color.alphaBlend(
      containerScheme.primaryContainer.withValues(alpha: surfaceAlpha),
      appScheme.surfaceContainer,
    );
    final surfaceHighColor = Color.alphaBlend(
      containerScheme.primaryContainer.withValues(alpha: surfaceHighAlpha),
      appScheme.surfaceContainerHighest,
    );
    final outlineColor = containerScheme.primary.withValues(
      alpha: outlineBorderAlpha,
    );

    return ContainerColorPalette(
      accentColor: containerScheme.primary,
      onAccentColor: containerScheme.onPrimary,
      containerColor: containerScheme.primaryContainer,
      onContainerColor: containerScheme.onPrimaryContainer,
      surfaceColor: surfaceColor,
      surfaceHighColor: surfaceHighColor,
      outlineColor: outlineColor,
      backgroundColor: surfaceColor,
      selectedBackgroundColor: containerScheme.primaryContainer,
      borderSide: BorderSide(color: outlineColor),
      selectedBorderSide: const BorderSide(color: Colors.transparent),
      foregroundColor: appScheme.onSurfaceVariant,
      selectedForegroundColor: containerScheme.onPrimaryContainer,
      badgeBackgroundColor: containerScheme.primary,
      badgeForegroundColor: containerScheme.onPrimary,
      avatarColor: containerScheme.primary,
      selectedAvatarColor: containerScheme.onPrimaryContainer,
      avatarBackgroundColor: surfaceHighColor,
      avatarForegroundColor: containerScheme.primary,
    );
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
