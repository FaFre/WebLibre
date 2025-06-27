import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/search/domain/repositories/search_suggestions.dart';
import 'package:weblibre/features/search/domain/autosuggest/brave.dart';
import 'package:weblibre/features/search/domain/autosuggest/duckduckgo.dart';
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
