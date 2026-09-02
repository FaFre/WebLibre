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

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
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

  Future<void> dispose();
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

  @override
  Future<void> dispose() => _plugin.dispose();
}

@Riverpod(keepAlive: true)
SingboxProxyClient singboxProxyClient(Ref ref) {
  return FlutterSingboxProxyClient();
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
  @override
  Set<String> build() => const {};

  void _begin(Set<String> encodedIds) {
    if (encodedIds.isEmpty) return;
    state = {...state, ...encodedIds};
  }

  void _end(Set<String> encodedIds) {
    if (encodedIds.isEmpty) return;
    state = state.difference(encodedIds);
  }
}

@Riverpod(keepAlive: true)
class SingboxProxyRuntimeRepository extends _$SingboxProxyRuntimeRepository {
  final _lock = Lock();

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
      final activeProfileIds = _activeProfileIds(currentState);

      return _startProfilesUnlocked(
        {...activeProfileIds, profileId}.toList(),
        options: options,
      );
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
      final activeProfileIds = _activeProfileIds(currentState);

      if (profileIds.every(activeProfileIds.contains)) return currentState;

      return _startProfilesUnlocked(
        {...activeProfileIds, ...profileIds}.toList(),
        options: options,
      );
    });
  }

  Set<String> _activeProfileIds(SingboxProxyRuntimeState runtimeState) {
    return runtimeState.endpoints
        .map((endpoint) => ProxyConnectionId.decode(endpoint.profileId))
        .whereType<SingboxProxyConnectionId>()
        .map((connectionId) => connectionId.profileId)
        .toSet();
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
      final activeProfileIds = _activeProfileIds(currentState);
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
    state = const AsyncLoading<SingboxProxyRuntimeState>();

    final startingIds = {
      for (final profileId in profileIds)
        SingboxProxyConnectionId(profileId).encode(),
    };
    // Announced before the first suspension, so routing recomputed anywhere in
    // this start's window sees it. Cleared in the `finally` whichever way the
    // start goes: one that threw is not one anything should still be held for.
    ref
        .read(singboxProxyStartingConnectionsProvider.notifier)
        ._begin(startingIds);

    try {
      final profiles = await _runtimeProfiles(profileIds);
      final resolvedOptions = await _buildRuntimeOptions(
        options ?? SingboxProxyRuntimeOptions(),
        profileIds: profileIds.toSet(),
      );

      final nextState = await _plugin.start(profiles, options: resolvedOptions);

      state = AsyncData(nextState);
      return nextState;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } finally {
      ref
          .read(singboxProxyStartingConnectionsProvider.notifier)
          ._end(startingIds);
    }
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
    return _lock.synchronized(() async {
      await _plugin.stopAll();
      final nextState = await _plugin.getState();
      state = AsyncData(nextState);
    });
  }

  Future<String?> validateProfile(ProxyProfile profile) async {
    return _plugin.validateProfile(await _runtimeProfile(profile));
  }

  Future<void> _stopProfilesUnlocked(List<String> profileIds) async {
    final proxyIds = profileIds
        .map((profileId) => SingboxProxyConnectionId(profileId).encode())
        .toList();

    await _plugin.stop(proxyIds);
    final nextState = await _plugin.getState();
    state = AsyncData(nextState);
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
    return _plugin.buildConfig(
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

    return Future.wait(
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
      unawaited(plugin.dispose());
    });

    return plugin.getState();
  }
}
