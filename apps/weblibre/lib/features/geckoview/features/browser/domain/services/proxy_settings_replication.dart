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
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'proxy_settings_replication.g.dart';

sealed class _ProxyAssignment with FastEquatable {
  _ProxyAssignment();

  factory _ProxyAssignment.inherit() = _InheritProxyAssignment;

  factory _ProxyAssignment.direct(String scopeId) = _DirectProxyAssignment;

  factory _ProxyAssignment.explicit(String proxyId) = _ExplicitProxyAssignment;
}

final class _InheritProxyAssignment extends _ProxyAssignment {
  _InheritProxyAssignment();

  @override
  List<Object?> get hashParameters => const ['inherit'];
}

final class _DirectProxyAssignment extends _ProxyAssignment {
  final String scopeId;

  _DirectProxyAssignment(this.scopeId);

  @override
  List<Object?> get hashParameters => [scopeId];
}

final class _ExplicitProxyAssignment extends _ProxyAssignment {
  final String proxyId;

  _ExplicitProxyAssignment(this.proxyId);

  @override
  List<Object?> get hashParameters => [proxyId];
}

@Riverpod(keepAlive: true)
class ProxySettingsReplication extends _$ProxySettingsReplication {
  var _isolatedProxyAssignments = <String, _ProxyAssignment>{};
  var _appliedContainerProxies = <String, _ProxyAssignment>{};

  final _recomputeLock = Lock();
  var _recomputeDirty = false;

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

    final containerAssignments = <String, _ProxyAssignment>{
      for (final c in containers)
        if (c.metadata.contextualIdentity case final contextId?)
          c.id: switch (c.metadata.proxyConnectionId) {
            final proxyId? => _ProxyAssignment.explicit(proxyId.encode()),
            null when c.metadata.bypassGlobalProxy => _ProxyAssignment.direct(
              contextId,
            ),
            null => _ProxyAssignment.inherit(),
          },
    };

    final newAssignments = <String, _ProxyAssignment>{};
    for (final entry in contextContainerMap.entries) {
      final assignments = entry.value
          .map((containerId) => containerAssignments[containerId])
          .nonNulls
          .toList();

      if (assignments.isEmpty) continue;

      final proxyIds =
          assignments
              .whereType<_ExplicitProxyAssignment>()
              .map((assignment) => assignment.proxyId)
              .toSet()
              .toList()
            ..sort();
      final directScopeIds =
          assignments
              .whereType<_DirectProxyAssignment>()
              .map((assignment) => assignment.scopeId)
              .toSet()
              .toList()
            ..sort();
      final hasInheritedAssignment = assignments.any(
        (assignment) => assignment is _InheritProxyAssignment,
      );

      final chosenAssignment = proxyIds.isNotEmpty
          ? _ProxyAssignment.explicit(proxyIds.first)
          : directScopeIds.isNotEmpty && !hasInheritedAssignment
          ? _ProxyAssignment.direct(directScopeIds.first)
          : _ProxyAssignment.inherit();
      if (chosenAssignment is! _InheritProxyAssignment) {
        newAssignments[entry.key] = chosenAssignment;
      }
      final chosenLabel = switch (chosenAssignment) {
        _DirectProxyAssignment(:final scopeId) => 'direct:$scopeId',
        _ExplicitProxyAssignment(:final proxyId) => proxyId,
        _InheritProxyAssignment() => 'inherit',
      };

      final distinctAssignmentCount =
          proxyIds.length +
          directScopeIds.length +
          (hasInheritedAssignment ? 1 : 0);
      if (distinctAssignmentCount > 1) {
        // Isolation contexts can hold multiple containers; if they disagree on
        // routing, the alias is forced to pick one. Surface this so the user
        // can split the containers across isolation contexts.
        logger.w(
          'Isolation context ${entry.key} has containers with multiple '
          'proxy routing assignments '
          '(${[if (hasInheritedAssignment) 'inherit', ...directScopeIds.map((id) => 'direct:$id'), ...proxyIds].join(', ')}); using $chosenLabel',
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

      await _applyProxyAssignment(key, value);
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

    ref.listen(watchStrictContextAssignmentsProvider, (previous, next) async {
      if (next.hasValue) {
        await ref
            .read(containerProxyRepositoryProvider.notifier)
            .setStrictContexts(next.requireValue);
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

    final desired = <String, _ProxyAssignment>{};
    for (final container in containers) {
      final contextId = container.metadata.contextualIdentity;
      if (contextId == null || contextId.isEmpty) continue;
      final proxyConnectionId = container.metadata.proxyConnectionId;
      desired[contextId] = proxyConnectionId != null
          ? _ProxyAssignment.explicit(proxyConnectionId.encode())
          : container.metadata.bypassGlobalProxy
          ? _ProxyAssignment.direct(contextId)
          : _ProxyAssignment.inherit();
    }

    final repo = ref.read(containerProxyRepositoryProvider.notifier);
    final nextApplied = Map<String, _ProxyAssignment>.from(
      _appliedContainerProxies,
    );

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
        await _applyProxyAssignment(key, value);
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

  Future<void> _applyProxyAssignment(
    String contextId,
    _ProxyAssignment assignment,
  ) async {
    final repo = ref.read(containerProxyRepositoryProvider.notifier);
    switch (assignment) {
      case _ExplicitProxyAssignment(:final proxyId):
        await repo.setContainerProxy(contextId, proxyId);
      case _DirectProxyAssignment(:final scopeId):
        await repo.setContainerDirectConnection(contextId, scopeId: scopeId);
      case _InheritProxyAssignment():
        await repo.clearContainerProxy(contextId);
    }
  }
}
