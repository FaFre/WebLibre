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
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// What native's frozen placeholder says for each container shown as frozen
/// (5.6, 5.8, 7.2): "{container} is frozen", how far a freeze or Resume got,
/// or that WebLibre froze it to be safe, with the reason and the skipped
/// background messages under it, one sentence a line. [names] holds each
/// container's display name; one without gets the general title. Native
/// picks the entry through the owner of the tab's context.
List<FrozenPlaceholderLabel> frozenPlaceholderLabels(
  AppLocalizations l10n,
  Map<String, ContainerFreezeView> views,
  Map<String, String> names,
) => [
  for (final MapEntry(key: ownerId, value: view) in views.entries)
    if (view.showsFrozen)
      FrozenPlaceholderLabel(
        ownerId: ownerId,
        title: _title(l10n, view, names[ownerId]),
        detail: _detail(l10n, view),
      ),
];

String? _detail(AppLocalizations l10n, ContainerFreezeView view) {
  final lines = [
    if (_frozenToBeSafe(view)) l10n.splitView_frozenToBeSafeDetail,
    if (view.undeliveredPushCount > 0)
      l10n.splitView_frozenSkippedMessages(view.undeliveredPushCount),
  ];
  return lines.isEmpty ? null : lines.join('\n');
}

/// Frozen by WebLibre after a damaged record, and resting there (5.6).
bool _frozenToBeSafe(ContainerFreezeView view) =>
    view.recovered &&
    view.operation == LifecycleOperationState.idle &&
    view.phase == ContextFreezePhase.frozen;

String _title(AppLocalizations l10n, ContainerFreezeView view, String? name) {
  if (name == null) return l10n.splitView_frozenTitle;
  if (_frozenToBeSafe(view)) {
    return l10n.splitView_frozenToBeSafeTitleNamed(name);
  }
  if (view.operation == LifecycleOperationState.freezing) {
    return l10n.splitView_freezingTitleNamed(name);
  }
  if (view.operation == LifecycleOperationState.resuming) {
    return l10n.splitView_resumingTitleNamed(name);
  }
  return switch (view.phase) {
    ContextFreezePhase.failed => l10n.splitView_freezeIncompleteTitleNamed(
      name,
    ),
    ContextFreezePhase.resuming => l10n.splitView_resumeIncompleteTitleNamed(
      name,
    ),
    _ => l10n.splitView_frozenTitleNamed(name),
  };
}
