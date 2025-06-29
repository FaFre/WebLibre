/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoIconsApi();

class GeckoIconService {
  final GeckoIconsApi _api;

  GeckoIconService({GeckoIconsApi? api}) : _api = api ?? _apiInstance;

  Future<IconResult> loadIcon({
    required Uri url,
    List<Resource> resources = const [],
    IconSize size = IconSize.defaultSize,
    bool isPrivate = false,
    bool waitOnNetworkLoad = true,
  }) {
    return _api.loadIcon(
      IconRequest(
        url: url.toString(),
        size: size,
        resources: resources,
        isPrivate: isPrivate,
        waitOnNetworkLoad: waitOnNetworkLoad,
      ),
    );
  }
}
