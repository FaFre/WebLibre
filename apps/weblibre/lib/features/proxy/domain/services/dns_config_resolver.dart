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
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_dns_override.dart';

/// The DoH endpoint sing-box resolves names through, from the browser's own
/// resolver settings.
///
/// Never blank. sing-box has no usable resolver of its own on Android: every
/// lookup — the WireGuard peer hostname included — is bounced to the platform
/// `local` transport, which is backed by this URL. A blank setting therefore
/// does not mean "no DNS preference", it means *no DNS at all*: the runtime
/// starts without a `dns` block, so `default_domain_resolver` is never set and
/// the bootstrap bridge answers SERVFAIL to everything, which reads as every
/// lookup failing rather than as a misconfigured resolver.
///
/// [selectedUrl] is the resolver the user picked, [defaultUrl] the one the
/// engine falls back to; a built-in provider backstops both so a profile with
/// no override still resolves.
String resolveBrowserDohUrl({
  required String selectedUrl,
  required String defaultUrl,
}) {
  final selected = selectedUrl.trim();
  if (selected.isNotEmpty) return selected;

  final fallback = defaultUrl.trim();
  if (fallback.isNotEmpty) return fallback;

  return BuiltInDohProviders.quad9.url;
}

/// Builds a sing-box [SingboxProxyDnsConfig] from automatic browser-DNS
/// mirroring plus per-profile [overridesByProfileId].
///
/// Profiles without an override reuse the browser DoH URL, detoured through the
/// profile and scoped to that profile's SOCKS inbound, so a proxied tab's
/// lookups leave the device inside the same tunnel its traffic does. Profiles
/// with an override use their own resolver instead — the address from a
/// WireGuard config's `DNS =` line, or an internal resolver behind the tunnel.
///
/// The mirror only works when the browser's DoH endpoint is reachable from
/// inside the tunnel. Commercial VPNs commonly answer on an in-tunnel address
/// only (Mullvad on `10.64.0.1`, not on its public anycast address), and there
/// the mirrored server is a black hole: because the inbound rule points at it,
/// every lookup dies on sing-box's 10s DNS budget rather than falling through.
/// Configure a profile resolver for such a tunnel — the WireGuard import fills
/// one in from the config's `DNS =` line.
///
/// Returns null when there is nothing to configure, letting sing-box fall back
/// to its built-in resolver behaviour.
SingboxProxyDnsConfig? buildDnsConfig({
  required Map<String, ProxyDnsOverride?> overridesByProfileId,
  required Set<String> runningProfileIds,
  required String? browserDohUrl,
}) {
  final servers = <SingboxProxyDnsServerConfig>[];
  final hasBrowserDoh = browserDohUrl != null && browserDohUrl.isNotEmpty;

  if (hasBrowserDoh) {
    servers.add(
      SingboxProxyDnsServerConfig(tag: 'browser-doh', address: browserDohUrl),
    );

    // Mirror the browser DoH URL through each running profile unless that
    // profile has an explicit override. Scope by inbound so endpoint bootstrap
    // lookups do not route through the not-yet-ready outbound and deadlock.
    for (final profileId in runningProfileIds) {
      if (overridesByProfileId[profileId] != null) {
        continue;
      }

      final outboundTag = _outboundTagForProfile(profileId);
      final inboundTag = _inboundTagForProfile(profileId);

      servers.add(
        SingboxProxyDnsServerConfig(
          tag: 'browser-doh-${singboxSanitizeTag(profileId)}',
          address: browserDohUrl,
          detourTag: outboundTag,
          matchInbounds: [inboundTag],
        ),
      );
    }
  }

  overridesByProfileId.forEach((profileId, override) {
    if (override == null || !runningProfileIds.contains(profileId)) {
      return;
    }

    final outboundTag = _outboundTagForProfile(profileId);
    final inboundTag = _inboundTagForProfile(profileId);

    final address = override.remoteServerAddress;
    if (address == null || address.isEmpty) {
      return;
    }

    servers.add(
      SingboxProxyDnsServerConfig(
        tag: 'override-${singboxSanitizeTag(profileId)}',
        address: address,
        detourTag: outboundTag,
        matchInbounds: [inboundTag],
      ),
    );
  });

  if (servers.isEmpty) return null;
  return SingboxProxyDnsConfig(
    servers: servers,
    finalServerTag: hasBrowserDoh ? 'browser-doh' : null,
    domainStrategy: _domainStrategy(overridesByProfileId).singboxValue,
  );
}

ProxyDnsDomainStrategy _domainStrategy(
  Map<String, ProxyDnsOverride?> overridesByProfileId,
) {
  for (final override in overridesByProfileId.values) {
    if (override != null) return override.domainStrategy;
  }
  return ProxyDnsDomainStrategy.preferIpv4;
}

/// Must mirror Kotlin `SingboxTagFormat.outboundTag(profileId)`.
///
/// The Kotlin builder receives the *runtime* profile id (which Dart prefixes
/// with `singbox:` via [SingboxProxyConnectionId] in
/// `ProxyProfileX.toRuntimeProfile`), then sanitises it. We must therefore
/// apply the same prefix here so the detour tag we emit references the same
/// outbound the builder actually created.
///
/// The mirrored Kotlin test lives in `SingboxTagFormatTest.kt` — both must
/// update together if this format ever changes.
String _outboundTagForProfile(String profileId) {
  return singboxOutboundTag(SingboxProxyConnectionId(profileId).encode());
}

/// Must mirror Kotlin `SingboxTagFormat.inboundTag(profileId)`.
String _inboundTagForProfile(String profileId) {
  return singboxInboundTag(SingboxProxyConnectionId(profileId).encode());
}

/// Public so the format-contract test can assert it directly.
String singboxOutboundTag(String runtimeProfileId) =>
    'out-${singboxSanitizeTag(runtimeProfileId)}';

String singboxInboundTag(String runtimeProfileId) =>
    'in-${singboxSanitizeTag(runtimeProfileId)}';

String singboxSanitizeTag(String value) =>
    value.replaceAll(RegExp('[^A-Za-z0-9_.-]'), '_');
