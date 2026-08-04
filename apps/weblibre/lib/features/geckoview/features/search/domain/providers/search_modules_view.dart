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

  /// Popular-domain prefix completions from the bundled Tranco-derived
  /// `sites.db` asset (filtered against adult/gambling + tracker/CDN lists).
  /// Static popularity data, ranked below history and bookmarks so
  /// visited/saved sites always win. Domain autocomplete: typing "git"
  /// suggests github.com even with no local history.
  popularSites,

  historyHighlights,
  topSites,
  recentHistory,
  recentArticles,
  recentTabs,
  containers,
  frequentBangs,

  /// The daily quote card. Carries no list of its own, so it neither paginates
  /// nor reports a count; the header's trailing slot holds the reroll button.
  quote,

  /// New tab / View tabs / Resume last tab. These act on the browser shell
  /// around the surface, so they are only offered on [ModuleSurface.home] —
  /// on the new-tab page "New tab" is the page you are already looking at.
  quickActions;

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
    popularSites => 'Popular Sites',
    historyHighlights => 'History Highlights',
    topSites => 'Shortcuts',
    recentHistory => 'Recent History',
    recentArticles => 'Recent Articles',
    recentTabs => 'Recent Tabs',
    containers => 'Containers',
    frequentBangs => 'Frequent Bangs',
    quote => 'Quote',
    quickActions => 'Quick Actions',
  };
}

/// One module slot on a surface: which module, and whether it starts enabled.
typedef ModuleSurfaceDefault = ({SearchModuleType type, bool visible});

/// An independently-configured module list.
///
/// Each surface persists its own order and visibility under [key] while sharing
/// one module catalogue ([SearchModuleType]), one section chrome
/// ([SearchModuleSection]) and one customization UI — the same split
/// `ToolbarConfigLocation` uses for the two toolbars.
///
/// A module may appear on several surfaces, so the surface cannot be derived
/// from the module. It is supplied by the host instead, via `ModuleSurfaceScope`.
enum ModuleSurface {
  /// The browser home shown when no tab is selected.
  home(
    key: 'HomeModuleOrder',
    defaultModules: [
      (type: SearchModuleType.quickActions, visible: true),
      (type: SearchModuleType.topSites, visible: true),
      (type: SearchModuleType.recentTabs, visible: true),
      (type: SearchModuleType.quote, visible: true),
      (type: SearchModuleType.recentHistory, visible: false),
      (type: SearchModuleType.historyHighlights, visible: false),
      (type: SearchModuleType.recentArticles, visible: false),
      (type: SearchModuleType.containers, visible: false),
    ],
  ),

  /// The new-tab page: the search screen before anything has been typed.
  ///
  /// [key] is a compatibility contract — this order has shipped to users under
  /// that exact string, and renaming it resets every existing layout.
  newTab(
    key: 'EmptyStateModuleOrder',
    defaultModules: [
      (type: SearchModuleType.recentSearches, visible: true),
      (type: SearchModuleType.frequentBangs, visible: true),
      (type: SearchModuleType.topSites, visible: true),
      (type: SearchModuleType.recentArticles, visible: true),
      (type: SearchModuleType.recentTabs, visible: true),
      (type: SearchModuleType.recentHistory, visible: true),
      (type: SearchModuleType.historyHighlights, visible: true),
      (type: SearchModuleType.containers, visible: true),
      // Offered but off, so adding it leaves existing new-tab pages untouched.
      (type: SearchModuleType.quote, visible: false),
    ],
  ),

  /// The search screen once a query has been entered.
  search(
    key: 'SearchModuleOrder',
    defaultModules: [
      (type: SearchModuleType.searchProviders, visible: true),
      (type: SearchModuleType.searchSuggestions, visible: true),
      (type: SearchModuleType.tabs, visible: true),
      (type: SearchModuleType.bookmarks, visible: true),
      (type: SearchModuleType.articles, visible: true),
      (type: SearchModuleType.combinedHistory, visible: true),
      (type: SearchModuleType.popularSites, visible: true),
    ],
  );

  const ModuleSurface({required this.key, required this.defaultModules});

  /// Storage key for this surface's persisted order. Never change a shipped one.
  final String key;

  final List<ModuleSurfaceDefault> defaultModules;

  /// Whether [module] is offered on this surface at all.
  bool offers(SearchModuleType module) =>
      defaultModules.any((d) => d.type == module);
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

  /// Keyed by surface as well as module: the same module can be on screen on
  /// two surfaces at once (home stays mounted underneath the pushed search
  /// screen), and collapsing it in one place must not collapse it in the other.
  @override
  SearchModuleDisplayState build(
    ModuleSurface surface,
    SearchModuleType module,
  ) {
    return SearchModuleDisplayState.preview;
  }
}

@Riverpod()
class SearchReorderMode extends _$SearchReorderMode {
  void activate() => state = true;
  void deactivate() => state = false;

  /// Keyed by surface, like [SearchModuleDisplayStateController] — and here the
  /// key also bounds the state's lifetime. The browser home stays mounted
  /// underneath the pushed search screen and would keep a single shared
  /// instance alive, so a reorder started on the search screen and left by the
  /// system back gesture (rather than "Done") would survive the pop and still
  /// be active the next time that screen opened. Per surface, the search
  /// screen's own instance is disposed with the screen.
  @override
  bool build(ModuleSurface surface) => false;
}
