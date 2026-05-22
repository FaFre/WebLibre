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

sealed class ProxyConnectionId {
  const ProxyConnectionId();

  String encode();

  static ProxyConnectionId? decode(String? raw) {
    if (raw == null) return null;
    if (raw == TorProxyConnectionId.encoded) {
      return const TorProxyConnectionId();
    }

    if (raw.startsWith(SingboxProxyConnectionId._prefix)) {
      final profileId = raw.substring(SingboxProxyConnectionId._prefix.length);
      if (profileId.isEmpty) return null;
      return SingboxProxyConnectionId(profileId);
    }

    return null;
  }
}

final class TorProxyConnectionId extends ProxyConnectionId {
  static const String encoded = 'tor';

  const TorProxyConnectionId();

  @override
  String encode() => encoded;

  @override
  bool operator ==(Object other) => other is TorProxyConnectionId;

  @override
  int get hashCode => encoded.hashCode;
}

final class SingboxProxyConnectionId extends ProxyConnectionId {
  static const String _prefix = 'singbox:';

  final String profileId;

  const SingboxProxyConnectionId(this.profileId);

  @override
  String encode() => '$_prefix$profileId';

  @override
  bool operator ==(Object other) {
    return other is SingboxProxyConnectionId && other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(_prefix, profileId);
}
