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
    this.seedColor = const Color(0xFF167C80),
    this.privateTabPurple = const Color(0xFF8000D7),
    this.privateTabBackground = const Color(0xFF25003E),
    this.privateTabForeground = const Color(0xFFFFFFFF),
    this.privateSelectionOverlay = const Color(0x648000D7),
    this.torPurple = const Color(0xFF7D4698),
    this.torActiveGreen = const Color(0xFF68B030),
    this.torBackgroundGrey = const Color(0xFF333A41),
    this.warningAmber = const Color(0xFFFFA000),
  });

  final Color seedColor;
  final Color privateTabPurple;
  final Color privateTabBackground;
  final Color privateTabForeground;
  final Color privateSelectionOverlay;
  final Color torPurple;
  final Color torActiveGreen;
  final Color torBackgroundGrey;
  final Color warningAmber;

  static const light = AppColors._();
  static const dark = AppColors._();

  @override
  AppColors copyWith({
    Color? seedColor,
    Color? privateTabPurple,
    Color? privateTabBackground,
    Color? privateTabForeground,
    Color? privateSelectionOverlay,
    Color? torPurple,
    Color? torActiveGreen,
    Color? torBackgroundGrey,
    Color? warningAmber,
  }) {
    return AppColors._(
      seedColor: seedColor ?? this.seedColor,
      privateTabPurple: privateTabPurple ?? this.privateTabPurple,
      privateTabBackground: privateTabBackground ?? this.privateTabBackground,
      privateTabForeground: privateTabForeground ?? this.privateTabForeground,
      privateSelectionOverlay:
          privateSelectionOverlay ?? this.privateSelectionOverlay,
      torPurple: torPurple ?? this.torPurple,
      torActiveGreen: torActiveGreen ?? this.torActiveGreen,
      torBackgroundGrey: torBackgroundGrey ?? this.torBackgroundGrey,
      warningAmber: warningAmber ?? this.warningAmber,
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
      torPurple: Color.lerp(torPurple, other.torPurple, t)!,
      torActiveGreen: Color.lerp(torActiveGreen, other.torActiveGreen, t)!,
      torBackgroundGrey: Color.lerp(
        torBackgroundGrey,
        other.torBackgroundGrey,
        t,
      )!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
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
