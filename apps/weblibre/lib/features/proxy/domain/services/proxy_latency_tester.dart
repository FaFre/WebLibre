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
import 'dart:io';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socks5_proxy/socks_client.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'proxy_latency_tester.g.dart';

/// Mullvad's connectivity check — returns JSON with the egress `ip` plus
/// geolocation. Single round trip gives both reachability and the IP we
/// surface in the chip. Mullvad has a no-logs policy, which fits a
/// privacy-focused browser better than funneling every probe through
/// Cloudflare.
const _probeUrl = 'https://am.i.mullvad.net/json';

const _testTimeout = Duration(seconds: 8);

class ProxyLatencyData with FastEquatable {
  final Duration latency;
  final int statusCode;
  final String? egressIp;

  ProxyLatencyData({
    required this.latency,
    required this.statusCode,
    this.egressIp,
  });

  @override
  List<Object?> get hashParameters => [latency, statusCode, egressIp];
}

/// Per-profile latency results, keyed by profile id. Holds the latest result
/// only; we don't keep history because the test is user-triggered and the user
/// is looking at the chip we render from it.
@Riverpod(keepAlive: true)
class ProxyLatencyResults extends _$ProxyLatencyResults {
  @override
  Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>> build() => const {};

  void _set(ProxyConnectionId id, AsyncValue<ProxyLatencyData> result) {
    state = {...state, id: result};
  }

  void clear(ProxyConnectionId id) {
    if (!state.containsKey(id)) return;
    state = {
      for (final entry in state.entries)
        if (entry.key != id) entry.key: entry.value,
    };
  }

  Future<void> _run(
    ProxyConnectionId id,
    SingboxProxyRuntimeEndpoint endpoint,
  ) async {
    _set(id, const AsyncLoading());
    final result = await AsyncValue.guard(
      () => measureViaSocks(endpoint: endpoint, url: Uri.parse(_probeUrl)),
    );
    _set(id, result);
  }

  /// Runs a probe through the profile's local SOCKS endpoint and records the
  /// result. Profile must already be running — the endpoint is read from the
  /// live runtime state.
  Future<void> test(String profileId) async {
    final runtimeState = ref.read(singboxProxyRuntimeRepositoryProvider).value;
    final endpoint = runtimeState?.endpoints.where((endpoint) {
      final decoded = ProxyConnectionId.decode(endpoint.profileId);
      return decoded is SingboxProxyConnectionId &&
          decoded.profileId == profileId;
    }).firstOrNull;

    if (endpoint == null) {
      _set(
        SingboxProxyConnectionId(profileId),
        AsyncError('Profile is not running', StackTrace.current),
      );
      return;
    }

    await _run(SingboxProxyConnectionId(profileId), endpoint);
  }

  /// Probes Tor's local SOCKS endpoint. Keyed by [TorProxyConnectionId] so the
  /// chip and clear/retain logic share a code path with sing-box profiles.
  Future<void> testTor() async {
    final socksPort = ref.read(torProxyServiceProvider).value?.usableSocksPort;

    if (socksPort == null) {
      _set(
        const TorProxyConnectionId(),
        AsyncError('$torBrand is not ready', StackTrace.current),
      );
      return;
    }

    await _run(
      const TorProxyConnectionId(),
      SingboxProxyRuntimeEndpoint(
        profileId: const TorProxyConnectionId().encode(),
        host: '127.0.0.1',
        port: socksPort,
        username: '',
        password: '',
      ),
    );
  }

  /// Drop any cached results for profile ids that are no longer running.
  void retainRunning(Set<ProxyConnectionId> runningIds) {
    if (setEquals(runningIds, state.keys.toSet())) return;

    state = {
      for (final entry in state.entries)
        if (runningIds.contains(entry.key)) entry.key: entry.value,
    };
  }
}

/// Runs a warmup probe (discarded) followed by [sampleCount] timed requests
/// through a single SOCKS5-bound [HttpClient] and reports the minimum RTT —
/// mirrors the speedtest-style "best RTT" reporting used by NekoBox/v2rayN/
/// clash for user-triggered URL tests. The cold path (TCP + SOCKS5 handshake +
/// upstream outbound warmup) skews the first sample, so we discard it. Reusing
/// the HttpClient lets later samples reuse the pooled SOCKS connection.
///
/// Throws on failure; the latest successful sample also yields the egress IP
/// parsed from the probe body.
Future<ProxyLatencyData> measureViaSocks({
  required SingboxProxyRuntimeEndpoint endpoint,
  required Uri url,
  Duration timeout = _testTimeout,
  int sampleCount = 3,
}) async {
  final httpClient = HttpClient()..connectionTimeout = timeout;
  SocksTCPClient.assignToHttpClient(httpClient, [
    ProxySettings(
      InternetAddress(endpoint.host),
      endpoint.port,
      username: endpoint.username,
      password: endpoint.password,
    ),
  ]);

  try {
    // Warmup — result discarded for timing, but if it fails we surface the
    // error rather than aggregating min of {failures}.
    await _singleProbe(httpClient, url, timeout);

    Duration? best;
    var lastStatusCode = 0;
    String? lastEgressIp;
    Object? lastError;
    StackTrace? lastStackTrace;
    for (var i = 0; i < sampleCount; i++) {
      try {
        final probe = await _singleProbe(httpClient, url, timeout);
        if (best == null || probe.latency < best) best = probe.latency;
        lastStatusCode = probe.statusCode;
        lastEgressIp = probe.egressIp ?? lastEgressIp;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
      }
    }

    if (best == null) {
      if (lastError != null) {
        Error.throwWithStackTrace(lastError, lastStackTrace!);
      }
      throw const SocketException('No samples completed');
    }

    return ProxyLatencyData(
      latency: best,
      statusCode: lastStatusCode,
      egressIp: lastEgressIp,
    );
  } finally {
    httpClient.close(force: true);
  }
}

Future<ProxyLatencyData> _singleProbe(
  HttpClient httpClient,
  Uri url,
  Duration timeout,
) async {
  final stopwatch = Stopwatch()..start();
  final request = await httpClient.getUrl(url).timeout(timeout);
  final response = await request.close().timeout(timeout);
  stopwatch.stop();

  String? egressIp;
  if (response.statusCode == 200) {
    final body = await response.transform(utf8.decoder).join();
    egressIp = _parseEgressIp(body);
  } else {
    await response.drain<void>();
  }

  return ProxyLatencyData(
    latency: stopwatch.elapsed,
    statusCode: response.statusCode,
    egressIp: egressIp,
  );
}

String? _parseEgressIp(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final ip = decoded['ip'];
      if (ip is String && ip.isNotEmpty) return ip;
    }
  } on FormatException {
    // Not JSON — fall through.
  }
  return null;
}
