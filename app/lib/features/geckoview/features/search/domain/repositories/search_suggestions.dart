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
