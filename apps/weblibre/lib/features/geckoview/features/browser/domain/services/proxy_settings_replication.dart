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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'proxy_settings_replication.g.dart';

@Riverpod(keepAlive: true)
class ProxySettingsReplication extends _$ProxySettingsReplication {
  var _isolatedProxyAssignments = <String, String>{};
  var _appliedContainerProxies = <String, String?>{};

  final _recomputeLock = Lock();
  var _recomputeDirty = false;

  Future<void> _ensureProxyConnectionAvailable(
    ProxyConnectionId proxyConnectionId,
  ) async {
    if (proxyConnectionId is! SingboxProxyConnectionId) return;

    try {
      await ref
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .ensureProxyConnectionAvailable(proxyConnectionId);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to make proxy connection $proxyConnectionId available; '
        'assigned traffic will remain blocked',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _queueIsolatedProxyAliasesRecompute() async {
    _recomputeDirty = true;
    if (_recomputeLock.inLock) return;

    await _recomputeLock.synchronized(() async {
      while (_recomputeDirty) {
        _recomputeDirty = false;
        try {
          await _recomputeIsolatedProxyAliases();
        } catch (error, stackTrace) {
          logger.e(
            'Error recomputing isolated proxy aliases',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    });
  }

  Future<void> _recomputeIsolatedProxyAliases() async {
    final db = ref.read(tabDatabaseProvider);

    final contextContainerMap = <String, Set<String>>{};
    final pairs = await db.tabDao.isolatedContextContainerPairs().get();

    for (final pair in pairs) {
      final isolationContextId = pair.isolationContextId;
      final containerId = pair.containerId;

      if (isolationContextId == null || containerId == null) continue;

      contextContainerMap
          .putIfAbsent(isolationContextId, () => <String>{})
          .add(containerId);
    }

    final containers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();

    final containerProxyIds = <String, String>{
      for (final c in containers)
        if (c.metadata.proxyConnectionId case final proxyId?)
          c.id: proxyId.encode(),
    };

    final newAssignments = <String, String>{};
    for (final entry in contextContainerMap.entries) {
      final proxyIds =
          entry.value
              .map((containerId) => containerProxyIds[containerId])
              .nonNulls
              .toSet()
              .toList()
            ..sort();

      if (proxyIds.isEmpty) continue;

      newAssignments[entry.key] = proxyIds.first;

      if (proxyIds.length > 1) {
        // Isolation contexts can hold multiple containers; if they disagree on
        // a proxy connection the alias is forced to pick one. Surface this so
        // the user can split the containers across isolation contexts.
        logger.w(
          'Isolation context ${entry.key} has containers with multiple '
          'proxy connections (${proxyIds.join(', ')}); using ${proxyIds.first}',
        );
      }
    }

    final previousContexts = _isolatedProxyAssignments.keys.toSet();
    final nextContexts = newAssignments.keys.toSet();

    final toRemove = previousContexts.difference(nextContexts);
    for (final contextId in toRemove) {
      await ref
          .read(containerProxyRepositoryProvider.notifier)
          .clearContainerProxy(contextId);
    }

    for (final MapEntry(:key, :value) in newAssignments.entries) {
      if (_isolatedProxyAssignments[key] == value) continue;

      await ref
          .read(containerProxyRepositoryProvider.notifier)
          .setContainerProxy(key, value);
    }

    _isolatedProxyAssignments = newAssignments;
  }

  @override
  void build() {
    ref.listen(
      fireImmediately: true,
      torProxyServiceProvider.select((data) => data.value),
      (previous, next) async {
        await ref
            .read(containerProxyRepositoryProvider.notifier)
            .setTorProxyPort(next?.socksPort);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to torProxyServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      proxyRoutingSettingsWithDefaultsProvider.select(
        (value) => value.privateTabsProxyConnectionId,
      ),
      (previous, next) async {
        final containerProxy = ref.read(
          containerProxyRepositoryProvider.notifier,
        );
        if (next == null) {
          await containerProxy.clearContainerProxy('private');
        } else {
          await containerProxy.setContainerProxy('private', next.encode());
          await _ensureProxyConnectionAvailable(next);
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to generalSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      proxyRoutingSettingsWithDefaultsProvider.select(
        (value) => (value.regularTabsMode, value.regularTabsProxyConnectionId),
      ),
      (previous, next) async {
        final (regularTabsMode, proxyConnectionId) = next;
        final containerProxy = ref.read(
          containerProxyRepositoryProvider.notifier,
        );
        switch (regularTabsMode) {
          case ProxyRegularTabRoutingMode.container:
            await containerProxy.clearContainerProxy('general');
          case ProxyRegularTabRoutingMode.all:
            if (proxyConnectionId == null) {
              await containerProxy.clearContainerProxy('general');
            } else {
              await containerProxy.setContainerProxy(
                'general',
                proxyConnectionId.encode(),
              );
              await _ensureProxyConnectionAvailable(proxyConnectionId);
            }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to generalSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(watchAllAssignedSitesProvider, (previous, next) async {
      if (next.hasValue) {
        await ref
            .read(containerProxyRepositoryProvider.notifier)
            .setSiteAssignments(next.requireValue);
      }
    });

    ref.listen(
      fireImmediately: true,
      watchIsolatedContextContainerMapProvider.select(
        (value) => EquatableValue(value.value),
      ),
      (previous, next) => _queueIsolatedProxyAliasesRecompute(),
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to isolated context proxy aliases',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      watchContainersWithCountProvider.select(
        (value) => EquatableValue(value.value),
      ),
      (previous, next) async {
        await _applyContainerProxies(next.value);
        await _queueIsolatedProxyAliasesRecompute();
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to containersWithCountProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Push per-container proxy assignments to Gecko, reconciling against the
  /// last applied state so a transient mid-loop failure surfaces as a retry
  /// on the next event rather than leaving Gecko half-updated forever.
  Future<void> _applyContainerProxies(
    List<ContainerDataWithCount>? containers,
  ) async {
    if (containers == null) return;

    final desired = <String, String?>{};
    for (final container in containers) {
      final contextId = container.metadata.contextualIdentity;
      if (contextId == null || contextId.isEmpty) continue;
      desired[contextId] = container.metadata.proxyConnectionId?.encode();
    }

    final repo = ref.read(containerProxyRepositoryProvider.notifier);
    final nextApplied = Map<String, String?>.from(_appliedContainerProxies);

    for (final contextId in _appliedContainerProxies.keys.toSet().difference(
      desired.keys.toSet(),
    )) {
      try {
        await repo.clearContainerProxy(contextId);
        nextApplied.remove(contextId);
      } catch (error, stackTrace) {
        logger.e(
          'Failed to clear removed container proxy assignment for $contextId',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final MapEntry(:key, :value) in desired.entries) {
      if (_appliedContainerProxies[key] == value &&
          _appliedContainerProxies.containsKey(key)) {
        continue;
      }
      try {
        if (value != null) {
          final proxyConnectionId = ProxyConnectionId.decode(value);
          if (proxyConnectionId != null) {
            await _ensureProxyConnectionAvailable(proxyConnectionId);
          }
          await repo.setContainerProxy(key, value);
        } else {
          await repo.clearContainerProxy(key);
        }
        nextApplied[key] = value;
      } catch (error, stackTrace) {
        logger.e(
          'Failed to push container proxy assignment for $key',
          error: error,
          stackTrace: stackTrace,
        );
        // Leave nextApplied[key] at its previous value so the next event
        // sees it as out-of-sync and retries.
      }
    }

    _appliedContainerProxies = nextApplied;
  }
}
