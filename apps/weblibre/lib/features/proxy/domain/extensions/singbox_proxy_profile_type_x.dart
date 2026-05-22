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
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';

extension SingboxProxyProfileTypeExt on SingboxProxyProfileType {
  /// Long human label for menus, dialogs, subtitles.
  String get label => switch (this) {
    SingboxProxyProfileType.socks => 'SOCKS',
    SingboxProxyProfileType.http => 'HTTP',
    SingboxProxyProfileType.shadowsocks => 'Shadowsocks',
    SingboxProxyProfileType.vmess => 'VMess',
    SingboxProxyProfileType.vless => 'VLESS',
    SingboxProxyProfileType.trojan => 'Trojan',
    SingboxProxyProfileType.naive => 'Naive',
    SingboxProxyProfileType.hysteria => 'Hysteria',
    SingboxProxyProfileType.hysteria2 => 'Hysteria2',
    SingboxProxyProfileType.tuic => 'TUIC',
    SingboxProxyProfileType.ssh => 'SSH',
    SingboxProxyProfileType.wireguard => 'WireGuard',
    SingboxProxyProfileType.shadowTls => 'ShadowTLS',
    SingboxProxyProfileType.anyTls => 'AnyTLS',
    SingboxProxyProfileType.customOutbound => 'Custom Outbound',
  };

  /// Short 2-5 char protocol abbreviation for the profile-list badge.
  String get badge => switch (this) {
    SingboxProxyProfileType.socks => 'SOCKS',
    SingboxProxyProfileType.http => 'HTTP',
    SingboxProxyProfileType.shadowsocks => 'SS',
    SingboxProxyProfileType.vmess => 'VMESS',
    SingboxProxyProfileType.vless => 'VLESS',
    SingboxProxyProfileType.trojan => 'TRJ',
    SingboxProxyProfileType.naive => 'NAIVE',
    SingboxProxyProfileType.hysteria => 'HY1',
    SingboxProxyProfileType.hysteria2 => 'HY2',
    SingboxProxyProfileType.tuic => 'TUIC',
    SingboxProxyProfileType.ssh => 'SSH',
    SingboxProxyProfileType.wireguard => 'WG',
    SingboxProxyProfileType.shadowTls => 'STLS',
    SingboxProxyProfileType.anyTls => 'ATLS',
    SingboxProxyProfileType.customOutbound => 'JSON',
  };
}
