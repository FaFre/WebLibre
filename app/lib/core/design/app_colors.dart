import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors._({
    this.seedColor = const Color(0xFF167C80),
    this.privateTabPurple = const Color(0xFF8000D7),
    this.privateTabBackground = const Color(0xFF25003E),
    this.privateSelectionOverlay = const Color(0x648000D7),
    this.torPurple = const Color(0xFF7D4698),
    this.torActiveGreen = const Color(0xFF68B030),
    this.torBackgroundGrey = const Color(0xFF333A41),
  });

  final Color seedColor;
  final Color privateTabPurple;
  final Color privateTabBackground;
  final Color privateSelectionOverlay;
  final Color torPurple;
  final Color torActiveGreen;
  final Color torBackgroundGrey;

  static const light = AppColors._();
  static const dark = AppColors._();

  @override
  AppColors copyWith({
    Color? seedColor,
    Color? privateTabPurple,
    Color? privateTabBackground,
    Color? privateSelectionOverlay,
    Color? torPurple,
    Color? torActiveGreen,
    Color? torBackgroundGrey,
  }) {
    return AppColors._(
      seedColor: seedColor ?? this.seedColor,
      privateTabPurple: privateTabPurple ?? this.privateTabPurple,
      privateTabBackground: privateTabBackground ?? this.privateTabBackground,
      privateSelectionOverlay:
          privateSelectionOverlay ?? this.privateSelectionOverlay,
      torPurple: torPurple ?? this.torPurple,
      torActiveGreen: torActiveGreen ?? this.torActiveGreen,
      torBackgroundGrey: torBackgroundGrey ?? this.torBackgroundGrey,
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
