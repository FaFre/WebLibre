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
import 'package:weblibre/features/proxy/data/forms/singbox_form_field.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_spec.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display label/helper text for [SingboxProxyFormField]. Resolved by
/// [SingboxProxyFormField.labelKey], not [SingboxProxyFormField.key] — see that
/// field's doc comment for why they can differ.
extension SingboxProxyFormFieldL10n on SingboxProxyFormField {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (labelKey) {
      'server' => l10n.proxy_fieldServerAddress,
      'server_port' => l10n.proxy_fieldServerPort,
      'username' => l10n.proxy_fieldUsername,
      'password' => l10n.proxy_fieldPassword,
      'uuid' => l10n.proxy_fieldUuid,
      'tls.enabled' => l10n.proxy_fieldTlsEnabled,
      'tls.server_name' => l10n.proxy_fieldTlsServerName,
      'tls.insecure' => l10n.proxy_fieldTlsInsecure,
      'tls.alpn' => l10n.proxy_fieldTlsAlpn,
      'transport.type' => l10n.proxy_fieldTransportType,
      'transport.path' => l10n.proxy_fieldTransportPath,
      'transport.service_name' => l10n.proxy_fieldGrpcServiceName,
      'multiplex.enabled' => l10n.proxy_fieldMultiplexEnabled,
      'multiplex.protocol' => l10n.proxy_fieldMultiplexProtocol,
      'multiplex.max_connections' => l10n.proxy_fieldMultiplexMaxConnections,
      'detour' => l10n.proxy_fieldDialDetour,
      'bind_interface' => l10n.proxy_fieldBindInterface,
      'routing_mark' => l10n.proxy_fieldRoutingMark,
      'domain_strategy' => l10n.proxy_fieldDomainStrategy,
      'connect_timeout' => l10n.proxy_fieldConnectTimeout,
      'version' => l10n.proxy_fieldSocksVersion,
      'method' => l10n.proxy_fieldMethod,
      'security' => l10n.proxy_fieldSecurity,
      'alter_id' => l10n.proxy_fieldAlterId,
      'flow' => l10n.proxy_fieldFlow,
      'auth_str' => l10n.proxy_fieldAuthString,
      'up' => l10n.proxy_fieldUploadBandwidth,
      'down' => l10n.proxy_fieldDownloadBandwidth,
      'obfs' => l10n.proxy_fieldObfuscation,
      'recv_window_conn' => l10n.proxy_fieldReceiveWindowConn,
      'recv_window' => l10n.proxy_fieldReceiveWindow,
      'disable_mtu_discovery' => l10n.proxy_fieldDisableMtuDiscovery,
      'up_mbps' => l10n.proxy_fieldUploadMbps,
      'down_mbps' => l10n.proxy_fieldDownloadMbps,
      'obfs.type' => l10n.proxy_fieldObfuscationType,
      'obfs.password' => l10n.proxy_fieldObfuscationPassword,
      'congestion_control' => l10n.proxy_fieldCongestionControl,
      'udp_relay_mode' => l10n.proxy_fieldUdpRelayMode,
      'zero_rtt_handshake' => l10n.proxy_fieldZeroRttHandshake,
      'user' => l10n.proxy_fieldUser,
      'private_key' => l10n.proxy_fieldPrivateKey,
      'private_key_passphrase' => l10n.proxy_fieldPrivateKeyPassphrase,
      'local_address' => l10n.proxy_fieldLocalAddress,
      'peer_public_key' => l10n.proxy_fieldPeerPublicKey,
      'wireguardPrivateKey' => l10n.proxy_fieldWireguardPrivateKey,
      'pre_shared_key' => l10n.proxy_fieldPreSharedKey,
      'mtu' => l10n.proxy_fieldMtu,
      'persistent_keepalive_interval' => l10n.proxy_fieldPersistentKeepalive,
      'reserved' => l10n.proxy_fieldReservedBytes,
      'shadowTlsVersion' => l10n.proxy_fieldShadowTlsVersion,
      _ => key,
    };
  }

  String? helperText(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (labelKey) {
      'tls.enabled' => l10n.proxy_fieldTlsEnabledHelper,
      'tls.insecure' => l10n.proxy_fieldTlsInsecureHelper,
      'tls.alpn' => l10n.proxy_fieldTlsAlpnHelper,
      'transport.type' => l10n.proxy_fieldTransportTypeHelper,
      'multiplex.enabled' => l10n.proxy_fieldMultiplexEnabledHelper,
      'domain_strategy' => l10n.proxy_fieldDomainStrategyHelper,
      'connect_timeout' => l10n.proxy_fieldConnectTimeoutHelper,
      'disable_mtu_discovery' => l10n.proxy_fieldDisableMtuDiscoveryHelper,
      'zero_rtt_handshake' => l10n.proxy_fieldZeroRttHandshakeHelper,
      'local_address' => l10n.proxy_fieldLocalAddressHelper,
      'wireguardPrivateKey' => l10n.proxy_fieldWireguardPrivateKeyHelper,
      'pre_shared_key' => l10n.proxy_fieldPreSharedKeyHelper,
      'mtu' => l10n.proxy_fieldMtuHelper,
      'persistent_keepalive_interval' =>
        l10n.proxy_fieldPersistentKeepaliveHelper,
      'reserved' => l10n.proxy_fieldReservedBytesHelper,
      _ => null,
    };
  }
}

/// Display text for a [SingboxFormFieldError].
extension SingboxFormFieldErrorL10n on SingboxFormFieldError {
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = field.label(context);

    return switch (kind) {
      SingboxFieldErrorKind.required => l10n.proxy_fieldErrorRequired(label),
      SingboxFieldErrorKind.notPositiveNumber =>
        l10n.proxy_fieldErrorNotPositiveNumber(label),
      SingboxFieldErrorKind.outOfPortRange => l10n.proxy_fieldErrorPortRange(
        label,
      ),
      SingboxFieldErrorKind.wrongListLength => l10n.proxy_fieldErrorListLength(
        label,
        intParam!,
      ),
      SingboxFieldErrorKind.notAllNumbers => l10n.proxy_fieldErrorNotAllNumbers(
        label,
      ),
      SingboxFieldErrorKind.belowMinValue => l10n.proxy_fieldErrorBelowMin(
        label,
        intParam!,
      ),
      SingboxFieldErrorKind.aboveMaxValue => l10n.proxy_fieldErrorAboveMax(
        label,
        intParam!,
      ),
      SingboxFieldErrorKind.invalidCidr => l10n.proxy_fieldErrorInvalidCidr(
        label,
        stringParam!,
      ),
      SingboxFieldErrorKind.notBoolean => l10n.proxy_fieldErrorNotBoolean(
        label,
      ),
      SingboxFieldErrorKind.notAllowedValue =>
        l10n.proxy_fieldErrorNotAllowedValue(label, listParam!.join(', ')),
    };
  }
}
