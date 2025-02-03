import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/user/data/models/general_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_browser_data.g.dart';

@Riverpod()
class DeleteBrowserDataService extends _$DeleteBrowserDataService {
  final _service = GeckoDeleteBrowserDataService();

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
