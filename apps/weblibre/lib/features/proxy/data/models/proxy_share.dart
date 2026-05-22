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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';

/// Custom share-link scheme for round-tripping a WebLibre proxy profile
/// (including any secret config) between WebLibre installs. NOT cross-app
/// compatible — for that use the standard ss://, vless://, etc. URIs imported
/// from the editor (and exposed by future per-protocol exporters).
const weblibreProxyShareScheme = 'weblibre-proxy';

class ProxyShareEnvelope with FastEquatable {
  /// Schema version — bumped if the wrapped JSON shape ever changes.
  /// v1: name + type + config + secret.
  /// v2: also carries dnsOverrideJson so per-profile DNS settings survive
  ///     share/import. Older v1 payloads stay readable (treated as no
  ///     override).
  static const int currentVersion = 2;

  final String name;
  final SingboxProxyProfileType type;
  final String configJson;
  final String? secretJson;
  final String? dnsOverrideJson;

  ProxyShareEnvelope({
    required this.name,
    required this.type,
    required this.configJson,
    this.secretJson,
    this.dnsOverrideJson,
  });

  @override
  List<Object?> get hashParameters => [
    name,
    type,
    configJson,
    secretJson,
    dnsOverrideJson,
  ];
}

/// Encodes the profile as `weblibre-proxy://<base64url(JSON)>`. The JSON body
/// is compact (no whitespace) to keep the URL short for QR rendering once
/// added.
String encodeProxyShareUri(ProxyShareEnvelope envelope) {
  final body = <String, Object?>{
    'v': ProxyShareEnvelope.currentVersion,
    'name': envelope.name,
    'type': envelope.type.name,
    'config': jsonDecode(envelope.configJson),
    if (envelope.secretJson != null && envelope.secretJson!.isNotEmpty)
      'secret': jsonDecode(envelope.secretJson!),
    if (envelope.dnsOverrideJson != null &&
        envelope.dnsOverrideJson!.isNotEmpty)
      'dnsOverride': jsonDecode(envelope.dnsOverrideJson!),
  };
  final encoded = base64UrlEncode(utf8.encode(jsonEncode(body)));
  return '$weblibreProxyShareScheme://$encoded';
}

/// Decodes a `weblibre-proxy://...` share URI. Throws [FormatException] on
/// malformed input or version mismatch.
const _shareUriPrefix = '$weblibreProxyShareScheme://';

ProxyShareEnvelope decodeProxyShareUri(String rawUri) {
  final trimmed = rawUri.trim();
  if (!trimmed.startsWith(_shareUriPrefix)) {
    throw const FormatException(
      'Not a WebLibre proxy share URI (expected scheme $weblibreProxyShareScheme).',
    );
  }
  final payload = trimmed.substring(_shareUriPrefix.length);
  final List<int> bytes;
  try {
    bytes = base64Url.decode(base64Url.normalize(payload));
  } on FormatException {
    throw const FormatException('Share URI payload is not valid base64url.');
  }

  final dynamic decoded;
  try {
    decoded = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const FormatException('Share URI payload is not valid JSON.');
  }
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('Share URI payload must be a JSON object.');
  }

  final version = decoded['v'];
  if (version is! int ||
      version < 1 ||
      version > ProxyShareEnvelope.currentVersion) {
    throw FormatException('Unsupported share URI version: $version.');
  }

  final name = decoded['name'];
  final typeName = decoded['type'];
  final config = decoded['config'];
  final secret = decoded['secret'];
  final dnsOverride = decoded['dnsOverride'];

  if (name is! String || typeName is! String || config == null) {
    throw const FormatException('Share URI is missing required fields.');
  }
  final type = SingboxProxyProfileType.values
      .where((value) => value.name == typeName)
      .firstOrNull;
  if (type == null) {
    throw FormatException('Unknown profile type: $typeName.');
  }

  return ProxyShareEnvelope(
    name: name,
    type: type,
    configJson: jsonEncode(config),
    secretJson: secret == null ? null : jsonEncode(secret),
    dnsOverrideJson: dnsOverride == null ? null : jsonEncode(dnsOverride),
  );
}
