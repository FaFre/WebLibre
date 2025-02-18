import 'package:lensai/features/kagi/data/services/autosuggest.dart';
import 'package:lensai/features/kagi/domain/repositories/search_suggestions.dart';
import 'package:lensai/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_suggestions.g.dart';

@Riverpod(keepAlive: true)
ISearchSuggestionProvider defaultSearchSuggestions(Ref ref) {
  return ref.watch(kagiAutosuggestServiceProvider.notifier);
}

@Riverpod()
class SearchSuggestions extends _$SearchSuggestions {
  late void Function(String query) _addQueryBinding;

  void addQuery(String query) => _addQueryBinding(query);

  @override
  Stream<List<String>> build({ISearchSuggestionProvider? suggestionsProvider}) {
    final defaultProvider = ref.watch(defaultSearchSuggestionsProvider);
    final resolvedProvider = suggestionsProvider ?? defaultProvider;

    _addQueryBinding =
        ref
            .watch(
              searchSuggestionsRepositoryProvider(resolvedProvider).notifier,
            )
            .addQuery;

    return ref.watch(searchSuggestionsRepositoryProvider(resolvedProvider));
  }
}
