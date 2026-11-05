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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/contextual_toolbar_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/quick_switcher_toolbar_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;

part 'toolbar_button_config_repository.g.dart';

/// Shared contract for a single toolbar button configuration set. Both the
/// contextual toolbar and the quick tab switcher cluster persist to their own
/// table but expose this same interface, so the resolution logic, providers and
/// customization UI are location-agnostic. [ToolbarButtonConfig] (the contextual
/// drift row) is used as the shared transport type; the quick switcher
/// repository maps its own row type at the boundary.
abstract interface class ToolbarButtonConfigRepository {
  Stream<List<ToolbarButtonConfig>> watchAll();

  /// Stores [configs], writing only the buttons whose configuration differs
  /// from what is stored. Buttons not in [configs] keep their rows, those of
  /// buttons this version does not know included.
  Future<void> saveAll(List<ToolbarButtonConfig> configs);

  Future<void> seedMissingDefaults();
}

/// [ToolbarButtonConfigRepository.saveAll] one write after another, in the
/// order they were asked for. Lives with the kept-alive repository, so the
/// order holds even when the editor that asked is gone before its write
/// lands.
mixin SerializedSaveAll implements ToolbarButtonConfigRepository {
  Future<void> _lastWrite = Future.value();

  /// Stores [configs], the actual write (see [saveAll]).
  Future<void> writeChanged(List<ToolbarButtonConfig> configs);

  @override
  Future<void> saveAll(List<ToolbarButtonConfig> configs) {
    final write = _lastWrite.then((_) => writeChanged(configs));
    // A failed write does not stop the ones after it; its caller sees the
    // failure.
    _lastWrite = write.then<void>((_) {}, onError: (_) {});
    return write;
  }
}

@Riverpod(keepAlive: true)
ToolbarButtonConfigRepository toolbarConfigRepository(
  Ref ref,
  ToolbarConfigLocation location,
) {
  return switch (location) {
    ToolbarConfigLocation.contextual => ref.watch(
      contextualToolbarConfigRepositoryProvider,
    ),
    ToolbarConfigLocation.quickSwitcher => ref.watch(
      quickSwitcherToolbarConfigRepositoryProvider,
    ),
  };
}
