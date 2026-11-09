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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

extension BrowserActionPolicy on BrowserAction {
  /// The feature that owns this action: a binding to it asks to show that
  /// feature while it is hidden. Exhaustive, so a new action does not compile
  /// until it has an owner.
  FeatureId get owningFeature => switch (this) {
    BrowserAction.focusAddressBar ||
    BrowserAction.back ||
    BrowserAction.forward ||
    BrowserAction.reload ||
    BrowserAction.hardReload ||
    BrowserAction.scrollTop ||
    BrowserAction.scrollBottom ||
    BrowserAction.pageUp ||
    BrowserAction.pageDown ||
    BrowserAction.toggleDesktopMode ||
    BrowserAction.findInPage ||
    BrowserAction.findNext ||
    BrowserAction.findPrevious ||
    BrowserAction.showBrowserMenu ||
    BrowserAction.openSettings ||
    BrowserAction.showAbout ||
    BrowserAction.moveToBackground ||
    BrowserAction.quitBrowser => FeatureId.coreBrowsing,
    BrowserAction.newTab ||
    BrowserAction.newPrivateTab ||
    BrowserAction.closeTab ||
    BrowserAction.reopenClosedTab ||
    BrowserAction.duplicateTab ||
    BrowserAction.nextTab ||
    BrowserAction.previousTab ||
    BrowserAction.lastUsedTab ||
    BrowserAction.selectLastTab ||
    BrowserAction.togglePinTab ||
    BrowserAction.moveTabBackward ||
    BrowserAction.moveTabForward ||
    BrowserAction.moveTabToStart ||
    BrowserAction.moveTabToEnd ||
    BrowserAction.openInPrivateTab ||
    BrowserAction.showTabView ||
    BrowserAction.selectTab1 ||
    BrowserAction.selectTab2 ||
    BrowserAction.selectTab3 ||
    BrowserAction.selectTab4 ||
    BrowserAction.selectTab5 ||
    BrowserAction.selectTab6 ||
    BrowserAction.selectTab7 ||
    BrowserAction.selectTab8 => FeatureId.coreTabs,
    BrowserAction.voiceSearch => FeatureId.searchDefaultProvider,
    BrowserAction.toggleBookmark ||
    BrowserAction.quickToggleBookmark ||
    BrowserAction.showBookmarks ||
    BrowserAction.newBookmarkFolder => FeatureId.libraryBookmarks,
    BrowserAction.showHistory ||
    BrowserAction.showDownloads => FeatureId.libraryHistoryDownloads,
    BrowserAction.showHome => FeatureId.homeLayoutHome,
    BrowserAction.showFontSize ||
    BrowserAction.increaseFontSize ||
    BrowserAction.decreaseFontSize ||
    BrowserAction.resetFontSize => FeatureId.appearanceCore,
    BrowserAction.toggleTabBar => FeatureId.layoutBasic,
    BrowserAction.showKeyboardShortcuts => FeatureId.inputKeyboardShortcuts,
    BrowserAction.showAddons => FeatureId.extensionsAddonManagement,
    BrowserAction.showContentBlockerLists =>
      FeatureId.extensionsFilterListSelection,
    BrowserAction.siteSettings => FeatureId.sitePanel,
    // The profile list hides adding profiles itself and always keeps this
    // profile's own controls (P5), like the menu's profile row.
    BrowserAction.showProfiles => FeatureId.profilesCurrentProfileControls,
    BrowserAction.newProfile => FeatureId.profilesMulti,
    BrowserAction.clearBrowsingData => FeatureId.dataDeleteManual,
    BrowserAction.toggleReaderMode => FeatureId.contentReaderMode,
    BrowserAction.translatePage => FeatureId.contentTranslation,
    BrowserAction.sharePage ||
    BrowserAction.printPage ||
    BrowserAction.copyLink => FeatureId.contentShareExport,
    BrowserAction.scanQrCode => FeatureId.contentQrScanner,
    BrowserAction.addToHomeScreen => FeatureId.webappsInstallBasic,
    BrowserAction.showSyncSettings => FeatureId.syncFirefoxSync,
    BrowserAction.subscribeToPageFeed ||
    BrowserAction.showFeeds => FeatureId.feedsSubscribeRead,
    BrowserAction.addFeed => FeatureId.feedsManualAndArchive,
    BrowserAction.nextContainer ||
    BrowserAction.previousContainer ||
    BrowserAction.moveTabToContainer ||
    BrowserAction.showContainers ||
    BrowserAction.newContainer => FeatureId.containerCore,
    BrowserAction.toggleGestures => FeatureId.inputDrawnGestures,
    BrowserAction.newSearchEngine => FeatureId.bangsTypedAndBasicCustom,
    BrowserAction.backupProfile => FeatureId.backupProfileBackupRestore,
    BrowserAction.showTor => FeatureId.connectionsTorBasic,
    BrowserAction.showProxySettings => FeatureId.connectionsImportVpnProxy,
    BrowserAction.newProxyProfile => FeatureId.connectionsManualProxyConfig,
    BrowserAction.showErrorLogs => FeatureId.diagnosticsBasic,
    BrowserAction.splitView ||
    BrowserAction.splitWithAnotherTab ||
    BrowserAction.toggleSplitSinglePage ||
    BrowserAction.showSplitControls ||
    BrowserAction.focusOtherSplitPane ||
    BrowserAction.swapSplitPanes ||
    BrowserAction.endSplitView => FeatureId.tabsSplitView,
  };

  /// Whether pickers offer this action and bindings run it without asking:
  /// only while its owning feature is shown.
  bool isShownIn(GeneralSettings settings) =>
      settings.isFeatureShown(owningFeature);
}

/// [actions] without the ones whose feature is hidden, keeping [selected] so a
/// picker still shows what a binding is currently set to.
List<BrowserAction> shownBrowserActions(
  Iterable<BrowserAction> actions,
  GeneralSettings settings, {
  BrowserAction? selected,
}) => [
  for (final action in actions)
    if (action == selected || action.isShownIn(settings)) action,
];
