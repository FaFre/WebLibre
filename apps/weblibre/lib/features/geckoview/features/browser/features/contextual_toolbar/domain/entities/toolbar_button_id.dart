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

import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';

enum ToolbarButtonId {
  back,
  forward,
  home,
  history,
  bookmarks,
  bookmarkToggle,
  share,
  addTab,
  tabsCount,
  navigationMenu,
  reload,
  readerMode,
  desktop,
  translation,
  findInPage,
  closeTab,
  inputUrl,
  qrScan,
  voiceSearch,
  duplicateTab,
  increaseFont,
  decreaseFont,
  moveToBackground,
  pageUp,
  pageDown,
  scrollTop,
  scrollBottom,
  font,
  extensionShortcut,
  toggleGestures,
  hideTabBar,
  clearBrowsingData,
  quit;

  /// The [BrowserAction] that does what tapping this button does.
  ///
  /// It gives the button its name in the toolbar settings, and lets the
  /// button be chosen from the same action list as a long-press binding, so
  /// one thing never shows up under two names. Null only for the extension
  /// shortcut: it opens a menu anchored to the button itself, which no action
  /// can do.
  BrowserAction? get action => switch (this) {
    back => BrowserAction.back,
    forward => BrowserAction.forward,
    home => BrowserAction.showHome,
    history => BrowserAction.showHistory,
    bookmarks => BrowserAction.showBookmarks,
    bookmarkToggle => BrowserAction.quickToggleBookmark,
    share => BrowserAction.sharePage,
    addTab => BrowserAction.newTab,
    tabsCount => BrowserAction.showTabView,
    navigationMenu => BrowserAction.showBrowserMenu,
    reload => BrowserAction.reload,
    readerMode => BrowserAction.toggleReaderMode,
    desktop => BrowserAction.toggleDesktopMode,
    translation => BrowserAction.translatePage,
    findInPage => BrowserAction.findInPage,
    closeTab => BrowserAction.closeTab,
    inputUrl => BrowserAction.focusAddressBar,
    qrScan => BrowserAction.scanQrCode,
    voiceSearch => BrowserAction.voiceSearch,
    duplicateTab => BrowserAction.duplicateTab,
    increaseFont => BrowserAction.increaseFontSize,
    decreaseFont => BrowserAction.decreaseFontSize,
    moveToBackground => BrowserAction.moveToBackground,
    pageUp => BrowserAction.pageUp,
    pageDown => BrowserAction.pageDown,
    scrollTop => BrowserAction.scrollTop,
    scrollBottom => BrowserAction.scrollBottom,
    font => BrowserAction.showFontSize,
    extensionShortcut => null,
    toggleGestures => BrowserAction.toggleGestures,
    hideTabBar => BrowserAction.toggleTabBar,
    clearBrowsingData => BrowserAction.clearBrowsingData,
    quit => BrowserAction.quitBrowser,
  };
}

/// The button for each [BrowserAction] some button does, the reverse of
/// [ToolbarButtonId.action].
final Map<BrowserAction, ToolbarButtonId> toolbarButtonIdsByAction = {
  for (final id in ToolbarButtonId.values) ?id.action: id,
};
