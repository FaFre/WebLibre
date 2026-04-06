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

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors._({
    required this.seedColor,
    required this.privateTabPurple,
    required this.privateTabBackground,
    required this.privateTabForeground,
    required this.privateSelectionOverlay,
    required this.isolatedTabTeal,
    required this.isolatedTabBackground,
    required this.isolatedTabForeground,
    required this.isolatedSelectionOverlay,
    required this.torPurple,
    required this.torActiveGreen,
    required this.torBackgroundGrey,
    required this.warningAmber,
    required this.auraPurple,
    required this.auraGold,
    required this.auraShadow,
    required this.auraShadowHighlight,
    required this.auraTint,
    required this.brandLink,
  });

  final Color seedColor;
  final Color privateTabPurple;
  final Color privateTabBackground;
  final Color privateTabForeground;
  final Color privateSelectionOverlay;
  final Color isolatedTabTeal;
  final Color isolatedTabBackground;
  final Color isolatedTabForeground;
  final Color isolatedSelectionOverlay;
  final Color torPurple;
  final Color torActiveGreen;
  final Color torBackgroundGrey;
  final Color warningAmber;
  final Color auraPurple;
  final Color auraGold;
  final Color auraShadow;
  final Color auraShadowHighlight;
  final Color auraTint;
  final Color brandLink;

  /// Brand colors derived from the logo (constant across themes).
  static const brandPurple = Color(0xFF9C83F8);
  static const brandYellow = Color(0xFFFBDC6B);
  static const brandGrey = Color(0xFFA7A7A7);

  static const light = AppColors._(
    seedColor: Color(0xFF167C80),
    privateTabPurple: Color(0xFF8000D7),
    privateTabBackground: Color(0xFFF3E5F5),
    privateTabForeground: Color(0xFF4A0072),
    privateSelectionOverlay: Color(0x648000D7),
    isolatedTabTeal: Color(0xFF00897B),
    isolatedTabBackground: Color(0xFFE0F2F1),
    isolatedTabForeground: Color(0xFF004D40),
    isolatedSelectionOverlay: Color(0x6400897B),
    torPurple: Color(0xFF7D4698),
    torActiveGreen: Color(0xFF68B030),
    torBackgroundGrey: Color(0xFFECEFF1),
    warningAmber: Color(0xFFFFA000),
    // Aura: brand colors lightened toward white
    auraPurple: Color(0xFFE0D6FC),
    auraGold: Color(0xFFFDF1D6),
    auraShadow: Color(0xFFEDEDF0),
    auraShadowHighlight: Color(0xFFE2E2E7),
    auraTint: Color(0xFFFFFFFF),
    brandLink: Color(0xFF7A5AF0),
  );

  static const dark = AppColors._(
    seedColor: Color(0xFF167C80),
    privateTabPurple: Color(0xFF8000D7),
    privateTabBackground: Color(0xFF25003E),
    privateTabForeground: Color(0xFFFFFFFF),
    privateSelectionOverlay: Color(0x648000D7),
    isolatedTabTeal: Color(0xFF00897B),
    isolatedTabBackground: Color(0xFF003D36),
    isolatedTabForeground: Color(0xFFFFFFFF),
    isolatedSelectionOverlay: Color(0x6400897B),
    torPurple: Color(0xFF7D4698),
    torActiveGreen: Color(0xFF68B030),
    torBackgroundGrey: Color(0xFF333A41),
    warningAmber: Color(0xFFFFA000),
    // Aura: brand colors darkened toward black
    auraPurple: Color(0xFF2C2543),
    auraGold: Color(0xFF3C3827),
    auraShadow: Color(0xFF222224),
    auraShadowHighlight: Color(0xFF2D2D31),
    auraTint: Color(0xFF000000),
    brandLink: Color(0xFFFBDC6B),
  );

  @override
  AppColors copyWith({
    Color? seedColor,
    Color? privateTabPurple,
    Color? privateTabBackground,
    Color? privateTabForeground,
    Color? privateSelectionOverlay,
    Color? isolatedTabTeal,
    Color? isolatedTabBackground,
    Color? isolatedTabForeground,
    Color? isolatedSelectionOverlay,
    Color? torPurple,
    Color? torActiveGreen,
    Color? torBackgroundGrey,
    Color? warningAmber,
    Color? auraPurple,
    Color? auraGold,
    Color? auraShadow,
    Color? auraShadowHighlight,
    Color? auraTint,
    Color? brandLink,
  }) {
    return AppColors._(
      seedColor: seedColor ?? this.seedColor,
      privateTabPurple: privateTabPurple ?? this.privateTabPurple,
      privateTabBackground: privateTabBackground ?? this.privateTabBackground,
      privateTabForeground: privateTabForeground ?? this.privateTabForeground,
      privateSelectionOverlay:
          privateSelectionOverlay ?? this.privateSelectionOverlay,
      isolatedTabTeal: isolatedTabTeal ?? this.isolatedTabTeal,
      isolatedTabBackground:
          isolatedTabBackground ?? this.isolatedTabBackground,
      isolatedTabForeground:
          isolatedTabForeground ?? this.isolatedTabForeground,
      isolatedSelectionOverlay:
          isolatedSelectionOverlay ?? this.isolatedSelectionOverlay,
      torPurple: torPurple ?? this.torPurple,
      torActiveGreen: torActiveGreen ?? this.torActiveGreen,
      torBackgroundGrey: torBackgroundGrey ?? this.torBackgroundGrey,
      warningAmber: warningAmber ?? this.warningAmber,
      auraPurple: auraPurple ?? this.auraPurple,
      auraGold: auraGold ?? this.auraGold,
      auraShadow: auraShadow ?? this.auraShadow,
      auraShadowHighlight: auraShadowHighlight ?? this.auraShadowHighlight,
      auraTint: auraTint ?? this.auraTint,
      brandLink: brandLink ?? this.brandLink,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors._(
      seedColor: Color.lerp(seedColor, other.seedColor, t)!,
      privateTabPurple: Color.lerp(
        privateTabPurple,
        other.privateTabPurple,
        t,
      )!,
      privateTabBackground: Color.lerp(
        privateTabBackground,
        other.privateTabBackground,
        t,
      )!,
      privateTabForeground: Color.lerp(
        privateTabForeground,
        other.privateTabForeground,
        t,
      )!,
      privateSelectionOverlay: Color.lerp(
        privateSelectionOverlay,
        other.privateSelectionOverlay,
        t,
      )!,
      isolatedTabTeal: Color.lerp(isolatedTabTeal, other.isolatedTabTeal, t)!,
      isolatedTabBackground: Color.lerp(
        isolatedTabBackground,
        other.isolatedTabBackground,
        t,
      )!,
      isolatedTabForeground: Color.lerp(
        isolatedTabForeground,
        other.isolatedTabForeground,
        t,
      )!,
      isolatedSelectionOverlay: Color.lerp(
        isolatedSelectionOverlay,
        other.isolatedSelectionOverlay,
        t,
      )!,
      torPurple: Color.lerp(torPurple, other.torPurple, t)!,
      torActiveGreen: Color.lerp(torActiveGreen, other.torActiveGreen, t)!,
      torBackgroundGrey: Color.lerp(
        torBackgroundGrey,
        other.torBackgroundGrey,
        t,
      )!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      auraPurple: Color.lerp(auraPurple, other.auraPurple, t)!,
      auraGold: Color.lerp(auraGold, other.auraGold, t)!,
      auraShadow: Color.lerp(auraShadow, other.auraShadow, t)!,
      auraShadowHighlight: Color.lerp(
        auraShadowHighlight,
        other.auraShadowHighlight,
        t,
      )!,
      auraTint: Color.lerp(auraTint, other.auraTint, t)!,
      brandLink: Color.lerp(brandLink, other.brandLink, t)!,
    );
  }

  /// Get AppColors from the current theme
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ??
        switch (Theme.of(context).brightness) {
          Brightness.dark => dark,
          Brightness.light => light,
        };
  }
}
