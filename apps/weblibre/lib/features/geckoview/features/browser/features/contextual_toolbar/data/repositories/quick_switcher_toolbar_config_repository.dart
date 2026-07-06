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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/user/data/database/daos/quick_switcher_button_config.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show QuickSwitcherButtonConfig, ToolbarButtonConfig;
import 'package:weblibre/features/user/data/providers.dart';

part 'quick_switcher_toolbar_config_repository.g.dart';

/// Quick tab switcher counterpart to [ContextualToolbarConfigRepository]. Backed
/// by the separate `quick_switcher_button_configs` table and mapping its row
/// type to the shared [ToolbarButtonConfig] transport type.
class QuickSwitcherToolbarConfigRepository
    implements ToolbarButtonConfigRepository {
  QuickSwitcherToolbarConfigRepository(this._dao);

  final QuickSwitcherButtonConfigDao _dao;

  ToolbarButtonConfig _toShared(QuickSwitcherButtonConfig config) =>
      ToolbarButtonConfig(
        buttonId: config.buttonId,
        orderKey: config.orderKey,
        isVisible: config.isVisible,
        fallbackId: config.fallbackId,
      );

  QuickSwitcherButtonConfig _fromShared(ToolbarButtonConfig config) =>
      QuickSwitcherButtonConfig(
        buttonId: config.buttonId,
        orderKey: config.orderKey,
        isVisible: config.isVisible,
        fallbackId: config.fallbackId,
      );

  @override
  Stream<List<ToolbarButtonConfig>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_toShared).toList());

  @override
  Future<void> replaceAll(List<ToolbarButtonConfig> configs) {
    return _dao.replaceAll(configs.map(_fromShared).toList());
  }

  @override
  Future<void> assignOrderKey(String buttonId, {required String orderKey}) {
    return _dao.assignOrderKey(buttonId, orderKey: orderKey);
  }

  @override
  Future<void> assignVisibility(String buttonId, {required bool visible}) {
    return _dao.assignVisibility(buttonId, visible: visible);
  }

  @override
  Future<void> assignFallback(String buttonId, String? fallbackId) {
    return _dao.assignFallback(buttonId, fallbackId);
  }

  @override
  Future<String> generateLeadingOrderKey({required bool isVisible}) {
    return _dao.generateLeadingOrderKey(isVisible: isVisible).getSingle();
  }

  @override
  Future<String> generateTrailingOrderKey({required bool isVisible}) {
    return _dao.generateTrailingOrderKey(isVisible: isVisible).getSingle();
  }

  @override
  Future<String?> generateOrderKeyAfterButtonId(
    String buttonId, {
    required bool isVisible,
  }) {
    return _dao
        .generateOrderKeyAfterButtonId(buttonId, isVisible: isVisible)
        .getSingleOrNull();
  }

  @override
  Future<String> generateOrderKeyBeforeButtonId(
    String buttonId, {
    required bool isVisible,
  }) {
    return _dao
        .generateOrderKeyBeforeButtonId(buttonId, isVisible: isVisible)
        .getSingle();
  }

  @override
  Future<void> seedMissingDefaults() {
    // The quick switcher cluster starts empty: every known button is seeded
    // hidden with no fallback, so nothing renders until the user enables it.
    return _dao.seedMissing(
      toolbarButtonSpecs
          .map(
            (spec) => (
              buttonId: spec.id.name,
              defaultVisible: false,
              defaultFallback: null,
            ),
          )
          .toList(),
    );
  }
}

@Riverpod(keepAlive: true)
QuickSwitcherToolbarConfigRepository quickSwitcherToolbarConfigRepository(
  Ref ref,
) {
  return QuickSwitcherToolbarConfigRepository(
    ref.watch(userDatabaseProvider).quickSwitcherButtonConfigDao,
  );
}
