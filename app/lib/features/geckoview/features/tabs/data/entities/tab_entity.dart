import 'package:fast_equatable/fast_equatable.dart';

sealed class TabEntity with FastEquatable {
  String get tabId;
}

class DefaultTabEntity extends TabEntity {
  @override
  final String tabId;

  DefaultTabEntity({required this.tabId});

  @override
  List<Object?> get hashParameters => [tabId];
}

class SearchResultTabEntity extends TabEntity {
  @override
  final String tabId;

  final String searchQuery;

  SearchResultTabEntity({required this.tabId, required this.searchQuery});

  @override
  List<Object?> get hashParameters => [tabId, searchQuery];
}

class TabTreeEntity extends TabEntity {
  @override
  final String tabId;

  final String rootId;

  final int totalTabs;

  TabTreeEntity({
    required this.tabId,
    required this.rootId,
    required this.totalTabs,
  });

  @override
  List<Object?> get hashParameters => [tabId, rootId, totalTabs];
}
