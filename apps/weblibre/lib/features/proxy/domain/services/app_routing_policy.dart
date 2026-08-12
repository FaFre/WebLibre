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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

/// How the app's own network requests must be routed.
///
/// The app makes requests the engine knows nothing about — favicon lookups,
/// search suggestions, feed fetches, add-on metadata. They carry exactly the
/// information a proxy is meant to hide (which sites the user visits, what they
/// type, what they subscribe to), so they follow the same global routing
/// decision as regular tabs rather than going out on their own.
sealed class AppRoutingPolicy with FastEquatable {
  AppRoutingPolicy();
}

/// Global routing is direct, so requests may go out unproxied.
final class DirectAppRouting extends AppRoutingPolicy {
  DirectAppRouting();

  @override
  List<Object?> get hashParameters => const ['direct'];
}

/// Requests must go through this SOCKS5 endpoint.
final class ProxiedAppRouting extends AppRoutingPolicy {
  final String host;
  final int port;
  final String? username;
  final String? password;

  ProxiedAppRouting({
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  @override
  List<Object?> get hashParameters => [
    'proxied',
    host,
    port,
    username,
    password,
  ];
}

/// Global routing requires a proxy that is not usable. No request may be made:
/// opening a direct socket here is the leak, not the error.
final class BlockedAppRouting extends AppRoutingPolicy {
  final String reason;

  BlockedAppRouting(this.reason);

  @override
  List<Object?> get hashParameters => ['blocked', reason];
}

/// Thrown instead of sending a request that global routing cannot carry.
class AppRoutingBlockedException implements Exception {
  final String reason;

  const AppRoutingBlockedException(this.reason);

  @override
  String toString() => 'Request blocked by proxy routing: $reason';
}

/// Resolve the policy for requests the app makes on behalf of [contextId].
///
/// Requests that belong to no particular container — favicon lookups, search
/// suggestions, feed fetches, add-on metadata — pass [generalContextId], which
/// is how the extension treats the engine's own contextless requests.
///
/// Deliberately mirrors the extension's `Store.getProxiesForContainer`,
/// including the rule that `private` never inherits the general relation, so
/// app-originated traffic for a container is routed exactly like that
/// container's tabs. Every uncertain case resolves to [BlockedAppRouting].
///
/// Resolving this from the snapshot rather than re-reading container settings
/// is the point: a hand-rolled second implementation is how a container ends up
/// proxied for page loads but direct for the app's own lookups.
AppRoutingPolicy resolveAppRoutingPolicyForContext(
  ContainerRoutingSnapshot? snapshot,
  String contextId,
) {
  if (snapshot == null) {
    // Routing has not been decided yet. "Not yet known" is not "not needed".
    return BlockedAppRouting('container routing has not resolved yet');
  }

  final proxyIds =
      snapshot.relations[contextId] ??
      (contextId != privateContextId
          ? snapshot.relations[generalContextId]
          : null) ??
      const <String>[];

  if (proxyIds.isEmpty) {
    return DirectAppRouting();
  }

  final proxyId = proxyIds.first;
  final proxy = snapshot.proxies
      .where((candidate) => candidate.id == proxyId)
      .firstOrNull;

  if (proxy == null) {
    return BlockedAppRouting('proxy connection "$proxyId" is not running');
  }

  // Only SOCKS is carried here. Anything else is a configuration the app-side
  // client cannot honour, and guessing would mean going direct.
  if (proxy.type != 'socks') {
    return BlockedAppRouting(
      'proxy connection "$proxyId" uses unsupported type "${proxy.type}"',
    );
  }

  return ProxiedAppRouting(
    host: proxy.host,
    port: proxy.port,
    username: proxy.username,
    password: proxy.password,
  );
}
