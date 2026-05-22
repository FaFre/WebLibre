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
import 'package:weblibre/features/proxy/data/parsers/base64_text.dart';
import 'package:weblibre/features/proxy/data/parsers/host_port.dart';

/// Form-spec-shaped result of parsing a single proxy URI (ss://, vless://, …).
class SingboxProxyUriImport with FastEquatable {
  final SingboxProxyProfileType type;
  final String? name;
  final Map<String, String> values;

  SingboxProxyUriImport({required this.type, required this.values, this.name});

  @override
  List<Object?> get hashParameters => [type, name, values];
}

/// Dispatches on the URI scheme and delegates to the matching importer.
/// Throws [FormatException] for unknown or malformed schemes.
SingboxProxyUriImport importSingboxProxyUri(String rawUri) {
  final trimmedUri = rawUri.trim();
  final schemeEnd = trimmedUri.indexOf('://');
  if (schemeEnd <= 0) {
    throw const FormatException('Proxy URI must include a scheme.');
  }

  final scheme = trimmedUri.substring(0, schemeEnd).toLowerCase();
  return switch (scheme) {
    'ss' => _importShadowsocksUri(trimmedUri),
    'socks' || 'socks5' => _importSocksUri(trimmedUri),
    'http' || 'https' => _importHttpUri(trimmedUri),
    'trojan' => _importTrojanUri(trimmedUri),
    'vless' => _importVlessUri(trimmedUri),
    'vmess' => _importVmessUri(trimmedUri),
    'hysteria2' || 'hy2' => _importHysteria2Uri(trimmedUri),
    'tuic' => _importTuicUri(trimmedUri),
    _ => throw FormatException('Unsupported proxy URI scheme: $scheme'),
  };
}

SingboxProxyUriImport _importShadowsocksUri(String rawUri) {
  final payload = rawUri.substring('ss://'.length);
  final fragmentIndex = payload.indexOf('#');
  final withoutFragment = fragmentIndex >= 0
      ? payload.substring(0, fragmentIndex)
      : payload;
  final name = fragmentIndex >= 0
      ? Uri.decodeComponent(payload.substring(fragmentIndex + 1))
      : null;
  final withoutQuery = withoutFragment.split('?').first;
  final decodedPayload = withoutQuery.contains('@')
      ? withoutQuery
      : decodeBase64Text(withoutQuery);
  final atIndex = decodedPayload.lastIndexOf('@');
  if (atIndex <= 0 || atIndex == decodedPayload.length - 1) {
    throw const FormatException('Shadowsocks URI must include credentials.');
  }

  final rawCredentials = decodedPayload.substring(0, atIndex);
  final credentials = rawCredentials.contains(':')
      ? rawCredentials
      : decodeBase64Text(rawCredentials);
  final credentialSeparator = credentials.indexOf(':');
  if (credentialSeparator <= 0) {
    throw const FormatException(
      'Shadowsocks URI credentials must be method:password.',
    );
  }
  final endpoint = parseHostPort(
    decodedPayload.substring(atIndex + 1),
    invalidMessage: 'Proxy URI endpoint must be host:port.',
  );

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.shadowsocks,
    name: _nonEmptyName(name),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'method': Uri.decodeComponent(
        credentials.substring(0, credentialSeparator),
      ),
      'password': Uri.decodeComponent(
        credentials.substring(credentialSeparator + 1),
      ),
    },
  );
}

SingboxProxyUriImport _importTrojanUri(String rawUri) {
  final uri = Uri.parse(rawUri);
  final endpoint = _uriEndpoint(uri, 'Trojan');

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.trojan,
    name: _uriName(uri),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'password': Uri.decodeComponent(uri.userInfo),
      'tls.enabled': 'true',
      ..._tlsImportValues(uri),
    },
  );
}

SingboxProxyUriImport _importVlessUri(String rawUri) {
  final uri = Uri.parse(rawUri);
  final endpoint = _uriEndpoint(uri, 'VLESS');

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.vless,
    name: _uriName(uri),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'uuid': Uri.decodeComponent(uri.userInfo),
      'flow': uri.queryParameters['flow'] ?? '',
      ..._tlsImportValues(uri),
    },
  );
}

SingboxProxyUriImport _importSocksUri(String rawUri) {
  final uri = Uri.parse(rawUri);
  final endpoint = _uriHostPort(uri, 'SOCKS');
  final userInfo = _splitUserInfo(uri.userInfo);

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.socks,
    name: _uriName(uri),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'version': '5',
      'username': userInfo.username,
      'password': userInfo.password,
    },
  );
}

SingboxProxyUriImport _importHttpUri(String rawUri) {
  final uri = Uri.parse(rawUri);
  final endpoint = _uriHostPort(uri, 'HTTP');
  final userInfo = _splitUserInfo(uri.userInfo);

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.http,
    name: _uriName(uri),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'username': userInfo.username,
      'password': userInfo.password,
      if (uri.scheme.toLowerCase() == 'https') 'tls.enabled': 'true',
      ..._tlsImportValues(uri),
    },
  );
}

SingboxProxyUriImport _importHysteria2Uri(String rawUri) {
  final uri = Uri.parse(rawUri);
  final endpoint = _uriEndpoint(uri, 'Hysteria2');
  final query = uri.queryParameters;

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.hysteria2,
    name: _uriName(uri),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'password': Uri.decodeComponent(uri.userInfo),
      'obfs.type': query['obfs'] ?? '',
      'obfs.password': query['obfs-password'] ?? query['obfs_password'] ?? '',
      'tls.enabled': 'true',
      ..._tlsImportValues(uri),
    },
  );
}

SingboxProxyUriImport _importTuicUri(String rawUri) {
  final uri = Uri.parse(rawUri);
  final endpoint = _uriEndpoint(uri, 'TUIC');
  final userInfo = _splitUserInfo(uri.userInfo);
  final query = uri.queryParameters;

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.tuic,
    name: _uriName(uri),
    values: {
      'server': endpoint.host,
      'server_port': endpoint.port,
      'uuid': userInfo.username,
      'password': userInfo.password,
      'congestion_control':
          query['congestion_control'] ?? query['congestion'] ?? 'cubic',
      'udp_relay_mode': query['udp_relay_mode'] ?? 'native',
      'tls.enabled': 'true',
      ..._tlsImportValues(uri),
    },
  );
}

SingboxProxyUriImport _importVmessUri(String rawUri) {
  final payload = rawUri.substring('vmess://'.length).split('#').first.trim();
  final decoded = jsonDecode(decodeBase64Text(payload)) as Object?;
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('VMess URI payload must be a JSON object.');
  }

  final server = _stringValue(decoded['add'], '');
  final port = _stringValue(decoded['port'], '');
  final uuid = _stringValue(decoded['id'], '');
  if (server.isEmpty || port.isEmpty || uuid.isEmpty) {
    throw const FormatException('VMess URI must include add, port, and id.');
  }

  return SingboxProxyUriImport(
    type: SingboxProxyProfileType.vmess,
    name: _nonEmptyName(_stringValue(decoded['ps'], '')),
    values: {
      'server': server,
      'server_port': port,
      'uuid': uuid,
      'security': _stringValue(decoded['scy'], 'auto'),
      'alter_id': _stringValue(decoded['aid'], ''),
      'tls.enabled': _stringValue(decoded['tls'], '') == 'tls' ? 'true' : '',
      'tls.server_name': _stringValue(decoded['sni'], ''),
      'transport.type': _stringValue(decoded['net'], ''),
      'transport.path': _stringValue(decoded['path'], ''),
    },
  );
}

HostPort _uriEndpoint(Uri uri, String label) {
  final endpoint = _uriHostPort(uri, label);
  if (uri.userInfo.isEmpty) {
    throw FormatException('$label URI must include credentials.');
  }
  return endpoint;
}

HostPort _uriHostPort(Uri uri, String label) {
  final hasExplicitOrDefaultPort = uri.hasPort || uri.port > 0;
  if (uri.host.isEmpty || !hasExplicitOrDefaultPort) {
    throw FormatException('$label URI must include host and port.');
  }
  return (host: uri.host, port: uri.port.toString());
}

String? _uriName(Uri uri) {
  if (!uri.hasFragment) return null;
  return _nonEmptyName(Uri.decodeComponent(uri.fragment));
}

String? _nonEmptyName(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

({String username, String password}) _splitUserInfo(String userInfo) {
  if (userInfo.isEmpty) return (username: '', password: '');
  final separatorIndex = userInfo.indexOf(':');
  if (separatorIndex < 0) {
    return (username: Uri.decodeComponent(userInfo), password: '');
  }

  return (
    username: Uri.decodeComponent(userInfo.substring(0, separatorIndex)),
    password: Uri.decodeComponent(userInfo.substring(separatorIndex + 1)),
  );
}

Map<String, String> _tlsImportValues(Uri uri) {
  final query = uri.queryParameters;
  final values = <String, String>{};
  final security = query['security'] ?? query['tls'];
  if (security == 'tls' || security == '1' || security == 'true') {
    values['tls.enabled'] = 'true';
  }
  final serverName = query['sni'] ?? query['peer'] ?? query['server_name'];
  if (serverName != null && serverName.isNotEmpty) {
    values['tls.server_name'] = serverName;
  }
  final insecure =
      query['allowInsecure'] ?? query['allow_insecure'] ?? query['insecure'];
  if (insecure != null && insecure.isNotEmpty) {
    values['tls.insecure'] = insecure;
  }
  final alpn = query['alpn'];
  if (alpn != null && alpn.isNotEmpty) values['tls.alpn'] = alpn;
  return values;
}

String _stringValue(Object? value, String fallback) {
  if (value == null) return fallback;
  return value.toString();
}
