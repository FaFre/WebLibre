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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show AppLinksMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'effective_app_link_policy.g.dart';

/// Resolve a tab's live contextId to the app-link override storage key — the
/// base contextId of the container with "isolated app link settings" enabled
/// that governs the tab — or null when the global mode + rules apply.
///
/// [liveContextId] is the container's base contextId for a regular tab, or the
/// tab's `isolation_context_id` for an isolated tab (i.e. `TabState.contextId`
/// as reported by the engine). Uses the same lowest-sorted-base tiebreak as the
/// snapshot builder so lookups land on the bucket that is published to native.
String? resolveAppLinkOverrideKey({
  required String? liveContextId,
  required List<ContainerDataWithCount> containers,
  required Map<String, Set<String>> isolationContextContainerMap,
}) {
  if (liveContextId == null) return null;

  // Regular tab: liveContextId is a container's own base contextId.
  for (final container in containers) {
    if (container.metadata.contextualIdentity == liveContextId) {
      return container.metadata.isolatedAppLinkSettings ? liveContextId : null;
    }
  }

  // Isolated tab: liveContextId is an isolation context shared by one or more
  // containers; pick the isolated-app-link one with the lowest base contextId.
  final containerIds = isolationContextContainerMap[liveContextId];
  if (containerIds == null || containerIds.isEmpty) return null;

  final byId = {for (final container in containers) container.id: container};
  final baseIds =
      containerIds
          .map((id) => byId[id])
          .nonNulls
          .where(
            (container) =>
                container.metadata.isolatedAppLinkSettings &&
                container.metadata.contextualIdentity != null,
          )
          .map((container) => container.metadata.contextualIdentity!)
          .toList()
        ..sort();
  return baseIds.isEmpty ? null : baseIds.first;
}

/// The app-link policy effectively governing a tab: the global mode + rules,
/// or the owning container's override when it has isolated app-link settings
/// (replace semantics). Used by the site settings sheet to display and edit
/// the settings in the bucket that actually applies to the shown tab.
class EffectiveAppLinkPolicy with FastEquatable {
  /// The override storage key (container base contextId), or null when the
  /// global bucket governs the tab.
  final String? overrideKey;

  /// Display name of the governing container; null when global.
  final String? containerName;

  /// The effective open-links-in-apps mode.
  final AppLinksMode mode;

  /// The effective remembered rules, keyed by canonical scope
  /// (`host:<host>` | `pkg:<package>`).
  final Map<String, PersistedAppLinkRule> rules;

  EffectiveAppLinkPolicy({
    required this.overrideKey,
    required this.containerName,
    required this.mode,
    required this.rules,
  });

  /// Whether the tab is governed by a container override (true) or the global
  /// bucket (false).
  bool get isContainerScoped => overrideKey != null;

  @override
  List<Object?> get hashParameters => [overrideKey, containerName, mode, rules];
}

/// Compute the [EffectiveAppLinkPolicy] for a tab's live contextId. Returns
/// null until the container/isolation inputs have loaded — resolving against
/// empty placeholders could misattribute an isolated container's tab to the
/// global bucket, so callers show a loading state instead.
@Riverpod()
EffectiveAppLinkPolicy? effectiveAppLinkPolicy(Ref ref, String? liveContextId) {
  final settings = ref.watch(generalSettingsWithDefaultsProvider);
  final containers = ref.watch(watchContainersWithCountProvider).value;
  final isolationMap = ref
      .watch(watchIsolatedContextContainerMapProvider)
      .value;
  if (containers == null || isolationMap == null) return null;

  final overrideKey = resolveAppLinkOverrideKey(
    liveContextId: liveContextId,
    containers: containers,
    isolationContextContainerMap: isolationMap,
  );

  if (overrideKey == null) {
    return EffectiveAppLinkPolicy(
      overrideKey: null,
      containerName: null,
      mode: settings.appLinksMode,
      rules: settings.appLinkRules,
    );
  }

  final override =
      settings.appLinkContextOverrides[overrideKey] ??
      ContextAppLinkPolicy.blank();
  final containerName = containers
      .where((c) => c.metadata.contextualIdentity == overrideKey)
      .firstOrNull
      ?.name;

  return EffectiveAppLinkPolicy(
    overrideKey: overrideKey,
    containerName: containerName,
    mode: override.mode,
    rules: override.rules,
  );
}
