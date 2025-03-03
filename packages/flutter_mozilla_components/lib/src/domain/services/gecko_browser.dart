import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoBrowserApi();

class GeckoBrowserService {
  final GeckoBrowserApi _api;

  GeckoBrowserService({GeckoBrowserApi? api}) : _api = api ?? _apiInstance;

  Future<bool> showNativeFragment() {
    return _api.showNativeFragment();
  }

  Future<void> onTrimMemory(int level) {
    return _api.onTrimMemory(level);
  }
}
