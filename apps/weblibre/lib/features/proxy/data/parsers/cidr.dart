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

/// A single tunnel address, always with the prefix length sing-box requires.
typedef Cidr = ({String address, int prefixLength, bool isIpv6});

/// Reads one address, with or without a prefix length.
///
/// A bare address gets the host prefix for its family — `/32` for IPv4, `/128`
/// for IPv6 — rather than being rejected. That is what a bare address means
/// everywhere it is written: `wg-quick` accepts `Address = 10.0.0.2`, and every
/// provider-issued config that omits the prefix issues exactly one address.
/// sing-box does not: `local_address` is a list of prefixes, and a bare one
/// fails the config parse, so the tunnel that imported cleanly refuses to start
/// later with an error naming a field the user never typed.
///
/// Returns null when [raw] is not an address at all, so callers can tell an
/// omitted prefix (fill it in) from a typo (refuse it).
Cidr? tryParseCidr(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  final separatorIndex = value.lastIndexOf('/');
  final addressPart = separatorIndex < 0
      ? value
      : value.substring(0, separatorIndex);
  final prefixPart = separatorIndex < 0
      ? null
      : value.substring(separatorIndex + 1);

  // Brackets are endpoint syntax (`[fd00::1]:443`); an address list never needs
  // them, but a config written by hand from an endpoint often carries them.
  final address = addressPart.startsWith('[') && addressPart.endsWith(']')
      ? addressPart.substring(1, addressPart.length - 1)
      : addressPart;

  final isIpv6 = address.contains(':');
  if (!(isIpv6 ? _isIpv6 : _isIpv4)(address)) return null;

  final maxPrefixLength = isIpv6 ? 128 : 32;
  if (prefixPart == null) {
    return (address: address, prefixLength: maxPrefixLength, isIpv6: isIpv6);
  }

  final prefixLength = int.tryParse(prefixPart);
  if (prefixLength == null ||
      prefixLength < 0 ||
      prefixLength > maxPrefixLength) {
    return null;
  }

  return (address: address, prefixLength: prefixLength, isIpv6: isIpv6);
}

/// [raw] as `address/prefix`, or null when it is not an address.
String? tryNormalizeCidr(String raw) {
  final cidr = tryParseCidr(raw);
  if (cidr == null) return null;

  return '${cidr.address}/${cidr.prefixLength}';
}

bool _isIpv4(String address) {
  final octets = address.split('.');
  if (octets.length != 4) return false;

  for (final octet in octets) {
    if (octet.isEmpty || octet.length > 3) return false;
    final value = int.tryParse(octet);
    if (value == null || value < 0 || value > 255) return false;
    // `010` is not an octet anywhere that matters, and treating it as one is
    // how an address means two different things in two different parsers.
    if (octet.length > 1 && octet.startsWith('0')) return false;
  }

  return true;
}

bool _isIpv6(String address) {
  if (address.isEmpty) return false;

  // A zone id (`fe80::1%wlan0`) names an interface this device may not have and
  // sing-box has no use for; refuse rather than pass it through.
  if (address.contains('%')) return false;

  // A trailing IPv4 part (`::ffff:192.0.2.1`) is legal and stands in for the
  // last two groups. Substituted for two literal groups rather than split off,
  // because splitting at the last colon takes a colon with it — and when the
  // `::` sits directly in front of the quad (`2001:db8::192.0.2.1`) that colon
  // is half the compression marker, leaving a head that parses as nothing.
  var candidate = address;
  final lastColonIndex = address.lastIndexOf(':');
  final tail = address.substring(lastColonIndex + 1);
  if (tail.contains('.')) {
    if (!_isIpv4(tail)) return false;
    candidate = '${address.substring(0, lastColonIndex + 1)}0:0';
  }

  final compressionIndex = candidate.indexOf('::');
  if (compressionIndex != candidate.lastIndexOf('::')) return false;

  final hasCompression = compressionIndex >= 0;
  final parts = hasCompression
      ? [
          candidate.substring(0, compressionIndex),
          candidate.substring(compressionIndex + 2),
        ]
      : [candidate];

  var groups = 0;
  for (final part in parts) {
    if (part.isEmpty) continue;
    for (final group in part.split(':')) {
      if (group.isEmpty || group.length > 4) return false;
      if (int.tryParse(group, radix: 16) == null) return false;
      groups++;
    }
  }

  // Compression stands in for at least one group, so a compressed address that
  // already spells out all eight is spelling one of them twice.
  return hasCompression ? groups < 8 : groups == 8;
}
