import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/user/data/models/general_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'browser_data.g.dart';

@Riverpod(keepAlive: true)
class BrowserDataService extends _$BrowserDataService {
  final _service = GeckoDeleteBrowserDataService();

  var _onStartDeleted = false;

  Future<void> deleteDataOnEngineStart(
    Set<DeleteBrowsingDataType>? types,
  ) async {
    if (!_onStartDeleted) {
      _onStartDeleted = true;
      return deleteData(types);
    }
  }

  Future<void> deleteData(Set<DeleteBrowsingDataType>? types) async {
    if (types != null) {
      for (final type in types) {
        switch (type) {
          case DeleteBrowsingDataType.tabs:
            await _service.deleteTabs();
          case DeleteBrowsingDataType.history:
            await _service.deleteBrowsingHistory();
          case DeleteBrowsingDataType.cookies:
            await _service.deleteCookiesAndSiteData();
          case DeleteBrowsingDataType.cache:
            await _service.deleteCachedFiles();
          case DeleteBrowsingDataType.permissions:
            await _service.deleteSitePermissions();
          case DeleteBrowsingDataType.downloads:
            await _service.deleteDownloads();
        }
      }
    }
  }

  @override
  void build() {}
}
