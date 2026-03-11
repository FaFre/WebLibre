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

List<ContextualToolbarButtonResolution> resolveVisibleContextualToolbarButtons({
  required List<ToolbarButtonConfig> configs,
  required Set<String> knownButtonIds,
  required bool Function(String buttonId) isPrimaryAvailable,
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

ContextualToolbarButtonResolution? resolveContextualToolbarButton({
  required ToolbarButtonConfig config,
  required Map<String, ToolbarButtonConfig> configById,
  required Set<String> knownButtonIds,
  required bool Function(String buttonId) isPrimaryAvailable,
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

  if (isPrimaryAvailable(config.buttonId)) {
    return ContextualToolbarButtonResolution(
      buttonId: config.buttonId,
      isEnabled: true,
    );
  }

  final fallbackId = ToolbarFallbackChoice.fromStored(
    config.fallbackId,
  ).resolveRuntimeFallbackId();
  if (fallbackId == null) {
    return ContextualToolbarButtonResolution(
      buttonId: config.buttonId,
      isEnabled: false,
    );
  }

  final fallbackConfig = configById[fallbackId];
  if (fallbackConfig == null) {
    return knownButtonIds.contains(fallbackId)
        ? ContextualToolbarButtonResolution(
            buttonId: fallbackId,
            isEnabled: true,
          )
        : ContextualToolbarButtonResolution(
            buttonId: config.buttonId,
            isEnabled: false,
          );
  }

  return resolveContextualToolbarButton(
    config: fallbackConfig,
    configById: configById,
    knownButtonIds: knownButtonIds,
    isPrimaryAvailable: isPrimaryAvailable,
    visited: {...visited, config.buttonId},
  );
}
