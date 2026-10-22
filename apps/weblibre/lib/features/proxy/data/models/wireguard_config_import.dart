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
import 'package:weblibre/features/proxy/data/models/proxy_import_failure.dart';
import 'package:weblibre/features/proxy/data/parsers/cidr.dart';
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
    final interfaces = sections
        .where((section) => section.name == 'interface')
        .toList();
    final peers = sections.where((section) => section.name == 'peer').toList();
    if (interfaces.isEmpty || peers.isEmpty) {
      throw const ProxyImportFailure(
        ProxyImportFailureKind.wireguardMissingSections,
      );
    }
    // Refused rather than merged: sections used to be keyed by name, so a
    // second [Peer] overwrote the first key by key and the profile ended up
    // with one peer's key, another's endpoint and either one's AllowedIPs.
    if (interfaces.length > 1) {
      throw const ProxyImportFailure(
        ProxyImportFailureKind.wireguardSeveralInterfaces,
      );
    }
    if (peers.length > 1) {
      throw ProxyImportFailure(
        ProxyImportFailureKind.wireguardSeveralPeers,
        count: peers.length,
      );
    }
    final interface = interfaces.single.entries;
    final peer = peers.single.entries;

    final rawEndpoint = (peer['endpoint'] ?? '').trim();
    final endpoint = rawEndpoint.isEmpty
        ? (host: '', port: '')
        : _parseEndpoint(rawEndpoint);
    final mtu = interface['mtu']?.trim();
    // A phone is always behind NAT. Without keepalives the mapping for the
    // tunnel's UDP flow expires while idle, the peer's packets stop arriving,
    // and everything stalls until WireGuard notices ("stopped hearing back
    // after 15 seconds") and re-handshakes — over and over. Configs written
    // for a server routinely leave this out, so absent means 25s, not off.
    final keepalive = peer['persistentkeepalive']?.trim();

    return WireguardConfigImport(
      values: {
        'server': endpoint.host,
        'server_port': endpoint.port,
        // Normalized here rather than only on the way to sing-box, so the
        // form the user is about to look at shows the prefix that will
        // actually be used instead of silently disagreeing with it.
        'local_address': _wireguardAddressValue(interface['address']),
        'private_key': interface['privatekey']?.trim() ?? '',
        'peer_public_key': peer['publickey']?.trim() ?? '',
        'pre_shared_key': peer['presharedkey']?.trim() ?? '',
        // sing-box's own default is 1408, which assumes a 1500-byte path.
        // A phone rarely has one: mobile carriers, PPPoE and any tunnel this
        // device is already inside give less, and then every full-size packet
        // fails to send at all ("sendmsg: message too long") while handshakes
        // and DNS still fit. 1280 is the IPv6 minimum every path must carry.
        'mtu': mtu == null || mtu.isEmpty ? '1280' : mtu,
        'persistent_keepalive_interval': keepalive == null || keepalive.isEmpty
            ? '25'
            : keepalive,
        // Empty when the config has none, which the runtime reads as "route
        // everything" — WireGuard's own default for a client.
        'allowed_ips': _wireguardAddressValue(peer['allowedips']),
      },
      dns: _wireguardListValue(interface['dns']),
    );
  }

  /// First parsed DNS entry as a sing-box-compatible address, or null when
  /// the imported config had no `DNS = …` line. Bare IPs become `udp://<ip>`
  /// (sing-box's plain-UDP scheme); anything already containing `://` is kept
  /// verbatim so users can paste `https://…/dns-query` etc.
  ///
  /// An IPv6 literal is bracketed on the way in. A `DNS =` line carries it
  /// bare, but the result is parsed as a URI, and `udp://fd00::1` has no
  /// readable host — the runtime would refuse to start on an address the user
  /// never typed.
  String? get primaryDnsAddress {
    final entries = _splitList(dns);
    if (entries.isEmpty) return null;
    final first = entries.first;
    if (first.contains('://')) return first;
    if (first.contains(':')) return 'udp://[$first]';
    return 'udp://$first';
  }

  /// Every DNS server the config names, in order.
  List<String> get dnsServers => _splitList(dns);

  /// DNS servers past the first. A profile resolves through one server, so
  /// these are not used — said at import rather than dropped silently.
  List<String> get extraDnsServers => _splitList(dns).skip(1).toList();

  /// The peer's AllowedIPs when they leave out part of the IPv4 internet, or
  /// null when everything is routed (or the config does not say). Sites
  /// outside them cannot be reached through the profile at all.
  List<String>? get splitTunnelAllowedIps =>
      splitTunnelRanges(_splitList(values['allowed_ips'] ?? ''));
}

HostPort _parseEndpoint(String rawEndpoint) {
  try {
    return parseHostPort(rawEndpoint);
  } on FormatException {
    throw const ProxyImportFailure(
      ProxyImportFailureKind.wireguardInvalidEndpoint,
    );
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

typedef _WireguardSection = ({String name, Map<String, String> entries});

/// The config's sections in order, each repeated section kept as its own.
List<_WireguardSection> _parseWireguardConfig(String configText) {
  final sections = <_WireguardSection>[];
  _WireguardSection? currentSection;

  for (final rawLine in const LineSplitter().convert(configText)) {
    final line = _stripWireguardComment(rawLine).trim();
    if (line.isEmpty) continue;

    if (line.startsWith('[') && line.endsWith(']')) {
      final name = line.substring(1, line.length - 1).trim().toLowerCase();
      if (name.isEmpty) {
        throw const ProxyImportFailure(
          ProxyImportFailureKind.wireguardEmptySection,
        );
      }
      currentSection = (name: name, entries: <String, String>{});
      sections.add(currentSection);
      continue;
    }

    if (currentSection == null) {
      throw const ProxyImportFailure(
        ProxyImportFailureKind.wireguardEntryOutsideSection,
      );
    }

    final separatorIndex = line.indexOf('=');
    if (separatorIndex < 1) {
      throw ProxyImportFailure(
        ProxyImportFailureKind.wireguardInvalidLine,
        detail: rawLine,
      );
    }

    final key = line.substring(0, separatorIndex).trim().toLowerCase();
    final value = line.substring(separatorIndex + 1).trim();
    if (key.isEmpty) {
      throw ProxyImportFailure(
        ProxyImportFailureKind.wireguardInvalidLine,
        detail: rawLine,
      );
    }
    currentSection.entries[key] = value;
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

/// The `[Interface] Address` list, every entry carrying a prefix length.
///
/// `wg-quick` accepts `Address = 10.0.0.2`; sing-box's `local_address` is a
/// list of prefixes and refuses to parse a bare one, so a config that imported
/// cleanly would fail at start-up instead — see [tryNormalizeCidr]. Entries
/// that are not addresses at all are kept verbatim: the form validates them and
/// says so, which is more use than dropping them here without a word.
String _wireguardAddressValue(String? value) {
  return _splitList(
    _wireguardListValue(value),
  ).map((entry) => tryNormalizeCidr(entry) ?? entry).join('\n');
}

String _wireguardListValue(String? value) {
  if (value == null) return '';
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join('\n');
}
