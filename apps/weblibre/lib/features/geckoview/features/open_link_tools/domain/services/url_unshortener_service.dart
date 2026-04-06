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
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/data/models/unshorten_response_data.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/unshorten_result.dart';

part 'url_unshortener_service.g.dart';

const _shortenerListAssetPath = 'assets/preferences/url-shortener-list.json';

@Riverpod(keepAlive: true)
class UrlUnshortenerService extends _$UrlUnshortenerService {
  Future<Set<String>> loadSupportedShortenerHosts({
    AssetBundle? bundle,
    String assetPath = _shortenerListAssetPath,
  }) async {
    try {
      final content = await (bundle ?? rootBundle).loadString(assetPath);
      return parseSupportedShortenerHosts(content);
    } catch (_) {
      return {};
    }
  }

  Set<String> parseSupportedShortenerHosts(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return {};

      final list = decoded['list'];
      if (list is! List) return {};

      return list
          .whereType<String>()
          .map(_normalizeHost)
          .where((host) => host.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  bool isSupportedShortenerUrl(String url, Set<String> supportedHosts) {
    if (supportedHosts.isEmpty) return false;

    final parsed = Uri.tryParse(url);
    final host = parsed != null && parsed.host.isNotEmpty
        ? parsed.host
        : Uri.tryParse('https://$url')?.host;

    return isSupportedShortenerHost(host, supportedHosts);
  }

  bool isSupportedShortenerHost(String? host, Set<String> supportedHosts) {
    if (supportedHosts.isEmpty) return false;

    var candidate = _normalizeHost(host ?? '');
    if (candidate.isEmpty) return false;

    while (true) {
      if (supportedHosts.contains(candidate)) return true;

      final dotIndex = candidate.indexOf('.');
      if (dotIndex == -1) return false;

      candidate = candidate.substring(dotIndex + 1);
    }
  }

  Future<UnshortenResult> unshortenUrl(
    String url, {
    String token = '',
    http.Client? client,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);
    final httpClient = client ?? http.Client();

    final http.Response response;
    final bool authenticated = token.isNotEmpty;

    try {
      if (authenticated) {
        response = await httpClient
            .get(
              Uri.parse(
                'https://unshorten.me/api/v2/unshorten?url=$encodedUrl',
              ),
              headers: {'Authorization': 'Token $token'},
            )
            .timeout(const Duration(seconds: 15));
      } else {
        response = await httpClient
            .get(Uri.parse('https://unshorten.me/json/$encodedUrl'))
            .timeout(const Duration(seconds: 15));
      }
    } finally {
      if (client == null) httpClient.close();
    }

    if (response.statusCode != 200) {
      return UnshortenResult(
        success: false,
        error: 'HTTP ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final responseData = authenticated
        ? UnshortenResponseData.fromAuthenticatedJson(json)
        : UnshortenResponseData.fromUnauthenticatedJson(json);

    final result = responseData.toDomain();

    // Reject non-HTTP(S) URLs from the API to prevent scheme-based attacks.
    if (result.success && result.finalUrl != null) {
      final parsed = Uri.tryParse(result.finalUrl!);
      if (parsed != null && parsed.hasScheme && !parsed.isHttpOrHttps) {
        return UnshortenResult(
          success: false,
          error: 'Unsupported URL scheme: ${parsed.scheme}',
        );
      }
    }

    return result;
  }

  @override
  Future<Set<String>> build() {
    return loadSupportedShortenerHosts();
  }
}

final _leadingWildcard = RegExp(r'^\*\.');
final _leadingDot = RegExp(r'^\.');
final _trailingDot = RegExp(r'\.$');

String _normalizeHost(String host) {
  var normalized = host.trim().toLowerCase();
  if (normalized.isEmpty) return '';

  final isUrlLike =
      normalized.contains('://') ||
      normalized.contains('/') ||
      normalized.contains('?') ||
      normalized.contains('#');
  if (isUrlLike) {
    final parsed = normalized.contains('://')
        ? Uri.tryParse(normalized)
        : Uri.tryParse('https://$normalized');
    final parsedHost = parsed?.host ?? '';
    normalized = parsedHost.isNotEmpty ? parsedHost : normalized;
  }

  normalized = normalized.replaceFirst(_leadingWildcard, '');
  normalized = normalized.replaceFirst(_leadingDot, '');
  normalized = normalized.replaceFirst(_trailingDot, '');
  return normalized;
}
