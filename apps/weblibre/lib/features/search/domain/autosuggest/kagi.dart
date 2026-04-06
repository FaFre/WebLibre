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
import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';

part 'kagi.g.dart';

@Riverpod(keepAlive: true)
class KagiAutosuggestService extends _$KagiAutosuggestService
    implements ISearchSuggestionProvider {
  static final _baseUrl = Uri.https('kagi.com', 'api/autosuggest');

  late http.Client _client;

  @override
  void build() {
    _client = http.Client();

    ref.onDispose(() {
      _client.close();
    });
  }

  @override
  Future<Result<List<String>>> getSuggestions(String query) {
    return Result.fromAsync(() async {
      final response = await _client
          .get(_baseUrl.replace(queryParameters: {'q': query}))
          .timeout(const Duration(seconds: 5));

      final results = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return switch (results.last) {
        final String result => [result],
        final List resultList => resultList.cast(),
        _ => [],
      };
    }, exceptionHandler: handleHttpError);
  }
}
