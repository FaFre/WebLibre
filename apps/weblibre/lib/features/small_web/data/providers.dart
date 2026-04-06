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
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:weblibre/core/database_registry.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/models/kagi_category.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SmallWebDatabase smallWebDatabase(Ref ref) {
  final db = SmallWebDatabase(
    LazyDatabase(() async {
      final file = File(
        p.join(filesystem.profileDatabasesDir.path, 'small_web.db'),
      );

      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      return NativeDatabase.createInBackground(file);
    }),
  );

  DatabaseRegistry.instance.register('small_web', db);

  ref.onDispose(() async {
    await db.close();
  });

  return db;
}

@Riverpod(keepAlive: true)
Future<KagiCategories> kagiCategories(Ref ref) async {
  final jsonStr = await rootBundle.loadString(
    'assets/small_web/kagi_categories.json',
  );

  return KagiCategories.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
