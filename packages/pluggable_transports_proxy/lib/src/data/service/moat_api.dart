/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
    return await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> _post(String endpoint, Object body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await _client
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/vnd.api+json',
    'Accept': 'application/vnd.api+json',
  };

  void dispose() {
    _client.close();
  }
}
