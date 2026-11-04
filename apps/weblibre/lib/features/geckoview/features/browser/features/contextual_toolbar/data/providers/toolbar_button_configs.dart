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

import 'package:drift/drift.dart' show Value;
import 'package:fast_equatable/fast_equatable.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

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
      isVisible: !allHidden && spec.defaultVisible,
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

/// The configuration of [location] as stored, for the screen that edits it:
/// known buttons only, the defaults while loading or empty.
@Riverpod(keepAlive: true)
EquatableValue<List<ToolbarButtonConfig>> storedToolbarButtonConfigs(
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

/// The configuration of [location] as it applies: [storedToolbarButtonConfigs]
/// with the default fallbacks and no long-press actions while the advanced
/// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
/// visibility are ordinary layout and stay as stored.
@Riverpod(keepAlive: true)
EquatableValue<List<ToolbarButtonConfig>> effectiveToolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) {
  final stored = ref.watch(storedToolbarButtonConfigsProvider(location));
  final advancedShown = ref.watch(
    shownFeaturesProvider.select(
      (shown) => shown.contains(FeatureId.layoutContextualToolbarAdvanced),
    ),
  );
  if (advancedShown) return stored;

  return EquatableValue(
    toolbarButtonConfigsAsApplied(stored.value, location, advancedShown: false),
  );
}

/// [stored] as it applies: with the advanced toolbar options hidden
/// ([advancedShown] false), every button falls back the default way and has
/// no long-press action.
List<ToolbarButtonConfig> toolbarButtonConfigsAsApplied(
  List<ToolbarButtonConfig> stored,
  ToolbarConfigLocation location, {
  required bool advancedShown,
}) {
  if (advancedShown) return stored;

  final defaultFallbacks = {
    for (final config in defaultToolbarButtonConfigsFor(location).value)
      config.buttonId: config.fallbackId,
  };
  return [
    for (final config in stored)
      config.copyWith(
        fallbackId: Value(defaultFallbacks[config.buttonId]),
        longPressAction: const Value(null),
      ),
  ];
}
