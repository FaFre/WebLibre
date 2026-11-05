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

  /// Stores [configs]: each listed button whose row differs is written, and
  /// nothing else. Rows of buttons not listed stay, among them those of
  /// buttons this version does not know (written by a newer one), and the
  /// fallbacks pointing at them.
  ///
  /// Fallbacks reference other rows, so they are assigned once every listed
  /// row exists.
  Future<void> writeChanged(List<ToolbarButtonConfig> configs) =>
      transaction(() async {
        final existing = {for (final row in await getAll()) row.buttonId: row};
        final changed = [
          for (final config in configs)
            if (existing[config.buttonId] != config) config,
        ];
        for (final config in changed) {
          await into(db.toolbarButtonConfigs).insertOnConflictUpdate(
            ToolbarButtonConfigsCompanion(
              buttonId: Value(config.buttonId),
              orderKey: Value(config.orderKey),
              isVisible: Value(config.isVisible),
              longPressAction: Value(config.longPressAction),
            ),
          );
        }
        for (final config in changed) {
          if (existing[config.buttonId]?.fallbackId == config.fallbackId) {
            continue;
          }
          await _assignFallback(config.buttonId, config.fallbackId);
        }
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
        final orderKey = await generateTrailingOrderKey(
          isVisible: def.defaultVisible,
        ).getSingle();
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

  SingleSelectable<String> generateTrailingOrderKey({
    int bucket = 0,
    required bool isVisible,
  }) => db.definitionsDrift.toolbarTrailingOrderKey(
    bucket: bucket,
    isVisible: isVisible,
  );

  Future<void> _assignFallbacks(List<ToolbarButtonConfig> configs) async {
    for (final config in configs) {
      if (config.fallbackId == null) continue;
      await _assignFallback(config.buttonId, config.fallbackId);
    }
  }

  Future<void> _assignFallback(String buttonId, String? fallbackId) =>
      (update(db.toolbarButtonConfigs)
            ..where((t) => t.buttonId.equals(buttonId)))
          .write(ToolbarButtonConfigsCompanion(fallbackId: Value(fallbackId)));
}
