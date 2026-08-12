/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoContainerProxyApi();

class GeckoContainerProxyService {
  /// Replaces the proxy extension's entire routing state, completing once the
  /// extension acknowledges the [GeckoProxyRoutingSnapshot.generation].
  ///
  /// There is deliberately no incremental variant. The extension's store is
  /// memory-only and starts empty, and an empty store routes directly — so a
  /// state built from unacknowledged messages cannot be told apart from one
  /// that was silently lost.
  Future<int> applySnapshot(GeckoProxyRoutingSnapshot snapshot) {
    return _apiInstance.applySnapshot(snapshot);
  }

  /// Whether the extension's port answers at all. Says nothing about whether
  /// routing is installed — see [routingStatus].
  Future<bool> healthcheck() async {
    try {
      return await _apiInstance.healthcheck().timeout(
        const Duration(milliseconds: 250),
      );
    } catch (e, s) {
      developer.log(
        'Container proxy healthcheck failed',
        error: e,
        stackTrace: s,
        name: 'GeckoContainerProxyService',
      );
      return Future.value(false);
    }
  }

  /// Whether the extension currently holds an acknowledged routing snapshot.
  ///
  /// Answered from native's own record of the last acknowledgement, so it does
  /// not wait on the extension. A false answer means traffic is being blocked,
  /// not that it is flowing unproxied.
  Future<GeckoProxyRoutingStatus> routingStatus() async {
    try {
      return await _apiInstance.routingStatus();
    } catch (e, s) {
      developer.log(
        'Container proxy routing status failed',
        error: e,
        stackTrace: s,
        name: 'GeckoContainerProxyService',
      );
      return GeckoProxyRoutingStatus(ready: false);
    }
  }
}
