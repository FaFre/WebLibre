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

extension TableSize on DatabaseConnectionUser {
  SingleSelectable<double> tableSize(TableInfo table) {
    return customSelect(
      'SELECT SUM(pgsize) /(1024.0 * 1024.0)AS pgsize_mb FROM dbstat WHERE name = ?1',
      variables: [Variable<String>(table.actualTableName)],
      readsFrom: {table},
    ).map((QueryRow row) => row.read<double>('pgsize_mb'));
  }
}
