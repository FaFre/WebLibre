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
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter/foundation.dart';
import 'package:weblibre/features/bangs/data/database/daos/bang.dart';
import 'package:weblibre/features/bangs/data/database/daos/sync.dart';
import 'package:weblibre/features/bangs/data/database/database.drift.dart';
import 'package:weblibre/features/bangs/data/database/database.steps.dart';
import 'package:weblibre/features/bangs/data/database/definitions.drift.dart';
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';

@DriftDatabase(include: {'definitions.drift'}, daos: [BangDao, SyncDao])
class BangDatabase extends $BangDatabase with PrefixQueryBuilderMixin {
  @override
  final int schemaVersion = 5;

  @override
  final int ftsTokenLimit = 6;
  @override
  final int ftsMinTokenLength = 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Following the advice from https://drift.simonbinder.eu/Migrations/api/#general-tips
      await customStatement('PRAGMA foreign_keys = OFF');

      await transaction(
        () => VersionedSchema.runMigrationSteps(
          migrator: m,
          from: from,
          to: to,
          steps: _upgrade,
        ),
      );

      if (kDebugMode) {
        final wrongForeignKeys = await customSelect(
          'PRAGMA foreign_key_check',
        ).get();
        assert(
          wrongForeignKeys.isEmpty,
          '${wrongForeignKeys.map((e) => e.data)}',
        );
      }

      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (details) async {
      if (kDebugMode) {
        // This check pulls in a fair amount of code that's not needed
        // anywhere else, so we recommend only doing it in debug builds.
        await validateDatabaseSchema();
      }

      if (details.hadUpgrade && details.versionBefore != null) {
        if (details.versionBefore! < 3) {
          await bang.deleteWhere((t) => t.group.equals(3));
          await bangTriggers.deleteWhere((t) => t.group.equals(3));
          await bangSync.deleteWhere((t) => t.group.equals(3));
          await bangFrequency.deleteWhere((t) => t.group.equals(3));
          await bangHistory.deleteWhere((t) => t.group.equals(3));
        } else if (details.versionBefore! < 5) {
          await bang.deleteWhere((t) => t.group.equals(1));
          await bangTriggers.deleteWhere((t) => t.group.equals(1));
          await bangSync.deleteWhere((t) => t.group.equals(1));
          await bangFrequency.deleteWhere((t) => t.group.equals(1));
          await bangHistory.deleteWhere((t) => t.group.equals(1));

          await (bang.update()..where((t) => t.group.isBiggerThanValue(0)))
              .write(
                BangCompanion.custom(group: bang.group - const Constant(1)),
              );
          await (bangTriggers.update()
                ..where((t) => t.group.isBiggerThanValue(0)))
              .write(
                BangTriggersCompanion.custom(
                  group: bangTriggers.group - const Constant(1),
                ),
              );
          await (bangSync.update()..where((t) => t.group.isBiggerThanValue(0)))
              .write(
                BangSyncCompanion.custom(
                  group: bangSync.group - const Constant(1),
                ),
              );
          await (bangFrequency.update()
                ..where((t) => t.group.isBiggerThanValue(0)))
              .write(
                BangFrequencyCompanion.custom(
                  group: bangFrequency.group - const Constant(1),
                ),
              );
          await (bangHistory.update()
                ..where((t) => t.group.isBiggerThanValue(0)))
              .write(
                BangHistoryCompanion.custom(
                  group: bangHistory.group - const Constant(1),
                ),
              );
        }
      }

      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  BangDatabase(super.e);

  static final _upgrade = migrationSteps(
    from1To2: (m, schema) async {
      //Too many changes, we switch to a new database
    },
    from2To3: (m, schema) async {
      await m.addColumn(schema.bang, schema.bang.searxngApi);
    },
    from3To4: (m, schema) async {
      await m.alterTable(TableMigration(schema.bangHistory));
    },
    from4To5: (m, schema) async {
      await m.addColumn(schema.bang, schema.bang.snapDomain);
    },
  );
}
