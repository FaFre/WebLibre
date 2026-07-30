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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

/// Shows [child] only once [watchIsCurrentSiteAssignedToContainerProvider]
/// has resolved and the current tab's site is not yet assigned to a
/// container. Shared between TabMenu and the browser menu bottom sheet so
/// the "assign URL to container" affordance stays in sync in both surfaces.
class ContainerRelationUnassignedVisibility extends ConsumerWidget {
  final Widget child;

  const ContainerRelationUnassignedVisibility({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSiteAssigned = ref.watch(
      watchIsCurrentSiteAssignedToContainerProvider,
    );

    return Visibility(
      visible: isSiteAssigned.hasValue && !isSiteAssigned.requireValue,
      child: child,
    );
  }
}

/// Shows [child] only once [watchIsCurrentSiteAssignedToContainerProvider]
/// has resolved and the current tab's site is already assigned to a
/// container. Shared between TabMenu and the browser menu bottom sheet.
class ContainerRelationAssignedVisibility extends ConsumerWidget {
  final Widget child;

  const ContainerRelationAssignedVisibility({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSiteAssigned = ref.watch(
      watchIsCurrentSiteAssignedToContainerProvider,
    );

    return Visibility(
      visible: isSiteAssigned.hasValue && isSiteAssigned.requireValue,
      child: child,
    );
  }
}

/// Shows [child] only when [tabId] currently has a container assigned.
/// Shared between TabMenu and the browser menu bottom sheet.
class ContainerAssignedVisibility extends ConsumerWidget {
  final String tabId;
  final Widget child;

  const ContainerAssignedVisibility({
    super.key,
    required this.tabId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containerId = ref.watch(
      watchContainerTabIdProvider(tabId).select((value) => value.value),
    );

    return Visibility(visible: containerId != null, child: child);
  }
}
