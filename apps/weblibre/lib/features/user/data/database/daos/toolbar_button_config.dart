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
import 'package:drift/drift.dart';
import 'package:weblibre/features/user/data/database/daos/toolbar_button_config.drift.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

@DriftAccessor()
class ToolbarButtonConfigDao extends DatabaseAccessor<UserDatabase>
    with $ToolbarButtonConfigDaoMixin {
  ToolbarButtonConfigDao(super.attachedDatabase);

  Selectable<ToolbarButtonConfig> selectAll() =>
      db.toolbarButtonConfigs.select()
        ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]);

  Stream<List<ToolbarButtonConfig>> watchAll() => selectAll().watch();

  Future<List<ToolbarButtonConfig>> getAll() => selectAll().get();

  Future<void> upsert(ToolbarButtonConfig config) =>
      into(db.toolbarButtonConfigs).insertOnConflictUpdate(config);

  Future<void> assignOrderKey(String buttonId, {required String orderKey}) =>
      (update(db.toolbarButtonConfigs)
            ..where((t) => t.buttonId.equals(buttonId)))
          .write(ToolbarButtonConfigsCompanion(orderKey: Value(orderKey)));

  Future<void> assignVisibility(String buttonId, {required bool visible}) =>
      (update(db.toolbarButtonConfigs)
            ..where((t) => t.buttonId.equals(buttonId)))
          .write(ToolbarButtonConfigsCompanion(isVisible: Value(visible)));

  Future<void> assignFallback(String buttonId, String? fallbackId) =>
      (update(db.toolbarButtonConfigs)
            ..where((t) => t.buttonId.equals(buttonId)))
          .write(ToolbarButtonConfigsCompanion(fallbackId: Value(fallbackId)));

  Future<void> replaceAll(List<ToolbarButtonConfig> configs) =>
      transaction(() async {
        await delete(db.toolbarButtonConfigs).go();
        await _insertWithDeferredFallbacks(configs);
      });

  Future<void> seedMissing(
    List<({String buttonId, bool defaultVisible, String? defaultFallback})>
    defaults,
  ) async {
    final existing = await getAll();
    final existingIds = {for (final r in existing) r.buttonId};

    final missing = defaults
        .where((d) => !existingIds.contains(d.buttonId))
        .toList();
    if (missing.isEmpty) return;

    await transaction(() async {
      final inserted = <ToolbarButtonConfig>[];
      for (final def in missing) {
        final orderKey = await generateTrailingOrderKey().getSingle();
        inserted.add(
          ToolbarButtonConfig(
            buttonId: def.buttonId,
            orderKey: orderKey,
            isVisible: def.defaultVisible,
            fallbackId: def.defaultFallback,
          ),
        );
        await into(db.toolbarButtonConfigs).insert(
          ToolbarButtonConfig(
            buttonId: def.buttonId,
            orderKey: orderKey,
            isVisible: def.defaultVisible,
          ),
        );
      }

      await _assignFallbacks(inserted);
    });
  }

  SingleSelectable<String> generateLeadingOrderKey({int bucket = 0}) =>
      db.definitionsDrift.toolbarLeadingOrderKey(bucket: bucket);

  SingleSelectable<String> generateTrailingOrderKey({int bucket = 0}) =>
      db.definitionsDrift.toolbarTrailingOrderKey(bucket: bucket);

  SingleOrNullSelectable<String> generateOrderKeyAfterButtonId(
    String buttonId,
  ) => db.definitionsDrift.toolbarOrderKeyAfterButton(buttonId: buttonId);

  SingleSelectable<String> generateOrderKeyBeforeButtonId(String buttonId) =>
      db.definitionsDrift.toolbarOrderKeyBeforeButton(buttonId: buttonId);

  Future<void> _insertWithDeferredFallbacks(
    List<ToolbarButtonConfig> configs,
  ) async {
    for (final config in configs) {
      await into(db.toolbarButtonConfigs).insert(
        ToolbarButtonConfig(
          buttonId: config.buttonId,
          orderKey: config.orderKey,
          isVisible: config.isVisible,
        ),
      );
    }

    await _assignFallbacks(configs);
  }

  Future<void> _assignFallbacks(List<ToolbarButtonConfig> configs) async {
    for (final config in configs) {
      if (config.fallbackId == null) continue;
      await assignFallback(config.buttonId, config.fallbackId);
    }
  }
}
