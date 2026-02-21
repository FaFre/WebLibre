/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoBrowserApi();

class GeckoBrowserService {
  final GeckoBrowserApi _api;

  GeckoBrowserService({GeckoBrowserApi? api}) : _api = api ?? _apiInstance;

  Future<String> getGeckoVersion() {
    return _api.getGeckoVersion();
  }

  Future<void> initialize(
    String profileFolder,
    LogLevel logLevel,
    ContentBlocking contentBlocking,
    AddonCollection? addonCollection,
    String? fxaServerOverride,
    String? syncTokenServerOverride,
  ) {
    return _api.initialize(
      profileFolder,
      logLevel,
      contentBlocking,
      addonCollection,
      fxaServerOverride,
      syncTokenServerOverride,
    );
  }

  Future<bool> showNativeFragment() {
    return _api.showNativeFragment();
  }

  Future<void> onTrimMemory(int level) {
    return _api.onTrimMemory(level);
  }
}
