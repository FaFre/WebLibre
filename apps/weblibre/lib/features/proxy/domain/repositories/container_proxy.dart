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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

part 'container_proxy.g.dart';

/// How long a snapshot push waits for the proxy extension to come up.
///
/// Generous, because the first push races engine startup — and while it waits
/// the extension is blocking traffic, so waiting is the safe side.
const _snapshotHealthcheckTimeout = Duration(seconds: 30);

/// How long to wait for the extension to acknowledge an installed snapshot.
///
/// The acknowledgement travels back over the extension's native port. If that
/// port dies mid-flight native fails the pending request, but a reply lost any
/// other way would otherwise hang this future forever — and because pushes are
/// serialised, every later push would queue behind it and routing would freeze
/// at whatever the extension last had.
const _snapshotAckTimeout = Duration(seconds: 20);

const _healthcheckInitialDelay = Duration(milliseconds: 50);
const _healthcheckMaxDelay = Duration(milliseconds: 500);

/// How long a user action waits for routing to be installed before it is
/// refused.
///
/// Shorter than the push timeouts above: this one is blocking a tap, so it has
/// to give up while the user is still willing to wait for it.
const _routingReadyTimeout = Duration(seconds: 8);

/// Pushes the app's routing state into Gecko's proxy extension.
///
/// Snapshots are the only way state reaches the extension, and each carries a
/// generation the extension echoes back. Nothing is recorded as applied until
/// that acknowledgement arrives, so a push that fails leaves the repository
/// out-of-sync on purpose and the next recompute retries it. While out of sync
/// the extension blocks rather than connecting directly, so the failure mode is
/// lost connectivity, never unproxied traffic.
@Riverpod(keepAlive: true)
class ContainerProxyRepository extends _$ContainerProxyRepository {
  final _service = GeckoContainerProxyService();
  final _serviceLock = Lock();

  var _generation = 0;
  ContainerRoutingSnapshot? _appliedSnapshot;

  /// Installs [snapshot] unless the extension already acknowledged an identical
  /// one. Throws if the extension does not acknowledge it.
  Future<void> applySnapshot(ContainerRoutingSnapshot snapshot) {
    return _serviceLock.synchronized(() async {
      // Skipping an identical snapshot is only safe while the extension still
      // holds it. A background script that restarted and lost its replay comes
      // back with an empty store — blocking everything — so "unchanged" must be
      // checked against what the extension acknowledges, not against what this
      // repository last sent.
      if (_appliedSnapshot == snapshot && await isRoutingReady()) return;

      await _waitHealthcheck(
        timeout: _snapshotHealthcheckTimeout,
      ).timeout(_snapshotHealthcheckTimeout);

      _generation += 1;
      await _service
          .applySnapshot(snapshot.toPigeon(_generation))
          .timeout(_snapshotAckTimeout);

      _appliedSnapshot = snapshot;
    });
  }

  /// Whether the extension holds an acknowledged snapshot, i.e. whether
  /// container routing is in force.
  Future<bool> isRoutingReady() async {
    final status = await _service.routingStatus();
    return status.ready;
  }

  /// Waits until container routing is in force, up to [timeout].
  ///
  /// The window this covers is a normal part of a cold start — engine start,
  /// extension install, healthcheck, push, acknowledgement — and a user action
  /// that lands inside it should be delayed by it, not silently dropped. Only a
  /// wait that runs out means routing is genuinely broken.
  ///
  /// A failing probe counts as "not ready yet" and keeps polling: during exactly
  /// this window the native channel may not be up, which throws rather than
  /// answering false.
  Future<bool> waitUntilRoutingReady({
    Duration timeout = _routingReadyTimeout,
  }) async {
    final deadline = DateTime.now().add(timeout);
    var delay = _healthcheckInitialDelay;

    while (true) {
      try {
        if (await isRoutingReady()) return true;
      } catch (error, stackTrace) {
        logger.d(
          'Container routing status probe failed while waiting',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (!DateTime.now().isBefore(deadline)) return false;

      await Future<void>.delayed(delay);
      delay = delay * 2;
      if (delay > _healthcheckMaxDelay) delay = _healthcheckMaxDelay;
    }
  }

  /// Polls the Gecko proxy service with exponential backoff (capped) until it
  /// reports healthy. The previous implementation polled every 25ms, which
  /// burns CPU during the cold-start window before the native plugin is ready.
  ///
  /// [timeout] is checked between polls, so callers wrap the call in a
  /// `.timeout` of the same length as the hard cap: the deadline here can only
  /// be noticed once a `healthcheck()` returns, and one that never does would
  /// otherwise wait forever. Conversely the internal deadline is what stops the
  /// loop from polling on forever behind an outer timeout that already fired.
  Future<void> _waitHealthcheck({required Duration timeout}) async {
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
