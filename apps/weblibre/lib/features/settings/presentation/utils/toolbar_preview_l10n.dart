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
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension PreviewDeviceL10n on PreviewDevice {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      PreviewDevice.thisWindow => l10n.settings_previewDeviceThisWindow,
      PreviewDevice.phone => l10n.settings_previewDevicePhone,
      PreviewDevice.phoneLandscape => l10n.settings_previewDevicePhoneLandscape,
      PreviewDevice.largeScreen => l10n.settings_previewDeviceLargeScreen,
    };
  }

  IconData get icon => switch (this) {
    PreviewDevice.thisWindow => Icons.fit_screen_outlined,
    PreviewDevice.phone => Icons.smartphone,
    PreviewDevice.phoneLandscape => Icons.stay_current_landscape,
    PreviewDevice.largeScreen => Icons.desktop_windows_outlined,
  };
}

extension PreviewSampleStateL10n on PreviewSampleState {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      PreviewSampleState.page => l10n.settings_previewStatePage,
      PreviewSampleState.home => l10n.settings_previewStateHome,
      PreviewSampleState.sidePanelCollapsed =>
        l10n.settings_previewStateSidePanelCollapsed,
    };
  }

  IconData get icon => switch (this) {
    PreviewSampleState.page => Icons.article_outlined,
    PreviewSampleState.home => Icons.home_outlined,
    PreviewSampleState.sidePanelCollapsed => Icons.view_sidebar_outlined,
  };
}

extension PreviewStateBlockerL10n on PreviewStateBlocker {
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      PreviewStateBlocker.needsSidePanel =>
        l10n.settings_previewStateNeedsSidePanel,
    };
  }
}

extension LayoutPartL10n on LayoutPart {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      LayoutPart.tabBar => l10n.settings_tabBarSectionTitle,
      LayoutPart.quickTabSwitcher => l10n.settings_quickTabSwitcherSectionTitle,
      LayoutPart.tabChip => l10n.settings_layoutPartTabChips,
      LayoutPart.contextualToolbar =>
        l10n.settings_contextualToolbarSectionTitle,
      LayoutPart.tabView => l10n.settings_tabViewSectionTitle,
      LayoutPart.menu => l10n.settings_menuSectionTitle,
    };
  }
}
