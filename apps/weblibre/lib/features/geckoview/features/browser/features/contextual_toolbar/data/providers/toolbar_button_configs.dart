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
import 'package:lexo_rank/lexo_rank.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;

part 'toolbar_button_configs.g.dart';

List<ToolbarButtonConfig> _buildDefaultToolbarButtonConfigs({
  required bool allHidden,
}) {
  String? lastKey;

  return toolbarButtonSpecs.map((spec) {
    final key = lastKey == null
        ? LexoRank.middle().value
        : LexoRank.parse(lastKey!).genNext().value;

    lastKey = key;

    return ToolbarButtonConfig(
      buttonId: spec.id.name,
      orderKey: key,
      isVisible: allHidden ? false : spec.defaultVisible,
      fallbackId: allHidden ? null : spec.defaultFallback?.name,
    );
  }).toList();
}

final _contextualDefaultConfigs = EquatableValue(
  _buildDefaultToolbarButtonConfigs(allHidden: false),
);

final _quickSwitcherDefaultConfigs = EquatableValue(
  _buildDefaultToolbarButtonConfigs(allHidden: true),
);

/// Default configuration set for [location], used as the reset target and as the
/// fallback while the persisted set is still loading. The quick switcher starts
/// with every button hidden.
EquatableValue<List<ToolbarButtonConfig>> defaultToolbarButtonConfigsFor(
  ToolbarConfigLocation location,
) {
  return switch (location) {
    ToolbarConfigLocation.contextual => _contextualDefaultConfigs,
    ToolbarConfigLocation.quickSwitcher => _quickSwitcherDefaultConfigs,
  };
}

@Riverpod(keepAlive: true)
Stream<List<ToolbarButtonConfig>> toolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) async* {
  final repository = ref.watch(toolbarConfigRepositoryProvider(location));
  await repository.seedMissingDefaults();
  yield* repository.watchAll();
}

@Riverpod(keepAlive: true)
EquatableValue<List<ToolbarButtonConfig>> effectiveToolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) {
  final configsAsync = ref.watch(toolbarButtonConfigsProvider(location));

  return configsAsync.when(
    data: (configs) {
      final filtered = configs
          .where((config) => knownToolbarButtonIds.contains(config.buttonId))
          .toList();

      if (filtered.isEmpty) {
        return defaultToolbarButtonConfigsFor(location);
      }

      return EquatableValue(filtered);
    },
    loading: () => defaultToolbarButtonConfigsFor(location),
    error: (_, _) => defaultToolbarButtonConfigsFor(location),
  );
}
