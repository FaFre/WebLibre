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

/// The actions the search screen's Actions section may offer, in the order the
/// new-tab page lists them.
///
/// Page actions come first: they only appear when the search was opened from a
/// page's address bar, and then they are what that search is about.
///
/// Left out on purpose:
/// - what the search screen itself already is (new tab, focus address bar);
/// - navigation that belongs to the toolbar and menu (back, forward, reload);
/// - actions that only make sense as a repeated key press (scrolling, stepping
///   through tabs, containers or find results);
/// - quitting or leaving the app.
///
/// Close tab and clear browsing data are in: both keep their own confirmation
/// (and undo, for the tab).
const searchableBrowserActions = <BrowserAction>{
  // Page
  BrowserAction.toggleBookmark,
  BrowserAction.findInPage,
  BrowserAction.copyLink,
  BrowserAction.sharePage,
  BrowserAction.toggleReaderMode,
  BrowserAction.toggleDesktopMode,
  BrowserAction.translatePage,
  BrowserAction.siteSettings,
  BrowserAction.addToHomeScreen,
  BrowserAction.subscribeToPageFeed,
  BrowserAction.printPage,
  BrowserAction.increaseFontSize,
  BrowserAction.decreaseFontSize,
  BrowserAction.resetFontSize,
  // Tab
  BrowserAction.openInPrivateTab,
  BrowserAction.moveTabToContainer,
  BrowserAction.duplicateTab,
  BrowserAction.togglePinTab,
  BrowserAction.closeTab,
  BrowserAction.reopenClosedTab,
  // Open
  BrowserAction.showHistory,
  BrowserAction.showBookmarks,
  BrowserAction.showDownloads,
  BrowserAction.showTabView,
  BrowserAction.showContainers,
  BrowserAction.showFeeds,
  BrowserAction.showProfiles,
  BrowserAction.showProxySettings,
  BrowserAction.showTor,
  BrowserAction.showSyncSettings,
  BrowserAction.showAddons,
  BrowserAction.showContentBlockerLists,
  BrowserAction.openSettings,
  BrowserAction.showKeyboardShortcuts,
  BrowserAction.showErrorLogs,
  BrowserAction.showAbout,
  // Create
  BrowserAction.newContainer,
  BrowserAction.newBookmarkFolder,
  BrowserAction.addFeed,
  BrowserAction.newSearchEngine,
  BrowserAction.newProfile,
  BrowserAction.newProxyProfile,
  // App
  BrowserAction.backupProfile,
  BrowserAction.clearBrowsingData,
};

/// Queries shorter than this match nothing: one letter would list half the
/// catalogue under every search that starts with it.
const actionSearchMinLength = 2;

/// One searchable row as the user reads it, in the UI language.
///
/// [item] is whatever the row stands for — a browser action, a container, a
/// setting. The domain layer has no localizations, so the caller supplies the
/// display strings it matched against. [keywords] are extra words the row
/// should be found by but never shows, such as a setting's synonyms.
typedef ActionSearchEntry<T> = ({
  T item,
  String label,
  String description,
  String category,
  List<String> keywords,
});

/// The items among [entries] that [query] matches, best match first.
///
/// Every word of [query] has to be found in the row's label, category,
/// keywords or description; matching the label, and matching it at the start
/// of a word, ranks higher. Description words only count from three letters
/// on, because short fragments ("th", "pa") occur in almost every description.
/// Ties keep the order of [entries].
List<T> rankActionSearchEntries<T>(
  String query,
  Iterable<ActionSearchEntry<T>> entries,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.length < actionSearchMinLength) return const [];

  final tokens = normalized.split(RegExp(r'\s+'));

  final scored = <({T item, int score, int order})>[];
  var order = 0;
  for (final entry in entries) {
    final score = _score(normalized, tokens, entry);
    if (score != null) {
      scored.add((item: entry.item, score: score, order: order));
    }
    order++;
  }

  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.order.compareTo(b.order);
  });

  return [for (final entry in scored) entry.item];
}

int? _score<T>(String query, List<String> tokens, ActionSearchEntry<T> entry) {
  final label = entry.label.toLowerCase();
  final labelWords = _words(label);
  final categoryWords = _words(entry.category.toLowerCase());
  final keywordWords = [
    for (final keyword in entry.keywords) ..._words(keyword.toLowerCase()),
  ];
  final descriptionWords = _words(entry.description.toLowerCase());

  var score = 0;
  for (final token in tokens) {
    if (labelWords.any((word) => word.startsWith(token))) {
      score += 3;
    } else if (label.contains(token)) {
      score += 2;
    } else if (categoryWords.any((word) => word.startsWith(token)) ||
        keywordWords.any((word) => word.startsWith(token))) {
      score += 1;
    } else if (token.length >= 3 &&
        descriptionWords.any((word) => word.startsWith(token))) {
      score += 1;
    } else {
      return null;
    }
  }

  if (label.startsWith(query)) score += 5;
  if (label == query) score += 5;

  return score;
}

List<String> _words(String text) =>
    text.split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      ..removeWhere((word) => word.isEmpty);
