/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoContainerProxyApi();

class GeckoContainerProxyService {
  Future<void> setProxyPort(int port) {
    return _apiInstance.setProxyPort(port);
  }

  Future<void> addContainerProxy(String contextId) {
    return _apiInstance.addContainerProxy(contextId);
  }

  Future<void> removeContainerProxy(String contextId) {
    return _apiInstance.removeContainerProxy(contextId);
  }

  Future<bool> healthcheck() async {
    try {
      return await _apiInstance.healthcheck().timeout(
        const Duration(milliseconds: 250),
      );
    } catch (_) {
      return Future.value(false);
    }
  }
}
