import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

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
    return ref
        .read(engineSuggestionsServiceProvider)
        .querySuggestions(query, providers: providers);
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
        (suggestions) =>
            suggestions
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
