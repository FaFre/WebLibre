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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'engine_suggestions.g.dart';

@Riverpod()
class EngineSuggestions extends _$EngineSuggestions {
  Future<String?> getAutocompleteSuggestion(String query) {
    return ref
        .read(engineSuggestionsServiceProvider)
        .getAutocompleteSuggestion(query)
        .then((result) => result?.text);
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
            .toList(),
      ),
    ),
  );
}
