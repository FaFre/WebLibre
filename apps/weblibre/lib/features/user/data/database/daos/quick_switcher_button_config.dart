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
import 'package:weblibre/features/user/data/database/daos/quick_switcher_button_config.drift.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

/// Mirror of [ToolbarButtonConfigDao] against the separate
/// `quick_switcher_button_configs` table.
@DriftAccessor()
class QuickSwitcherButtonConfigDao extends DatabaseAccessor<UserDatabase>
    with $QuickSwitcherButtonConfigDaoMixin {
  QuickSwitcherButtonConfigDao(super.attachedDatabase);

  Selectable<QuickSwitcherButtonConfig> selectAll() =>
      db.quickSwitcherButtonConfigs.select()
        ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]);

  Stream<List<QuickSwitcherButtonConfig>> watchAll() => selectAll().watch();

  Future<List<QuickSwitcherButtonConfig>> getAll() => selectAll().get();

  /// Stores [configs]; see [ToolbarButtonConfigDao.writeChanged].
  Future<void> writeChanged(List<QuickSwitcherButtonConfig> configs) =>
      transaction(() async {
        final existing = {for (final row in await getAll()) row.buttonId: row};
        final changed = [
          for (final config in configs)
            if (existing[config.buttonId] != config) config,
        ];
        for (final config in changed) {
          await into(db.quickSwitcherButtonConfigs).insertOnConflictUpdate(
            QuickSwitcherButtonConfigsCompanion(
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
      final inserted = <QuickSwitcherButtonConfig>[];
      for (final def in missing) {
        final orderKey = await generateTrailingOrderKey(
          isVisible: def.defaultVisible,
        ).getSingle();
        inserted.add(
          QuickSwitcherButtonConfig(
            buttonId: def.buttonId,
            orderKey: orderKey,
            isVisible: def.defaultVisible,
            fallbackId: def.defaultFallback,
          ),
        );
        await into(db.quickSwitcherButtonConfigs).insert(
          QuickSwitcherButtonConfig(
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
  }) => db.definitionsDrift.quickSwitcherTrailingOrderKey(
    bucket: bucket,
    isVisible: isVisible,
  );

  Future<void> _assignFallbacks(List<QuickSwitcherButtonConfig> configs) async {
    for (final config in configs) {
      if (config.fallbackId == null) continue;
      await _assignFallback(config.buttonId, config.fallbackId);
    }
  }

  Future<void> _assignFallback(String buttonId, String? fallbackId) =>
      (update(
        db.quickSwitcherButtonConfigs,
      )..where((t) => t.buttonId.equals(buttonId))).write(
        QuickSwitcherButtonConfigsCompanion(fallbackId: Value(fallbackId)),
      );
}
