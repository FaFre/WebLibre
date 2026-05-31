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

/// Actions that can be bound to a touch gesture.
///
/// Each value carries a human-readable [title]/[description] for the settings
/// UI and an [icon] mirroring the action's representation elsewhere in the app
/// (contextual toolbar, browser menu sheet). The dispatcher resolves each value
/// against the currently selected tab.
enum GestureAction {
  // Navigation
  back(
    'Back',
    'Go back in history',
    Icons.arrow_back,
    GestureActionCategory.navigation,
  ),
  forward(
    'Forward',
    'Go forward in history',
    Icons.arrow_forward,
    GestureActionCategory.navigation,
  ),
  reload(
    'Reload',
    'Reload the current page',
    Icons.refresh,
    GestureActionCategory.navigation,
  ),

  // Scrolling
  scrollTop(
    'Scroll to Top',
    'Jump to the top of the page',
    Icons.vertical_align_top,
    GestureActionCategory.scrolling,
  ),
  scrollBottom(
    'Scroll to Bottom',
    'Jump to the bottom of the page',
    Icons.vertical_align_bottom,
    GestureActionCategory.scrolling,
  ),
  pageUp(
    'Page Up',
    'Scroll up by one screen',
    MdiIcons.chevronDoubleUp,
    GestureActionCategory.scrolling,
  ),
  pageDown(
    'Page Down',
    'Scroll down by one screen',
    MdiIcons.chevronDoubleDown,
    GestureActionCategory.scrolling,
  ),

  // Tabs
  newTab(
    'New Tab',
    'Open a new tab',
    MdiIcons.tabPlus,
    GestureActionCategory.tabs,
  ),
  closeTab(
    'Close Tab',
    'Close the current tab',
    MdiIcons.tabMinus,
    GestureActionCategory.tabs,
  ),
  duplicateTab(
    'Duplicate Tab',
    'Open a copy of the current tab',
    MdiIcons.contentDuplicate,
    GestureActionCategory.tabs,
  ),
  nextTab(
    'Next Tab',
    'Switch to the next tab',
    Icons.skip_next,
    GestureActionCategory.tabs,
  ),
  previousTab(
    'Previous Tab',
    'Switch to the previous tab',
    Icons.skip_previous,
    GestureActionCategory.tabs,
  ),
  lastUsedTab(
    'Last Used Tab',
    'Switch to the previously used tab',
    Icons.swap_horiz,
    GestureActionCategory.tabs,
  ),
  togglePinTab(
    'Pin / Unpin Tab',
    'Toggle the pinned state of the current tab',
    MdiIcons.pin,
    GestureActionCategory.tabs,
  ),

  // Page tools
  toggleReaderMode(
    'Reader Mode',
    'Toggle reader mode for the current page',
    MdiIcons.bookOpenOutline,
    GestureActionCategory.page,
  ),
  toggleDesktopMode(
    'Desktop Site',
    'Toggle desktop site for the current page',
    Icons.desktop_windows,
    GestureActionCategory.page,
  ),
  findInPage(
    'Find in Page',
    'Open find in page',
    Icons.find_in_page,
    GestureActionCategory.page,
  ),
  increaseFontSize(
    'Increase Font',
    'Increase the page font size',
    MdiIcons.formatFontSizeIncrease,
    GestureActionCategory.page,
  ),
  decreaseFontSize(
    'Decrease Font',
    'Decrease the page font size',
    MdiIcons.formatFontSizeDecrease,
    GestureActionCategory.page,
  ),
  toggleBookmark(
    'Bookmark',
    'Bookmark or unbookmark the current page',
    Icons.bookmark_border,
    GestureActionCategory.page,
  ),
  translatePage(
    'Translate',
    'Open the page translation sheet',
    Icons.translate,
    GestureActionCategory.page,
  ),

  // Open
  showHistory(
    'History',
    'Open browsing history',
    Icons.history,
    GestureActionCategory.open,
  ),
  showBookmarks(
    'Bookmarks',
    'Open bookmarks',
    MdiIcons.bookmarkMultiple,
    GestureActionCategory.open,
  ),

  // App
  moveToBackground(
    'Minimize',
    'Send WebLibre to the background',
    MdiIcons.arrowCollapseDown,
    GestureActionCategory.app,
  ),
  quitBrowser(
    'Quit',
    'Close all tabs and quit WebLibre',
    MdiIcons.power,
    GestureActionCategory.app,
  );

  final String title;
  final String description;
  final IconData icon;

  /// Grouping used to organise actions in the bindings list and picker.
  final GestureActionCategory category;

  const GestureAction(this.title, this.description, this.icon, this.category);
}

/// High-level grouping of [GestureAction]s for the settings UI.
enum GestureActionCategory {
  navigation('Navigation'),
  scrolling('Scrolling'),
  tabs('Tabs'),
  page('Page'),
  open('Open'),
  app('App');

  final String label;

  const GestureActionCategory(this.label);
}
