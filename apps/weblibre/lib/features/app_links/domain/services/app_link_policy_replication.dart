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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    hide ProtectedTargetPattern;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    as pigeon
    show ProtectedTargetPattern;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/app_links/domain/services/effective_routing.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'app_link_policy_replication.g.dart';

/// Effective app-link protection (§2.3), recomputed whenever routing, strict
/// mode, contextual identities, or site assignments change.
@Riverpod(keepAlive: true)
AppLinkProtection appLinkProtection(Ref ref) {
  final routing = ref.watch(proxyRoutingSettingsWithDefaultsProvider);
  final protectGeneralContext =
      routing.regularTabsMode == ProxyRegularTabRoutingMode.all &&
      routing.regularTabsProxyConnectionId != null;

  final containers =
      ref.watch(watchContainersWithCountProvider).value ?? const [];
  final isolationMap =
      ref.watch(watchIsolatedContextContainerMapProvider).value ?? const {};
  final strict =
      ref.watch(watchStrictContextAssignmentsProvider).value ?? const {};
  final sites = ref.watch(watchAllAssignedSitesProvider).value ?? const [];

  return computeAppLinkProtection(
    protectGeneralContext: protectGeneralContext,
    containers: containers,
    isolationContextContainerMap: isolationMap,
    strictContextIds: strict.keys.toSet(),
    siteAssignments: sites,
  );
}

/// The complete policy snapshot to push, or null until the real persisted
/// settings have loaded (the `...WithDefaults` loading placeholder is not valid
/// input, §2.8). Combines the user-intent settings with computed protection.
@Riverpod(keepAlive: true)
AppLinkPolicySnapshot? appLinkPolicySnapshot(Ref ref) {
  final settings = ref.watch(generalSettingsRepositoryProvider).value;
  if (settings == null) return null;

  // Don't push a snapshot until the protection/override inputs have actually
  // loaded (§2.8). `appLinkProtection` and `_computeContextOverrides` fall back to
  // empty collections while these streams are still loading; pushing that would
  // briefly persist "no protected contexts / no overrides" to native and let a
  // protected or isolated container's links leak out during startup. Native keeps
  // last session's persisted snapshot until the real one is ready.
  final containersLoaded = ref.watch(watchContainersWithCountProvider).hasValue;
  final isolationLoaded = ref
      .watch(watchIsolatedContextContainerMapProvider)
      .hasValue;
  final strictLoaded = ref
      .watch(watchStrictContextAssignmentsProvider)
      .hasValue;
  final sitesLoaded = ref.watch(watchAllAssignedSitesProvider).hasValue;
  // The real proxy-routing settings drive `protectGeneralContext`; the
  // `...WithDefaults` view silently substitutes defaults while the row loads,
  // which would compute "general context not proxied" and let a globally-proxied
  // setup auto-launch during startup. Wait for the actual value.
  final routingLoaded = ref
      .watch(proxyRoutingSettingsRepositoryProvider)
      .hasValue;
  if (!containersLoaded ||
      !isolationLoaded ||
      !strictLoaded ||
      !sitesLoaded ||
      !routingLoaded) {
    return null;
  }

  final protection = ref.watch(appLinkProtectionProvider);

  return AppLinkPolicySnapshot(
    globalMode: settings.appLinksMode,
    rules: {
      for (final MapEntry(:key, :value) in settings.appLinkRules.entries)
        key: _toNativeRule(value),
    },
    marketplaceFallbackEnabled: settings.appLinkMarketplaceFallback,
    authExceptionsEnabled: settings.appLinkAuthExceptionsEnabled,
    protectGeneralContext: protection.protectGeneralContext,
    protectedContextIds: protection.protectedContextIds.toList(),
    strictContextIds: protection.strictContextIds.toList(),
    protectedTargetPatterns: protection.protectedTargetPatterns
        .map(_toNativePattern)
        .toList(),
    contextOverrides: _computeContextOverrides(ref, settings),
  );
}

/// Build the per-container override map (§ container isolation): one entry per
/// container whose "isolated app link settings" toggle is on and which has a
/// contextId. A freshly isolated container with no stored override still gets a
/// blank-slate entry so its "replace" behaviour takes effect immediately rather
/// than silently falling back to the global policy.
///
/// The override is published under the container's base contextId **and** under
/// every active isolation context id belonging to that container: isolated tabs
/// (`tab_mode = 2`) load under their own `isolation_context_id`, which is the
/// `session.contextId` the native interceptor keys the lookup on — so without the
/// fan-out isolated tabs would silently fall back to the global policy (mirrors
/// how `computeAppLinkProtection` expands protection to isolation contexts). When
/// an isolation context is shared by several isolated-app-link containers, the
/// container with the lowest sorted base contextId wins (deterministic).
Map<String, NativeContextAppLinkPolicy> _computeContextOverrides(
  Ref ref,
  GeneralSettings settings,
) {
  final containers =
      ref.watch(watchContainersWithCountProvider).value ?? const [];
  final isolationMap =
      ref.watch(watchIsolatedContextContainerMapProvider).value ?? const {};

  NativeContextAppLinkPolicy toNative(ContextAppLinkPolicy policy) {
    return NativeContextAppLinkPolicy(
      mode: policy.mode,
      rules: {
        for (final MapEntry(:key, :value) in policy.rules.entries)
          key: _toNativeRule(value),
      },
    );
  }

  // Base contextId -> native override, plus containerId -> base contextId for the
  // isolation-context fan-out below (only isolated-app-link containers).
  final overrideByBaseContextId = <String, NativeContextAppLinkPolicy>{};
  final baseContextIdByContainerId = <String, String>{};
  for (final container in containers) {
    final contextId = container.metadata.contextualIdentity;
    if (contextId == null || !container.metadata.isolatedAppLinkSettings) {
      continue;
    }
    overrideByBaseContextId[contextId] = toNative(
      settings.appLinkContextOverrides[contextId] ??
          ContextAppLinkPolicy.blank(),
    );
    baseContextIdByContainerId[container.id] = contextId;
  }

  final overrides = <String, NativeContextAppLinkPolicy>{
    ...overrideByBaseContextId,
  };

  for (final MapEntry(key: isolationContextId, value: containerIds)
      in isolationMap.entries) {
    final baseIds =
        containerIds
            .map((id) => baseContextIdByContainerId[id])
            .nonNulls
            .toList()
          ..sort();
    if (baseIds.isEmpty) continue;
    // A base contextId never collides with an isolation context id, but guard
    // so a real container's own entry always wins if one ever did.
    overrides.putIfAbsent(
      isolationContextId,
      () => overrideByBaseContextId[baseIds.first]!,
    );
  }

  return overrides;
}

NativeAppLinkRule _toNativeRule(PersistedAppLinkRule rule) {
  return NativeAppLinkRule(
    decision: switch (rule.decision) {
      AppLinkRuleDecision.alwaysOpen => NativeAppLinkRuleDecision.alwaysOpen,
      AppLinkRuleDecision.neverOpen => NativeAppLinkRuleDecision.neverOpen,
    },
    scope: rule.scope,
    packageName: rule.packageName,
  );
}

pigeon.ProtectedTargetPattern _toNativePattern(ProtectedTargetPattern pattern) {
  return pigeon.ProtectedTargetPattern(
    scheme: pattern.scheme,
    hostOrSuffix: pattern.hostOrSuffix,
    includeSubdomains: pattern.includeSubdomains,
    port: pattern.port,
  );
}

/// Single serialised writer that mirrors the Dart-owned app-link policy to the
/// native profile-scoped store (§2.8), the sole policy source consulted by the
/// interceptor. Structured like `ProxySettingsReplication`; mounted from app root
/// after initialisation.
@Riverpod(keepAlive: true)
class AppLinkPolicyReplication extends _$AppLinkPolicyReplication {
  final _appLinks = GeckoAppLinksService();

  final _pushLock = Lock();
  // Coalesces the most recent snapshot while a push is in flight; genuinely
  // nullable (no snapshot pushed yet).
  // ignore: use_late_for_private_fields_and_variables
  AppLinkPolicySnapshot? _latest;
  var _pushDirty = false;

  Future<void> _queuePush(AppLinkPolicySnapshot snapshot) async {
    _latest = snapshot;
    _pushDirty = true;
    if (_pushLock.inLock) return;

    await _pushLock.synchronized(() async {
      while (_pushDirty) {
        _pushDirty = false;
        final pending = _latest!;
        try {
          await _appLinks.setAppLinkPolicy(pending);
        } catch (error, stackTrace) {
          // `setAppLinkPolicy` before a profile is bound is an error the
          // replicator retries after initialisation (§2.8).
          logger.w(
            'Failed to push app-link policy; will retry',
            error: error,
            stackTrace: stackTrace,
          );
          _pushDirty = true;
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
    });
  }

  @override
  void build() {
    ref.listen(
      fireImmediately: true,
      appLinkPolicySnapshotProvider,
      (previous, next) {
        if (next == null) return;
        unawaited(_queuePush(next));
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error computing app-link policy snapshot',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
