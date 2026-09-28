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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/search/domain/services/address_completion.dart';
import 'package:weblibre/features/popular_sites/domain/repositories/popular_sites.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'engine_suggestions.g.dart';

@Riverpod()
class EngineSuggestions extends _$EngineSuggestions {
  /// Inline ghost-text completion for the omnibar.
  ///
  /// Sources are tried best first, and the first that completes [query] wins:
  ///
  /// 1. The engine's own autofill, which draws on saved history (Places). Only
  ///    asked when [includeHistory] is set — see `SearchSourcePolicy`.
  /// 2. A saved bookmark whose address continues the typed text. Bookmarks are
  ///    an explicit choice, so they rank above static popularity data.
  /// 3. A popular-domain prefix match from the bundled Tranco-derived
  ///    `sites.db`, so typing "git" still completes to "github.com" without any
  ///    local data. Off with the `popularSitesAutocompleteEnabled` setting.
  Future<String?> getAutocompleteSuggestion(
    String query, {
    bool includeHistory = true,
  }) async {
    if (includeHistory) {
      final engineResult = await ref
          .read(engineSuggestionsServiceProvider)
          .getAutocompleteSuggestion(query)
          .then((result) => result?.text);

      if (engineResult != null) {
        return engineResult;
      }

      if (!ref.mounted) return null;
    }

    final bookmarkResult = await _bookmarkCompletion(query);
    if (bookmarkResult != null) {
      return bookmarkResult;
    }

    if (!ref.mounted) return null;

    final popularSitesEnabled = ref.read(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.popularSitesAutocompleteEnabled,
      ),
    );

    if (!popularSitesEnabled) {
      return null;
    }

    final popularSites = await ref
        .read(popularSitesRepositoryProvider.notifier)
        .searchByPrefix(query, limit: 1);

    return popularSites.isEmpty ? null : popularSites.first.domain;
  }

  Future<String?> _bookmarkCompletion(String query) async {
    // A search phrase can never be an address to complete, and storage search
    // would still have to rank every bookmark matching its words.
    if (query.contains(RegExp(r'\s'))) return null;

    try {
      final bookmarks = await ref
          .read(bookmarksRepositoryProvider.notifier)
          .searchEntries(query, limit: 20);

      return addressCompletionFor(query, bookmarks.map((entry) => entry.url));
    } on PlatformException catch (e) {
      // Storage interrupts a search the next keystroke has superseded.
      if (e.code == 'OperationInterrupted') return null;
      rethrow;
    }
  }

  Future<void> addQuery(
    String query, {
    List<GeckoSuggestionType> providers = const [GeckoSuggestionType.history],
  }) {
    final allowClipboard = ref.read(
      generalSettingsWithDefaultsProvider.select((s) => s.allowClipboardAccess),
    );

    return ref
        .read(engineSuggestionsServiceProvider)
        .querySuggestions(
          query,
          providers: providers,
          allowClipboard: allowClipboard,
        );
  }

  @override
  Stream<List<GeckoSuggestion>> build() {
    final service = ref.watch(engineSuggestionsServiceProvider);
    return ConcatStream([Stream.value([]), service.suggestionsStream]);
  }
}

@Riverpod()
AsyncValue<List<GeckoSuggestion>> engineHistorySuggestions(Ref ref) {
  return ref.watch(
    engineSuggestionsProvider.select(
      (suggestions) => suggestions.whenData(
        (suggestions) => suggestions
            .where(
              (suggestion) =>
                  suggestion.type == GeckoSuggestionType.history &&
                  (suggestion.title.isNotEmpty) &&
                  (suggestion.description.mapNotNull(
                        (url) => Uri.tryParse(url),
                      ) !=
                      null),
            )
            .take(25)
            .toList(),
      ),
    ),
  );
}
