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
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter/foundation.dart';
import 'package:weblibre/features/small_web/data/database/daos/small_web_item_dao.dart';
import 'package:weblibre/features/small_web/data/database/daos/small_web_visit_dao.dart';
import 'package:weblibre/features/small_web/data/database/daos/wander_console_dao.dart';
import 'package:weblibre/features/small_web/data/database/database.drift.dart';

@DriftDatabase(
  include: {'definitions.drift'},
  daos: [SmallWebItemDao, SmallWebVisitDao, WanderConsoleDao],
)
class SmallWebDatabase extends $SmallWebDatabase {
  SmallWebDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (kDebugMode) {
        await validateDatabaseSchema();
      }
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
