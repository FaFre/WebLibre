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
import 'package:flutter/widgets.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Long human label for menus, dialogs, subtitles. Most branches are
/// technical protocol names left untranslated on purpose (SOCKS, VLESS, ...);
/// only `customOutbound` has real prose.
extension SingboxProxyProfileTypeL10n on SingboxProxyProfileType {
  String label(BuildContext context) => switch (this) {
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
    SingboxProxyProfileType.wireguard => wireGuardBrand,
    SingboxProxyProfileType.shadowTls => 'ShadowTLS',
    SingboxProxyProfileType.anyTls => 'AnyTLS',
    SingboxProxyProfileType.customOutbound => AppLocalizations.of(
      context,
    ).proxy_customOutboundLabel,
  };
}
