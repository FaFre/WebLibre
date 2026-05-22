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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_tor/flutter_tor.dart';

enum ProxyLogSource { singBox, tor }

class ProxyLogMessage with FastEquatable {
  final ProxyLogSource source;
  final String level;
  final String message;
  final int timestamp;
  final String? profileId;

  ProxyLogMessage({
    required this.source,
    required this.level,
    required this.message,
    required this.timestamp,
    this.profileId,
  });

  factory ProxyLogMessage.fromSingbox(SingboxProxyLogMessage message) {
    return ProxyLogMessage(
      source: ProxyLogSource.singBox,
      level: message.level,
      message: message.message,
      timestamp: message.timestamp,
      profileId: message.profileId,
    );
  }

  factory ProxyLogMessage.fromTor(TorLogMessage message) {
    return ProxyLogMessage(
      source: ProxyLogSource.tor,
      level: _torSeverityToLevel(message.severity),
      message: message.message,
      timestamp: message.timestamp,
    );
  }

  @override
  List<Object?> get hashParameters => [
    source,
    level,
    message,
    timestamp,
    profileId,
  ];
}

String _torSeverityToLevel(String severity) {
  return switch (severity.toUpperCase()) {
    'ERR' => 'error',
    'WARN' => 'warn',
    'DEBUG' => 'debug',
    'INFO' || 'NOTICE' => 'info',
    _ => severity.toLowerCase(),
  };
}
