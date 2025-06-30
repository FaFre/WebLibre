// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';

part 'qwant.g.dart';

@Riverpod(keepAlive: true)
class QwantAutosuggestService extends _$QwantAutosuggestService
    implements ISearchSuggestionProvider {
  static final _baseUrl = Uri.https('api.qwant.com', 'v3/suggest');

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

      final results =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (results['status'] != 'success') {
        throw Exception('qwant api error');
      }

      final items = results['data']['items'] as List;
      return items.map((item) => item['value'] as String).toList();
    }, exceptionHandler: handleHttpError);
  }
}
