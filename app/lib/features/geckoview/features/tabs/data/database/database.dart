/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.steps.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';

@DriftDatabase(include: {'definitions.drift'}, daos: [ContainerDao, TabDao])
class TabDatabase extends $TabDatabase with TrigramQueryBuilderMixin {
  @override
  final int schemaVersion = 5;

  @override
  final int ftsTokenLimit = 10;
  @override
  final int ftsMinTokenLength = 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (kDebugMode) {
        // This check pulls in a fair amount of code that's not needed
        // anywhere else, so we recommend only doing it in debug builds.
        await validateDatabaseSchema();
      }

      await customStatement('PRAGMA foreign_keys = ON');
      await definitionsDrift.optimizeFtsIndex();
    },
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
  );

  TabDatabase(super.e);

  static final _upgrade = migrationSteps(
    from2To3: (m, schema) async {
      final tabAtV3 = schema.tab;
      await m.addColumn(tabAtV3, tabAtV3.isPrivate);
    },
    from3To4: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.tab,
          columnTransformer: {
            schema.tab.source: Constant(TabSource.manual.index),
          },
          newColumns: [schema.tab.source],
        ),
      );
    },
    from4To5: (m, schema) async {
      await m.drop(schema.tabMaintainParentChainOnDelete);
      await m.create(schema.tabMaintainParentChainOnDelete);
    },
  );
}
