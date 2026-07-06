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

  Future<void> replaceAll(List<ToolbarButtonConfig> configs);

  Future<void> assignOrderKey(String buttonId, {required String orderKey});

  Future<void> assignVisibility(String buttonId, {required bool visible});

  Future<void> assignFallback(String buttonId, String? fallbackId);

  Future<String> generateLeadingOrderKey({required bool isVisible});

  Future<String> generateTrailingOrderKey({required bool isVisible});

  Future<String?> generateOrderKeyAfterButtonId(
    String buttonId, {
    required bool isVisible,
  });

  Future<String> generateOrderKeyBeforeButtonId(
    String buttonId, {
    required bool isVisible,
  });

  Future<void> seedMissingDefaults();
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
