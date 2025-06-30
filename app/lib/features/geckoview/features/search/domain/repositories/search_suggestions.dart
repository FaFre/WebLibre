import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'search_suggestions.g.dart';

@Riverpod(keepAlive: true)
class SearchSuggestionsRepository extends _$SearchSuggestionsRepository {
  final LRUCache<String, List<String>> _cache;

  late StreamController<String> _queryStreamController;

  SearchSuggestionsRepository() : _cache = LRUCache(100);

  void addQuery(String query) {
    if (!_queryStreamController.isClosed) {
      _queryStreamController.add(query);
    }
  }

  @override
  Raw<Stream<List<String>>> build(
    ISearchSuggestionProvider suggestionsProvider,
  ) {
    _queryStreamController = StreamController();
    ref.onDispose(() async {
      await _queryStreamController.close();
    });

    return _queryStreamController.stream
        .sampleTime(const Duration(milliseconds: 100))
        .switchMap<List<String>>((query) {
          if (query.isEmpty) {
            return Stream.value([]);
          }

          final cached = _cache.get(query);
          if (cached != null) {
            return Stream.value(cached);
          }

          return suggestionsProvider
              // ignore: discarded_futures is used as stream
              .getSuggestions(query)
              // ignore: discarded_futures is used as stream
              .then((result) {
                result.onSuccess((result) {
                  _cache.set(query, result);
                });

                return result.value;
              })
              .asStream();
        })
        .asBroadcastStream();
  }
}
