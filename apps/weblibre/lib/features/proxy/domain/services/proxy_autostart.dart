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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'proxy_autostart.g.dart';

/// Starts the proxy connections the user flagged for autostart as part of app
/// startup, so tabs bound to them are usable without the "start this proxy?"
/// prompt.
///
/// While a start is in flight [pendingStartFor] hands the caller the running
/// future instead of a "not running" snapshot — the connection is on its way
/// up, so prompting the user for it would be wrong.
///
/// The provider's own state answers the same question for everything that
/// cannot hold a future: the encoded ids startup is still going to bring up,
/// or null while the configuration that decides them has not been read yet.
/// [ProxyStartExpectation] reads it to tell a relation whose backend is still
/// coming up from one whose backend is simply not running, and startup
/// publishes routing long before [run] is even called — so "nothing is known
/// yet" has to be the initial answer, not "nothing is pending".
///
/// Deliberately a set rather than a "startup has finished" flag. The flag made
/// every connection look pending until the slowest start settled, so a
/// container routed through a sing-box profile nobody was starting sat out the
/// extension's whole budget behind an unrelated Tor bootstrap. What ends the
/// unknown state is the *lookups* landing; from then on the answer is per
/// connection.
@Riverpod(keepAlive: true)
class ProxyAutostartService extends _$ProxyAutostartService {
  /// Completes when the autostart profile set is known. Published before the
  /// first suspension of [run] so the lookup window is never mistaken for
  /// "nothing is autostarting".
  Future<void>? _singboxLookup;

  /// Null until the lookup lands, then the set that autostart will bring up
  /// (empty when nothing is flagged or the lookup failed).
  Set<String>? _singboxProfileIds;
  Future<void>? _singboxStart;

  Future<void>? _torLookup;
  bool? _torAutostart;
  Future<void>? _torStart;

  /// Each backend's contribution to [state], null until its lookup lands.
  ///
  /// Kept apart so the two can resolve independently, and republished as a
  /// whole: a set assembled from one landed lookup and one outstanding one
  /// would present a connection nothing has decided about yet as one nothing
  /// is starting, which is the answer that fails a request rather than holding
  /// it.
  Set<String>? _singboxPending;
  Set<String>? _torPending;

  void _publishPending() {
    final singbox = _singboxPending;
    final tor = _torPending;
    if (singbox == null || tor == null) return;

    state = {...singbox, ...tor};
  }

  /// Kicks off every configured autostart connection and completes once they
  /// have all settled. Failures are logged, never thrown: a proxy that cannot
  /// come up must not take app startup down with it.
  Future<void> run() async {
    try {
      await (_startSingboxProfiles(), _startTor()).wait;
    } finally {
      // In a `finally` because what this publishes is "startup is no longer
      // going to bring anything up", which is just as true of a sequence that
      // failed. Leaving anything pending would hold requests for connections
      // nothing is starting any more, for as long as the extension's budget
      // allows.
      state = const {};
    }
  }

  /// The in-flight autostart for [connectionId], or null when it is not part
  /// of this startup (or has already settled).
  ///
  /// While the lookups are still running nothing is known yet, so the returned
  /// future resolves the lookup first and only then waits on a start that
  /// actually covers [connectionId] — an unrelated connection is never held
  /// behind someone else's (potentially slow) bootstrap.
  Future<void>? pendingStartFor(ProxyConnectionId connectionId) {
    return switch (connectionId) {
      TorProxyConnectionId() => _pendingTorStart(),
      SingboxProxyConnectionId(:final profileId) => _pendingSingboxStart(
        profileId,
      ),
    };
  }

  Future<void>? _pendingSingboxStart(String profileId) {
    final resolvedProfileIds = _singboxProfileIds;
    if (resolvedProfileIds != null) {
      return resolvedProfileIds.contains(profileId) ? _singboxStart : null;
    }

    final lookup = _singboxLookup;
    if (lookup == null) return null;

    return lookup.then(
      (_) => _pendingSingboxStart(profileId) ?? Future<void>.value(),
    );
  }

  Future<void>? _pendingTorStart() {
    final resolvedAutostart = _torAutostart;
    if (resolvedAutostart != null) {
      return resolvedAutostart ? _torStart : null;
    }

    final lookup = _torLookup;
    if (lookup == null) return null;

    return lookup.then((_) => _pendingTorStart() ?? Future<void>.value());
  }

  Future<void> _startSingboxProfiles() async {
    final lookup = Completer<void>();
    _singboxLookup = lookup.future;

    List<String> profileIds;
    try {
      final profiles = await ref
          .read(singboxProxyProfilesRepositoryProvider.notifier)
          .fetchAutostartProfiles();
      profileIds = profiles.map((profile) => profile.id).toList();
    } catch (error, stackTrace) {
      logger.e(
        'Failed to read autostart sing-box proxy profiles',
        error: error,
        stackTrace: stackTrace,
      );
      profileIds = const [];
    }

    // Resolve the set before waking the lookup waiters, so they immediately see
    // whether their connection is part of this startup. No await may separate
    // the completion from the _singboxStart assignment below.
    _singboxProfileIds = profileIds.toSet();
    _singboxPending = {
      for (final profileId in profileIds)
        SingboxProxyConnectionId(profileId).encode(),
    };
    _publishPending();
    lookup.complete();

    if (profileIds.isEmpty) return;

    // A single start call brings the whole set up in one runtime config, which
    // is both cheaper and avoids restarting already-started endpoints.
    final pending = _runSingboxStart(profileIds);
    _singboxStart = pending;

    await pending;
  }

  Future<void> _runSingboxStart(List<String> profileIds) async {
    try {
      await ref
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .startProfiles(profileIds);
      logger.i('Autostarted sing-box proxy profiles: $profileIds');
    } catch (error, stackTrace) {
      logger.e(
        'Failed to autostart sing-box proxy profiles $profileIds',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _singboxStart = null;
      // Settled, whichever way it went. A start that threw is not one anything
      // is still waiting for.
      _singboxPending = const {};
      _publishPending();
    }
  }

  Future<void> _startTor() async {
    final lookup = Completer<void>();
    _torLookup = lookup.future;

    bool autostart;
    try {
      final torSettings = await ref
          .read(torSettingsRepositoryProvider.notifier)
          .fetchSettings();
      autostart = torSettings.autostart;
    } catch (error, stackTrace) {
      logger.e(
        'Failed to read Tor autostart setting',
        error: error,
        stackTrace: stackTrace,
      );
      autostart = false;
    }

    _torAutostart = autostart;
    _torPending = autostart
        ? {const TorProxyConnectionId().encode()}
        : const {};
    _publishPending();
    lookup.complete();

    if (!autostart) return;

    final pending = _runTorStart();
    _torStart = pending;

    await pending;
  }

  Future<void> _runTorStart() async {
    try {
      // No connect notification: the user opted into this happening on every
      // launch, and the overlay would outlive a bootstrap that finishes before
      // the browser view mounts.
      await ref
          .read(startProxyControllerProvider.notifier)
          .startProxy(showNotification: false);
      logger.i('Autostarted Tor proxy');
    } catch (error, stackTrace) {
      logger.e(
        'Failed to autostart Tor proxy',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _torStart = null;
      _torPending = const {};
      _publishPending();
    }
  }

  /// What startup is still going to bring up, or null while it does not know.
  /// See the class doc: the initial `null` is load-bearing, because routing is
  /// published before startup runs autostart.
  @override
  Set<String>? build() => null;
}
