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
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socks5_proxy/socks_client.dart' as socks;
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_context.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

part 'routed_http_client.g.dart';

/// Configure [client] to obey [policy].
///
/// The single place a routing policy becomes an actual connection. Throws
/// [AppRoutingBlockedException] for a blocked policy, before [client] is used
/// for anything — a blocked request must not even resolve its host.
void applyRoutingPolicy(HttpClient client, AppRoutingPolicy policy) {
  switch (policy) {
    case DirectAppRouting():
      return;
    case BlockedAppRouting(:final reason):
      throw AppRoutingBlockedException(reason);
    case ProxiedAppRouting(
      :final host,
      :final port,
      :final username,
      :final password,
    ):
      final address = InternetAddress.tryParse(host);
      if (address == null) {
        // Every endpoint the runtimes publish is a loopback literal. A host
        // that needed resolving would have to be resolved unproxied first.
        throw AppRoutingBlockedException(
          'proxy endpoint host "$host" is not an IP address',
        );
      }

      // socks5_proxy hands the destination host to the proxy as a SOCKS5
      // domain address instead of resolving it locally, so the hostname never
      // reaches the system resolver.
      socks.SocksTCPClient.assignToHttpClient(client, [
        socks.ProxySettings(
          address,
          port,
          username: username,
          password: password,
        ),
      ]);
  }
}

/// An [http.Client] that honours the app's global proxy routing.
///
/// Every app-originated request resolves the policy afresh, so a proxy that
/// starts, stops or changes port takes effect on the next request rather than
/// on the next app launch. When routing cannot be honoured the request throws
/// [AppRoutingBlockedException] — it must never quietly fall back to a direct
/// socket, which is the whole reason this class exists.
class RoutedHttpClient extends http.BaseClient {
  final Future<AppRoutingPolicy> Function() _resolvePolicy;

  AppRoutingPolicy? _currentPolicy;
  http.Client? _delegate;

  /// The [HttpClient] behind [_delegate], kept so a retired delegate can be
  /// drained rather than force-closed. See [_delegateFor].
  HttpClient? _delegateHttpClient;
  var _closed = false;

  RoutedHttpClient(this._resolvePolicy);

  // `async` so a blocked policy surfaces as a failed future rather than a
  // synchronous throw — callers that use `send` directly (rather than via
  // `get`/`post`) would otherwise have to guard the call itself.
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_closed) {
      throw StateError('RoutedHttpClient has been closed');
    }

    final policy = await _resolvePolicy();
    if (policy is BlockedAppRouting) {
      // Deliberately before any socket work: nothing about this request,
      // including a DNS lookup for its host, may reach the network.
      throw AppRoutingBlockedException(policy.reason);
    }

    return await _delegateFor(policy).send(request);
  }

  http.Client _delegateFor(AppRoutingPolicy policy) {
    final existing = _delegate;
    if (existing != null && _currentPolicy == policy) {
      return existing;
    }

    // Graceful, unlike `IOClient.close()`, which force-closes the underlying
    // client and aborts whatever is still streaming on it. A proxy starting or
    // stopping must not kill unrelated in-flight requests: they finish on the
    // route they started on, and the socket pool is released once they do.
    _delegateHttpClient?.close();
    _delegate = null;
    _delegateHttpClient = null;
    // Dropped before the new delegate exists, so a policy that fails to apply
    // cannot leave a stale delegate matched to a policy it does not implement.
    _currentPolicy = null;

    final httpClient = HttpClient();
    try {
      applyRoutingPolicy(httpClient, policy);
    } catch (_) {
      httpClient.close(force: true);
      rethrow;
    }

    final delegate = IOClient(httpClient);
    _delegate = delegate;
    _delegateHttpClient = httpClient;
    _currentPolicy = policy;
    return delegate;
  }

  @override
  void close() {
    _closed = true;
    // Explicit shutdown, so this one does force: the owner is going away and
    // wants its resources back, not a drain of unbounded length.
    _delegate?.close();
    _delegate = null;
    _delegateHttpClient = null;
    _currentPolicy = null;
  }
}

/// How long a request waits for routing to be decided before giving up on it.
///
/// Bounded because "still loading" must not become "hangs forever": routing
/// that never resolves has to fail the request closed, like any other routing
/// that cannot be honoured.
const _routingResolveTimeout = Duration(seconds: 15);

/// Routing for an app-originated request on behalf of [contextId] — the single
/// seam every caller reads, so consumers depend on the routing decision rather
/// than on the whole snapshot pipeline behind it.
///
/// Awaited rather than sampled, because a request issued before the routing
/// inputs have loaded would otherwise resolve to blocked and stay failed:
/// nothing re-runs a favicon lookup, feed fetch or page-info request once
/// routing lands, so a browser opened straight onto a page could spend its
/// first seconds silently failing them. "Not known yet" is a wait; only "known
/// and unusable" is a block.
///
/// A function rather than a provider on purpose. Cached routing would have to
/// be invalidated to stay honest, and a provider that waits inside its own
/// build hands the caller a future belonging to that build — one that a
/// rebuild, which is exactly what resolving the snapshot causes, leaves behind.
/// Resolving per call also keeps a proxy that starts or stops later taking
/// effect on the very next request.
Future<AppRoutingPolicy> resolveAppRoutingPolicy(
  Ref ref,
  String contextId,
) async {
  final resolved = ref.read(containerRoutingSnapshotProvider);
  if (resolved != null) {
    return resolveAppRoutingPolicyForContext(resolved, contextId);
  }

  final pending = Completer<ContainerRoutingSnapshot?>();
  final subscription = ref.listen(containerRoutingSnapshotProvider, (
    previous,
    next,
  ) {
    if (next != null && !pending.isCompleted) {
      pending.complete(next);
    }
  });

  try {
    // Timing out resolves to null, which is the same block sampling would have
    // produced. Waiting may only ever delay that answer, never replace it with
    // a direct connection.
    final snapshot = await pending.future.timeout(
      _routingResolveTimeout,
      onTimeout: () => null,
    );
    return resolveAppRoutingPolicyForContext(snapshot, contextId);
  } finally {
    subscription.close();
  }
}

/// The client for app-originated requests that belong to no particular tab —
/// add-on metadata, proxy subscriptions, catalog downloads, account handoff.
///
/// Anything that bypasses this and builds its own `HttpClient`/`http.Client`
/// is, by construction, traffic that ignores the user's proxy settings.
///
/// Requests that describe what the user is browsing belong on
/// [selectedTabRoutedHttpClient] instead.
@Riverpod(keepAlive: true)
Raw<http.Client> routedHttpClient(Ref ref) {
  final client = RoutedHttpClient(
    () => resolveAppRoutingPolicy(ref, generalContextId),
  );
  ref.onDispose(client.close);
  return client;
}

/// Resolves routing for a request made on behalf of the selected tab.
///
/// Search suggestions, favicon lookups and link expansions disclose what the
/// user is typing, looking at and about to open, which is exactly what the
/// tab's own proxy is there to hide. Sending them over the general container's
/// route would leak them past the proxy of whatever container the user is
/// actually browsing in.
///
/// A provider handing back a function, for two reasons: the context has to be
/// resolved per request so switching tabs takes effect on the next one, and
/// consumers that are otherwise engine-free — the favicon service, its tests —
/// get a seam they can substitute instead of standing up the tab and engine
/// graph behind the selected tab.
@Riverpod(keepAlive: true)
Raw<Future<AppRoutingPolicy> Function()> selectedTabRoutingPolicy(Ref ref) {
  return () async =>
      resolveAppRoutingPolicy(ref, await routingContextIdForSelectedTab(ref));
}

/// The client for app-originated requests made on behalf of the selected tab.
///
/// See [selectedTabRoutingPolicy] for why these do not follow the general
/// container. [RoutedHttpClient] swaps its delegate when the resolved policy
/// changes, so a tab switch costs a new delegate rather than a stale route.
@Riverpod(keepAlive: true)
Raw<http.Client> selectedTabRoutedHttpClient(Ref ref) {
  final client = RoutedHttpClient(ref.watch(selectedTabRoutingPolicyProvider));
  ref.onDispose(client.close);
  return client;
}
