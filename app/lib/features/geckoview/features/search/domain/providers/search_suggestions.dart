/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/search/domain/repositories/search_suggestions.dart';
import 'package:weblibre/features/search/domain/autosuggest/brave.dart';
import 'package:weblibre/features/search/domain/autosuggest/duckduckgo.dart';
import 'package:weblibre/features/search/domain/autosuggest/empty.dart';
import 'package:weblibre/features/search/domain/autosuggest/kagi.dart';
import 'package:weblibre/features/search/domain/autosuggest/qwant.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'search_suggestions.g.dart';

@Riverpod(keepAlive: true)
ISearchSuggestionProvider defaultSearchSuggestions(Ref ref) {
  final provider = ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.defaultSearchSuggestionsProvider,
    ),
  );

  return switch (provider) {
    SearchSuggestionProviders.none => ref.watch(
      emptyAutosuggestServiceProvider.notifier,
    ),
    SearchSuggestionProviders.brave => ref.watch(
      braveAutosuggestServiceProvider.notifier,
    ),
    SearchSuggestionProviders.ddg => ref.watch(
      duckDuckGoAutosuggestServiceProvider.notifier,
    ),
    SearchSuggestionProviders.kagi => ref.watch(
      kagiAutosuggestServiceProvider.notifier,
    ),
    SearchSuggestionProviders.qwant => ref.watch(
      qwantAutosuggestServiceProvider.notifier,
    ),
  };
}

@Riverpod()
class SearchSuggestions extends _$SearchSuggestions {
  late void Function(String query) _addQueryBinding;

  void addQuery(String query) => _addQueryBinding(query);

  @override
  Stream<List<String>> build({ISearchSuggestionProvider? suggestionsProvider}) {
    final defaultProvider = ref.watch(defaultSearchSuggestionsProvider);
    final resolvedProvider = suggestionsProvider ?? defaultProvider;

    _addQueryBinding = ref
        .watch(searchSuggestionsRepositoryProvider(resolvedProvider).notifier)
        .addQuery;

    return ref.watch(searchSuggestionsRepositoryProvider(resolvedProvider));
  }
}
