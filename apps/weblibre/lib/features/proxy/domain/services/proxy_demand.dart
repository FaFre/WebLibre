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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';

part 'proxy_demand.g.dart';

/// The native side of the demand handover.
///
/// A provider so tests can drive launches without a platform channel; nothing
/// in the app has a reason to override it.
@Riverpod(keepAlive: true)
GeckoContainerProxyService geckoContainerProxyService(Ref ref) {
  return GeckoContainerProxyService();
}

/// Starts the proxy connections a Custom Tab or PWA launch is waiting on.
///
/// Those launches are decided natively, before the app half exists and often
/// without a window of ours on screen, and a launch into a container that
/// routes through a stopped proxy cannot be served: sing-box and Tor both run
/// inside this isolate. Until now that ended the launch at a dialog — the user
/// was sent to the browser to start the proxy by hand and to tap their shortcut
/// again. But a container the user pointed at a proxy is a standing instruction
/// to use it, so the launch's need is recorded natively and answered here.
///
/// Deliberately unprompted, unlike [ensureProxyStartedForConnection]: the
/// windows these launches wait in are native, there is no Flutter UI in them to
/// ask through, and the question would be about a connection the user already
/// configured for the container they just opened.
///
/// The provider's own state names the connections it is bringing up, in the
/// same shape and for the same reason as [ProxyAutostartService]: routing is
/// published continuously, and an endpoint-less relation must read as "still
/// coming up" rather than as a settled block for as long as that is true.
/// Null until the first read lands, because "nothing is demanded" is an answer
/// this has to *get* — assuming it before asking would publish a block over a
/// launch that is at that moment being served.
@Riverpod(keepAlive: true)
class ProxyDemandService extends _$ProxyDemandService {
  GeckoContainerProxyService get _service =>
      ref.read(geckoContainerProxyServiceProvider);

  var _stopped = false;

  /// How many un-settled launches each connection is being started for.
  ///
  /// A count, not a set: two launches into two containers can name the same
  /// backend, and the first one settling must not withdraw the second one's
  /// claim on it while its start is still in flight.
  final _startingFor = <String, int>{};

  /// Sing-box profiles asked for but not yet handed to the runtime.
  ///
  /// A set the worker drains rather than one call per demand: the runtime takes
  /// its whole profile list at once, so serving two launches separately would
  /// restart the first launch's backend — and drop the port its page had just
  /// been given — to bring the second one up.
  final _wantedProfileIds = <String>{};

  /// The in-flight start per backend, joined rather than queued behind.
  ///
  /// Per backend, because that is the granularity at which starts are actually
  /// independent. One worker for everything would put a launch that needs a
  /// sing-box profile behind a Tor bootstrap it has nothing to do with, and Tor
  /// takes long enough that the launch would give up first.
  Future<void>? _singboxStart;
  Future<void>? _torStart;

  @override
  Set<String>? build() {
    ref.onDispose(() => _stopped = true);
    return null;
  }

  /// Serves the launch waiting now, then every launch that arrives later.
  ///
  /// Never completes in the ordinary case — it is the isolate's standing answer
  /// to "is anything waiting for a proxy?" — so callers leave it unawaited.
  /// Failures are logged and the loop continues: a proxy that cannot come up
  /// costs one launch its page, not every later launch its chance.
  ///
  /// The loop deliberately never awaits a start. A launch is served in the few
  /// seconds it spends waiting, and a Tor bootstrap outlasts that easily — so a
  /// loop that waited for one would leave the next launch's demand unread,
  /// unpublished, and unstarted until it was over, which is the launch giving
  /// up on a proxy nothing had begun to bring up.
  Future<void> run() async {
    // Immediate, and first: it both serves a launch that started this isolate
    // and resolves the state below out of "not asked yet". A blocking wait here
    // would leave every endpoint-less route published as still coming up for as
    // long as no launch ever arrived, which is most of the time.
    final pending = await _service.takeRoutingDemand();
    state = const {};

    if (pending != null) {
      _serve(pending);
    }

    while (!_stopped) {
      final GeckoRoutingDemand demand;
      try {
        demand = await _service.nextRoutingDemand();
      } catch (error, stackTrace) {
        // The channel is gone (a teardown, a detached engine). Nothing is going
        // to arrive over it again, and retrying would spin.
        logger.w(
          'Stopped waiting for launches that need a proxy',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }

      if (_stopped) return;
      _serve(demand);
    }
  }

  /// Claims what [demand] needs and sets its start going, without waiting for
  /// it. Synchronous up to the point the claim is published.
  void _serve(GeckoRoutingDemand demand) {
    final connections = demand.proxyIds
        .map(ProxyConnectionId.decode)
        .nonNulls
        .toSet();

    if (connections.isEmpty) {
      logger.w(
        'A launch in ${demand.contextId} needs ${demand.proxyIds}, '
        'which names no connection this profile knows',
      );
      return;
    }

    logger.i('Starting ${demand.proxyIds} for a launch in ${demand.contextId}');

    final encodedIds = connections.map((id) => id.encode()).toList();

    // Published before anything is awaited, so the routing snapshot recomputed
    // for this start already calls these connections "coming up". Left any
    // later and the extension can be handed a snapshot that resolves the
    // waiting launch's context to a settled block, which releases its held
    // requests into the error page this whole path exists to avoid.
    _claim(encodedIds);

    unawaited(
      _start(connections).whenComplete(() {
        // Settled, whichever way it went: what a failed start owes the snapshot
        // is a block, not indefinite patience. The backends' own "starting"
        // reporting covers the rest of the window.
        _release(encodedIds);
      }),
    );
  }

  Future<void> _start(Set<ProxyConnectionId> connections) async {
    // Neither half throws — both log instead — but a start that found a way to
    // would otherwise surface as an unhandled error on an unawaited future and
    // take the release above with it.
    try {
      await (
        _startSingbox(connections.whereType<SingboxProxyConnectionId>()),
        _startTor(connections.whereType<TorProxyConnectionId>()),
      ).wait;
    } catch (error, stackTrace) {
      logger.e(
        'Failed to start the proxies a launch was waiting for',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _claim(Iterable<String> encodedIds) {
    for (final id in encodedIds) {
      _startingFor.update(id, (count) => count + 1, ifAbsent: () => 1);
    }
    _publishClaims();
  }

  void _release(Iterable<String> encodedIds) {
    for (final id in encodedIds) {
      final count = _startingFor[id];
      if (count == null) continue;

      if (count > 1) {
        _startingFor[id] = count - 1;
      } else {
        _startingFor.remove(id);
      }
    }
    _publishClaims();
  }

  void _publishClaims() {
    // Never back to null: that means "this isolate has not asked native yet",
    // which stops being true the moment [run] gets its first answer.
    state = _startingFor.keys.toSet();
  }

  Future<void> _startSingbox(Iterable<SingboxProxyConnectionId> ids) {
    if (ids.isEmpty) return Future<void>.value();

    _wantedProfileIds.addAll(ids.map((id) => id.profileId));

    // Joining an in-flight worker is safe because it drains to empty before it
    // completes — so a caller that joined one is only released once the
    // profiles it added have been handed to the runtime too.
    return _singboxStart ??= _drainSingboxStarts().whenComplete(() {
      _singboxStart = null;
    });
  }

  Future<void> _drainSingboxStarts() async {
    while (_wantedProfileIds.isNotEmpty) {
      final batch = _wantedProfileIds.toList();
      _wantedProfileIds.clear();

      try {
        // Additive, and in one call. `startProfiles` would be wrong twice over:
        // it is authoritative, so it would stop every profile this launch did
        // not name — including the ones other containers are using right now —
        // and per-id calls would restart the running set once per profile.
        await ref
            .read(singboxProxyRuntimeRepositoryProvider.notifier)
            .ensureProfilesStarted(batch);
      } catch (error, stackTrace) {
        logger.e(
          'Failed to start sing-box proxy profiles $batch for a launch',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _startTor(Iterable<TorProxyConnectionId> ids) {
    if (ids.isEmpty) return Future<void>.value();

    // Joined rather than started again: a second launch arriving mid-bootstrap
    // is waiting for the very connection that is coming up.
    return _torStart ??= _runTorStart().whenComplete(() {
      _torStart = null;
    });
  }

  Future<void> _runTorStart() async {
    try {
      // No connect banner: the window waiting for this is a native one, and the
      // overlay would outlive a bootstrap that finishes before any Flutter view
      // is mounted — the same reason autostart passes this.
      await ref
          .read(startProxyControllerProvider.notifier)
          .startProxy(showNotification: false);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to start the Tor proxy for a launch',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
