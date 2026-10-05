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
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client for Google Takeout API to export Chrome bookmarks and history.
///
/// Google Takeout allows users to export their data including Chrome bookmarks
/// and browsing history. This client automates the export request and download
/// process using OAuth2 authentication.
///
/// Reference: https://developers.google.com/takeout
///
/// Note: Requires OAuth2 scope 'https://www.googleapis.com/auth/dataportability'
/// which is available to all verified applications without special approval.
class GoogleTakeoutClient {
  static const _takeoutApiBase = 'https://takeout.googleapis.com/v1';

  final http.Client _httpClient;
  final Future<String> Function() _getAccessToken;

  GoogleTakeoutClient(this._httpClient, this._getAccessToken);

  /// Request a Chrome bookmarks and history export from Google Takeout.
  /// Returns an export job ID that can be polled for completion.
  Future<String?> requestChromeExport() async {
    final token = await _getAccessToken();

    final response = await _httpClient.post(
      Uri.parse('$_takeoutApiBase/exports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'services': ['chromesync'],
        'exportOptions': {
          'format': 'JSON',
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['id'] as String?;
    }

    // Takeout API may not be available for all accounts
    return null;
  }

  /// Check the status of an export job.
  /// Returns the download URL if complete, null if still processing.
  Future<String?> getExportStatus(String jobId) async {
    final token = await _getAccessToken();

    final response = await _httpClient.get(
      Uri.parse('$_takeoutApiBase/exports/$jobId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final state = json['state'] as String?;

    if (state == 'COMPLETED') {
      final exports = json['exports'] as List<dynamic>?;
      if (exports != null && exports.isNotEmpty) {
        final first = exports[0] as Map<String, dynamic>;
        final files = first['files'] as List<dynamic>?;
        if (files != null && files.isNotEmpty) {
          final file = files[0] as Map<String, dynamic>;
          return file['downloadUrl'] as String?;
        }
      }
    }

    return null;
  }
}
