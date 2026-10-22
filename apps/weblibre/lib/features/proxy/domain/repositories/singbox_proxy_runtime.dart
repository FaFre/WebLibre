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
import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals, setEquals;
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/extensions/proxy_log_level_x.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/services/dns_config_resolver.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/proxy_dns_override.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

part 'singbox_proxy_runtime.g.dart';

abstract interface class SingboxProxyClient {
  Stream<SingboxProxyRuntimeState> get stateStream;

  Stream<SingboxProxyLogMessage> get logStream;

  Future<String?> validateProfile(SingboxProxyProfile profile);

  Future<String?> probeProfile(SingboxProxyProfile profile);

  Future<SingboxProxyConfigResult> buildConfig(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  });

  Future<SingboxProxyRuntimeState> start(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  });

  Future<void> stop(List<String> profileIds);

  Future<void> stopAll();

  Future<SingboxProxyRuntimeState> getState();
}

class FlutterSingboxProxyClient implements SingboxProxyClient {
  final _plugin = FlutterSingboxProxy();

  @override
  Stream<SingboxProxyRuntimeState> get stateStream => _plugin.stateStream;

  @override
  Stream<SingboxProxyLogMessage> get logStream => _plugin.logStream;

  @override
  Future<String?> validateProfile(SingboxProxyProfile profile) {
    return _plugin.validateProfile(profile);
  }

  @override
  Future<String?> probeProfile(SingboxProxyProfile profile) {
    return _plugin.probeProfile(profile);
  }

  @override
  Future<SingboxProxyConfigResult> buildConfig(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _plugin.buildConfig(profiles, options: options);
  }

  @override
  Future<SingboxProxyRuntimeState> start(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _plugin.start(profiles, options: options);
  }

  @override
  Future<void> stop(List<String> profileIds) => _plugin.stop(profileIds);

  @override
  Future<void> stopAll() => _plugin.stopAll();

  @override
  Future<SingboxProxyRuntimeState> getState() => _plugin.getState();
}

/// [profileIds] as the encoded connection ids the runtime and routing use.
Set<String> _encodedConnectionIds(Iterable<String> profileIds) => {
  for (final profileId in profileIds)
    SingboxProxyConnectionId(profileId).encode(),
};

/// The sing-box profile id inside [encodedId], or null for another kind of
/// connection.
String? singboxProfileIdOf(String encodedId) =>
    switch (ProxyConnectionId.decode(encodedId)) {
      SingboxProxyConnectionId(:final profileId) => profileId,
      _ => null,
    };

extension SingboxProxyRuntimeStateProfiles on SingboxProxyRuntimeState {
  /// The sing-box profiles this state has running.
  ///
  /// Only a running runtime has any. After a failed start native keeps the
  /// last endpoints in its ERROR state for reporting, but their instance is
  /// closed: read as running, they made a start of exactly those profiles
  /// return without starting anything — a retry then counted as a success and
  /// they stayed down for good.
  ///
  Set<String> get runningProfileIds {
    if (status != SingboxProxyRuntimeStatus.running) return const {};
    return {
      for (final endpoint in endpoints) ?singboxProfileIdOf(endpoint.profileId),
    };
  }
}

extension SingboxProxyRuntimeValueProfiles
    on AsyncValue<SingboxProxyRuntimeState> {
  /// The sing-box profiles running according to this value — only when it
  /// holds data.
  ///
  /// A loading or failed value still carries the last data it had, which
  /// after a failed start lists profiles that are down: read through `.value`,
  /// the menu offered to stop a profile that was down, a start prompt counted
  /// it as started, and a profile being retried read as up.
  Set<String> get runningProfileIds => switch (this) {
    AsyncData(:final value) => value.runningProfileIds,
    _ => const {},
  };
}

/// What a start handed the runtime.
typedef _RuntimeStart = ({
  List<SingboxProxyProfile> profiles,
  SingboxProxyRuntimeOptions options,
});

@Riverpod(keepAlive: true)
SingboxProxyClient singboxProxyClient(Ref ref) {
  return FlutterSingboxProxyClient();
}

/// The sing-box profiles that are running, by profile id.
///
/// What every reader outside the repository asks of the runtime, so none has
/// to remember both halves of "running": a runtime status of running, and a
/// state that holds data ([SingboxProxyRuntimeValueProfiles]).
@Riverpod(keepAlive: true)
class RunningSingboxProfileIds extends _$RunningSingboxProfileIds {
  @override
  Set<String> build() =>
      ref.watch(singboxProxyRuntimeRepositoryProvider).runningProfileIds;

  @override
  bool updateShouldNotify(Set<String> previous, Set<String> next) =>
      !setEquals(previous, next);
}

/// The proxy connections a sing-box start is in flight for, encoded.
///
/// The runtime's own status is one flag for the whole runtime — it does not
/// report which profiles a start covers until they are running — so reading it
/// as "sing-box is starting" holds every endpoint-less sing-box relation behind
/// whichever profile happens to be coming up. The ids are known at exactly one
/// place, the start call, so that is where they are recorded.
///
/// Published separately from [SingboxProxyRuntimeRepository]'s own state
/// because it answers a different question — "is something bringing this
/// connection up?" rather than "what is running?" — and because the routing
/// snapshot has to recompute when it changes.
@Riverpod(keepAlive: true)
class SingboxProxyStartingConnections
    extends _$SingboxProxyStartingConnections {
  /// How many holds each id is announced under.
  ///
  /// Counted rather than a set because holds nest: a start that puts the
  /// running set back after a failed one runs inside a hold covering both, and
  /// the inner start ending must not release ids the outer hold still covers —
  /// in the gap the routing would block the very profiles being restored.
  final _holds = <String, int>{};

  @override
  Set<String> build() => const {};

  void _begin(Set<String> encodedIds) {
    if (encodedIds.isEmpty) return;
    for (final id in encodedIds) {
      _holds.update(id, (count) => count + 1, ifAbsent: () => 1);
    }
    state = _holds.keys.toSet();
  }

  void _end(Set<String> encodedIds) {
    if (encodedIds.isEmpty) return;
    for (final id in encodedIds) {
      final count = _holds[id];
      if (count == null) continue;

      if (count > 1) {
        _holds[id] = count - 1;
      } else {
        _holds.remove(id);
      }
    }
    state = _holds.keys.toSet();
  }
}

typedef SingboxProfileRejection = ({String name, String message});

/// Profiles sing-box refused to run, keyed by profile id, with its reason and
/// the profile's name for messages.
///
/// Thrown by a start that left them out. The profiles it was given that
/// sing-box accepted are running when this arrives: unlike any other start
/// failure there is nothing to put back, and since a config sing-box refuses
/// does not fix itself, nothing to retry.
class SingboxProfilesRejected implements Exception {
  final Map<String, SingboxProfileRejection> rejections;

  const SingboxProfilesRejected(this.rejections);

  @override
  String toString() => rejections.values
      .map((rejection) => '"${rejection.name}": ${rejection.message}')
      .join('; ');
}

/// Profiles a failed start took down that putting them back did not bring up
/// again, as [SingboxProxyRuntimeRepository] last reported them.
///
/// Nobody asked for them to go down, and the error that reaches the caller is
/// the start's, not theirs — so they are announced here for the retries to
/// pick up, rather than staying down with nothing to say so. A provider of its
/// own because the retries already watch the runtime, and the runtime must not
/// depend on them in turn.
@Riverpod(keepAlive: true)
class SingboxProxyLostProfiles extends _$SingboxProxyLostProfiles {
  @override
  ({Set<String> profileIds, bool permanent})? build() => null;

  void _report(Iterable<String> profileIds, {required bool permanent}) {
    state = (profileIds: profileIds.toSet(), permanent: permanent);
  }
}

/// A retry that was not attempted because the profile's probe says it would
/// fail the same way again — see [SingboxProxyRuntimeRepository.retryProfile].
class SingboxProbeFailed implements Exception {
  final String reason;

  const SingboxProbeFailed(this.reason);

  @override
  String toString() => reason;
}

@Riverpod(keepAlive: true)
class SingboxProxyRuntimeRepository extends _$SingboxProxyRuntimeRepository {
  final _lock = Lock();

  /// sing-box's verdict on each profile it was asked about, by the profile's
  /// full content.
  ///
  /// Every start, stop and reload checks each profile in it, and each check
  /// builds a whole sing-box instance on the runtime's one thread, before the
  /// start itself — for profiles that are already running, too. The verdict
  /// depends on nothing but the profile, so a profile is checked again only
  /// once it has changed.
  final _verdicts = <SingboxProxyProfile, String?>{};

  /// Bounds [_verdicts]; reached only through many edits in one session.
  static const _verdictsLimit = 64;

  /// What the running instance was started with, by the last start that
  /// succeeded; null once it is gone.
  ///
  /// A start that leaves refused profiles out skips the reload when it would
  /// run exactly this again — telling that apart from the same profile ids
  /// with an edited profile or new options, which do need one.
  _RuntimeStart? _lastStart;

  SingboxProxyClient get _plugin => ref.read(singboxProxyClientProvider);

  Future<SingboxProxyRuntimeState> _stateSnapshotUnlocked() async {
    final currentState = state.asData?.value;
    if (currentState != null) return currentState;

    final nextState = await _plugin.getState();
    state = AsyncData(nextState);
    return nextState;
  }

  Future<SingboxProxyRuntimeState> startProfile(
    String profileId, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _lock.synchronized(() async {
      final currentState = await _stateSnapshotUnlocked();
      final activeProfileIds = currentState.runningProfileIds;

      return await _extendRunningUnlocked(activeProfileIds, [
        profileId,
      ], options: options);
    });
  }

  /// Brings [profileIds] up alongside whatever already runs.
  ///
  /// [startProfile] for a set, and deliberately not [startProfiles]: that one
  /// is authoritative — it starts exactly the list it is given and stops
  /// everything else — which is what startup wants and the opposite of what a
  /// caller adding one connection wants. One union under one lock, so a set is
  /// not N restarts of everything already running.
  Future<SingboxProxyRuntimeState> ensureProfilesStarted(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _lock.synchronized(() async {
      final currentState = await _stateSnapshotUnlocked();
      final activeProfileIds = currentState.runningProfileIds;

      if (profileIds.every(activeProfileIds.contains)) return currentState;

      return await _extendRunningUnlocked(
        activeProfileIds,
        profileIds,
        options: options,
      );
    });
  }

  /// [ensureProfilesStarted] for an unattended retry of [profileId], which
  /// must not do two things a start someone asked for may.
  ///
  /// It must not bring up a profile that was given up on while it waited for
  /// the lock: [stillWanted] is asked once the lock is held, when a stop that
  /// queued ahead of it has run. Returns null when it says no.
  ///
  /// And it must not reload the runtime for nothing. Every start rebuilds the
  /// one instance all profiles share, and one that fails cuts the working
  /// connections twice — for the start, and for putting them back. So while
  /// other profiles run, the profile is probed first, and the runtime is left
  /// alone while the probe still fails ([SingboxProbeFailed]). Outside the
  /// lock: a probe can take seconds, and starts must not queue behind it.
  Future<SingboxProxyRuntimeState?> retryProfile(
    String profileId, {
    required bool Function() stillWanted,
  }) async {
    final othersRunning = state.runningProfileIds.any((id) => id != profileId);
    if (othersRunning) {
      final profiles = await _runtimeProfiles([profileId]);
      final reason = await _plugin.probeProfile(profiles.single);
      if (reason != null) throw SingboxProbeFailed(reason);
    }

    return await _lock.synchronized(() async {
      if (!stillWanted()) return null;

      final currentState = await _stateSnapshotUnlocked();
      final activeProfileIds = currentState.runningProfileIds;
      if (activeProfileIds.contains(profileId)) return currentState;

      return await _extendRunningUnlocked(activeProfileIds, [profileId]);
    });
  }

  /// Starts [runningProfileIds] together with [addedProfileIds], and puts the
  /// running set back if that fails.
  ///
  /// The runtime is one instance for every profile, and a reload replaces it
  /// whole: a profile that cannot come up — a WireGuard peer that does not
  /// resolve, a config sing-box rejects — fails the entire start, and the old
  /// instance is already gone by then. Without this, asking for one more
  /// profile could take down every connection that was working a moment
  /// earlier (issue #669). The error is still rethrown, so the caller reports
  /// the profile that failed.
  ///
  /// The running set is announced as starting across both attempts, not just
  /// within each, so no snapshot computed in between calls those profiles a
  /// settled block.
  Future<SingboxProxyRuntimeState> _extendRunningUnlocked(
    Set<String> runningProfileIds,
    Iterable<String> addedProfileIds, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    final runningIds = _encodedConnectionIds(runningProfileIds);
    ref
        .read(singboxProxyStartingConnectionsProvider.notifier)
        ._begin(runningIds);

    try {
      return await _startProfilesUnlocked(
        {...runningProfileIds, ...addedProfileIds}.toList(),
        options: options,
      );
    } on SingboxProfilesRejected {
      // The profiles sing-box accepted are running; there is nothing to put
      // back.
      rethrow;
    } catch (error, stackTrace) {
      if (runningProfileIds.isNotEmpty) {
        await _restoreRunningUnlocked(runningProfileIds);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref
          .read(singboxProxyStartingConnectionsProvider.notifier)
          ._end(runningIds);
    }
  }

  /// Puts [profileIds] back after a failed start, and reports the ones that do
  /// not come back as lost ([SingboxProxyLostProfiles]).
  Future<void> _restoreRunningUnlocked(Set<String> profileIds) async {
    final lost = ref.read(singboxProxyLostProfilesProvider.notifier);
    try {
      await _startProfilesUnlocked(profileIds.toList());
      logger.w(
        'Restored sing-box proxy profiles $profileIds after a failed start',
      );
    } on SingboxProfilesRejected catch (error) {
      logger.e(
        'sing-box refused sing-box proxy profiles while restoring them after '
        'a failed start: $error',
      );
      lost._report(error.rejections.keys, permanent: true);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to restore sing-box proxy profiles $profileIds after a '
        'failed start',
        error: error,
        stackTrace: stackTrace,
      );
      lost._report(profileIds, permanent: false);
    }
  }

  /// Logs WireGuard profiles in one start that share a private key.
  ///
  /// A server sees them as one client and keeps switching between them, so
  /// each one's traffic stalls whenever the other sends — which from the
  /// outside reads as "starting this proxy broke that one". Nothing is changed:
  /// both may be wanted, they just cannot work at once.
  void _warnAboutSharedWireguardKeys(List<SingboxProxyProfile> profiles) {
    final namesByKey = <String, List<String>>{};
    for (final profile in profiles) {
      if (profile.type != SingboxProxyProfileType.wireguard) continue;
      final key = wireguardPrivateKeyOf(profile.secretJson);
      if (key == null) continue;
      namesByKey.putIfAbsent(key, () => []).add(profile.name);
    }
    for (final names in namesByKey.values) {
      if (names.length > 1) {
        logger.w(
          'WireGuard profiles $names share a private key; running them '
          'together makes them cut each other off',
        );
      }
    }
  }

  SingboxProfilesRejected _rejectionOf(
    Map<SingboxProxyProfile, String> rejected,
  ) {
    return SingboxProfilesRejected({
      for (final MapEntry(key: profile, value: message) in rejected.entries)
        ?singboxProfileIdOf(profile.id): (name: profile.name, message: message),
    });
  }

  /// Restart whatever is currently running, so options resolved at start time
  /// are rebuilt from current settings.
  ///
  /// Needed because a few of those options are not reconfigurable in place:
  /// sing-box reads `log.level` out of the config document it is handed, so a
  /// changed level reaches a running runtime only by handing it a new one.
  /// Reuses the running endpoints' ports, so tabs keep the SOCKS address they
  /// were already given.
  ///
  /// A no-op when nothing runs — there is no config to replace, and the next
  /// start will pick the new options up on its own.
  Future<void> reloadActiveProfiles() {
    return _lock.synchronized(() async {
      final currentState = await _stateSnapshotUnlocked();
      final activeProfileIds = currentState.runningProfileIds;
      if (activeProfileIds.isEmpty) return;

      await _startProfilesUnlocked(activeProfileIds.toList());
    });
  }

  Future<SingboxProxyRuntimeState> startProfiles(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _lock.synchronized(
      () => _startProfilesUnlocked(profileIds, options: options),
    );
  }

  Future<SingboxProxyRuntimeState> _startProfilesUnlocked(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    // Data only. Right after a failed start — a restore runs then — the state
    // is an error still carrying the last data, which lists profiles that
    // are down: taken as running, a restore left them out of the start and
    // reported them up.
    final previousState = state.asData?.value;
    state = const AsyncLoading<SingboxProxyRuntimeState>();

    final startingIds = _encodedConnectionIds(profileIds);
    // Announced before the first suspension, so routing recomputed anywhere in
    // this start's window sees it. Cleared in the `finally` whichever way the
    // start goes: one that threw is not one anything should still be held for.
    ref
        .read(singboxProxyStartingConnectionsProvider.notifier)
        ._begin(startingIds);

    try {
      final (:accepted, :rejected) = await _vetProfiles(
        await _runtimeProfiles(profileIds),
      );
      _warnAboutSharedWireguardKeys(accepted);
      final acceptedIds = {
        for (final profile in accepted) ?singboxProfileIdOf(profile.id),
      };
      final runtimeOptions = await _buildRuntimeOptions(
        options ?? SingboxProxyRuntimeOptions(),
        profileIds: acceptedIds,
      );

      if (rejected.isNotEmpty) {
        // An instance this repository did not start — one that outlived the
        // Dart side — is taken as running what it reports.
        final lastStart = _lastStart;
        final alreadyRunning =
            previousState != null &&
            setEquals(acceptedIds, previousState.runningProfileIds) &&
            (lastStart == null ||
                (listEquals(lastStart.profiles, accepted) &&
                    lastStart.options == runtimeOptions));
        if (accepted.isEmpty || alreadyRunning) {
          // Reloading the runtime would only drop the connections of the
          // profiles in it. Without a state to put back, the runtime says what
          // it is: the state would otherwise stay loading for good, and every
          // run switch with it.
          state = AsyncData(previousState ?? await _plugin.getState());
          throw _rejectionOf(rejected);
        }
      }

      _lastStart = null;
      final nextState = await _plugin.start(accepted, options: runtimeOptions);
      _lastStart = (profiles: accepted, options: runtimeOptions);
      state = AsyncData(nextState);

      if (rejected.isNotEmpty) throw _rejectionOf(rejected);
      return nextState;
    } on SingboxProfilesRejected {
      // Not a failed start: whatever could run is running. State stays as
      // the start left it.
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } finally {
      ref
          .read(singboxProxyStartingConnectionsProvider.notifier)
          ._end(startingIds);
    }
  }

  /// Splits [profiles] into those sing-box accepts and those it refuses, with
  /// its reason.
  ///
  /// Every profile runs in one instance, and an instance whose config sing-box
  /// refuses does not start at all: one broken profile took every other one
  /// down with it. So each is checked on its own, and a start leaves the
  /// refused ones out.
  Future<
    ({
      List<SingboxProxyProfile> accepted,
      Map<SingboxProxyProfile, String> rejected,
    })
  >
  _vetProfiles(List<SingboxProxyProfile> profiles) async {
    final rejected = <SingboxProxyProfile, String>{};
    for (final profile in profiles) {
      if (await _checkProfile(profile) case final message?) {
        rejected[profile] = message;
      }
    }
    return (
      accepted: [
        for (final profile in profiles)
          if (!rejected.containsKey(profile)) profile,
      ],
      rejected: rejected,
    );
  }

  Future<String?> _checkProfile(SingboxProxyProfile profile) async {
    if (_verdicts.containsKey(profile)) return _verdicts[profile];

    final message = await _plugin.validateProfile(profile);
    if (_verdicts.length >= _verdictsLimit) _verdicts.clear();
    return _verdicts[profile] = message;
  }

  Future<SingboxProxyRuntimeOptions> _buildRuntimeOptions(
    SingboxProxyRuntimeOptions base, {
    required Set<String> profileIds,
  }) async {
    // Don't overwrite a caller-supplied dnsConfig (e.g. tests or one-off
    // overrides).
    final engineSettings = await ref
        .read(engineSettingsRepositoryProvider.notifier)
        .fetchSettings();
    // Resolved rather than read straight off the settings: a blank resolver
    // URL would leave the runtime with no `dns` block and a bootstrap bridge
    // that SERVFAILs every lookup — see [resolveBrowserDohUrl].
    final dohUrl = resolveBrowserDohUrl(
      selectedUrl: engineSettings.dohProviderUrl,
      defaultUrl: engineSettings.dohDefaultProviderUrl,
    );

    // Read here rather than watched: `log.level` is fixed at the moment
    // sing-box is handed a config, so the only value that matters is the one
    // in force at the start. A change to it restarts the runtime
    // ([ProxyLogLevelApplier]), which comes back through this same path.
    final logLevel =
        (await ref
                .read(proxyDiagnosticsSettingsRepositoryProvider.notifier)
                .fetchSettings())
            .logLevel
            .singboxLevel;

    if (base.dnsConfig != null) {
      final baseBootstrap = base.bootstrapDohUrl?.trim();

      return SingboxProxyRuntimeOptions(
        preferredBasePort: base.preferredBasePort,
        blockUnmatchedTraffic: base.blockUnmatchedTraffic,
        dnsConfig: base.dnsConfig,
        bootstrapDohUrl: (baseBootstrap == null || baseBootstrap.isEmpty)
            ? dohUrl
            : baseBootstrap,
        logLevel: logLevel,
      );
    }

    final profiles = await ref
        .read(singboxProxyProfilesRepositoryProvider.notifier)
        .fetchProfiles();

    final overrides = <String, ProxyDnsOverride?>{
      for (final profile in profiles)
        if (profileIds.contains(profile.id))
          profile.id: _decodeOverride(profile.dnsOverrideJson),
    };

    final dnsConfig = buildDnsConfig(
      overridesByProfileId: overrides,
      runningProfileIds: profileIds,
      browserDohUrl: dohUrl,
    );

    return SingboxProxyRuntimeOptions(
      preferredBasePort: base.preferredBasePort,
      blockUnmatchedTraffic: base.blockUnmatchedTraffic,
      dnsConfig: dnsConfig,
      bootstrapDohUrl: dohUrl,
      logLevel: logLevel,
    );
  }

  ProxyDnsOverride? _decodeOverride(String? json) {
    if (json == null || json.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return null;
      return ProxyDnsOverride.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> stopProfiles(List<String> profileIds) {
    return _lock.synchronized(() async {
      await _stopProfilesUnlocked(profileIds);
    });
  }

  Future<void> deleteProfile(String profileId) {
    return _lock.synchronized(() async {
      await _stopProfilesUnlocked([profileId]);
      await ref
          .read(singboxProxyProfilesRepositoryProvider.notifier)
          .deleteProfile(profileId);
    });
  }

  Future<void> stopAll() {
    return _lock.synchronized(_stopAllInRuntimeUnlocked);
  }

  Future<String?> validateProfile(ProxyProfile profile) async {
    return await _plugin.validateProfile(await _runtimeProfile(profile));
  }

  Future<void> _stopProfilesUnlocked(List<String> profileIds) async {
    final activeProfileIds = (await _stateSnapshotUnlocked()).runningProfileIds;
    final stopping = profileIds.toSet().intersection(activeProfileIds);
    final remaining = activeProfileIds.difference(stopping);

    // Nothing is to stay up, so the runtime is stopped outright. Its own
    // partial stop would keep what it last ran, which after a failed start is
    // a set read here as not running: it reloaded those, bringing back
    // profiles nobody asked for — and failing the stop, and a delete behind
    // it, when they still could not come up.
    if (remaining.isEmpty) {
      await _stopAllInRuntimeUnlocked();
      return;
    }
    // Nothing asked for is running: reloading the rest for it would only drop
    // their connections.
    if (stopping.isEmpty) return;

    // Stopping some profiles while others stay up is a start of the ones that
    // stay, with runtime options built for exactly them. The runtime's own
    // partial stop reuses the last start's options, whose DNS block routes a
    // resolver through every profile running then; sing-box refuses that
    // config once one of them is gone ("outbound detour not found"), after it
    // has closed the old instance — stopping one profile took every other one
    // down (issue #671). The start also holds the routing for the profiles
    // that stay across the reload.
    //
    // Whatever goes wrong bringing the rest back, the stop itself must hold
    // and must not fail — a delete waits behind it — and the profiles that
    // did not come back are reported lost, so they are not left down with
    // nothing to say so.
    final lost = ref.read(singboxProxyLostProfilesProvider.notifier);
    try {
      await _startProfilesUnlocked(remaining.toList());
    } on SingboxProfilesRejected catch (error) {
      // A profile that stays up now fails the check — libbox changed under
      // it, say.
      logger.w('Profiles left running after a stop were refused: $error');

      // When none was accepted, the runtime was left as it was, the stopped
      // profiles still in it. Nothing that stays can run, so all of it goes.
      final stillActive = (await _stateSnapshotUnlocked()).runningProfileIds;
      if (stillActive.intersection(stopping).isNotEmpty) {
        await _stopAllInRuntimeUnlocked();
      }
      lost._report(error.rejections.keys, permanent: true);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to bring back sing-box proxy profiles $remaining after '
        'stopping $stopping',
        error: error,
        stackTrace: stackTrace,
      );

      // A start can fail before it reaches the runtime, which then still runs
      // the profiles asked to stop. Stopped outright, so the stop holds either
      // way.
      await _stopAllInRuntimeUnlocked();
      lost._report(remaining, permanent: false);
    }
  }

  Future<void> _stopAllInRuntimeUnlocked() async {
    _lastStart = null;
    await _plugin.stopAll();
    state = AsyncData(await _plugin.getState());
  }

  Future<String?> validateProfileDraft(
    ProxyProfile profile, {
    String? secretJson,
  }) {
    return _plugin.validateProfile(
      profile.toRuntimeProfile(secretJson: secretJson),
    );
  }

  Future<SingboxProxyConfigResult> buildConfig(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    final resolvedOptions = await _buildRuntimeOptions(
      options ?? SingboxProxyRuntimeOptions(),
      profileIds: profileIds.toSet(),
    );
    return await _plugin.buildConfig(
      await _runtimeProfiles(profileIds),
      options: resolvedOptions,
    );
  }

  Future<List<SingboxProxyProfile>> _runtimeProfiles(
    List<String> profileIds,
  ) async {
    final profiles = await ref
        .read(singboxProxyProfilesRepositoryProvider.notifier)
        .fetchProfiles();
    final profileMap = {for (final profile in profiles) profile.id: profile};

    return await Future.wait(
      profileIds.map((profileId) {
        final profile = profileMap[profileId];
        if (profile == null) {
          throw StateError('Unknown sing-box proxy profile: $profileId');
        }

        return _runtimeProfile(profile);
      }),
    );
  }

  Future<SingboxProxyProfile> _runtimeProfile(ProxyProfile profile) async {
    final secretJson = await ref
        .read(singboxProxyCredentialsRepositoryProvider.notifier)
        .readSecretJson(profile.id);

    return profile.toRuntimeProfile(secretJson: secretJson);
  }

  @override
  Future<SingboxProxyRuntimeState> build() {
    final plugin = ref.watch(singboxProxyClientProvider);
    final stateSubscription = plugin.stateStream.listen((nextState) {
      state = AsyncData(nextState);
    });

    ref.onDispose(() {
      unawaited(stateSubscription.cancel());
    });

    return plugin.getState();
  }
}
