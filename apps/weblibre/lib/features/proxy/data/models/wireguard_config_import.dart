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
import 'package:weblibre/features/proxy/data/parsers/host_port.dart';

class WireguardConfigImport with FastEquatable {
  /// Values that seed the shared [SingboxProxyFormSpec]-driven WireGuard form.
  final Map<String, String> values;

  /// Newline-separated DNS servers parsed from the WireGuard `[Interface] DNS`
  /// line. Not round-tripped through sing-box outbound JSON because DNS lives
  /// in the top-level `dns` block and is surfaced as a per-profile override.
  final String dns;

  WireguardConfigImport({required this.values, this.dns = ''});

  @override
  List<Object?> get hashParameters => [values, dns];

  factory WireguardConfigImport.fromConfigText(String configText) {
    final sections = _parseWireguardConfig(configText);
    final interface = sections['interface'];
    final peer = sections['peer'];
    if (interface == null || peer == null) {
      throw const FormatException(
        'WireGuard config must contain [Interface] and [Peer] sections.',
      );
    }

    final rawEndpoint = (peer['endpoint'] ?? '').trim();
    final endpoint = rawEndpoint.isEmpty
        ? (host: '', port: '')
        : parseHostPort(
            rawEndpoint,
            invalidMessage: 'WireGuard endpoint must be host:port.',
          );
    final mtu = interface['mtu']?.trim();

    return WireguardConfigImport(
      values: {
        'server': endpoint.host,
        'server_port': endpoint.port,
        'local_address': _wireguardListValue(interface['address']),
        'private_key': interface['privatekey']?.trim() ?? '',
        'peer_public_key': peer['publickey']?.trim() ?? '',
        'pre_shared_key': peer['presharedkey']?.trim() ?? '',
        'mtu': mtu == null || mtu.isEmpty ? '1408' : mtu,
      },
      dns: _wireguardListValue(interface['dns']),
    );
  }

  /// First parsed DNS entry as a sing-box-compatible address, or null when
  /// the imported config had no `DNS = …` line. Bare IPs become `udp://<ip>`
  /// (sing-box's plain-UDP scheme); anything already containing `://` is kept
  /// verbatim so users can paste `https://…/dns-query` etc.
  String? get primaryDnsAddress {
    final entries = _splitList(dns);
    if (entries.isEmpty) return null;
    final first = entries.first;
    if (first.contains('://')) return first;
    return 'udp://$first';
  }
}

List<String> _splitList(String value) {
  return value
      .replaceAll('[', '')
      .replaceAll(']', '')
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, Map<String, String>> _parseWireguardConfig(String configText) {
  final sections = <String, Map<String, String>>{};
  String? currentSection;

  for (final rawLine in const LineSplitter().convert(configText)) {
    final line = _stripWireguardComment(rawLine).trim();
    if (line.isEmpty) continue;

    if (line.startsWith('[') && line.endsWith(']')) {
      currentSection = line.substring(1, line.length - 1).trim().toLowerCase();
      if (currentSection.isEmpty) {
        throw const FormatException('WireGuard config contains empty section.');
      }
      sections.putIfAbsent(currentSection, () => <String, String>{});
      continue;
    }

    if (currentSection == null) {
      throw const FormatException(
        'WireGuard config entries must be inside a section.',
      );
    }

    final separatorIndex = line.indexOf('=');
    if (separatorIndex < 1) {
      throw FormatException('Invalid WireGuard config line: $rawLine');
    }

    final key = line.substring(0, separatorIndex).trim().toLowerCase();
    final value = line.substring(separatorIndex + 1).trim();
    if (key.isEmpty) {
      throw FormatException('Invalid WireGuard config line: $rawLine');
    }
    sections[currentSection]![key] = value;
  }

  return sections;
}

String _stripWireguardComment(String line) {
  final hashIndex = line.indexOf('#');
  final semicolonIndex = line.indexOf(';');
  final indexes = [
    if (hashIndex >= 0) hashIndex,
    if (semicolonIndex >= 0) semicolonIndex,
  ];
  if (indexes.isEmpty) return line;
  indexes.sort();
  return line.substring(0, indexes.first);
}

String _wireguardListValue(String? value) {
  if (value == null) return '';
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join('\n');
}
