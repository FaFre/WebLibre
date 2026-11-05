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
import 'package:weblibre/features/user/data/database/daos/toolbar_button_config.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/data/providers.dart';

part 'contextual_toolbar_config_repository.g.dart';

class ContextualToolbarConfigRepository
    with SerializedSaveAll
    implements ToolbarButtonConfigRepository {
  ContextualToolbarConfigRepository(this._dao);

  final ToolbarButtonConfigDao _dao;

  @override
  Stream<List<ToolbarButtonConfig>> watchAll() => _dao.watchAll();

  @override
  Future<void> writeChanged(List<ToolbarButtonConfig> configs) {
    return _dao.writeChanged(configs);
  }

  @override
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
