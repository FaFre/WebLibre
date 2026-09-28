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
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
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
      BrowserAction.openInPrivateTab =>
        l10n.browserActions_openInPrivateTabTitle,
      BrowserAction.moveTabToContainer =>
        l10n.browserActions_moveTabToContainerTitle,
      BrowserAction.copyLink => l10n.browserActions_copyLinkTitle,
      BrowserAction.siteSettings => l10n.browserActions_siteSettingsTitle,
      BrowserAction.addToHomeScreen => l10n.browserActions_addToHomeScreenTitle,
      BrowserAction.subscribeToPageFeed =>
        l10n.browserActions_subscribeToPageFeedTitle,
      BrowserAction.showFeeds => l10n.browserActions_showFeedsTitle,
      BrowserAction.showProfiles => l10n.browserActions_showProfilesTitle,
      BrowserAction.showProxySettings =>
        l10n.browserActions_showProxySettingsTitle,
      BrowserAction.showTor => l10n.browserActions_showTorTitle,
      BrowserAction.showSyncSettings =>
        l10n.browserActions_showSyncSettingsTitle,
      BrowserAction.showContentBlockerLists =>
        l10n.browserActions_showContentBlockerListsTitle,
      BrowserAction.showErrorLogs => l10n.browserActions_showErrorLogsTitle,
      BrowserAction.showAbout => l10n.browserActions_showAboutTitle,
      BrowserAction.newContainer => l10n.browserActions_newContainerTitle,
      BrowserAction.newBookmarkFolder =>
        l10n.browserActions_newBookmarkFolderTitle,
      BrowserAction.addFeed => l10n.browserActions_addFeedTitle,
      BrowserAction.newSearchEngine => l10n.browserActions_newSearchEngineTitle,
      BrowserAction.newProfile => l10n.browserActions_newProfileTitle,
      BrowserAction.newProxyProfile => l10n.browserActions_newProxyProfileTitle,
      BrowserAction.backupProfile => l10n.browserActions_backupProfileTitle,
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
      BrowserAction.openInPrivateTab =>
        l10n.browserActions_openInPrivateTabDescription,
      BrowserAction.moveTabToContainer =>
        l10n.browserActions_moveTabToContainerDescription,
      BrowserAction.copyLink => l10n.browserActions_copyLinkDescription,
      BrowserAction.siteSettings => l10n.browserActions_siteSettingsDescription,
      BrowserAction.addToHomeScreen =>
        l10n.browserActions_addToHomeScreenDescription,
      BrowserAction.subscribeToPageFeed =>
        l10n.browserActions_subscribeToPageFeedDescription,
      BrowserAction.showFeeds => l10n.browserActions_showFeedsDescription,
      BrowserAction.showProfiles => l10n.browserActions_showProfilesDescription,
      BrowserAction.showProxySettings =>
        l10n.browserActions_showProxySettingsDescription,
      BrowserAction.showTor => l10n.browserActions_showTorDescription,
      BrowserAction.showSyncSettings =>
        l10n.browserActions_showSyncSettingsDescription,
      BrowserAction.showContentBlockerLists =>
        l10n.browserActions_showContentBlockerListsDescription,
      BrowserAction.showErrorLogs =>
        l10n.browserActions_showErrorLogsDescription,
      BrowserAction.showAbout => l10n.browserActions_showAboutDescription,
      BrowserAction.newContainer => l10n.browserActions_newContainerDescription,
      BrowserAction.newBookmarkFolder =>
        l10n.browserActions_newBookmarkFolderDescription,
      BrowserAction.addFeed => l10n.browserActions_addFeedDescription,
      BrowserAction.newSearchEngine =>
        l10n.browserActions_newSearchEngineDescription,
      BrowserAction.newProfile => l10n.browserActions_newProfileDescription,
      BrowserAction.newProxyProfile =>
        l10n.browserActions_newProxyProfileDescription,
      BrowserAction.backupProfile =>
        l10n.browserActions_backupProfileDescription,
    };
  }

  /// Words the search screen's Actions section also finds this action by,
  /// such as "pwa" for Add to Home Screen. Never displayed.
  ///
  /// Only the actions that section offers have any; the rest return none.
  List<String> keywords(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final message = switch (this) {
      BrowserAction.toggleBookmark =>
        l10n.browserActions_toggleBookmarkKeywords,
      BrowserAction.findInPage => l10n.browserActions_findInPageKeywords,
      BrowserAction.copyLink => l10n.browserActions_copyLinkKeywords,
      BrowserAction.sharePage => l10n.browserActions_sharePageKeywords,
      BrowserAction.toggleReaderMode =>
        l10n.browserActions_toggleReaderModeKeywords,
      BrowserAction.toggleDesktopMode =>
        l10n.browserActions_toggleDesktopModeKeywords,
      BrowserAction.translatePage => l10n.browserActions_translatePageKeywords,
      BrowserAction.siteSettings => l10n.browserActions_siteSettingsKeywords,
      BrowserAction.addToHomeScreen =>
        l10n.browserActions_addToHomeScreenKeywords,
      BrowserAction.subscribeToPageFeed =>
        l10n.browserActions_subscribeToPageFeedKeywords,
      BrowserAction.printPage => l10n.browserActions_printPageKeywords,
      BrowserAction.increaseFontSize =>
        l10n.browserActions_increaseFontSizeKeywords,
      BrowserAction.decreaseFontSize =>
        l10n.browserActions_decreaseFontSizeKeywords,
      BrowserAction.resetFontSize => l10n.browserActions_resetFontSizeKeywords,
      BrowserAction.openInPrivateTab =>
        l10n.browserActions_openInPrivateTabKeywords,
      BrowserAction.moveTabToContainer =>
        l10n.browserActions_moveTabToContainerKeywords,
      BrowserAction.duplicateTab => l10n.browserActions_duplicateTabKeywords,
      BrowserAction.togglePinTab => l10n.browserActions_togglePinTabKeywords,
      BrowserAction.closeTab => l10n.browserActions_closeTabKeywords,
      BrowserAction.reopenClosedTab =>
        l10n.browserActions_reopenClosedTabKeywords,
      BrowserAction.showHistory => l10n.browserActions_showHistoryKeywords,
      BrowserAction.showBookmarks => l10n.browserActions_showBookmarksKeywords,
      BrowserAction.showDownloads => l10n.browserActions_showDownloadsKeywords,
      BrowserAction.showTabView => l10n.browserActions_showTabViewKeywords,
      BrowserAction.showContainers =>
        l10n.browserActions_showContainersKeywords,
      BrowserAction.showFeeds => l10n.browserActions_showFeedsKeywords,
      BrowserAction.showProfiles => l10n.browserActions_showProfilesKeywords,
      BrowserAction.showProxySettings =>
        l10n.browserActions_showProxySettingsKeywords,
      BrowserAction.showTor => l10n.browserActions_showTorKeywords,
      BrowserAction.showSyncSettings =>
        l10n.browserActions_showSyncSettingsKeywords,
      BrowserAction.showAddons => l10n.browserActions_showAddonsKeywords,
      BrowserAction.showContentBlockerLists =>
        l10n.browserActions_showContentBlockerListsKeywords,
      BrowserAction.openSettings => l10n.browserActions_openSettingsKeywords,
      BrowserAction.showKeyboardShortcuts =>
        l10n.browserActions_showKeyboardShortcutsKeywords,
      BrowserAction.showErrorLogs => l10n.browserActions_showErrorLogsKeywords,
      BrowserAction.showAbout => l10n.browserActions_showAboutKeywords,
      BrowserAction.newContainer => l10n.browserActions_newContainerKeywords,
      BrowserAction.newBookmarkFolder =>
        l10n.browserActions_newBookmarkFolderKeywords,
      BrowserAction.addFeed => l10n.browserActions_addFeedKeywords,
      BrowserAction.newSearchEngine =>
        l10n.browserActions_newSearchEngineKeywords,
      BrowserAction.newProfile => l10n.browserActions_newProfileKeywords,
      BrowserAction.newProxyProfile =>
        l10n.browserActions_newProxyProfileKeywords,
      BrowserAction.backupProfile => l10n.browserActions_backupProfileKeywords,
      BrowserAction.clearBrowsingData =>
        l10n.browserActions_clearBrowsingDataKeywords,
      _ => null,
    };

    return message == null ? const [] : settingsKeywords(message);
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
      BrowserActionCategory.create => l10n.browserActions_categoryCreate,
      BrowserActionCategory.app => l10n.browserActions_categoryApp,
    };
  }
}
