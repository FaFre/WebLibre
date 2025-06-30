import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';

part 'empty.g.dart';

@Riverpod(keepAlive: true)
class EmptyAutosuggestService extends _$EmptyAutosuggestService
    implements ISearchSuggestionProvider {
  @override
  void build() {}

  @override
  Future<Result<List<String>>> getSuggestions(String query) {
    return Future.value(Result.success([]));
  }
}
