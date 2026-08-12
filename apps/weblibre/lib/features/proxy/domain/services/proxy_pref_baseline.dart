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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

part 'proxy_pref_baseline.g.dart';

/// Closes Gecko's own way around every proxy this app configures.
///
/// `nsIHttpChannelInternal.bypassProxy` makes a channel skip proxy resolution
/// altogether (`nsHttpChannel::MaybeResolveProxyAndBeginConnect`): not just the
/// proxy prefs, but the extension's `proxy.onRequest` filter too, because the
/// proxy service is never consulted for that channel. The request goes out on a
/// direct socket and resolves its host with the system resolver, whatever
/// routing says.
///
/// Gecko sets it on its own service traffic. Remote Settings
/// (`services/settings/Utils.sys.mjs`) retries with `bypassProxy: true` the
/// moment a proxied fetch fails, which is exactly what this app's fail-closed
/// routing makes it do — every blocked sync of
/// `firefox.settings.services.mozilla.com` and of the content-signature chain
/// on `content-signature-2.cdn.mozilla.net` came straight back out unproxied.
/// Telemetry's send path (`TelemetrySend.sys.mjs`) does the same.
///
/// The pref gates the flag itself: `HttpBaseChannel::BypassProxy()` reads it on
/// every check, and `SetBypassProxy` fails outright while it is false, so the
/// callers never get the bypass and Remote Settings' retry rejects instead of
/// falling back. It is the same switch Tor Browser compiles in as
/// `MOZ_PROXY_BYPASS_PROTECTION`, which is off in ordinary GeckoView builds.
///
/// Held in both baseline states, not just the armed one: a bypass is a leak
/// past whatever routing the extension decides per request, including routing
/// that only some containers use, and there is nothing it buys a profile that
/// routes everything directly anyway.
const _proxyBypassProtection = <String, Object>{
  'network.proxy.allow_bypass': false,
};

/// Proxy prefs pointing at a port nothing listens on.
///
/// This covers the one window the proxy extension cannot: the moment between
/// Gecko starting and the extension's `proxy.onRequest` listener being
/// installed. No request can be filtered before that listener exists, so
/// without a baseline the engine's own early traffic goes out directly.
/// GeckoView exposes no way to seed prefs before `GeckoRuntime.create`, so
/// instead these are written to the profile's user branch and left there —
/// prefs.js is read before anything starts, which makes every launch after the
/// first fail closed from the very first request.
///
/// The extension overrides this per request once it holds a snapshot: contexts
/// it resolves as direct return `null`, which Mozilla's proxy filter treats as
/// "ignore the prefs and connect directly".
///
/// It also depends on this baseline for the requests it *blocks*. The proxy
/// array it returns for those becomes a failover chain that Firefox terminates
/// with the prefs-derived default, so the extension's dead-proxy answer is only
/// as blocking as these prefs are. See `emergencyBreak` in the extension's
/// `BackgroundMain.ts` — the two are one mechanism, and neither should be
/// removed on the assumption that the other blocks by itself.
///
/// These prefs are owned here and nowhere else. They deliberately do not appear
/// in `assets/preferences/settings.json`: a hardening entry of the same name
/// would be rewritten by "apply all", by onboarding and by the hardening reset,
/// each of which would silently disarm the barrier — and because the value
/// persists in prefs.js, disarm it for the following cold start too.
const _deadProxyPrefs = <String, Object>{
  ..._proxyBypassProtection,
  // 1 = manual configuration. Protocols with no specific proxy set fall back to
  // the SOCKS proxy, so this covers http, https and everything else.
  'network.proxy.type': 1,
  'network.proxy.socks': '127.0.0.1',
  'network.proxy.socks_port': 1,
  'network.proxy.socks_version': 5,
  // Resolve names through the (dead) proxy as well, so a blocked request cannot
  // still leak the hostname to the system resolver.
  'network.proxy.socks_remote_dns': true,
};

/// What the same prefs hold while no context needs a proxy.
///
/// Written rather than reset, because Gecko's own defaults are not what this
/// profile wants: `network.proxy.type` defaults to 5 (inherit Android's system
/// proxy), and leaving DNS resolution local would undo the hardening the
/// armed state relies on. Setting them keeps WebLibre in charge of proxying in
/// both states instead of handing it back to the system on the way down.
const _directProxyPrefs = <String, Object>{
  ..._proxyBypassProtection,
  // 0 = no proxy, and specifically not the system's.
  'network.proxy.type': 0,
  'network.proxy.socks_remote_dns': true,
};

/// The dead endpoint itself is cleared on disarm, so no user-branch residue is
/// left pointing at a port nothing listens on.
final _socksEndpointPrefNames = _deadProxyPrefs.keys
    .where((name) => !_directProxyPrefs.containsKey(name))
    .toList();

/// Whether any context in [snapshot] routes through a proxy.
///
/// The baseline only makes sense for a profile that actually uses proxy
/// routing. Enabling it unconditionally would mean a browser that cannot reach
/// the network at all if the extension ever failed to load, for users who never
/// asked for a proxy in the first place.
bool routingRequiresProxy(ContainerRoutingSnapshot snapshot) {
  return snapshot.relations.values.any((proxyIds) => proxyIds.isNotEmpty);
}

/// Keeps the fail-closed proxy prefs in sync with whether routing needs them.
@Riverpod(keepAlive: true)
class ProxyPrefBaseline extends _$ProxyPrefBaseline {
  final _service = GeckoPrefService();
  final _lock = Lock();

  /// Last state successfully written. Null until the first write, so a failed
  /// write is retried rather than assumed.
  bool? _applied;

  Future<void> setRequired({required bool required}) {
    return _lock.synchronized(() async {
      if (_applied == required) return;

      if (required) {
        await _service.applyPrefs(_deadProxyPrefs);
      } else {
        // Order matters: dropping the proxy type first means the endpoint is
        // only cleared once nothing routes through it. The reverse order would
        // briefly leave manual proxying pointed at an empty host.
        await _service.applyPrefs(_directProxyPrefs);
        await _service.resetPrefs(_socksEndpointPrefNames);
      }

      _applied = required;
    });
  }

  @override
  void build() {
    return;
  }
}
