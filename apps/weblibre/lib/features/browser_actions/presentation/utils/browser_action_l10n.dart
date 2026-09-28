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
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display strings for [BrowserAction].
extension BrowserActionL10n on BrowserAction {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BrowserAction.focusAddressBar => l10n.browserActions_focusAddressBarTitle,
      BrowserAction.back => l10n.browserActions_backTitle,
      BrowserAction.forward => l10n.browserActions_forwardTitle,
      BrowserAction.reload => l10n.browserActions_reloadTitle,
      BrowserAction.hardReload => l10n.browserActions_hardReloadTitle,
      BrowserAction.scrollTop => l10n.browserActions_scrollTopTitle,
      BrowserAction.scrollBottom => l10n.browserActions_scrollBottomTitle,
      BrowserAction.pageUp => l10n.browserActions_pageUpTitle,
      BrowserAction.pageDown => l10n.browserActions_pageDownTitle,
      BrowserAction.newTab => l10n.browserActions_newTabTitle,
      BrowserAction.newPrivateTab => l10n.browserActions_newPrivateTabTitle,
      BrowserAction.closeTab => l10n.browserActions_closeTabTitle,
      BrowserAction.reopenClosedTab => l10n.browserActions_reopenClosedTabTitle,
      BrowserAction.duplicateTab => l10n.browserActions_duplicateTabTitle,
      BrowserAction.nextTab => l10n.browserActions_nextTabTitle,
      BrowserAction.previousTab => l10n.browserActions_previousTabTitle,
      BrowserAction.lastUsedTab => l10n.browserActions_lastUsedTabTitle,
      BrowserAction.selectTab1 => l10n.browserActions_selectTab1Title,
      BrowserAction.selectTab2 => l10n.browserActions_selectTab2Title,
      BrowserAction.selectTab3 => l10n.browserActions_selectTab3Title,
      BrowserAction.selectTab4 => l10n.browserActions_selectTab4Title,
      BrowserAction.selectTab5 => l10n.browserActions_selectTab5Title,
      BrowserAction.selectTab6 => l10n.browserActions_selectTab6Title,
      BrowserAction.selectTab7 => l10n.browserActions_selectTab7Title,
      BrowserAction.selectTab8 => l10n.browserActions_selectTab8Title,
      BrowserAction.selectLastTab => l10n.browserActions_selectLastTabTitle,
      BrowserAction.togglePinTab => l10n.browserActions_togglePinTabTitle,
      BrowserAction.moveTabBackward => l10n.browserActions_moveTabBackwardTitle,
      BrowserAction.moveTabForward => l10n.browserActions_moveTabForwardTitle,
      BrowserAction.moveTabToStart => l10n.browserActions_moveTabToStartTitle,
      BrowserAction.moveTabToEnd => l10n.browserActions_moveTabToEndTitle,
      BrowserAction.nextContainer => l10n.browserActions_nextContainerTitle,
      BrowserAction.previousContainer =>
        l10n.browserActions_previousContainerTitle,
      BrowserAction.toggleReaderMode =>
        l10n.browserActions_toggleReaderModeTitle,
      BrowserAction.toggleDesktopMode =>
        l10n.browserActions_toggleDesktopModeTitle,
      BrowserAction.findInPage => l10n.browserActions_findInPageTitle,
      BrowserAction.findNext => l10n.browserActions_findNextTitle,
      BrowserAction.findPrevious => l10n.browserActions_findPreviousTitle,
      BrowserAction.increaseFontSize =>
        l10n.browserActions_increaseFontSizeTitle,
      BrowserAction.decreaseFontSize =>
        l10n.browserActions_decreaseFontSizeTitle,
      BrowserAction.resetFontSize => l10n.browserActions_resetFontSizeTitle,
      BrowserAction.toggleBookmark => l10n.browserActions_toggleBookmarkTitle,
      BrowserAction.sharePage => l10n.browserActions_sharePageTitle,
      BrowserAction.translatePage => l10n.browserActions_translatePageTitle,
      BrowserAction.printPage => l10n.browserActions_printPageTitle,
      BrowserAction.showHome => l10n.browserActions_showHomeTitle,
      BrowserAction.showHistory => l10n.browserActions_showHistoryTitle,
      BrowserAction.showBookmarks => l10n.browserActions_showBookmarksTitle,
      BrowserAction.showContainers => l10n.browserActions_showContainersTitle,
      BrowserAction.showTabView => l10n.browserActions_showTabViewTitle,
      BrowserAction.showDownloads => l10n.browserActions_showDownloadsTitle,
      BrowserAction.showAddons => l10n.browserActions_showAddonsTitle,
      BrowserAction.openSettings => l10n.browserActions_openSettingsTitle,
      BrowserAction.showKeyboardShortcuts =>
        l10n.browserActions_showKeyboardShortcutsTitle,
      BrowserAction.toggleTabBar => l10n.browserActions_toggleTabBarTitle,
      BrowserAction.clearBrowsingData =>
        l10n.browserActions_clearBrowsingDataTitle,
      BrowserAction.moveToBackground =>
        l10n.browserActions_moveToBackgroundTitle,
      BrowserAction.quitBrowser => l10n.browserActions_quitBrowserTitle,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BrowserAction.focusAddressBar =>
        l10n.browserActions_focusAddressBarDescription,
      BrowserAction.back => l10n.browserActions_backDescription,
      BrowserAction.forward => l10n.browserActions_forwardDescription,
      BrowserAction.reload => l10n.browserActions_reloadDescription,
      BrowserAction.hardReload => l10n.browserActions_hardReloadDescription,
      BrowserAction.scrollTop => l10n.browserActions_scrollTopDescription,
      BrowserAction.scrollBottom => l10n.browserActions_scrollBottomDescription,
      BrowserAction.pageUp => l10n.browserActions_pageUpDescription,
      BrowserAction.pageDown => l10n.browserActions_pageDownDescription,
      BrowserAction.newTab => l10n.browserActions_newTabDescription,
      BrowserAction.newPrivateTab =>
        l10n.browserActions_newPrivateTabDescription,
      BrowserAction.closeTab => l10n.browserActions_closeTabDescription,
      BrowserAction.reopenClosedTab =>
        l10n.browserActions_reopenClosedTabDescription,
      BrowserAction.duplicateTab => l10n.browserActions_duplicateTabDescription,
      BrowserAction.nextTab => l10n.browserActions_nextTabDescription,
      BrowserAction.previousTab => l10n.browserActions_previousTabDescription,
      BrowserAction.lastUsedTab => l10n.browserActions_lastUsedTabDescription,
      BrowserAction.selectTab1 => l10n.browserActions_selectTab1Description,
      BrowserAction.selectTab2 => l10n.browserActions_selectTab2Description,
      BrowserAction.selectTab3 => l10n.browserActions_selectTab3Description,
      BrowserAction.selectTab4 => l10n.browserActions_selectTab4Description,
      BrowserAction.selectTab5 => l10n.browserActions_selectTab5Description,
      BrowserAction.selectTab6 => l10n.browserActions_selectTab6Description,
      BrowserAction.selectTab7 => l10n.browserActions_selectTab7Description,
      BrowserAction.selectTab8 => l10n.browserActions_selectTab8Description,
      BrowserAction.selectLastTab =>
        l10n.browserActions_selectLastTabDescription,
      BrowserAction.togglePinTab => l10n.browserActions_togglePinTabDescription,
      BrowserAction.moveTabBackward =>
        l10n.browserActions_moveTabBackwardDescription,
      BrowserAction.moveTabForward =>
        l10n.browserActions_moveTabForwardDescription,
      BrowserAction.moveTabToStart =>
        l10n.browserActions_moveTabToStartDescription,
      BrowserAction.moveTabToEnd => l10n.browserActions_moveTabToEndDescription,
      BrowserAction.nextContainer =>
        l10n.browserActions_nextContainerDescription,
      BrowserAction.previousContainer =>
        l10n.browserActions_previousContainerDescription,
      BrowserAction.toggleReaderMode =>
        l10n.browserActions_toggleReaderModeDescription,
      BrowserAction.toggleDesktopMode =>
        l10n.browserActions_toggleDesktopModeDescription,
      BrowserAction.findInPage => l10n.browserActions_findInPageDescription,
      BrowserAction.findNext => l10n.browserActions_findNextDescription,
      BrowserAction.findPrevious => l10n.browserActions_findPreviousDescription,
      BrowserAction.increaseFontSize =>
        l10n.browserActions_increaseFontSizeDescription,
      BrowserAction.decreaseFontSize =>
        l10n.browserActions_decreaseFontSizeDescription,
      BrowserAction.resetFontSize =>
        l10n.browserActions_resetFontSizeDescription,
      BrowserAction.toggleBookmark =>
        l10n.browserActions_toggleBookmarkDescription,
      BrowserAction.sharePage => l10n.browserActions_sharePageDescription,
      BrowserAction.translatePage =>
        l10n.browserActions_translatePageDescription,
      BrowserAction.printPage => l10n.browserActions_printPageDescription,
      BrowserAction.showHome => l10n.browserActions_showHomeDescription,
      BrowserAction.showHistory => l10n.browserActions_showHistoryDescription,
      BrowserAction.showBookmarks =>
        l10n.browserActions_showBookmarksDescription,
      BrowserAction.showContainers =>
        l10n.browserActions_showContainersDescription,
      BrowserAction.showTabView => l10n.browserActions_showTabViewDescription,
      BrowserAction.showDownloads =>
        l10n.browserActions_showDownloadsDescription,
      BrowserAction.showAddons => l10n.browserActions_showAddonsDescription,
      BrowserAction.openSettings => l10n.browserActions_openSettingsDescription,
      BrowserAction.showKeyboardShortcuts =>
        l10n.browserActions_showKeyboardShortcutsDescription,
      BrowserAction.toggleTabBar => l10n.browserActions_toggleTabBarDescription,
      BrowserAction.clearBrowsingData =>
        l10n.browserActions_clearBrowsingDataDescription,
      BrowserAction.moveToBackground =>
        l10n.browserActions_moveToBackgroundDescription,
      BrowserAction.quitBrowser => l10n.browserActions_quitBrowserDescription,
    };
  }
}

/// Display labels for [BrowserActionCategory].
extension BrowserActionCategoryL10n on BrowserActionCategory {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BrowserActionCategory.navigation =>
        l10n.browserActions_categoryNavigation,
      BrowserActionCategory.scrolling => l10n.browserActions_categoryScrolling,
      BrowserActionCategory.tabs => l10n.browserActions_categoryTabs,
      BrowserActionCategory.page => l10n.browserActions_categoryPage,
      BrowserActionCategory.open => l10n.browserActions_categoryOpen,
      BrowserActionCategory.app => l10n.browserActions_categoryApp,
    };
  }
}
