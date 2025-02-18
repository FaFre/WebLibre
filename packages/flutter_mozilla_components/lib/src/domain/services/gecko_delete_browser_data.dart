import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoDeleteBrowsingDataController();

class GeckoDeleteBrowserDataService {
  final GeckoDeleteBrowsingDataController _api;

  GeckoDeleteBrowserDataService({GeckoDeleteBrowsingDataController? api})
    : _api = api ?? _apiInstance;

  Future<void> deleteTabs() {
    return _api.deleteTabs();
  }

  Future<void> deleteBrowsingHistory() {
    return _api.deleteBrowsingHistory();
  }

  Future<void> deleteCookiesAndSiteData() {
    return _api.deleteCookiesAndSiteData();
  }

  Future<void> deleteCachedFiles() {
    return _api.deleteCachedFiles();
  }

  Future<void> deleteSitePermissions() {
    return _api.deleteSitePermissions();
  }

  Future<void> deleteDownloads() {
    return _api.deleteDownloads();
  }
}
