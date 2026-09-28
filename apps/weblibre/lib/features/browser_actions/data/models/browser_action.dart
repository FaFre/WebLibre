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
import 'package:weblibre/presentation/icons/tor_icons.dart';

/// Browser commands that can be bound to a touch gesture or a keyboard
/// shortcut.
///
/// Each value carries an [icon] mirroring the action's representation
/// elsewhere in the app (contextual toolbar, browser menu sheet).
/// `BrowserActionDispatcher` resolves each value against the currently
/// selected tab, whatever triggered it.
///
/// Persisted by [name] (gesture bindings, shortcut overrides): renaming a value
/// silently drops every binding that points at it.
enum BrowserAction {
  // Navigation
  focusAddressBar(Icons.search, BrowserActionCategory.navigation),
  back(Icons.arrow_back, BrowserActionCategory.navigation),
  forward(Icons.arrow_forward, BrowserActionCategory.navigation),
  reload(Icons.refresh, BrowserActionCategory.navigation),
  hardReload(MdiIcons.cached, BrowserActionCategory.navigation),

  // Scrolling
  scrollTop(Icons.vertical_align_top, BrowserActionCategory.scrolling),
  scrollBottom(Icons.vertical_align_bottom, BrowserActionCategory.scrolling),
  pageUp(MdiIcons.chevronDoubleUp, BrowserActionCategory.scrolling),
  pageDown(MdiIcons.chevronDoubleDown, BrowserActionCategory.scrolling),

  // Tabs
  newTab(MdiIcons.tabPlus, BrowserActionCategory.tabs),
  newPrivateTab(MdiIcons.dominoMask, BrowserActionCategory.tabs),
  closeTab(MdiIcons.tabMinus, BrowserActionCategory.tabs),
  reopenClosedTab(Icons.undo, BrowserActionCategory.tabs),
  duplicateTab(MdiIcons.contentDuplicate, BrowserActionCategory.tabs),
  nextTab(Icons.skip_next, BrowserActionCategory.tabs),
  previousTab(Icons.skip_previous, BrowserActionCategory.tabs),
  lastUsedTab(Icons.swap_horiz, BrowserActionCategory.tabs),
  selectTab1(MdiIcons.numeric1BoxOutline, BrowserActionCategory.tabs),
  selectTab2(MdiIcons.numeric2BoxOutline, BrowserActionCategory.tabs),
  selectTab3(MdiIcons.numeric3BoxOutline, BrowserActionCategory.tabs),
  selectTab4(MdiIcons.numeric4BoxOutline, BrowserActionCategory.tabs),
  selectTab5(MdiIcons.numeric5BoxOutline, BrowserActionCategory.tabs),
  selectTab6(MdiIcons.numeric6BoxOutline, BrowserActionCategory.tabs),
  selectTab7(MdiIcons.numeric7BoxOutline, BrowserActionCategory.tabs),
  selectTab8(MdiIcons.numeric8BoxOutline, BrowserActionCategory.tabs),
  selectLastTab(Icons.last_page, BrowserActionCategory.tabs),
  togglePinTab(MdiIcons.pin, BrowserActionCategory.tabs),
  moveTabBackward(MdiIcons.chevronLeft, BrowserActionCategory.tabs),
  moveTabForward(MdiIcons.chevronRight, BrowserActionCategory.tabs),
  moveTabToStart(MdiIcons.arrowCollapseLeft, BrowserActionCategory.tabs),
  moveTabToEnd(MdiIcons.arrowCollapseRight, BrowserActionCategory.tabs),
  nextContainer(MdiIcons.folderArrowRightOutline, BrowserActionCategory.tabs),
  previousContainer(
    MdiIcons.folderArrowLeftOutline,
    BrowserActionCategory.tabs,
  ),
  openInPrivateTab(MdiIcons.incognito, BrowserActionCategory.tabs),
  moveTabToContainer(
    MdiIcons.folderArrowUpDownOutline,
    BrowserActionCategory.tabs,
  ),

  // Page tools
  toggleReaderMode(MdiIcons.bookOpenOutline, BrowserActionCategory.page),
  toggleDesktopMode(Icons.desktop_windows, BrowserActionCategory.page),
  findInPage(Icons.find_in_page, BrowserActionCategory.page),
  findNext(Icons.keyboard_arrow_down, BrowserActionCategory.page),
  findPrevious(Icons.keyboard_arrow_up, BrowserActionCategory.page),
  increaseFontSize(MdiIcons.formatFontSizeIncrease, BrowserActionCategory.page),
  decreaseFontSize(MdiIcons.formatFontSizeDecrease, BrowserActionCategory.page),
  resetFontSize(MdiIcons.formatSize, BrowserActionCategory.page),
  toggleBookmark(Icons.bookmark_border, BrowserActionCategory.page),
  sharePage(Icons.share, BrowserActionCategory.page),
  translatePage(Icons.translate, BrowserActionCategory.page),
  printPage(MdiIcons.printer, BrowserActionCategory.page),
  copyLink(MdiIcons.contentCopy, BrowserActionCategory.page),
  siteSettings(MdiIcons.tuneVariant, BrowserActionCategory.page),
  addToHomeScreen(Icons.add_to_home_screen, BrowserActionCategory.page),
  subscribeToPageFeed(MdiIcons.rssBox, BrowserActionCategory.page),

  // Open
  showHome(Icons.home_outlined, BrowserActionCategory.open),
  showHistory(Icons.history, BrowserActionCategory.open),
  showBookmarks(MdiIcons.bookmarkMultiple, BrowserActionCategory.open),
  showContainers(MdiIcons.folderMultipleOutline, BrowserActionCategory.open),
  showTabView(MdiIcons.viewGridOutline, BrowserActionCategory.open),
  showDownloads(Icons.download, BrowserActionCategory.open),
  showAddons(MdiIcons.puzzleOutline, BrowserActionCategory.open),
  openSettings(Icons.settings_outlined, BrowserActionCategory.open),
  showKeyboardShortcuts(MdiIcons.keyboardOutline, BrowserActionCategory.open),
  showFeeds(MdiIcons.rss, BrowserActionCategory.open),
  showProfiles(Icons.people_outline, BrowserActionCategory.open),
  showProxySettings(MdiIcons.lanConnect, BrowserActionCategory.open),
  showTor(TorIcons.onionAlt, BrowserActionCategory.open),
  showSyncSettings(Icons.sync, BrowserActionCategory.open),
  showContentBlockerLists(MdiIcons.filterOutline, BrowserActionCategory.open),
  showErrorLogs(MdiIcons.bugOutline, BrowserActionCategory.open),
  showAbout(Icons.info_outline, BrowserActionCategory.open),

  // Create
  newContainer(MdiIcons.folderPlusOutline, BrowserActionCategory.create),
  newBookmarkFolder(MdiIcons.folderStarOutline, BrowserActionCategory.create),
  addFeed(MdiIcons.rssBox, BrowserActionCategory.create),
  newSearchEngine(Icons.manage_search, BrowserActionCategory.create),
  newProfile(Icons.person_add_outlined, BrowserActionCategory.create),
  newProxyProfile(MdiIcons.serverPlus, BrowserActionCategory.create),

  // App
  toggleTabBar(MdiIcons.dockBottom, BrowserActionCategory.app),
  clearBrowsingData(MdiIcons.fire, BrowserActionCategory.app),
  moveToBackground(MdiIcons.arrowCollapseDown, BrowserActionCategory.app),
  backupProfile(MdiIcons.backupRestore, BrowserActionCategory.app),
  quitBrowser(MdiIcons.power, BrowserActionCategory.app);

  final IconData icon;

  /// Grouping used to organise actions in the bindings list and picker.
  final BrowserActionCategory category;

  const BrowserAction(this.icon, this.category);
}

/// High-level grouping of [BrowserAction]s for the settings UI.
enum BrowserActionCategory {
  navigation,
  scrolling,
  tabs,
  page,
  open,
  create,
  app,
}
