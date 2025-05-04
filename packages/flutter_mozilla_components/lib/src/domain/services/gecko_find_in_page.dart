import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoFindApi();

class GeckoFindInPageService {
  final GeckoFindApi _api;
  final String? tabId;

  GeckoFindInPageService({required this.tabId, GeckoFindApi? api})
    : _api = api ?? _apiInstance;

  Future<void> findAll(String text) {
    return _api.findAll(tabId, text);
  }

  Future<void> findNext(bool forward) {
    return _api.findNext(tabId, forward);
  }

  Future<void> clearMatches() {
    return _api.clearMatches(tabId);
  }
}
