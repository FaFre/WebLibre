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

typedef PreferenceMigrationStep = Future<void> Function();

class PreferenceMigrationRunner {
  const PreferenceMigrationRunner({
    required this.schemaVersion,
    required this.steps,
  });

  final int schemaVersion;
  final Map<int, PreferenceMigrationStep> steps;

  Future<int> run({
    required Future<int> Function() readVersion,
    required Future<void> Function(int version) writeVersion,
  }) async {
    var version = await readVersion();

    while (version < schemaVersion) {
      final step = steps[version];
      if (step == null) {
        throw StateError(
          'Missing preference migration from version '
          '$version to ${version + 1}',
        );
      }

      await step();
      version++;
      await writeVersion(version);
    }

    return version;
  }
}
