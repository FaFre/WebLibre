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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';

/// What one search may draw its suggestions from.
///
/// A private search is isolated by default: its text never goes to a remote
/// suggestion provider and regular saved history never suggests into it. The
/// private search suggestions setting lifts that, giving private searches the
/// same sources as regular ones.
///
/// Open tabs, bookmarks and the bundled popular-sites list are not gated here.
/// They stay on the device, and a private search keeps them.
class SearchSourcePolicy with FastEquatable {
  /// Whether typed text may be sent to the configured remote suggestion
  /// provider (Brave, DuckDuckGo, Kagi, Qwant).
  final bool remoteSuggestions;

  /// Whether saved browsing history — engine history (Places) and the local
  /// content index — may supply result rows and inline completion.
  final bool savedHistory;

  SearchSourcePolicy({
    required this.remoteSuggestions,
    required this.savedHistory,
  });

  factory SearchSourcePolicy.resolve({
    required bool privateMode,
    required bool privateSearchSuggestionsEnabled,
  }) {
    final isolated = privateMode && !privateSearchSuggestionsEnabled;

    return SearchSourcePolicy(
      remoteSuggestions: !isolated,
      savedHistory: !isolated,
    );
  }

  /// Whether the search results surface may show [module] at all.
  ///
  /// The suggestions module is not removed when [remoteSuggestions] is off: it
  /// still offers the typed text as a search, it just stops asking the provider
  /// for more.
  bool allowsModule(SearchModuleType module) {
    return switch (module) {
      SearchModuleType.history ||
      SearchModuleType.localHistory ||
      SearchModuleType.combinedHistory => savedHistory,
      _ => true,
    };
  }

  @override
  List<Object?> get hashParameters => [remoteSuggestions, savedHistory];
}
