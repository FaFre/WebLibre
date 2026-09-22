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

/// Browser commands that can be bound to a touch gesture or a keyboard
/// shortcut.
///
/// Each value carries a human-readable [title]/[description] for the settings
/// UI and an [icon] mirroring the action's representation elsewhere in the app
/// (contextual toolbar, browser menu sheet). `BrowserActionDispatcher` resolves
/// each value against the currently selected tab, whatever triggered it.
///
/// Persisted by [name] (gesture bindings, shortcut overrides): renaming a value
/// silently drops every binding that points at it.
enum BrowserAction {
  // Navigation
  focusAddressBar(
    'Address Bar',
    'Edit the address or start a search',
    Icons.search,
    BrowserActionCategory.navigation,
  ),
  back(
    'Back',
    'Go back in history',
    Icons.arrow_back,
    BrowserActionCategory.navigation,
  ),
  forward(
    'Forward',
    'Go forward in history',
    Icons.arrow_forward,
    BrowserActionCategory.navigation,
  ),
  reload(
    'Reload',
    'Reload the current page',
    Icons.refresh,
    BrowserActionCategory.navigation,
  ),
  hardReload(
    'Hard Reload',
    'Reload the current page, bypassing the cache',
    MdiIcons.cached,
    BrowserActionCategory.navigation,
  ),

  // Scrolling
  scrollTop(
    'Scroll to Top',
    'Jump to the top of the page',
    Icons.vertical_align_top,
    BrowserActionCategory.scrolling,
  ),
  scrollBottom(
    'Scroll to Bottom',
    'Jump to the bottom of the page',
    Icons.vertical_align_bottom,
    BrowserActionCategory.scrolling,
  ),
  pageUp(
    'Page Up',
    'Scroll up by one screen',
    MdiIcons.chevronDoubleUp,
    BrowserActionCategory.scrolling,
  ),
  pageDown(
    'Page Down',
    'Scroll down by one screen',
    MdiIcons.chevronDoubleDown,
    BrowserActionCategory.scrolling,
  ),

  // Tabs
  newTab(
    'New Tab',
    'Open a new tab',
    MdiIcons.tabPlus,
    BrowserActionCategory.tabs,
  ),
  newPrivateTab(
    'New Private Tab',
    'Open a new private tab',
    MdiIcons.dominoMask,
    BrowserActionCategory.tabs,
  ),
  closeTab(
    'Close Tab',
    'Close the current tab',
    MdiIcons.tabMinus,
    BrowserActionCategory.tabs,
  ),
  reopenClosedTab(
    'Reopen Closed Tab',
    'Bring back the most recently closed tab',
    Icons.undo,
    BrowserActionCategory.tabs,
  ),
  duplicateTab(
    'Duplicate Tab',
    'Open a copy of the current tab',
    MdiIcons.contentDuplicate,
    BrowserActionCategory.tabs,
  ),
  nextTab(
    'Next Tab',
    'Switch to the next tab',
    Icons.skip_next,
    BrowserActionCategory.tabs,
  ),
  previousTab(
    'Previous Tab',
    'Switch to the previous tab',
    Icons.skip_previous,
    BrowserActionCategory.tabs,
  ),
  lastUsedTab(
    'Last Used Tab',
    'Switch to the previously used tab',
    Icons.swap_horiz,
    BrowserActionCategory.tabs,
  ),
  selectTab1(
    'Tab 1',
    'Switch to the first tab in the tab bar',
    MdiIcons.numeric1BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab2(
    'Tab 2',
    'Switch to the second tab in the tab bar',
    MdiIcons.numeric2BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab3(
    'Tab 3',
    'Switch to the third tab in the tab bar',
    MdiIcons.numeric3BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab4(
    'Tab 4',
    'Switch to the fourth tab in the tab bar',
    MdiIcons.numeric4BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab5(
    'Tab 5',
    'Switch to the fifth tab in the tab bar',
    MdiIcons.numeric5BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab6(
    'Tab 6',
    'Switch to the sixth tab in the tab bar',
    MdiIcons.numeric6BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab7(
    'Tab 7',
    'Switch to the seventh tab in the tab bar',
    MdiIcons.numeric7BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectTab8(
    'Tab 8',
    'Switch to the eighth tab in the tab bar',
    MdiIcons.numeric8BoxOutline,
    BrowserActionCategory.tabs,
  ),
  selectLastTab(
    'Last Tab',
    'Switch to the last tab in the tab bar',
    Icons.last_page,
    BrowserActionCategory.tabs,
  ),
  togglePinTab(
    'Pin / Unpin Tab',
    'Toggle the pinned state of the current tab',
    MdiIcons.pin,
    BrowserActionCategory.tabs,
  ),
  moveTabBackward(
    'Move Tab Back',
    'Move the current tab one place toward the start of the tab bar',
    MdiIcons.chevronLeft,
    BrowserActionCategory.tabs,
  ),
  moveTabForward(
    'Move Tab Forward',
    'Move the current tab one place toward the end of the tab bar',
    MdiIcons.chevronRight,
    BrowserActionCategory.tabs,
  ),
  moveTabToStart(
    'Move Tab to Start',
    'Move the current tab to the start of its group in the tab bar',
    MdiIcons.arrowCollapseLeft,
    BrowserActionCategory.tabs,
  ),
  moveTabToEnd(
    'Move Tab to End',
    'Move the current tab to the end of its group in the tab bar',
    MdiIcons.arrowCollapseRight,
    BrowserActionCategory.tabs,
  ),
  nextContainer(
    'Next Container',
    'Switch to the next container and its last used tab',
    MdiIcons.folderArrowRightOutline,
    BrowserActionCategory.tabs,
  ),
  previousContainer(
    'Previous Container',
    'Switch to the previous container and its last used tab',
    MdiIcons.folderArrowLeftOutline,
    BrowserActionCategory.tabs,
  ),

  // Page tools
  toggleReaderMode(
    'Reader Mode',
    'Toggle reader mode for the current page',
    MdiIcons.bookOpenOutline,
    BrowserActionCategory.page,
  ),
  toggleDesktopMode(
    'Desktop Site',
    'Toggle desktop site for the current page',
    Icons.desktop_windows,
    BrowserActionCategory.page,
  ),
  findInPage(
    'Find in Page',
    'Open find in page',
    Icons.find_in_page,
    BrowserActionCategory.page,
  ),
  findNext(
    'Find Next',
    'Jump to the next match of the last search',
    Icons.keyboard_arrow_down,
    BrowserActionCategory.page,
  ),
  findPrevious(
    'Find Previous',
    'Jump to the previous match of the last search',
    Icons.keyboard_arrow_up,
    BrowserActionCategory.page,
  ),
  increaseFontSize(
    'Increase Font',
    'Increase the page font size',
    MdiIcons.formatFontSizeIncrease,
    BrowserActionCategory.page,
  ),
  decreaseFontSize(
    'Decrease Font',
    'Decrease the page font size',
    MdiIcons.formatFontSizeDecrease,
    BrowserActionCategory.page,
  ),
  resetFontSize(
    'Reset Font',
    'Restore the default page font size',
    MdiIcons.formatSize,
    BrowserActionCategory.page,
  ),
  toggleBookmark(
    'Bookmark',
    'Bookmark or unbookmark the current page',
    Icons.bookmark_border,
    BrowserActionCategory.page,
  ),
  sharePage(
    'Share',
    'Share the current page',
    Icons.share,
    BrowserActionCategory.page,
  ),
  translatePage(
    'Translate',
    'Open the page translation sheet',
    Icons.translate,
    BrowserActionCategory.page,
  ),
  printPage(
    'Print',
    'Print the current page',
    MdiIcons.printer,
    BrowserActionCategory.page,
  ),

  // Open
  showHome(
    'Home',
    'Open the home screen',
    Icons.home_outlined,
    BrowserActionCategory.open,
  ),
  showHistory(
    'History',
    'Open browsing history',
    Icons.history,
    BrowserActionCategory.open,
  ),
  showBookmarks(
    'Bookmarks',
    'Open bookmarks',
    MdiIcons.bookmarkMultiple,
    BrowserActionCategory.open,
  ),
  showContainers(
    'Containers',
    'Open the container list',
    MdiIcons.folderMultipleOutline,
    BrowserActionCategory.open,
  ),
  showTabView(
    'Tab View',
    'Open the tab overview',
    MdiIcons.viewGridOutline,
    BrowserActionCategory.open,
  ),
  showDownloads(
    'Downloads',
    'Open downloads',
    Icons.download,
    BrowserActionCategory.open,
  ),
  showAddons(
    'Add-ons',
    'Manage extensions',
    MdiIcons.puzzleOutline,
    BrowserActionCategory.open,
  ),
  openSettings(
    'Settings',
    'Open settings',
    Icons.settings_outlined,
    BrowserActionCategory.open,
  ),
  showKeyboardShortcuts(
    'Keyboard Shortcuts',
    'List the keys that run browser actions',
    MdiIcons.keyboardOutline,
    BrowserActionCategory.open,
  ),

  // App
  toggleTabBar(
    'Hide / Show Tab Bar',
    'Hide the tab bar, or bring it back',
    MdiIcons.dockBottom,
    BrowserActionCategory.app,
  ),
  clearBrowsingData(
    'Clear Browsing Data',
    'Choose browsing data to delete',
    Icons.delete_sweep_outlined,
    BrowserActionCategory.app,
  ),
  moveToBackground(
    'Minimize',
    'Send WebLibre to the background',
    MdiIcons.arrowCollapseDown,
    BrowserActionCategory.app,
  ),
  quitBrowser(
    'Quit',
    'Close all tabs and quit WebLibre',
    MdiIcons.power,
    BrowserActionCategory.app,
  );

  final String title;
  final String description;
  final IconData icon;

  /// Grouping used to organise actions in the bindings list and picker.
  final BrowserActionCategory category;

  const BrowserAction(this.title, this.description, this.icon, this.category);
}

/// High-level grouping of [BrowserAction]s for the settings UI.
enum BrowserActionCategory {
  navigation('Navigation'),
  scrolling('Scrolling'),
  tabs('Tabs'),
  page('Page'),
  open('Open'),
  app('App');

  final String label;

  const BrowserActionCategory(this.label);
}
