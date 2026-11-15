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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The updater's state is installation-wide and outside every profile
/// (plans/APP_UPDATER_IMPLEMENTATION_PLAN.md, 6, 6.3): profile backup,
/// restore and settings export must never carry it, so a restored profile can
/// never bring back an old revision floor or installer journal.
void main() {
  Iterable<File> sources(String root, String extension) sync* {
    final dir = Directory(root);
    if (!dir.existsSync()) return;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File &&
          entity.path.endsWith(extension) &&
          !entity.path.endsWith('.g.dart') &&
          !entity.path.endsWith('.g.kt')) {
        yield entity;
      }
    }
  }

  test('no maintenance participant, backup or export touches app_update', () {
    final offenders = [
      for (final root in [
        'lib/core/maintenance',
        'lib/core/startup',
        'lib/features/settings',
        '../../packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/startup',
        '../../packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/maintenance',
      ])
        for (final file in [...sources(root, '.dart'), ...sources(root, '.kt')])
          for (final (index, line) in file.readAsLinesSync().indexed)
            if (line.contains('app_update') &&
                !line.startsWith('import ') &&
                !line.trimLeft().startsWith('//'))
              '${file.path}:${index + 1}',
    ];
    expect(offenders, isEmpty);
  });

  test(
    'the updater never stores anything in a profile or in SharedPreferences',
    () {
      final offenders = [
        for (final file in [
          ...sources('lib/features/app_update', '.dart'),
          ...sources(
            'android/app/src/main/kotlin/eu/weblibre/gecko/update',
            '.kt',
          ),
          ...sources(
            'android/app/src/github/kotlin/eu/weblibre/gecko/update',
            '.kt',
          ),
        ])
          for (final (index, line) in file.readAsLinesSync().indexed)
            if ((line.contains('SharedPreferences') ||
                    line.contains('profileDirectory') ||
                    line.contains('getSharedPreferences') ||
                    line.contains('filesDir')) &&
                !line.trimLeft().startsWith('//') &&
                !line.trimLeft().startsWith('*'))
              '${file.path}:${index + 1}',
      ];
      expect(offenders, isEmpty);
    },
  );

  test('domain code imports neither Flutter nor AppLocalizations', () {
    final offenders = [
      for (final file in sources('lib/features/app_update/domain', '.dart'))
        for (final (index, line) in file.readAsLinesSync().indexed)
          if (line.startsWith('import ') &&
              (line.contains('package:flutter/') ||
                  line.contains('app_localizations')))
            '${file.path}:${index + 1}',
    ];
    expect(offenders, isEmpty);
  });
}
