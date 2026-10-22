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

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

extension ProxyProfileExt on ProxyProfile {
  ProxyConnectionId get proxyConnection => SingboxProxyConnectionId(id);

  String get proxyConnectionId => proxyConnection.encode();

  SingboxProxyProfile toRuntimeProfile({String? secretJson}) {
    return SingboxProxyProfile(
      id: proxyConnectionId,
      name: name,
      type: type,
      configJson: configJson,
      secretJson: secretJson,
    );
  }
}

/// The WireGuard private key in a profile's [secretJson], or null when there
/// is none.
String? wireguardPrivateKeyOf(String? secretJson) {
  if (secretJson == null) return null;
  try {
    final decoded = jsonDecode(secretJson);
    if (decoded is! Map<String, dynamic>) return null;
    final key = decoded['private_key'];
    return key is String && key.trim().isNotEmpty ? key.trim() : null;
  } on FormatException {
    return null;
  }
}
