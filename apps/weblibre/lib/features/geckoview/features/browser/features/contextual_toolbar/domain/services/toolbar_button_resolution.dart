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

import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_fallback_choice.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

class ContextualToolbarButtonResolution {
  const ContextualToolbarButtonResolution({
    required this.buttonId,
    required this.isEnabled,
  });

  final String buttonId;
  final bool isEnabled;
}

/// The buttons a toolbar draws for [configs], in order, each slot resolved by
/// [resolveContextualToolbarButton].
///
/// [isHidden] names the buttons whose feature is hidden. Such a button is not
/// merely unavailable for now: its slot goes to its fallback, and without one
/// the slot is left out instead of drawing a greyed-out button for a feature
/// the user chose not to see. The stored configuration is not touched, so the
/// button is back where it was once the feature is shown again.
List<ContextualToolbarButtonResolution> resolveVisibleContextualToolbarButtons({
  required List<ToolbarButtonConfig> configs,
  required Set<String> knownButtonIds,
  required bool Function(String buttonId) isPrimaryAvailable,
  bool Function(String buttonId) isHidden = _nothingHidden,
}) {
  final configById = {for (final config in configs) config.buttonId: config};
  final resolvedButtons = <ContextualToolbarButtonResolution>[];
  final seenIds = <String>{};

  for (final config in configs.where((config) => config.isVisible)) {
    final resolvedButton = resolveContextualToolbarButton(
      config: config,
      configById: configById,
      knownButtonIds: knownButtonIds,
      isPrimaryAvailable: isPrimaryAvailable,
      isHidden: isHidden,
    );
    if (resolvedButton == null) {
      continue;
    }
    if (seenIds.add(resolvedButton.buttonId)) {
      resolvedButtons.add(resolvedButton);
    }
  }

  return resolvedButtons;
}

bool _nothingHidden(String buttonId) => false;

/// What [config]'s slot shows: the button itself while it is available, else
/// its fallback, else the button greyed out. A button that [isHidden] says is
/// hidden never shows: the fallback, or nothing (null).
ContextualToolbarButtonResolution? resolveContextualToolbarButton({
  required ToolbarButtonConfig config,
  required Map<String, ToolbarButtonConfig> configById,
  required Set<String> knownButtonIds,
  required bool Function(String buttonId) isPrimaryAvailable,
  bool Function(String buttonId) isHidden = _nothingHidden,
  Set<String> visited = const {},
}) {
  if (visited.contains(config.buttonId)) {
    return null;
  }

  if (!knownButtonIds.contains(config.buttonId)) {
    return ContextualToolbarButtonResolution(
      buttonId: config.buttonId,
      isEnabled: true,
    );
  }

  final hidden = isHidden(config.buttonId);
  if (!hidden && isPrimaryAvailable(config.buttonId)) {
    return ContextualToolbarButtonResolution(
      buttonId: config.buttonId,
      isEnabled: true,
    );
  }

  // Nothing to fall back to: a hidden button leaves its slot empty, an
  // unavailable one stays where it is, greyed out.
  final unresolved = hidden
      ? null
      : ContextualToolbarButtonResolution(
          buttonId: config.buttonId,
          isEnabled: false,
        );

  final fallbackId = ToolbarFallbackChoice.fromStored(
    config.fallbackId,
  ).resolveRuntimeFallbackId();
  if (fallbackId == null) {
    return unresolved;
  }

  final fallbackConfig = configById[fallbackId];
  if (fallbackConfig == null) {
    return knownButtonIds.contains(fallbackId) && !isHidden(fallbackId)
        ? ContextualToolbarButtonResolution(
            buttonId: fallbackId,
            isEnabled: true,
          )
        : unresolved;
  }

  final resolvedFallback = resolveContextualToolbarButton(
    config: fallbackConfig,
    configById: configById,
    knownButtonIds: knownButtonIds,
    isPrimaryAvailable: isPrimaryAvailable,
    isHidden: isHidden,
    visited: {...visited, config.buttonId},
  );
  // A fallback that is hidden itself, with nothing behind it, leaves this
  // slot as if it had none. (A fallback cycle still leaves it out.)
  if (resolvedFallback == null && isHidden(fallbackId)) return unresolved;
  return resolvedFallback;
}
