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
import 'package:weblibre/features/proxy/data/forms/singbox_form_field.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_spec.dart';

const _serverField = SingboxProxyFormField(key: 'server', required: true);
const _serverPortField = SingboxProxyFormField(
  key: 'server_port',
  required: true,
  kind: SingboxFieldKind.port,
);
const _usernameField = SingboxProxyFormField(
  key: 'username',
  kind: SingboxFieldKind.secret,
);
const _passwordField = SingboxProxyFormField(
  key: 'password',
  required: true,
  kind: SingboxFieldKind.secret,
);
const _optionalPasswordField = SingboxProxyFormField(
  key: 'password',
  kind: SingboxFieldKind.secret,
);
const _uuidField = SingboxProxyFormField(
  key: 'uuid',
  required: true,
  kind: SingboxFieldKind.secret,
);
const _tlsFields = [
  SingboxProxyFormField(key: 'tls.enabled', kind: SingboxFieldKind.boolean),
  SingboxProxyFormField(key: 'tls.server_name'),
  SingboxProxyFormField(key: 'tls.insecure', kind: SingboxFieldKind.boolean),
  SingboxProxyFormField(key: 'tls.alpn', kind: SingboxFieldKind.stringList),
];
const _transportFields = [
  SingboxProxyFormField(key: 'transport.type'),
  SingboxProxyFormField(key: 'transport.path'),
  SingboxProxyFormField(key: 'transport.service_name'),
];
const _multiplexFields = [
  SingboxProxyFormField(
    key: 'multiplex.enabled',
    kind: SingboxFieldKind.boolean,
  ),
  SingboxProxyFormField(key: 'multiplex.protocol'),
  SingboxProxyFormField(
    key: 'multiplex.max_connections',
    kind: SingboxFieldKind.integer,
  ),
];
const _dialFields = [
  SingboxProxyFormField(key: 'detour'),
  SingboxProxyFormField(key: 'bind_interface'),
  SingboxProxyFormField(key: 'routing_mark', kind: SingboxFieldKind.integer),
  SingboxProxyFormField(key: 'domain_strategy'),
  SingboxProxyFormField(key: 'connect_timeout'),
];
const _v2rayAdvancedFields = [
  ..._tlsFields,
  ..._transportFields,
  ..._multiplexFields,
  ..._dialFields,
];
const _commonAdvancedFields = [..._multiplexFields, ..._dialFields];

const singboxProxyFormSpecs = <SingboxProxyProfileType, SingboxProxyFormSpec>{
  SingboxProxyProfileType.socks: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.socks,
    outboundType: 'socks',
    fields: [
      _serverField,
      _serverPortField,
      SingboxProxyFormField(
        key: 'version',
        defaultValue: '5',
        // sing-box expects this as a JSON string enum, not a number.
        kind: SingboxFieldKind.choice,
        allowedValues: ['5', '4a', '4'],
      ),
      _usernameField,
      _optionalPasswordField,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.http: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.http,
    outboundType: 'http',
    fields: [
      _serverField,
      _serverPortField,
      _usernameField,
      _optionalPasswordField,
      ..._tlsFields,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.shadowsocks: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.shadowsocks,
    outboundType: 'shadowsocks',
    fields: [
      _serverField,
      _serverPortField,
      SingboxProxyFormField(
        key: 'method',
        defaultValue: '2022-blake3-aes-128-gcm',
        required: true,
      ),
      _passwordField,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.vmess: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.vmess,
    outboundType: 'vmess',
    fields: [
      _serverField,
      _serverPortField,
      _uuidField,
      SingboxProxyFormField(key: 'security', defaultValue: 'auto'),
      SingboxProxyFormField(key: 'alter_id', kind: SingboxFieldKind.integer),
      ..._v2rayAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.vless: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.vless,
    outboundType: 'vless',
    fields: [
      _serverField,
      _serverPortField,
      _uuidField,
      SingboxProxyFormField(key: 'flow'),
      ..._v2rayAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.trojan: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.trojan,
    outboundType: 'trojan',
    fields: [
      _serverField,
      _serverPortField,
      _passwordField,
      ..._v2rayAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.naive: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.naive,
    outboundType: 'naive',
    fields: [
      _serverField,
      _serverPortField,
      _usernameField,
      _passwordField,
      ..._tlsFields,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.hysteria: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.hysteria,
    outboundType: 'hysteria',
    fields: [
      _serverField,
      _serverPortField,
      SingboxProxyFormField(key: 'auth_str', kind: SingboxFieldKind.secret),
      SingboxProxyFormField(key: 'up'),
      SingboxProxyFormField(key: 'down'),
      SingboxProxyFormField(key: 'obfs', kind: SingboxFieldKind.secret),
      SingboxProxyFormField(
        key: 'recv_window_conn',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(key: 'recv_window', kind: SingboxFieldKind.integer),
      SingboxProxyFormField(
        key: 'disable_mtu_discovery',
        kind: SingboxFieldKind.boolean,
      ),
      ..._tlsFields,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.hysteria2: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.hysteria2,
    outboundType: 'hysteria2',
    fields: [
      _serverField,
      _serverPortField,
      _passwordField,
      SingboxProxyFormField(key: 'up_mbps', kind: SingboxFieldKind.integer),
      SingboxProxyFormField(key: 'down_mbps', kind: SingboxFieldKind.integer),
      SingboxProxyFormField(key: 'obfs.type'),
      SingboxProxyFormField(
        key: 'obfs.password',
        kind: SingboxFieldKind.secret,
      ),
      ..._tlsFields,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.tuic: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.tuic,
    outboundType: 'tuic',
    fields: [
      _serverField,
      _serverPortField,
      _uuidField,
      _passwordField,
      SingboxProxyFormField(key: 'congestion_control', defaultValue: 'cubic'),
      SingboxProxyFormField(key: 'udp_relay_mode', defaultValue: 'native'),
      SingboxProxyFormField(
        key: 'zero_rtt_handshake',
        kind: SingboxFieldKind.boolean,
      ),
      ..._tlsFields,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.ssh: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.ssh,
    outboundType: 'ssh',
    fields: [
      _serverField,
      _serverPortField,
      SingboxProxyFormField(key: 'user', required: true),
      _optionalPasswordField,
      SingboxProxyFormField(key: 'private_key', kind: SingboxFieldKind.secret),
      SingboxProxyFormField(
        key: 'private_key_passphrase',
        kind: SingboxFieldKind.secret,
      ),
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.wireguard: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.wireguard,
    outboundType: 'wireguard',
    fields: [
      _serverField,
      _serverPortField,
      SingboxProxyFormField(
        key: 'local_address',
        required: true,
        kind: SingboxFieldKind.cidrList,
      ),
      SingboxProxyFormField(key: 'peer_public_key', required: true),
      SingboxProxyFormField(
        key: 'private_key',
        // Distinct from SSH's 'private_key' field: same wire-format name,
        // but WireGuard's carries different helper text.
        labelKey: 'wireguardPrivateKey',
        required: true,
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(
        key: 'pre_shared_key',
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(
        key: 'mtu',
        defaultValue: '1280',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(
        key: 'persistent_keepalive_interval',
        defaultValue: '25',
        kind: SingboxFieldKind.integer,
        minValue: 0,
      ),
      SingboxProxyFormField(
        key: 'reserved',
        kind: SingboxFieldKind.integerList,
        exactListLength: 3,
        minValue: 0,
        maxValue: 255,
      ),
    ],
  ),
  SingboxProxyProfileType.shadowTls: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.shadowTls,
    outboundType: 'shadowtls',
    fields: [
      _serverField,
      _serverPortField,
      SingboxProxyFormField(
        key: 'version',
        // Distinct from SOCKS's 'version' field (also key: 'version', but a
        // different, choice-typed field with its own label).
        labelKey: 'shadowTlsVersion',
        defaultValue: '3',
        kind: SingboxFieldKind.integer,
      ),
      _passwordField,
      ..._tlsFields,
      ..._commonAdvancedFields,
    ],
  ),
  SingboxProxyProfileType.anyTls: SingboxProxyFormSpec(
    type: SingboxProxyProfileType.anyTls,
    outboundType: 'anytls',
    fields: [_serverField, _serverPortField, _passwordField, ..._dialFields],
  ),
};
