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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_modules_view.g.dart';

enum SearchModuleType {
  recentSearches,
  searchProviders,
  searchSuggestions,
  tabs,
  articles,
  bookmarks,

  /// Engine "History" suggestions, frecency-ranked from Places. Engine-only;
  /// no local FTS hits. Superseded in the default ordering by
  /// [combinedHistory] but kept as a separate module for users who want a
  /// pure engine view.
  history,

  /// Local FTS5 hits over the indexed `extracted_content` /
  /// `full_content`. Pure local view; complementary to [history].
  /// Superseded in the default ordering by [combinedHistory] which folds
  /// these hits in alongside engine results — enabling both [localHistory]
  /// and [combinedHistory] will surface the same local URLs in two
  /// consecutive sections.
  localHistory,

  /// Default "History" module: engine frecency results in their existing
  /// order, augmented with local content snippets where available, then
  /// padded with local-only matches at the tail. Prefer this over
  /// enabling [history] and [localHistory] separately.
  combinedHistory,

  historyHighlights,
  topSites,
  recentHistory,
  recentArticles,
  recentTabs,
  containers,
  frequentBangs;

  String get label => switch (this) {
    recentSearches => 'Recent Searches',
    searchProviders => 'Search Providers',
    searchSuggestions => 'Suggestions',
    tabs => 'Tabs',
    articles => 'Articles',
    bookmarks => 'Bookmarks',
    history => 'History (engine)',
    localHistory => 'Local content',
    combinedHistory => 'History',
    historyHighlights => 'History Highlights',
    topSites => 'Top Sites',
    recentHistory => 'Recent History',
    recentArticles => 'Recent Articles',
    recentTabs => 'Recent Tabs',
    containers => 'Containers',
    frequentBangs => 'Frequent Bangs',
  };
}

enum SearchModuleGroup {
  emptyState(
    key: 'EmptyStateModuleOrder',
    defaultModules: [
      SearchModuleType.recentSearches,
      SearchModuleType.frequentBangs,
      SearchModuleType.topSites,
      SearchModuleType.recentArticles,
      SearchModuleType.recentTabs,
      SearchModuleType.recentHistory,
      SearchModuleType.historyHighlights,
      SearchModuleType.containers,
    ],
  ),
  search(
    key: 'SearchModuleOrder',
    defaultModules: [
      SearchModuleType.searchProviders,
      SearchModuleType.searchSuggestions,
      SearchModuleType.tabs,
      SearchModuleType.bookmarks,
      SearchModuleType.articles,
      SearchModuleType.combinedHistory,
    ],
  );

  const SearchModuleGroup({required this.key, required this.defaultModules});
  final String key;
  final List<SearchModuleType> defaultModules;
}

extension SearchModuleTypeGroup on SearchModuleType {
  SearchModuleGroup get group => switch (this) {
    SearchModuleType.recentSearches ||
    SearchModuleType.topSites ||
    SearchModuleType.recentArticles ||
    SearchModuleType.recentTabs ||
    SearchModuleType.recentHistory ||
    SearchModuleType.historyHighlights ||
    SearchModuleType.containers ||
    SearchModuleType.frequentBangs => SearchModuleGroup.emptyState,
    SearchModuleType.searchProviders ||
    SearchModuleType.searchSuggestions ||
    SearchModuleType.tabs ||
    SearchModuleType.bookmarks ||
    SearchModuleType.articles ||
    SearchModuleType.history ||
    SearchModuleType.localHistory ||
    SearchModuleType.combinedHistory => SearchModuleGroup.search,
  };
}

enum SearchModuleDisplayState { preview, expanded, collapsed }

@Riverpod()
class SearchModuleDisplayStateController
    extends _$SearchModuleDisplayStateController {
  void cycle() {
    state = switch (state) {
      SearchModuleDisplayState.preview => SearchModuleDisplayState.expanded,
      SearchModuleDisplayState.expanded => SearchModuleDisplayState.collapsed,
      SearchModuleDisplayState.collapsed => SearchModuleDisplayState.preview,
    };
  }

  void toggleCollapse() {
    state = switch (state) {
      SearchModuleDisplayState.collapsed => SearchModuleDisplayState.preview,
      _ => SearchModuleDisplayState.collapsed,
    };
  }

  void toggleExpansion() {
    state = switch (state) {
      SearchModuleDisplayState.preview => SearchModuleDisplayState.expanded,
      SearchModuleDisplayState.expanded => SearchModuleDisplayState.preview,
      _ => state,
    };
  }

  @override
  SearchModuleDisplayState build(SearchModuleType module) {
    return SearchModuleDisplayState.preview;
  }
}

@Riverpod()
class SearchReorderMode extends _$SearchReorderMode {
  // ignore: use_setters_to_change_properties
  void activate(SearchModuleGroup group) => state = group;
  void deactivate() => state = null;

  @override
  SearchModuleGroup? build() => null;
}
