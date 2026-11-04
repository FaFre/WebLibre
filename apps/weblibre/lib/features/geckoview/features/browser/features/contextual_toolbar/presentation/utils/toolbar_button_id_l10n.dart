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
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display label and long-press submenu description for [ToolbarButtonId].
extension ToolbarButtonIdL10n on ToolbarButtonId {
  /// Named after its [action], so the toolbar settings and the action lists
  /// agree; only a button without one has a name of its own.
  String label(BuildContext context) {
    if (action case final action?) return action.label(context);

    return AppLocalizations.of(
      context,
    ).contextualToolbar_buttonLabelExtensionShortcut;
  }

  /// What the button's long-press submenu offers, for the settings search
  /// index and the settings screen's own display. Empty for buttons with no
  /// long-press menu.
  /// What a long press offers, as [settings] show it: entries of hidden
  /// features (child and isolated tabs) are left out, as in the menus
  /// themselves.
  List<String> longPressActions(
    BuildContext context,
    GeneralSettings settings,
  ) {
    final l10n = AppLocalizations.of(context);
    final childShown = settings.childTabEntryPointsShown;
    final isolatedShown = settings.isolatedTabEntryPointsShown;

    return switch (this) {
      ToolbarButtonId.back => [l10n.contextualToolbar_longPressBackHistoryMenu],
      ToolbarButtonId.forward => [
        l10n.contextualToolbar_longPressForwardHistoryMenu,
      ],
      ToolbarButtonId.bookmarks => [
        l10n.contextualToolbar_actionAddBookmark,
        l10n.contextualToolbar_actionRemoveBookmark,
      ],
      ToolbarButtonId.bookmarkToggle => [
        l10n.contextualToolbar_longPressOpenBookmarks,
      ],
      ToolbarButtonId.addTab || ToolbarButtonId.tabsCount => [
        l10n.contextualToolbar_longPressAddRegularTab,
        if (childShown) l10n.contextualToolbar_longPressAddChildTab,
        l10n.contextualToolbar_longPressAddPrivateTab,
        if (isolatedShown) l10n.contextualToolbar_longPressAddIsolatedTab,
      ],
      ToolbarButtonId.navigationMenu => [
        l10n.contextualToolbar_longPressOpenSettings,
      ],
      ToolbarButtonId.reload => [l10n.contextualToolbar_longPressHardRefresh],
      ToolbarButtonId.translation => [
        l10n.contextualToolbar_longPressShowTranslationOptions,
      ],
      ToolbarButtonId.closeTab => [
        l10n.contextualToolbar_actionCloseOthers,
        l10n.contextualToolbar_actionCloseFromSameHost,
      ],
      ToolbarButtonId.duplicateTab => [
        l10n.contextualToolbar_actionCloneAsRegular,
        l10n.contextualToolbar_actionCloneAsPrivate,
        if (isolatedShown) l10n.contextualToolbar_actionCloneAsIsolated,
      ],
      ToolbarButtonId.pageUp => [l10n.contextualToolbar_longPressScrollToTop],
      ToolbarButtonId.pageDown => [
        l10n.contextualToolbar_longPressScrollToBottom,
      ],
      ToolbarButtonId.extensionShortcut => [
        l10n.contextualToolbar_longPressExtensionsMenu,
      ],
      ToolbarButtonId.quit => [
        l10n.contextualToolbar_longPressQuitWithoutConfirmation,
      ],
      _ => const [],
    };
  }
}
