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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/app_links/domain/services/effective_routing.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';

/// Gecko's cookie-store context for regular, non-container tabs. Also the
/// context that contextless engine traffic is routed under.
const generalContextId = 'general';

/// Gecko's cookie-store context for private tabs. Deliberately never inherits
/// the general relation.
const privateContextId = 'private';

/// The complete container routing state, as the app knows it.
///
/// This is the whole of what the proxy extension is told: it replaces the
/// extension's state rather than amending it. That matters because the
/// extension's store is memory-only and starts empty, and an empty store means
/// "connect directly" — so a routing state assembled from incremental messages
/// is indistinguishable from one that was lost.
class ContainerRoutingSnapshot with FastEquatable {
  /// Every proxy endpoint that is currently live, sorted by id.
  ///
  /// A relation may name a proxy that is absent here (its backend is not
  /// running). The extension blocks those contexts rather than falling back to
  /// a direct connection, which is what makes "the proxy is not up yet" safe.
  final List<GeckoProxySettings> proxies;

  /// Context id to the proxies it routes through. An empty list is an explicit
  /// direct connection; an absent key inherits [generalContextId].
  final Map<String, List<String>> relations;

  /// Scope ids for explicitly-direct contexts, deciding which direct contexts
  /// count as the same context for site-assignment purposes.
  final Map<String, String> directScopes;

  /// Assigned site origin to the context it belongs in.
  final Map<String, String> siteAssignments;

  /// Strict-mode enforcement map: enforced context to the base contexts whose
  /// site assignments it honours.
  final Map<String, List<String>> strictContexts;

  ContainerRoutingSnapshot({
    required this.proxies,
    required this.relations,
    required this.directScopes,
    required this.siteAssignments,
    required this.strictContexts,
  });

  @override
  List<Object?> get hashParameters => [
    proxies,
    relations,
    directScopes,
    siteAssignments,
    strictContexts,
  ];

  GeckoProxyRoutingSnapshot toPigeon(int generation) {
    return GeckoProxyRoutingSnapshot(
      generation: generation,
      proxies: proxies,
      relations: relations,
      directScopes: directScopes,
      siteAssignments: siteAssignments,
      strictContexts: strictContexts,
    );
  }
}

/// Assemble the routing snapshot from every input that feeds it.
///
/// Pure, so the whole of routing resolution — global mode, per-container
/// overrides, isolation aliases — is testable without an engine. Collections
/// come out in a deterministic order so that recomputing from unchanged inputs
/// produces an equal snapshot and pushes nothing.
ContainerRoutingSnapshot computeContainerRoutingSnapshot({
  required int? torSocksPort,
  required List<SingboxProxyRuntimeEndpoint> singboxEndpoints,
  required Map<String, String> singboxProfileNames,
  required ProxyRoutingSettings routingSettings,
  required List<ContainerDataWithCount> containers,
  required Map<String, Set<String>> isolationContextContainers,
  required List<SiteAssignment> siteAssignments,
  required Map<String, List<String>> strictContexts,
  void Function(String message)? onConflict,
}) {
  final proxies = <GeckoProxySettings>[
    if (torSocksPort != null)
      GeckoProxySettings(
        id: const TorProxyConnectionId().encode(),
        title: torBrand,
        type: 'socks',
        host: '127.0.0.1',
        port: torSocksPort,
        proxyDNS: true,
        doNotProxyLocal: true,
      ),
    for (final endpoint in singboxEndpoints)
      GeckoProxySettings(
        id: endpoint.profileId,
        title: singboxProfileNames[endpoint.profileId] ?? endpoint.profileId,
        type: 'socks',
        host: endpoint.host,
        port: endpoint.port,
        username: endpoint.username,
        password: endpoint.password,
        proxyDNS: true,
        doNotProxyLocal: true,
      ),
  ]..sort((a, b) => a.id.compareTo(b.id));

  final relations = <String, List<String>>{};
  final directScopes = <String, String>{};

  void applyAssignment(String contextId, ProxyAssignment assignment) {
    switch (assignment) {
      case ExplicitProxyAssignment(:final proxyId):
        relations[contextId] = [proxyId];
      case DirectProxyAssignment(:final scopeId):
        relations[contextId] = const [];
        directScopes[contextId] = scopeId;
      case InheritProxyAssignment():
        // No entry: the extension falls back to the general relation.
        break;
    }
  }

  // Private tabs never inherit the general relation, so an unset connection
  // simply leaves them direct.
  if (routingSettings.privateTabsProxyConnectionId case final privateProxy?) {
    relations[privateContextId] = [privateProxy.encode()];
  }

  switch (routingSettings.regularTabsMode) {
    case ProxyRegularTabRoutingMode.container:
      break;
    case ProxyRegularTabRoutingMode.all:
      if (routingSettings.regularTabsProxyConnectionId
          case final generalProxy?) {
        relations[generalContextId] = [generalProxy.encode()];
      }
  }

  final assignmentByContainerId = <String, ProxyAssignment>{};
  for (final container in containers) {
    final contextId = container.metadata.contextualIdentity;
    if (contextId == null || contextId.isEmpty) continue;

    final assignment = resolveContainerAssignment(
      contextId: contextId,
      proxyConnectionId: container.metadata.proxyConnectionId,
      bypassGlobalProxy: container.metadata.bypassGlobalProxy,
    );
    assignmentByContainerId[container.id] = assignment;
    applyAssignment(contextId, assignment);
  }

  for (final MapEntry(key: isolationContextId, value: containerIds)
      in isolationContextContainers.entries) {
    final assignments = containerIds
        .map((containerId) => assignmentByContainerId[containerId])
        .nonNulls
        .toList();
    if (assignments.isEmpty) continue;

    final routing = resolveIsolationContextRouting(assignments);
    applyAssignment(isolationContextId, routing.chosen);

    if (routing.distinctAssignmentCount > 1) {
      // Isolation contexts can hold multiple containers; if they disagree on
      // routing, the alias is forced to pick one. Surface this so the user can
      // split the containers across isolation contexts.
      onConflict?.call(
        'Isolation context $isolationContextId has containers with multiple '
        'proxy routing assignments '
        '(${routing.assignmentLabels.join(', ')}); using ${routing.chosenLabel}',
      );
    }
  }

  return ContainerRoutingSnapshot(
    proxies: proxies,
    relations: relations,
    directScopes: directScopes,
    siteAssignments: {
      for (final assignment in siteAssignments)
        assignment.assignedSite.origin:
            assignment.contextualIdentity ?? generalContextId,
    },
    strictContexts: strictContexts,
  );
}
