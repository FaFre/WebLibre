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

part 'tor_proxy.g.dart';

@Riverpod(keepAlive: true)
class TorProxyRepository extends _$TorProxyRepository {
  final _service = GeckoContainerProxyService();
  final _serviceLock = Lock();

  Future<void> setProxyPort(int port) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 30));

      return _service.setProxyPort(port);
    });
  }

  Future<void> addContainerProxy(String contextId) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 10));

      return _service.addContainerProxy(contextId);
    });
  }

  Future<void> removeContainerProxy(String contextId) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 10));

      return _service.removeContainerProxy(contextId);
    });
  }

  Future<void> setSiteAssignments(List<SiteAssignment> assignements) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 10));

      return _service.setSiteAssignments(
        Map.fromEntries(
          assignements.map(
            (e) => MapEntry(
              e.assignedSite.origin,
              e.contextualIdentity ?? 'general',
            ),
          ),
        ),
      );
    });
  }

  Future<void> _waitHealthcheck({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final startTime = DateTime.now();

    var healthy = await _service.healthcheck();
    while (!healthy) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Timed out waiting for proxy service');
      }

      await Future.delayed(const Duration(milliseconds: 25));
      healthy = await _service.healthcheck();
    }
  }

  @override
  void build() {
    return;
  }
}
