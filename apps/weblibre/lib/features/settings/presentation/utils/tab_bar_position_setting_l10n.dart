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
import 'package:flutter/widgets.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for [TabBarPositionSetting].
extension TabBarPositionSettingL10n on TabBarPositionSetting {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      TabBarPositionSetting.auto => l10n.settings_tabBarPositionAutoLabel,
      TabBarPositionSetting.top => l10n.settings_tabBarPositionTopLabel,
      TabBarPositionSetting.bottom => l10n.settings_tabBarPositionBottomLabel,
      TabBarPositionSetting.left => l10n.settings_tabBarPositionLeftLabel,
      TabBarPositionSetting.right => l10n.settings_tabBarPositionRightLabel,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      TabBarPositionSetting.auto => l10n.settings_tabBarPositionAutoDescription,
      TabBarPositionSetting.top => l10n.settings_tabBarPositionTopDescription,
      TabBarPositionSetting.bottom =>
        l10n.settings_tabBarPositionBottomDescription,
      TabBarPositionSetting.left => l10n.settings_tabBarPositionLeftDescription,
      TabBarPositionSetting.right =>
        l10n.settings_tabBarPositionRightDescription,
    };
  }
}

/// Display labels for the resolved [TabBarPosition] — the same words as the
/// matching [TabBarPositionSetting], so "Automatic (currently: Bottom)" names
/// an option the user can see in the list.
extension TabBarPositionL10n on TabBarPosition {
  String label(BuildContext context) => switch (this) {
    TabBarPosition.top => TabBarPositionSetting.top,
    TabBarPosition.bottom => TabBarPositionSetting.bottom,
    TabBarPosition.left => TabBarPositionSetting.left,
    TabBarPosition.right => TabBarPositionSetting.right,
  }.label(context);
}
