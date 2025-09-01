import 'dart:io';

import 'package:http/io_client.dart';
import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:pluggable_transports_proxy/src/data/models/moat.dart';
import 'package:pluggable_transports_proxy/src/data/service/moat_api.dart';
import 'package:socks5_proxy/socks_client.dart';

const String _meekParameters =
    'url=https://1723079976.rsc.cdn77.org;front=www.phpmyadmin.net';

/// Manages MOAT API connections with persistent proxy setup.
class MoatService {
  MoatApi? _api;

  /// Initializes the MeekLite proxy and MOAT API connection.
  /// Must be called before using other methods.
  Future<void> initialize() async {
    if (_api != null) return;

    final port = await IPtProxyController().start(ProxyType.meekLite, "");

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
    await IPtProxyController().stop(ProxyType.meekLite);
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
  List<Setting> _convertBuiltinToSettings(
    BuiltInBridges builtinBridges,
    List<TransportType> transports,
  ) {
    final settings = <Setting>[];

    for (final transport in transports) {
      final bridgeStrings = switch (transport) {
        TransportType.obfs4 => builtinBridges.obfs4,
        TransportType.snowflake => builtinBridges.snowflake,
        TransportType.meek => builtinBridges.meek,
        TransportType.meekAzure => builtinBridges.meekAzure,
        TransportType.webtunnel => <String>[], // Not available in builtin
      };

      if (bridgeStrings.isNotEmpty) {
        settings.add(
          Setting(
            bridge: Bridge(
              type: transport.value,
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
  Future<List<Setting>?> getBuiltinBridges({
    List<TransportType> transports = const [
      TransportType.obfs4,
      TransportType.snowflake,
      TransportType.meek,
    ],
  }) async {
    _ensureInitialized();

    final builtinBridges = await _api!.builtin();
    final settings = _convertBuiltinToSettings(builtinBridges, transports);
    return settings.isEmpty ? null : settings;
  }

  /// Tries to automatically configure Pluggable Transports.
  Future<List<Setting>?> autoConf({
    String? country,
    bool cannotConnectWithoutPt = false,
    List<TransportType> transports = const [
      TransportType.obfs4,
      TransportType.snowflake,
      TransportType.webtunnel,
    ],
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
