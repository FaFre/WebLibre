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

typedef HostPort = ({String host, String port});

/// Parses a `host:port` endpoint. Accepts bracketed IPv6 syntax
/// (`[2001:db8::1]:443`). Throws [FormatException] on invalid input.
HostPort parseHostPort(
  String rawEndpoint, {
  String invalidMessage = 'Endpoint must be host:port.',
}) {
  final endpoint = rawEndpoint.trim();
  if (endpoint.startsWith('[')) {
    final closingIndex = endpoint.indexOf(']');
    if (closingIndex < 0 || closingIndex == endpoint.length - 1) {
      throw FormatException(invalidMessage);
    }
    final remainder = endpoint.substring(closingIndex + 1);
    if (!remainder.startsWith(':')) {
      throw FormatException(invalidMessage);
    }
    return (
      host: endpoint.substring(1, closingIndex),
      port: remainder.substring(1),
    );
  }

  final separatorIndex = endpoint.lastIndexOf(':');
  if (separatorIndex <= 0 || separatorIndex == endpoint.length - 1) {
    throw FormatException(invalidMessage);
  }
  final host = endpoint.substring(0, separatorIndex);
  if (host.contains(':')) {
    throw const FormatException(
      'IPv6 endpoints must use [address]:port syntax.',
    );
  }
  return (host: host, port: endpoint.substring(separatorIndex + 1));
}
