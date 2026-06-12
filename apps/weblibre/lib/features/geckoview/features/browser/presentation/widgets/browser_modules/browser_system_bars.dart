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
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Tints the status-bar (top) and navigation-bar (bottom) inset regions with
/// the active container's surface color, mirroring how the tab bar
/// ([BrowserBottomAppBar]) tints itself, and drives the system bar icon
/// brightness so the icons stay legible against the tint.
///
/// The app runs edge-to-edge, so on modern Android the native
/// `statusBarColor` / `navigationBarColor` window attributes are ignored — the
/// system bars are transparent and content draws behind them. The inset
/// regions are therefore filled in Flutter, and only the icon brightness is
/// forwarded to the platform through [SystemUiOverlayStyle].
///
/// Designed to be placed as a full-bleed ([Positioned.fill]) layer in the
/// browser [Stack], above the browser content but below the toolbars. The tab
/// bar's safe-area padding is transparent, so the bottom strip shows through
/// behind a visible bottom toolbar and remains visible when it is hidden.
class BrowserSystemBars extends HookConsumerWidget {
  final double topInset;
  final double bottomInset;

  const BrowserSystemBars({
    super.key,
    required this.topInset,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedTabId = ref.watch(selectedTabProvider);

    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showContainerUi),
    );
    final containerColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.color),
    );
    final useCustomColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.metadata.useCustomColor ?? false),
    );

    final effectiveContainerColor = (showContainerUi && containerColor != null)
        ? containerColor
        : null;
    final palette = effectiveContainerColor != null
        ? ContainerColors.palette(
            context,
            effectiveContainerColor,
            useCustomColor: useCustomColor,
          )
        : null;

    // Mirror the tab bar's surfaceContainer fallback so the inset regions stay
    // visually attached to the toolbar even when no container is active.
    final tintColor = palette?.surfaceColor ?? colorScheme.surfaceContainer;

    // Icons must contrast with whatever fills the inset region.
    final iconBrightness =
        ThemeData.estimateBrightnessForColor(tintColor) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return IgnorePointer(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: iconBrightness,
          systemNavigationBarIconBrightness: iconBrightness,
          // iOS reports the bar's own brightness rather than the icons'.
          statusBarBrightness: iconBrightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: ColoredBox(color: tintColor),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bottomInset,
              child: ColoredBox(color: tintColor),
            ),
          ],
        ),
      ),
    );
  }
}
