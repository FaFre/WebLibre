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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/contextual_toolbar_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;

part 'toolbar_button_configs.g.dart';

List<ToolbarButtonConfig> _buildDefaultToolbarButtonConfigs() {
  String? lastKey;

  return toolbarButtonSpecs.map((spec) {
    final key = lastKey == null
        ? LexoRank.middle().value
        : LexoRank.parse(lastKey!).genNext().value;

    lastKey = key;

    return ToolbarButtonConfig(
      buttonId: spec.id.name,
      orderKey: key,
      isVisible: spec.defaultVisible,
      fallbackId: spec.defaultFallback?.name,
    );
  }).toList();
}

final defaultToolbarButtonConfigs = EquatableValue(
  _buildDefaultToolbarButtonConfigs(),
);

@Riverpod(keepAlive: true)
Stream<List<ToolbarButtonConfig>> toolbarButtonConfigs(Ref ref) async* {
  final repository = ref.watch(contextualToolbarConfigRepositoryProvider);
  await repository.seedMissingDefaults();
  yield* repository.watchAll();
}

@Riverpod(keepAlive: true)
EquatableValue<List<ToolbarButtonConfig>> effectiveToolbarButtonConfigs(
  Ref ref,
) {
  final configsAsync = ref.watch(toolbarButtonConfigsProvider);

  return configsAsync.when(
    data: (configs) {
      final filtered = configs
          .where((config) => knownToolbarButtonIds.contains(config.buttonId))
          .toList();

      if (filtered.isEmpty) {
        return defaultToolbarButtonConfigs;
      }

      return EquatableValue(filtered);
    },
    loading: () => defaultToolbarButtonConfigs,
    error: (_, _) => defaultToolbarButtonConfigs,
  );
}
