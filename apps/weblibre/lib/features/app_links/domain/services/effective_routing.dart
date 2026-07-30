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

/// Shared, pure routing-resolution model (see APP_LINKS_OWN_IMPLEMENTATION_PLAN.md
/// §2.3). Owned by neither `ProxySettingsReplication` nor app-link protection —
/// both consume it so there is exactly one notion of "how is this container
/// routed" and "is this tab effectively proxied".
library;

import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

/// How a container (or isolation context) is routed after resolving its own
/// proxy settings — before inheriting/aliasing.
sealed class ProxyAssignment with FastEquatable {
  ProxyAssignment();

  /// Follows the global (`general`) routing.
  factory ProxyAssignment.inherit() = InheritProxyAssignment;

  /// Explicitly bypasses the global proxy (direct connection), scoped to [scopeId].
  factory ProxyAssignment.direct(String scopeId) = DirectProxyAssignment;

  /// Routed through the proxy identified by [proxyId].
  factory ProxyAssignment.explicit(String proxyId) = ExplicitProxyAssignment;
}

final class InheritProxyAssignment extends ProxyAssignment {
  InheritProxyAssignment();

  @override
  List<Object?> get hashParameters => const ['inherit'];
}

final class DirectProxyAssignment extends ProxyAssignment {
  final String scopeId;

  DirectProxyAssignment(this.scopeId);

  @override
  List<Object?> get hashParameters => ['direct', scopeId];
}

final class ExplicitProxyAssignment extends ProxyAssignment {
  final String proxyId;

  ExplicitProxyAssignment(this.proxyId);

  @override
  List<Object?> get hashParameters => ['explicit', proxyId];
}

/// Resolve a single container's routing from its own metadata fields.
///
/// - a set [proxyConnectionId] → `explicit`
/// - no proxy but [bypassGlobalProxy] → `direct` scoped to [contextId]
/// - otherwise → `inherit`
///
/// This is the one place the per-container `proxyConnectionId`/`bypassGlobalProxy`
/// precedence lives; the proxy replicator and app-link protection both call it.
ProxyAssignment resolveContainerAssignment({
  required String contextId,
  required ProxyConnectionId? proxyConnectionId,
  required bool bypassGlobalProxy,
}) {
  return switch (proxyConnectionId) {
    final proxyId? => ProxyAssignment.explicit(proxyId.encode()),
    null when bypassGlobalProxy => ProxyAssignment.direct(contextId),
    null => ProxyAssignment.inherit(),
  };
}

/// The result of collapsing the (possibly conflicting) routing of the containers
/// that share an isolation context into a single alias.
class IsolationContextRouting {
  /// The assignment the isolation context aliases to.
  final ProxyAssignment chosen;

  /// Human-readable label for [chosen] (used in the conflict warning).
  final String chosenLabel;

  /// The distinct assignment labels observed, ordered `inherit`, `direct:*`,
  /// then proxy ids — used to describe conflicts.
  final List<String> assignmentLabels;

  /// Number of distinct assignments; `> 1` means the containers disagree.
  final int distinctAssignmentCount;

  IsolationContextRouting({
    required this.chosen,
    required this.chosenLabel,
    required this.assignmentLabels,
    required this.distinctAssignmentCount,
  });
}

/// Collapse the routing of the containers sharing one isolation context.
///
/// Precedence: any explicit proxy wins (lowest sorted id); else a direct
/// connection wins only if no container inherits; else inherit.
IsolationContextRouting resolveIsolationContextRouting(
  Iterable<ProxyAssignment> assignments,
) {
  final proxyIds =
      assignments
          .whereType<ExplicitProxyAssignment>()
          .map((assignment) => assignment.proxyId)
          .toSet()
          .toList()
        ..sort();
  final directScopeIds =
      assignments
          .whereType<DirectProxyAssignment>()
          .map((assignment) => assignment.scopeId)
          .toSet()
          .toList()
        ..sort();
  final hasInheritedAssignment = assignments.any(
    (assignment) => assignment is InheritProxyAssignment,
  );

  final chosen = proxyIds.isNotEmpty
      ? ProxyAssignment.explicit(proxyIds.first)
      : directScopeIds.isNotEmpty && !hasInheritedAssignment
      ? ProxyAssignment.direct(directScopeIds.first)
      : ProxyAssignment.inherit();

  final chosenLabel = switch (chosen) {
    DirectProxyAssignment(:final scopeId) => 'direct:$scopeId',
    ExplicitProxyAssignment(:final proxyId) => proxyId,
    InheritProxyAssignment() => 'inherit',
  };

  return IsolationContextRouting(
    chosen: chosen,
    chosenLabel: chosenLabel,
    assignmentLabels: [
      if (hasInheritedAssignment) 'inherit',
      ...directScopeIds.map((id) => 'direct:$id'),
      ...proxyIds,
    ],
    distinctAssignmentCount:
        proxyIds.length +
        directScopeIds.length +
        (hasInheritedAssignment ? 1 : 0),
  );
}

/// Whether a tab whose container resolves to [assignment] is effectively
/// proxied — the app-link "protected context" test (§2.3).
///
/// - `explicit` → proxied
/// - `direct` → never proxied (deliberately bypasses the global proxy)
/// - `inherit` → proxied iff the global (`general`) route is a proxy
bool isAssignmentProtected(
  ProxyAssignment assignment, {
  required bool protectGeneralContext,
}) {
  return switch (assignment) {
    ExplicitProxyAssignment() => true,
    DirectProxyAssignment() => false,
    InheritProxyAssignment() => protectGeneralContext,
  };
}

/// A target-side protection pattern (§2.3/§2.8). Any navigation target assigned
/// to an effectively-proxied or strict container is protected independent of the
/// source tab, because site assignment moves the URL into its container
/// *asynchronously*, after the navigation.
class ProtectedTargetPattern with FastEquatable {
  final String scheme;
  final String hostOrSuffix;
  final bool includeSubdomains;

  /// Effective port for exact entries; null for wildcard entries (which ignore
  /// port), preserving [siteAssignmentMatches] semantics.
  final int? port;

  ProtectedTargetPattern({
    required this.scheme,
    required this.hostOrSuffix,
    required this.includeSubdomains,
    required this.port,
  });

  @override
  List<Object?> get hashParameters => [
    scheme,
    hostOrSuffix,
    includeSubdomains,
    port,
  ];
}

/// Build the [ProtectedTargetPattern] for a single site-assignment [Uri],
/// preserving [siteAssignmentMatches] semantics: wildcard (`*.host`) entries
/// match apex+subdomains for the scheme and ignore port; exact entries compare
/// scheme + origin (including effective port).
ProtectedTargetPattern protectedTargetPatternForSite(Uri assignedSite) {
  if (isWildcardSite(assignedSite)) {
    return ProtectedTargetPattern(
      scheme: assignedSite.scheme,
      hostOrSuffix: assignedSite.host.substring('*.'.length),
      includeSubdomains: true,
      port: null,
    );
  }

  return ProtectedTargetPattern(
    scheme: assignedSite.scheme,
    hostOrSuffix: assignedSite.host,
    includeSubdomains: false,
    // Uri.port yields the effective port (scheme default when unspecified), so
    // exact entries preserve the effective port as `siteAssignmentMatches` does
    // via origin comparison.
    port: assignedSite.port,
  );
}

/// Compute the protected target patterns from all site assignments, keeping only
/// those whose container [contextualIdentity] is effectively proxied or strict
/// ([protectedOrStrictContextIds]). Deduplicated.
List<ProtectedTargetPattern> computeProtectedTargetPatterns({
  required Iterable<SiteAssignment> assignments,
  required Set<String> protectedOrStrictContextIds,
}) {
  final patterns = <ProtectedTargetPattern>{};
  for (final assignment in assignments) {
    final contextId = assignment.contextualIdentity;
    if (contextId == null) continue;
    if (!protectedOrStrictContextIds.contains(contextId)) continue;
    patterns.add(protectedTargetPatternForSite(assignment.assignedSite));
  }
  return patterns.toList();
}

/// The complete app-link protection view (§2.3) replicated to native.
class AppLinkProtection with FastEquatable {
  /// Regular / no-contextId tabs are proxied via the `general` scope.
  final bool protectGeneralContext;

  /// contextIds (containers and isolation contexts) that resolve to a proxy.
  final Set<String> protectedContextIds;

  /// strictMode-enforced contextIds, independent of routing.
  final Set<String> strictContextIds;

  final List<ProtectedTargetPattern> protectedTargetPatterns;

  AppLinkProtection({
    required this.protectGeneralContext,
    required this.protectedContextIds,
    required this.strictContextIds,
    required this.protectedTargetPatterns,
  });

  @override
  List<Object?> get hashParameters => [
    protectGeneralContext,
    protectedContextIds,
    strictContextIds,
    protectedTargetPatterns,
  ];
}

/// Pure protection computation from the routing/container/assignment inputs
/// (§2.3). A container's contextId is protected when its effective assignment is
/// proxied; an isolation context is protected when the alias it collapses to is
/// proxied; strict contexts are always protected. Target patterns cover any site
/// assigned to a protected or strict container.
AppLinkProtection computeAppLinkProtection({
  required bool protectGeneralContext,
  required Iterable<ContainerData> containers,
  required Map<String, Set<String>> isolationContextContainerMap,
  required Set<String> strictContextIds,
  required Iterable<SiteAssignment> siteAssignments,
}) {
  final assignmentByContextId = <String, ProxyAssignment>{};
  final assignmentByContainerId = <String, ProxyAssignment>{};

  for (final container in containers) {
    final contextId = container.metadata.contextualIdentity;
    if (contextId == null || contextId.isEmpty) continue;
    final assignment = resolveContainerAssignment(
      contextId: contextId,
      proxyConnectionId: container.metadata.proxyConnectionId,
      bypassGlobalProxy: container.metadata.bypassGlobalProxy,
    );
    assignmentByContextId[contextId] = assignment;
    assignmentByContainerId[container.id] = assignment;
  }

  final protectedContextIds = <String>{};
  for (final MapEntry(:key, :value) in assignmentByContextId.entries) {
    if (isAssignmentProtected(
      value,
      protectGeneralContext: protectGeneralContext,
    )) {
      protectedContextIds.add(key);
    }
  }

  for (final MapEntry(:key, :value) in isolationContextContainerMap.entries) {
    final assignments = value
        .map((containerId) => assignmentByContainerId[containerId])
        .nonNulls
        .toList();
    if (assignments.isEmpty) continue;
    final chosen = resolveIsolationContextRouting(assignments).chosen;
    if (isAssignmentProtected(
      chosen,
      protectGeneralContext: protectGeneralContext,
    )) {
      protectedContextIds.add(key);
    }
  }

  final protectedOrStrict = {...protectedContextIds, ...strictContextIds};
  final patterns = computeProtectedTargetPatterns(
    assignments: siteAssignments,
    protectedOrStrictContextIds: protectedOrStrict,
  );

  return AppLinkProtection(
    protectGeneralContext: protectGeneralContext,
    protectedContextIds: protectedContextIds,
    strictContextIds: strictContextIds,
    protectedTargetPatterns: patterns,
  );
}
