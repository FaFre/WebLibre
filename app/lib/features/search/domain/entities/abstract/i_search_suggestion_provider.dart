import 'package:exceptions/exceptions.dart';

enum SearchSuggestionProviders {
  none('Disabled', null),
  brave('Brave', 'brave'),
  ddg('DuckDuckGo', 'ddg'),
  kagi('Kagi', 'kagi'),
  qwant('Qwant', 'qwant');

  final String label;
  final String? relatedBang;

  const SearchSuggestionProviders(this.label, this.relatedBang);
}

abstract interface class ISearchSuggestionProvider {
  Future<Result<List<String>>> getSuggestions(String query);
}
