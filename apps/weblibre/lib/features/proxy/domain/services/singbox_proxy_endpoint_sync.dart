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
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';

part 'singbox_proxy_endpoint_sync.g.dart';

/// Mirrors the sing-box runtime's active SOCKS endpoints into Gecko's
/// container-proxy registry. Listens to [singboxProxyRuntimeRepositoryProvider]
/// and diffs the previously registered set against the current endpoints.
///
/// Extracted from the runtime repository so that:
/// - the runtime repo only owns process state (start/stop/validate), and
/// - sync is a single side-effect channel — every transition (start, stop,
///   stream-driven refresh, native crash) flows through the same listener,
///   eliminating the duplicate-sync-call hazard that the inline approach had.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.
@Riverpod(keepAlive: true)
class SingboxProxyEndpointSync extends _$SingboxProxyEndpointSync {
  /// Proxy connection ids most recently registered with Gecko. Used to compute
  /// the unregister set on the next sync.
  var _registeredProxyIds = <String>{};

  /// Serialises [_sync] runs so that a fast start→stop→start sequence can't
  /// interleave upserts/removals.
  final _syncLock = Lock();

  Future<void> _sync(SingboxProxyRuntimeState runtimeState) async {
    await _syncLock.synchronized(() async {
      final nextProxyIds = runtimeState.endpoints
          .map((endpoint) => endpoint.profileId)
          .toSet();

      final containerProxy = ref.read(
        containerProxyRepositoryProvider.notifier,
      );

      for (final proxyId in _registeredProxyIds.difference(nextProxyIds)) {
        await containerProxy.removeProxy(proxyId);
      }

      if (runtimeState.endpoints.isNotEmpty) {
        final profiles = await ref
            .read(singboxProxyProfilesRepositoryProvider.notifier)
            .fetchProfiles();
        final profileNames = {
          for (final profile in profiles)
            profile.proxyConnectionId: profile.name,
        };

        for (final endpoint in runtimeState.endpoints) {
          await containerProxy.upsertProxy(
            GeckoProxySettings(
              id: endpoint.profileId,
              title: profileNames[endpoint.profileId] ?? endpoint.profileId,
              type: 'socks',
              host: endpoint.host,
              port: endpoint.port,
              username: endpoint.username,
              password: endpoint.password,
              proxyDNS: true,
              doNotProxyLocal: true,
            ),
          );
        }
      }

      _registeredProxyIds = nextProxyIds;
    });
  }

  @override
  void build() {
    ref.listen<AsyncValue<SingboxProxyRuntimeState>>(
      singboxProxyRuntimeRepositoryProvider,
      fireImmediately: true,
      (previous, next) {
        final runtimeState = next.value;
        if (runtimeState == null) return;
        unawaited(
          _sync(runtimeState).catchError((Object error, StackTrace stackTrace) {
            logger.e(
              'Failed to sync sing-box proxy endpoints to Gecko',
              error: error,
              stackTrace: stackTrace,
            );
          }),
        );
      },
    );
  }
}
