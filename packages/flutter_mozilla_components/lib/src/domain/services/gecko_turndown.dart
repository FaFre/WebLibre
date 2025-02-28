import 'package:flutter_mozilla_components/src/domain/entities/turndown_result.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoTurndownApi();

class GeckoTurndownService {
  Future<List<TurndownResults>> turndownHtml(List<String> htmlList) async {
    final markdownResult = await _apiInstance.getMarkdown(htmlList);

    final results =
        markdownResult
            .cast()
            .map(
              (result) => TurndownResults(
                // ignore: avoid_dynamic_calls valid
                markdown: result['fullContentMarkdown'] as String,
                // ignore: avoid_dynamic_calls valid
                plain: result['fullContentPlain'] as String,
              ),
            )
            .toList();

    return results;
  }
}
