import 'package:fast_equatable/fast_equatable.dart';

sealed class TabEntity with FastEquatable {
  String get tabId;
}

class SingleTabEntity extends TabEntity {
  @override
  final String tabId;

  SingleTabEntity({required this.tabId});

  @override
  List<Object?> get hashParameters => [tabId];
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
