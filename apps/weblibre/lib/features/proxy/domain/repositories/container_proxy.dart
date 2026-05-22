/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

part 'container_proxy.g.dart';

/// Slower-than-default healthcheck timeout for the Tor SOCKS port. Tor's
/// bootstrap can stall when the service is starting up before the proxy
/// service is fully ready; we accept a longer wait here than for other ops.
const _torHealthcheckTimeout = Duration(seconds: 30);

/// Default healthcheck timeout for ordinary proxy CRUD operations.
const _defaultHealthcheckTimeout = Duration(seconds: 10);

/// Outer cap on a single healthcheck wait. Exceeded → [TimeoutException].
const _maxHealthcheckTimeout = Duration(seconds: 15);

const _healthcheckInitialDelay = Duration(milliseconds: 50);
const _healthcheckMaxDelay = Duration(milliseconds: 500);

@Riverpod(keepAlive: true)
class ContainerProxyRepository extends _$ContainerProxyRepository {
  final _service = GeckoContainerProxyService();
  final _serviceLock = Lock();

  Future<void> setTorProxyPort(int? port) {
    return _runLocked(
      healthcheckTimeout: _torHealthcheckTimeout,
      body: () {
        if (port == null) {
          return _service.removeProxy(const TorProxyConnectionId().encode());
        }

        return _service.upsertProxy(
          GeckoProxySettings(
            id: const TorProxyConnectionId().encode(),
            title: 'Tor',
            type: 'socks',
            host: '127.0.0.1',
            port: port,
            proxyDNS: true,
            doNotProxyLocal: true,
          ),
        );
      },
    );
  }

  Future<void> upsertProxy(GeckoProxySettings proxy) {
    return _runLocked(body: () => _service.upsertProxy(proxy));
  }

  Future<void> removeProxy(String proxyId) {
    return _runLocked(body: () => _service.removeProxy(proxyId));
  }

  Future<void> setContainerProxy(String contextId, String proxyId) {
    return _runLocked(
      body: () => _service.setContainerProxy(contextId, proxyId),
    );
  }

  Future<void> clearContainerProxy(String contextId) {
    return _runLocked(body: () => _service.clearContainerProxy(contextId));
  }

  Future<void> removeContainerProxyRelation(String contextId, String proxyId) {
    return _runLocked(
      body: () => _service.removeContainerProxyRelation(contextId, proxyId),
    );
  }

  Future<void> setSiteAssignments(List<SiteAssignment> assignements) {
    return _runLocked(
      body: () => _service.setSiteAssignments(
        Map.fromEntries(
          assignements.map(
            (e) => MapEntry(
              e.assignedSite.origin,
              e.contextualIdentity ?? 'general',
            ),
          ),
        ),
      ),
    );
  }

  /// Serialises [body] behind the service lock after the underlying Gecko
  /// proxy service reports healthy. Replaces the per-method boilerplate that
  /// each public mutator used to repeat.
  Future<T> _runLocked<T>({
    required Future<T> Function() body,
    Duration healthcheckTimeout = _defaultHealthcheckTimeout,
  }) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(healthcheckTimeout);
      return body();
    });
  }

  /// Polls the Gecko proxy service with exponential backoff (capped) until it
  /// reports healthy. The previous implementation polled every 25ms, which
  /// burns CPU during the cold-start window before the native plugin is ready.
  Future<void> _waitHealthcheck({
    Duration timeout = _maxHealthcheckTimeout,
  }) async {
    final startTime = DateTime.now();
    var delay = _healthcheckInitialDelay;

    while (!await _service.healthcheck()) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Timed out waiting for proxy service');
      }

      await Future<void>.delayed(delay);
      delay = delay * 2;
      if (delay > _healthcheckMaxDelay) delay = _healthcheckMaxDelay;
    }
  }

  @override
  void build() {
    return;
  }
}
