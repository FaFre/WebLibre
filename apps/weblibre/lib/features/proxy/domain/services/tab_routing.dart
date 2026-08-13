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

/// Read-side counterpart to [ContainerRoutingSnapshot]: answers "how is *this*
/// tab routed right now, and is that route actually live" for the UI.
///
/// Resolution deliberately mirrors the proxy extension's `Store`
/// (`getEffectiveRelation`/`getProxiesForContainer`) rather than re-deriving
/// routing from settings and container rows. The snapshot is what the extension
/// was told, so reading it back is the only way the UI can claim to describe
/// what the engine is doing — including the two states the snapshot encodes but
/// no screen currently shows: a route naming a proxy that is not running
/// (traffic is *blocked*, not unproxied) and no acknowledged snapshot at all
/// (everything is blocked).
library;

import 'package:fast_equatable/fast_equatable.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

/// What the engine does with this tab's traffic.
enum TabRoutingStatus {
  /// The engine has not reported this tab's cookie-store context, so which
  /// relation carries it is not known. Distinct from [direct]: an unanswered
  /// question is not a direct connection.
  unknown,

  /// No acknowledged routing state: the extension blocks every request until
  /// one arrives. Normal for a fraction of a cold start, a fault after that.
  pending,

  /// Routed through a proxy that is running.
  active,

  /// Routed through a proxy that is *not* running. The extension blocks these
  /// requests rather than falling back to a direct connection, so this is a
  /// connectivity failure, never a leak.
  blocked,

  /// Connects directly, either explicitly (bypass) or because nothing routes
  /// this context.
  direct,
}

/// The resolved, display-ready routing of a single tab.
class TabRouting with FastEquatable {
  final TabRoutingStatus status;

  /// Whether the tab belongs to a container with a cookie-store context of its
  /// own but is not *in* that context — so whatever the container is set to
  /// route through, it is not what decides this tab.
  ///
  /// A container's contextual identity is fixed when the container is created,
  /// so this is a genuine inconsistency (a tab predating the identity, or one
  /// the engine opened without it), not a transient state. It is called out
  /// because the alternative is a tab that reads "Direct" while its container
  /// plainly names a proxy.
  final bool isContextMismatch;

  /// The cookie-store context the tab's traffic is keyed on: a container's
  /// contextual identity, an isolation context, [privateContextId] or
  /// [generalContextId]. Null while the engine has not reported one.
  final String? contextId;

  /// The connection carrying this tab, or null when it connects directly.
  ///
  /// Set for [TabRoutingStatus.blocked] too — knowing *which* proxy is down is
  /// the entire point of that state.
  final ProxyConnectionId? proxyConnectionId;

  /// Display title for [proxyConnectionId].
  final String? proxyTitle;

  /// Name of the container the tab belongs to, when it is in one.
  final String? containerName;

  TabRouting({
    required this.status,
    required this.isContextMismatch,
    required this.contextId,
    required this.proxyConnectionId,
    required this.proxyTitle,
    required this.containerName,
  });

  @override
  List<Object?> get hashParameters => [
    status,
    isContextMismatch,
    contextId,
    proxyConnectionId,
    proxyTitle,
    containerName,
  ];
}

/// The cookie-store context a tab's requests are keyed on, matching the
/// extension's `contextIdFromCookieStoreId`: private tabs are their own
/// context and never inherit the general one, everything without a container
/// falls back to [generalContextId].
String tabRoutingContextId({
  required String? contextId,
  required bool isPrivate,
}) {
  if (isPrivate) return privateContextId;
  if (contextId == null || contextId.isEmpty) return generalContextId;
  return contextId;
}

/// Resolve [contextId]'s routing out of [snapshot].
///
/// [contextId] is the tab's cookie-store context, or null when the engine has
/// not reported one — which is *not* the same as the general context, and must
/// not be answered with "direct".
///
/// [containerContextId] is the contextual identity of the container the tab
/// belongs to, when that container has one and the tab is expected to be in it
/// (so: not for private or isolated tabs, whose context is their own by
/// design). A context other than that one means the container's route is not
/// what decides this tab — see [TabRouting.isContextMismatch].
///
/// [routingInstalled] is whether the extension has acknowledged a snapshot;
/// without one it blocks regardless of what the snapshot says.
/// [proxyTitle] resolves a connection id to its display name — the snapshot
/// only carries titles for proxies that are *running*, and a blocked route by
/// definition names one that is not.
TabRouting resolveTabRouting({
  required ContainerRoutingSnapshot? snapshot,
  required bool routingInstalled,
  required String? contextId,
  required String? containerName,
  required String Function(ProxyConnectionId id) proxyTitle,
  String? containerContextId,
}) {
  // Checked before the tab's own context: with no snapshot the extension blocks
  // every request, whichever context this tab turns out to be in.
  if (snapshot == null || !routingInstalled) {
    return TabRouting(
      status: TabRoutingStatus.pending,
      isContextMismatch: false,
      contextId: contextId,
      proxyConnectionId: null,
      proxyTitle: null,
      containerName: containerName,
    );
  }

  if (contextId == null) {
    return TabRouting(
      status: TabRoutingStatus.unknown,
      isContextMismatch: false,
      contextId: null,
      proxyConnectionId: null,
      proxyTitle: null,
      containerName: containerName,
    );
  }

  // The container's route reaches this tab only if the tab is in its context.
  final isContextMismatch =
      containerContextId != null && containerContextId != contextId;

  final relation = effectiveRelationFor(snapshot, contextId);

  if (relation.isEmpty) {
    return TabRouting(
      status: TabRoutingStatus.direct,
      isContextMismatch: isContextMismatch,
      contextId: contextId,
      proxyConnectionId: null,
      proxyTitle: null,
      containerName: containerName,
    );
  }

  final liveProxyIds = {for (final proxy in snapshot.proxies) proxy.id};
  final isLive = relation.any(liveProxyIds.contains);

  final connectionId = ProxyConnectionId.decode(relation.first);

  return TabRouting(
    status: isLive ? TabRoutingStatus.active : TabRoutingStatus.blocked,
    isContextMismatch: isContextMismatch,
    contextId: contextId,
    proxyConnectionId: connectionId,
    proxyTitle: connectionId.mapNotNull(proxyTitle),
    containerName: containerName,
  );
}
