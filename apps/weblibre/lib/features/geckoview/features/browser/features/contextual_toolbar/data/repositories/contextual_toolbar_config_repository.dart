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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/user/data/database/daos/toolbar_button_config.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/data/providers.dart';

part 'contextual_toolbar_config_repository.g.dart';

class ContextualToolbarConfigRepository {
  ContextualToolbarConfigRepository(this._dao);

  final ToolbarButtonConfigDao _dao;

  Stream<List<ToolbarButtonConfig>> watchAll() => _dao.watchAll();

  Future<void> replaceAll(List<ToolbarButtonConfig> configs) {
    return _dao.replaceAll(configs);
  }

  Future<void> assignOrderKey(String buttonId, {required String orderKey}) {
    return _dao.assignOrderKey(buttonId, orderKey: orderKey);
  }

  Future<void> assignVisibility(String buttonId, {required bool visible}) {
    return _dao.assignVisibility(buttonId, visible: visible);
  }

  Future<void> assignFallback(String buttonId, String? fallbackId) {
    return _dao.assignFallback(buttonId, fallbackId);
  }

  Future<String> generateLeadingOrderKey() {
    return _dao.generateLeadingOrderKey().getSingle();
  }

  Future<String> generateTrailingOrderKey() {
    return _dao.generateTrailingOrderKey().getSingle();
  }

  Future<String?> generateOrderKeyAfterButtonId(String buttonId) {
    return _dao.generateOrderKeyAfterButtonId(buttonId).getSingleOrNull();
  }

  Future<String> generateOrderKeyBeforeButtonId(String buttonId) {
    return _dao.generateOrderKeyBeforeButtonId(buttonId).getSingle();
  }

  Future<void> seedMissingDefaults() {
    return _dao.seedMissing(
      toolbarButtonSpecs
          .map(
            (spec) => (
              buttonId: spec.id.name,
              defaultVisible: spec.defaultVisible,
              defaultFallback: spec.defaultFallback?.name,
            ),
          )
          .toList(),
    );
  }
}

@Riverpod(keepAlive: true)
ContextualToolbarConfigRepository contextualToolbarConfigRepository(Ref ref) {
  return ContextualToolbarConfigRepository(
    ref.watch(userDatabaseProvider).toolbarButtonConfigDao,
  );
}
