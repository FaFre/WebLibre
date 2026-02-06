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
import 'dart:io';

import 'package:flutter_tor/flutter_tor.dart';
import 'package:http/io_client.dart';
import 'package:socks5_proxy/socks_client.dart';
import 'package:weblibre/features/tor/data/models/moat.dart';
import 'package:weblibre/features/tor/data/services/moat_api.dart';

const String _meekParameters =
    'url=https://1723079976.rsc.cdn77.org;front=www.phpmyadmin.net';

const defaultBridges = [MoatTransportType.obfs4, MoatTransportType.snowflake];

/// Manages MOAT API connections with persistent proxy setup.
class MoatService {
  MoatApi? _api;

  /// Initializes the MeekLite proxy and MOAT API connection.
  /// Must be called before using other methods.
  Future<void> initialize() async {
    if (_api != null) return;

    final port = await IPtProxyController().start(TransportType.meek, "");

    final httpClient = HttpClient();
    SocksTCPClient.assignToHttpClient(httpClient, [
      ProxySettings(
        InternetAddress.loopbackIPv4,
        port,
        username: _meekParameters,
        password: '\u0000',
      ),
    ]);

    _api = MoatApi(IOClient(httpClient));
  }

  /// Disposes the API connection and stops the MeekLite proxy.
  /// Should be called when done using the client.
  Future<void> dispose() async {
    if (_api == null) return;

    _api!.dispose();
    await IPtProxyController().stop(TransportType.meek);
    _api = null;
  }

  /// Ensures the client is initialized before API calls.
  void _ensureInitialized() {
    if (_api == null) {
      throw StateError(
        'MoatClient must be initialized before use. Call initialize() first.',
      );
    }
  }

  /// Handles MOAT API errors and determines if PT is required.
  bool _handleMoatErrors(List<MoatError>? errors) {
    if (errors == null || errors.isEmpty) return false;

    final error = errors.first;
    if (error.code == 404 || error.code == 406) {
      // 404: Needs transport, but not the available ones
      // 406: No country from IP address
      return true;
    }
    throw error;
  }

  /// Converts BuiltInBridges to Settings for requested transports.
  static List<Setting> convertBuiltinToSettings(
    BuiltInBridges builtinBridges, {
    List<MoatTransportType> transports = defaultBridges,
  }) {
    final settings = <Setting>[];

    for (final transport in transports) {
      final bridgeStrings = switch (transport) {
        MoatTransportType.obfs4 => builtinBridges.obfs4,
        MoatTransportType.snowflake => builtinBridges.snowflake,
        MoatTransportType.meek => builtinBridges.meek,
        MoatTransportType.meekAzure => builtinBridges.meekAzure,
        MoatTransportType.webtunnel => <String>[], // Not available in builtin
      };

      if (bridgeStrings.isNotEmpty) {
        settings.add(
          Setting(
            bridge: Bridge(
              type: transport,
              source: 'builtin',
              bridges: bridgeStrings,
            ),
          ),
        );
      }
    }

    return settings;
  }

  /// Gets built-in bridges from the MOAT service endpoint.
  Future<BuiltInBridges> getBuiltinBridges({
    List<MoatTransportType> transports = defaultBridges,
  }) async {
    _ensureInitialized();

    final builtinBridges = await _api!.builtin();
    return builtinBridges;
  }

  /// Tries to automatically configure Pluggable Transports.
  Future<List<Setting>?> autoConf({
    String? country,
    bool cannotConnectWithoutPt = false,
    List<MoatTransportType> transports = defaultBridges,
  }) async {
    _ensureInitialized();

    bool localCannotConnectWithoutPt = cannotConnectWithoutPt;
    final request = SettingsRequest(country: country, transports: transports);

    var response = await _api!.settings(request);

    if (_handleMoatErrors(response.errors)) {
      localCannotConnectWithoutPt = true;
    }

    final hasSettings = response.settings?.isNotEmpty ?? false;
    if (!hasSettings && !localCannotConnectWithoutPt) {
      return null;
    }

    if (hasSettings) {
      return response.settings;
    }

    response = await _api!.defaults(SettingsRequest(transports: transports));
    return response.settings;
  }

  Future<List<Setting>?> getDefaultBridges({
    List<MoatTransportType> transports = defaultBridges,
  }) async {
    _ensureInitialized();

    final response = await _api!.defaults(
      SettingsRequest(transports: transports),
    );

    return response.settings;
  }

  /// Gets the list of supported countries from the MOAT service.
  Future<List<String>> getCountries() async {
    _ensureInitialized();
    return await _api!.countries();
  }

  /// Gets the country-to-settings map from the MOAT service.
  Future<Map<String, SettingsResponse>> getMap() async {
    _ensureInitialized();
    return await _api!.map();
  }
}
