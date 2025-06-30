import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';

part 'brave.g.dart';

@Riverpod(keepAlive: true)
class BraveAutosuggestService extends _$BraveAutosuggestService
    implements ISearchSuggestionProvider {
  static final _baseUrl = Uri.https('search.brave.com', 'api/suggest');

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
