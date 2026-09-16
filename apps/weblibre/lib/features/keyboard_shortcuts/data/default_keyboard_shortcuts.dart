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
import 'package:flutter/services.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';

KeyChord _ctrl(LogicalKeyboardKey key, {bool shift = false}) =>
    KeyChord.of(key, control: true, shift: shift);

KeyChord _alt(LogicalKeyboardKey key) => KeyChord.of(key, alt: true);

KeyChord _ctrlAlt(LogicalKeyboardKey key) =>
    KeyChord.of(key, control: true, alt: true);

KeyChord _plain(LogicalKeyboardKey key, {bool shift = false}) =>
    KeyChord.of(key, shift: shift);

/// Firefox desktop's key bindings for the actions WebLibre has.
///
/// Taken from the Windows/Linux variant of mozilla-central's
/// `browser/base/content/browser-sets.inc.xhtml` (keys in
/// `browser/locales/en-US/browser/browserSets.ftl`) and the tab keys in
/// `toolkit/modules/ShortcutUtils.sys.mjs`. Where Firefox differs between
/// GNOME and other Linux desktops, the non-GNOME binding is used: GNOME's
/// variants only dodge desktop shortcuts Android does not have.
///
/// Where Firefox has no default (duplicate tab, tab view, settings…), neither
/// do we. Home, End, Page Up/Down and Escape stay unbound on purpose: they
/// belong to the page.
///
/// No chord may appear twice; a test enforces it.
final Map<BrowserAction, List<KeyChord>> defaultKeyboardShortcuts = {
  BrowserAction.focusAddressBar: [
    _ctrl(LogicalKeyboardKey.keyL),
    _alt(LogicalKeyboardKey.keyD),
    // Firefox's search bar keys; the address bar is the search bar here.
    _ctrl(LogicalKeyboardKey.keyK),
    _ctrl(LogicalKeyboardKey.keyE),
  ],
  BrowserAction.back: [
    _alt(LogicalKeyboardKey.arrowLeft),
    _ctrl(LogicalKeyboardKey.bracketLeft),
  ],
  BrowserAction.forward: [
    _alt(LogicalKeyboardKey.arrowRight),
    _ctrl(LogicalKeyboardKey.bracketRight),
  ],
  BrowserAction.reload: [
    _ctrl(LogicalKeyboardKey.keyR),
    _plain(LogicalKeyboardKey.f5),
  ],
  BrowserAction.hardReload: [
    _ctrl(LogicalKeyboardKey.keyR, shift: true),
    _ctrl(LogicalKeyboardKey.f5),
  ],
  BrowserAction.newTab: [_ctrl(LogicalKeyboardKey.keyT)],
  BrowserAction.newPrivateTab: [_ctrl(LogicalKeyboardKey.keyP, shift: true)],
  BrowserAction.closeTab: [
    _ctrl(LogicalKeyboardKey.keyW),
    _ctrl(LogicalKeyboardKey.f4),
  ],
  BrowserAction.reopenClosedTab: [_ctrl(LogicalKeyboardKey.keyT, shift: true)],
  BrowserAction.nextTab: [
    _ctrl(LogicalKeyboardKey.tab),
    _ctrl(LogicalKeyboardKey.pageDown),
  ],
  BrowserAction.previousTab: [
    _ctrl(LogicalKeyboardKey.tab, shift: true),
    _ctrl(LogicalKeyboardKey.pageUp),
  ],
  BrowserAction.selectTab1: [_ctrl(LogicalKeyboardKey.digit1)],
  BrowserAction.selectTab2: [_ctrl(LogicalKeyboardKey.digit2)],
  BrowserAction.selectTab3: [_ctrl(LogicalKeyboardKey.digit3)],
  BrowserAction.selectTab4: [_ctrl(LogicalKeyboardKey.digit4)],
  BrowserAction.selectTab5: [_ctrl(LogicalKeyboardKey.digit5)],
  BrowserAction.selectTab6: [_ctrl(LogicalKeyboardKey.digit6)],
  BrowserAction.selectTab7: [_ctrl(LogicalKeyboardKey.digit7)],
  BrowserAction.selectTab8: [_ctrl(LogicalKeyboardKey.digit8)],
  BrowserAction.selectLastTab: [_ctrl(LogicalKeyboardKey.digit9)],
  BrowserAction.moveTabBackward: [
    _ctrl(LogicalKeyboardKey.pageUp, shift: true),
  ],
  BrowserAction.moveTabForward: [
    _ctrl(LogicalKeyboardKey.pageDown, shift: true),
  ],
  BrowserAction.moveTabToStart: [_ctrl(LogicalKeyboardKey.home, shift: true)],
  BrowserAction.moveTabToEnd: [_ctrl(LogicalKeyboardKey.end, shift: true)],
  BrowserAction.toggleReaderMode: [_ctrlAlt(LogicalKeyboardKey.keyR)],
  BrowserAction.findInPage: [_ctrl(LogicalKeyboardKey.keyF)],
  BrowserAction.findNext: [
    _ctrl(LogicalKeyboardKey.keyG),
    _plain(LogicalKeyboardKey.f3),
  ],
  BrowserAction.findPrevious: [
    _ctrl(LogicalKeyboardKey.keyG, shift: true),
    _plain(LogicalKeyboardKey.f3, shift: true),
  ],
  // Firefox zooms the page on these; the closest WebLibre has is text size.
  BrowserAction.increaseFontSize: [
    _ctrl(LogicalKeyboardKey.equal),
    _ctrl(LogicalKeyboardKey.equal, shift: true),
    _ctrl(LogicalKeyboardKey.numpadAdd),
  ],
  BrowserAction.decreaseFontSize: [
    _ctrl(LogicalKeyboardKey.minus),
    _ctrl(LogicalKeyboardKey.numpadSubtract),
  ],
  BrowserAction.resetFontSize: [
    _ctrl(LogicalKeyboardKey.digit0),
    _ctrl(LogicalKeyboardKey.numpad0),
  ],
  BrowserAction.toggleBookmark: [_ctrl(LogicalKeyboardKey.keyD)],
  BrowserAction.showHome: [_alt(LogicalKeyboardKey.home)],
  // Firefox opens the sidebar and the library window respectively; both are
  // the history screen here.
  BrowserAction.showHistory: [
    _ctrl(LogicalKeyboardKey.keyH),
    _ctrl(LogicalKeyboardKey.keyH, shift: true),
  ],
  BrowserAction.showBookmarks: [
    _ctrl(LogicalKeyboardKey.keyO, shift: true),
    _ctrl(LogicalKeyboardKey.keyB),
  ],
  BrowserAction.showDownloads: [_ctrl(LogicalKeyboardKey.keyJ)],
  BrowserAction.showAddons: [_ctrl(LogicalKeyboardKey.keyA, shift: true)],
  BrowserAction.printPage: [_ctrl(LogicalKeyboardKey.keyP)],
  // Firefox's "toggle sidebar"; the tab bar is what the side rail shows.
  BrowserAction.toggleTabBar: [_ctrlAlt(LogicalKeyboardKey.keyZ)],
  BrowserAction.clearBrowsingData: [
    _ctrl(LogicalKeyboardKey.delete, shift: true),
  ],
  BrowserAction.quitBrowser: [_ctrl(LogicalKeyboardKey.keyQ)],
  // The one default that is not Firefox's: Firefox has no shortcut list to
  // open, and without a key this one could not be found from the keyboard.
  BrowserAction.showKeyboardShortcuts: [_ctrl(LogicalKeyboardKey.slash)],
};

/// Actions that repeat while their chord is held.
///
/// Everything else fires once per press: holding Ctrl+W must close one tab,
/// not every tab.
const repeatableKeyboardActions = {
  BrowserAction.nextTab,
  BrowserAction.previousTab,
  BrowserAction.moveTabBackward,
  BrowserAction.moveTabForward,
  BrowserAction.findNext,
  BrowserAction.findPrevious,
  BrowserAction.increaseFontSize,
  BrowserAction.decreaseFontSize,
  BrowserAction.pageUp,
  BrowserAction.pageDown,
};
