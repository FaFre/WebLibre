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
import 'package:weblibre/core/logger.dart';

class DatabaseRegistry {
  DatabaseRegistry._();
  static final instance = DatabaseRegistry._();

  final _databases = <String, GeneratedDatabase>{};

  void register(String name, GeneratedDatabase db) {
    _databases[name] = db;
  }

  Future<void> closeAll() async {
    for (final entry in _databases.entries) {
      try {
        await entry.value.close();
        logger.i('${entry.key} database closed');
      } catch (e, st) {
        logger.e(
          'Failed to close ${entry.key} database',
          error: e,
          stackTrace: st,
        );
      }
    }
    _databases.clear();
  }
}
