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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension VisibilitySwitchL10n on VisibilitySwitch {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      VisibilitySwitch.containers => l10n.visibilitySwitch_containersLabel,
      VisibilitySwitch.isolatedTabs => l10n.visibilitySwitch_isolatedTabsLabel,
      VisibilitySwitch.connections => l10n.visibilitySwitch_connectionsLabel,
      VisibilitySwitch.profiles => l10n.visibilitySwitch_profilesLabel,
      VisibilitySwitch.treeTabs => l10n.visibilitySwitch_treeTabsLabel,
      VisibilitySwitch.layoutAdvanced =>
        l10n.visibilitySwitch_layoutAdvancedLabel,
      VisibilitySwitch.gestures => l10n.visibilitySwitch_gesturesLabel,
      VisibilitySwitch.keyboardCustomization =>
        l10n.visibilitySwitch_keyboardCustomizationLabel,
      VisibilitySwitch.privacyAdvanced =>
        l10n.visibilitySwitch_privacyAdvancedLabel,
      VisibilitySwitch.webappStorage =>
        l10n.visibilitySwitch_webappStorageLabel,
      VisibilitySwitch.ai => l10n.visibilitySwitch_aiLabel,
      VisibilitySwitch.expertDetails =>
        l10n.visibilitySwitch_expertDetailsLabel,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      VisibilitySwitch.containers =>
        l10n.visibilitySwitch_containersDescription,
      VisibilitySwitch.isolatedTabs =>
        l10n.visibilitySwitch_isolatedTabsDescription,
      VisibilitySwitch.connections =>
        l10n.visibilitySwitch_connectionsDescription,
      VisibilitySwitch.profiles => l10n.visibilitySwitch_profilesDescription,
      VisibilitySwitch.treeTabs => l10n.visibilitySwitch_treeTabsDescription,
      VisibilitySwitch.layoutAdvanced =>
        l10n.visibilitySwitch_layoutAdvancedDescription,
      VisibilitySwitch.gestures => l10n.visibilitySwitch_gesturesDescription,
      VisibilitySwitch.keyboardCustomization =>
        l10n.visibilitySwitch_keyboardCustomizationDescription,
      VisibilitySwitch.privacyAdvanced =>
        l10n.visibilitySwitch_privacyAdvancedDescription,
      VisibilitySwitch.webappStorage =>
        l10n.visibilitySwitch_webappStorageDescription,
      VisibilitySwitch.ai => l10n.visibilitySwitch_aiDescription,
      VisibilitySwitch.expertDetails =>
        l10n.visibilitySwitch_expertDetailsDescription,
    };
  }

  IconData get icon => switch (this) {
    VisibilitySwitch.containers => MdiIcons.folderMultipleOutline,
    VisibilitySwitch.isolatedTabs => MdiIcons.shieldHalfFull,
    VisibilitySwitch.connections => MdiIcons.lanConnect,
    VisibilitySwitch.profiles => Icons.people_outline,
    VisibilitySwitch.treeTabs => MdiIcons.fileTreeOutline,
    VisibilitySwitch.layoutAdvanced => MdiIcons.viewDashboardEditOutline,
    VisibilitySwitch.gestures => MdiIcons.gestureSwipe,
    VisibilitySwitch.keyboardCustomization => MdiIcons.keyboardOutline,
    VisibilitySwitch.privacyAdvanced => MdiIcons.shieldLockOutline,
    VisibilitySwitch.webappStorage => Icons.add_to_home_screen,
    VisibilitySwitch.ai => MdiIcons.creation,
    VisibilitySwitch.expertDetails => MdiIcons.tuneVariant,
  };
}
