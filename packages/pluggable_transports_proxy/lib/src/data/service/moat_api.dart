import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pluggable_transports_proxy/src/data/models/moat.dart';

class MoatApi {
  static const String _baseUrl =
      'https://bridges.torproject.org/moat/circumvention/';

  final http.Client _client;

  MoatApi(this._client);

  Future<SettingsResponse> settings([SettingsRequest? request]) async {
    final response = await _post('settings', request ?? SettingsRequest());
    return SettingsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<SettingsResponse> defaults([SettingsRequest? request]) async {
    final response = await _post('defaults', request ?? SettingsRequest());
    return SettingsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Map<String, SettingsResponse>> map() async {
    final response = await _get('map');
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return data.map(
      (key, value) => MapEntry(
        key,
        SettingsResponse.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<BuiltInBridges> builtin() async {
    final response = await _get('builtin');
    return BuiltInBridges.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<String>> countries() async {
    final response = await _get('countries');
    return List<String>.from(jsonDecode(response.body) as List);
  }

  Future<http.Response> _get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await _client.get(uri, headers: _headers);
  }

  Future<http.Response> _post(String endpoint, Object body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await _client.post(uri, headers: _headers, body: jsonEncode(body));
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/vnd.api+json',
    'Accept': 'application/vnd.api+json',
  };

  void dispose() {
    _client.close();
  }
}
