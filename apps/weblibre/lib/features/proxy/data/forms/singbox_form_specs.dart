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

const _serverField = SingboxProxyFormField(
  key: 'server',
  label: 'Server Address',
  required: true,
);
const _serverPortField = SingboxProxyFormField(
  key: 'server_port',
  label: 'Server Port',
  required: true,
  kind: SingboxFieldKind.port,
);
const _usernameField = SingboxProxyFormField(
  key: 'username',
  label: 'Username',
  kind: SingboxFieldKind.secret,
);
const _passwordField = SingboxProxyFormField(
  key: 'password',
  label: 'Password',
  required: true,
  kind: SingboxFieldKind.secret,
);
const _optionalPasswordField = SingboxProxyFormField(
  key: 'password',
  label: 'Password',
  kind: SingboxFieldKind.secret,
);
const _uuidField = SingboxProxyFormField(
  key: 'uuid',
  label: 'UUID',
  required: true,
  kind: SingboxFieldKind.secret,
);
const _tlsFields = [
  SingboxProxyFormField(
    key: 'tls.enabled',
    label: 'TLS Enabled',
    helperText: 'true or false.',
    kind: SingboxFieldKind.boolean,
  ),
  SingboxProxyFormField(key: 'tls.server_name', label: 'TLS Server Name'),
  SingboxProxyFormField(
    key: 'tls.insecure',
    label: 'Allow Invalid TLS Certificates',
    helperText: 'true or false.',
    kind: SingboxFieldKind.boolean,
  ),
  SingboxProxyFormField(
    key: 'tls.alpn',
    label: 'TLS ALPN',
    helperText: 'Comma-separated or one value per line.',
    kind: SingboxFieldKind.stringList,
  ),
];
const _transportFields = [
  SingboxProxyFormField(
    key: 'transport.type',
    label: 'Transport Type',
    helperText: 'For example ws, http, grpc, or quic.',
  ),
  SingboxProxyFormField(key: 'transport.path', label: 'Transport Path'),
  SingboxProxyFormField(
    key: 'transport.service_name',
    label: 'gRPC Service Name',
  ),
];
const _multiplexFields = [
  SingboxProxyFormField(
    key: 'multiplex.enabled',
    label: 'Multiplex Enabled',
    helperText: 'true or false.',
    kind: SingboxFieldKind.boolean,
  ),
  SingboxProxyFormField(key: 'multiplex.protocol', label: 'Multiplex Protocol'),
  SingboxProxyFormField(
    key: 'multiplex.max_connections',
    label: 'Multiplex Max Connections',
    kind: SingboxFieldKind.integer,
  ),
];
const _dialFields = [
  SingboxProxyFormField(key: 'detour', label: 'Dial Detour'),
  SingboxProxyFormField(key: 'bind_interface', label: 'Bind Interface'),
  SingboxProxyFormField(
    key: 'routing_mark',
    label: 'Routing Mark',
    kind: SingboxFieldKind.integer,
  ),
  SingboxProxyFormField(
    key: 'domain_strategy',
    label: 'Domain Strategy',
    helperText: 'For example prefer_ipv4 or prefer_ipv6.',
  ),
  SingboxProxyFormField(
    key: 'connect_timeout',
    label: 'Connect Timeout',
    helperText: 'For example 5s.',
  ),
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
        label: 'SOCKS Version',
        defaultValue: '5',
        kind: SingboxFieldKind.integer,
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
        label: 'Method',
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
      SingboxProxyFormField(
        key: 'security',
        label: 'Security',
        defaultValue: 'auto',
      ),
      SingboxProxyFormField(
        key: 'alter_id',
        label: 'Alter ID',
        kind: SingboxFieldKind.integer,
      ),
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
      SingboxProxyFormField(key: 'flow', label: 'Flow'),
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
      SingboxProxyFormField(
        key: 'auth_str',
        label: 'Auth String',
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(key: 'up', label: 'Upload Bandwidth'),
      SingboxProxyFormField(key: 'down', label: 'Download Bandwidth'),
      SingboxProxyFormField(
        key: 'obfs',
        label: 'Obfuscation',
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(
        key: 'recv_window_conn',
        label: 'Receive Window Conn',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(
        key: 'recv_window',
        label: 'Receive Window',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(
        key: 'disable_mtu_discovery',
        label: 'Disable MTU Discovery',
        helperText: 'true or false.',
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
      SingboxProxyFormField(
        key: 'up_mbps',
        label: 'Upload Mbps',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(
        key: 'down_mbps',
        label: 'Download Mbps',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(key: 'obfs.type', label: 'Obfuscation Type'),
      SingboxProxyFormField(
        key: 'obfs.password',
        label: 'Obfuscation Password',
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
      SingboxProxyFormField(
        key: 'congestion_control',
        label: 'Congestion Control',
        defaultValue: 'cubic',
      ),
      SingboxProxyFormField(
        key: 'udp_relay_mode',
        label: 'UDP Relay Mode',
        defaultValue: 'native',
      ),
      SingboxProxyFormField(
        key: 'zero_rtt_handshake',
        label: 'Zero RTT Handshake',
        helperText: 'true or false.',
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
      SingboxProxyFormField(key: 'user', label: 'User', required: true),
      _optionalPasswordField,
      SingboxProxyFormField(
        key: 'private_key',
        label: 'Private Key',
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(
        key: 'private_key_passphrase',
        label: 'Private Key Passphrase',
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
        label: 'Local Address',
        helperText: 'One CIDR per line, for example 10.0.0.2/32.',
        required: true,
        kind: SingboxFieldKind.stringList,
      ),
      SingboxProxyFormField(
        key: 'peer_public_key',
        label: 'Peer Public Key',
        required: true,
      ),
      SingboxProxyFormField(
        key: 'private_key',
        label: 'Private Key',
        helperText: 'Stored in secure storage, not profile JSON.',
        required: true,
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(
        key: 'pre_shared_key',
        label: 'Pre-shared Key',
        helperText: 'Optional. Stored in secure storage.',
        kind: SingboxFieldKind.secret,
      ),
      SingboxProxyFormField(
        key: 'mtu',
        label: 'MTU',
        helperText: 'Optional. sing-box uses 1408 by default.',
        defaultValue: '1408',
        kind: SingboxFieldKind.integer,
      ),
      SingboxProxyFormField(
        key: 'reserved',
        label: 'Reserved Bytes',
        helperText: 'Optional. Three comma-separated numbers, e.g. 0,0,0.',
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
        label: 'Version',
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
