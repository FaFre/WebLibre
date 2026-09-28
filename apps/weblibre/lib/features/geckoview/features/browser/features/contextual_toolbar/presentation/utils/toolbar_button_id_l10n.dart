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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display label and long-press submenu description for [ToolbarButtonId].
extension ToolbarButtonIdL10n on ToolbarButtonId {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      ToolbarButtonId.back => l10n.contextualToolbar_buttonLabelBack,
      ToolbarButtonId.forward => l10n.contextualToolbar_buttonLabelForward,
      ToolbarButtonId.home => l10n.contextualToolbar_buttonLabelHome,
      ToolbarButtonId.history => l10n.contextualToolbar_buttonLabelHistory,
      ToolbarButtonId.bookmarks => l10n.contextualToolbar_buttonLabelBookmarks,
      ToolbarButtonId.bookmarkToggle =>
        l10n.contextualToolbar_buttonLabelBookmarkToggle,
      ToolbarButtonId.share => l10n.contextualToolbar_buttonLabelShare,
      ToolbarButtonId.addTab => l10n.contextualToolbar_buttonLabelAddTab,
      ToolbarButtonId.tabsCount => l10n.contextualToolbar_buttonLabelTabsCount,
      ToolbarButtonId.navigationMenu =>
        l10n.contextualToolbar_buttonLabelNavigationMenu,
      ToolbarButtonId.reload => l10n.contextualToolbar_buttonLabelReload,
      ToolbarButtonId.readerMode =>
        l10n.contextualToolbar_buttonLabelReaderMode,
      ToolbarButtonId.desktop => l10n.contextualToolbar_buttonLabelDesktop,
      ToolbarButtonId.translation =>
        l10n.contextualToolbar_buttonLabelTranslation,
      ToolbarButtonId.findInPage =>
        l10n.contextualToolbar_buttonLabelFindInPage,
      ToolbarButtonId.closeTab => l10n.contextualToolbar_buttonLabelCloseTab,
      ToolbarButtonId.inputUrl => l10n.contextualToolbar_buttonLabelInputUrl,
      ToolbarButtonId.qrScan => l10n.contextualToolbar_buttonLabelQrScan,
      ToolbarButtonId.voiceSearch =>
        l10n.contextualToolbar_buttonLabelVoiceSearch,
      ToolbarButtonId.duplicateTab =>
        l10n.contextualToolbar_buttonLabelDuplicateTab,
      ToolbarButtonId.increaseFont =>
        l10n.contextualToolbar_buttonLabelIncreaseFont,
      ToolbarButtonId.decreaseFont =>
        l10n.contextualToolbar_buttonLabelDecreaseFont,
      ToolbarButtonId.moveToBackground =>
        l10n.contextualToolbar_buttonLabelMoveToBackground,
      ToolbarButtonId.pageUp => l10n.contextualToolbar_buttonLabelPageUp,
      ToolbarButtonId.pageDown => l10n.contextualToolbar_buttonLabelPageDown,
      ToolbarButtonId.font => l10n.contextualToolbar_buttonLabelFont,
      ToolbarButtonId.extensionShortcut =>
        l10n.contextualToolbar_buttonLabelExtensionShortcut,
      ToolbarButtonId.toggleGestures =>
        l10n.contextualToolbar_buttonLabelToggleGestures,
      ToolbarButtonId.hideTabBar =>
        l10n.contextualToolbar_buttonLabelHideTabBar,
      ToolbarButtonId.clearBrowsingData =>
        l10n.contextualToolbar_buttonLabelClearBrowsingData,
      ToolbarButtonId.quit => l10n.contextualToolbar_buttonLabelQuit,
    };
  }

  /// What the button's long-press submenu offers, for the settings search
  /// index and the settings screen's own display. Empty for buttons with no
  /// long-press menu.
  List<String> longPressActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        l10n.contextualToolbar_longPressAddChildTab,
        l10n.contextualToolbar_longPressAddPrivateTab,
        l10n.contextualToolbar_longPressAddIsolatedTab,
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
        l10n.contextualToolbar_actionCloneAsIsolated,
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
