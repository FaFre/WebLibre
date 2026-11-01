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

import 'package:clock/clock.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/domain/services/singbox_start_retry.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'proxy_health.g.dart';

/// How long a failed load counts against the proxy that carried it.
const proxyFailedLoadWindow = Duration(seconds: 60);

/// How many different sites have to fail through a proxy within
/// [proxyFailedLoadWindow] before it reads as not responding.
///
/// One is not enough. Through a SOCKS proxy a site that does not exist fails
/// exactly like a dead tunnel — sing-box cannot resolve it and answers with
/// the same general failure Gecko shows as "proxy refused" — so a single
/// mistyped address would mark a working proxy as broken.
const proxyFailedHostsForNotResponding = 2;

/// How long after a (re)start of a proxy ends a failed load through it is
/// still put down to the restart.
const proxyRestartGracePeriod = Duration(seconds: 5);

typedef ProxyFailedLoad = ({String host, DateTime at});

/// What page loads and connection tests have shown about a running proxy.
class ProxyTrafficEvidence with FastEquatable {
  /// Loads that failed through it within [proxyFailedLoadWindow], oldest
  /// first.
  final List<ProxyFailedLoad> failedLoads;

  /// The last connection test through it failed.
  final bool testFailed;

  /// Its WireGuard peer stopped answering handshakes.
  ///
  /// Reported by the runtime itself, which sees every handshake: no load has
  /// to fail first, and a tunnel nobody is using still shows as down.
  final bool peerUnanswered;

  ProxyTrafficEvidence({
    required this.failedLoads,
    required this.testFailed,
    this.peerUnanswered = false,
  });

  bool get notResponding =>
      testFailed ||
      peerUnanswered ||
      failedLoads.map((load) => load.host).toSet().length >=
          proxyFailedHostsForNotResponding;

  bool get isEmpty => failedLoads.isEmpty && !testFailed && !peerUnanswered;

  ProxyTrafficEvidence copyWith({
    List<ProxyFailedLoad>? failedLoads,
    bool? testFailed,
    bool? peerUnanswered,
  }) {
    return ProxyTrafficEvidence(
      failedLoads: failedLoads ?? this.failedLoads,
      testFailed: testFailed ?? this.testFailed,
      peerUnanswered: peerUnanswered ?? this.peerUnanswered,
    );
  }

  @override
  List<Object?> get hashParameters => [failedLoads, testFailed, peerUnanswered];
}

/// Evidence that a proxy which is up is not carrying traffic, keyed by encoded
/// connection id.
///
/// A proxy used to read as connected for as long as its runtime ran, because
/// "running" was all anything knew: a WireGuard tunnel whose peer never
/// answers starts just as successfully as one that works (issue #669). What
/// actually shows a tunnel is down is traffic through it failing, so failed
/// page loads and failed connection tests are collected here — passively, from
/// traffic the user sent anyway, with no probing of its own. So is what the
/// runtime reports of a WireGuard tunnel's handshakes, which go unanswered
/// before any load has had the time to fail (issue #693).
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow].
@Riverpod(keepAlive: true)
class ProxyTrafficHealth extends _$ProxyTrafficHealth {
  Timer? _expiry;

  /// When each sing-box connection last stopped being (re)started.
  final _startEndedAt = <String, DateTime>{};

  /// When the connection test now running through each connection began.
  final _testStartedAt = <String, DateTime>{};

  @override
  Map<String, ProxyTrafficEvidence> build() {
    ref.onDispose(() => _expiry?.cancel());

    ref.listen(singboxProxyStartingConnectionsProvider, (previous, starting) {
      final now = clock.now();
      final ended = {...?previous}.difference(starting);
      for (final id in ended) {
        _startEndedAt[id] = now;
      }
      _clear({...starting, ...ended});
    });

    ref.listen(torProxyServiceProvider.select((status) => status.isBusy), (
      _,
      isBusy,
    ) {
      if (isBusy) _clear({const TorProxyConnectionId().encode()});
    });

    ref.listen(proxyLatencyResultsProvider, (previous, next) {
      for (final MapEntry(key: connectionId, value: result) in next.entries) {
        if (identical(previous?[connectionId], result)) continue;
        _applyTestResult(connectionId.encode(), result);
      }
    });

    final tunnels = ref
        .read(singboxProxyClientProvider)
        .tunnelStream
        .listen(_applyTunnelEvent);
    ref.onDispose(tunnels.cancel);

    return const {};
  }

  /// Records that a page load through [encodedProxyId] failed while the proxy
  /// was up.
  void recordFailedLoad(String encodedProxyId, {required String? host}) {
    final now = clock.now();
    if (_failedFromRestart(encodedProxyId, now: now)) return;

    final current = state[encodedProxyId];
    final failedLoads = [
      ...?current?.failedLoads,
      // A load with no readable host still counts, as a site of its own.
      (host: host ?? '', at: now),
    ];

    state = {
      ...state,
      // Copied rather than rebuilt, so what else is on record — a failed test,
      // an unanswered peer — stays.
      encodedProxyId:
          current?.copyWith(failedLoads: failedLoads) ??
          ProxyTrafficEvidence(failedLoads: failedLoads, testFailed: false),
    };
    _prune();
  }

  /// Records that a page load through [encodedProxyId] got through, which
  /// outweighs every failure before it.
  void recordSuccessfulLoad(String encodedProxyId) => _clear({encodedProxyId});

  /// Whether traffic through [encodedProxyId] that failed at [now] may have
  /// failed because of a (re)start of the proxy rather than its tunnel.
  ///
  /// A failure while the proxy is being (re)started is down to the restart.
  /// So is one of an attempt that began before a restart ended — every
  /// profile shares the instance, so starting or stopping any other one
  /// reloads this one too — and only that: an attempt that began afterwards
  /// had a socket of the new instance, and its failure is the tunnel's.
  ///
  /// When it is not known when the attempt began — a page load, reported on
  /// its own — one reported shortly after a restart may still be its echo:
  /// closing the old instance resets the loads it carried, and those errors
  /// reach the app on their own schedule.
  bool _failedFromRestart(
    String encodedProxyId, {
    required DateTime now,
    DateTime? attemptStartedAt,
  }) {
    if (ref
        .read(singboxProxyStartingConnectionsProvider)
        .contains(encodedProxyId)) {
      return true;
    }

    final startEndedAt = _startEndedAt[encodedProxyId];
    if (startEndedAt == null) return false;
    if (attemptStartedAt != null) return startEndedAt.isAfter(attemptStartedAt);
    return now.difference(startEndedAt) < proxyRestartGracePeriod;
  }

  void _applyTestResult(
    String encodedProxyId,
    AsyncValue<ProxyLatencyData> result,
  ) {
    switch (result) {
      case AsyncData():
        _testStartedAt.remove(encodedProxyId);
        // Traffic got through just now, which outweighs every failure before.
        _clear({encodedProxyId});
      case AsyncError(:final error):
        final testStartedAt = _testStartedAt.remove(encodedProxyId);
        // Says nothing about the tunnel: there was none to test.
        if (error is ProxyNotRunningError) return;
        // Unlike failed loads, a failed test does not age out: one that the
        // restart cut would mark the proxy as not responding until the next
        // test or load got through.
        if (_failedFromRestart(
          encodedProxyId,
          now: clock.now(),
          attemptStartedAt: testStartedAt,
        )) {
          return;
        }

        final current = state[encodedProxyId];
        state = {
          ...state,
          encodedProxyId:
              current?.copyWith(testFailed: true) ??
              ProxyTrafficEvidence(failedLoads: const [], testFailed: true),
        };
      case AsyncLoading():
        _testStartedAt[encodedProxyId] = clock.now();
    }
  }

  /// The runtime's word on whether a WireGuard tunnel's peer answers.
  ///
  /// Not subject to [_failedFromRestart]: the runtime starts over watching
  /// handshakes with every (re)start, so whatever it says is about the
  /// instance running now.
  void _applyTunnelEvent(SingboxProxyTunnelEvent event) {
    // The runtime's profile ids are the encoded connection ids.
    final encodedProxyId = event.profileId;
    final current = state[encodedProxyId];

    if (event.answering) {
      if (current == null || !current.peerUnanswered) return;
      final next = current.copyWith(peerUnanswered: false);
      state = {
        for (final entry in state.entries)
          if (entry.key != encodedProxyId) entry.key: entry.value,
        if (!next.isEmpty) encodedProxyId: next,
      };
      return;
    }

    if (current?.peerUnanswered ?? false) return;
    state = {
      ...state,
      encodedProxyId:
          current?.copyWith(peerUnanswered: true) ??
          ProxyTrafficEvidence(
            failedLoads: const [],
            testFailed: false,
            peerUnanswered: true,
          ),
    };
  }

  void _clear(Set<String> encodedProxyIds) {
    if (!encodedProxyIds.any(state.containsKey)) return;

    state = {
      for (final entry in state.entries)
        if (!encodedProxyIds.contains(entry.key)) entry.key: entry.value,
    };
  }

  /// Drops failed loads that have aged out, and arms a timer for the next one
  /// to, so a proxy stops reading as not responding without any event to
  /// prompt it.
  void _prune() {
    _expiry?.cancel();
    _expiry = null;

    final now = clock.now();
    final cutoff = now.subtract(proxyFailedLoadWindow);
    DateTime? oldestKept;

    final next = <String, ProxyTrafficEvidence>{};
    for (final MapEntry(key: id, value: evidence) in state.entries) {
      final kept = evidence.failedLoads
          .where((load) => load.at.isAfter(cutoff))
          .toList();
      final pruned = evidence.copyWith(failedLoads: kept);
      if (pruned.isEmpty) continue;

      next[id] = pruned;
      for (final load in kept) {
        if (oldestKept == null || load.at.isBefore(oldestKept)) {
          oldestKept = load.at;
        }
      }
    }
    state = next;

    if (oldestKept != null) {
      _expiry = Timer(
        oldestKept.add(proxyFailedLoadWindow).difference(now),
        _prune,
      );
    }
  }
}

/// What the UI says about a proxy connection beyond whether it is on.
enum ProxyConnectionCondition {
  /// It is up, but traffic through it is failing.
  notResponding,

  /// It is not up: an automatic start failed, and another one is scheduled.
  startRetrying,

  /// It is not up: automatic starts failed, and there will be no more.
  startFailed,
}

/// The [ProxyConnectionCondition] for [connectionId], or null when there is
/// nothing to say beyond on or off.
@riverpod
ProxyConnectionCondition? proxyConnectionCondition(
  Ref ref,
  ProxyConnectionId connectionId,
) {
  final encodedId = connectionId.encode();

  final isUp = switch (connectionId) {
    TorProxyConnectionId() => ref.watch(
      torProxyServiceProvider.select(
        (status) => status.usableSocksPort != null,
      ),
    ),
    SingboxProxyConnectionId(:final profileId) => ref.watch(
      runningSingboxProfileIdsProvider.select(
        (running) => running.contains(profileId),
      ),
    ),
  };

  if (isUp) {
    final notResponding = ref.watch(
      proxyTrafficHealthProvider.select(
        (evidence) => evidence[encodedId]?.notResponding ?? false,
      ),
    );
    return notResponding ? ProxyConnectionCondition.notResponding : null;
  }

  if (connectionId case SingboxProxyConnectionId(:final profileId)) {
    final retry = ref.watch(
      singboxStartRetriesProvider.select((retries) => retries[profileId]),
    );
    if (retry != null) {
      return retry.exhausted
          ? ProxyConnectionCondition.startFailed
          : ProxyConnectionCondition.startRetrying;
    }
  }

  return null;
}
