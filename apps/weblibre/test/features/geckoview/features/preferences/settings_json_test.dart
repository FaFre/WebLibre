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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';

Future<Map<String, PreferenceSettingGroup>> _load(
  PreferencePartition partition,
) async {
  final content =
      jsonDecode(
            await rootBundle.loadString('assets/preferences/settings.json'),
          )
          as Map<String, dynamic>;
  return deserializePreferenceSettingGroups(partition, content);
}

Set<String> _names(Map<String, PreferenceSettingGroup> groups) => {
  for (final group in groups.values) ...group.settings.keys,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('engine baseline entries carry no user-branch flags', () async {
    // The system partition is written to Gecko's default branch on every
    // start; opt-in, locking and startup enforcement only mean something for
    // the user branch the hardening screens toggle.
    final system = await _load(PreferencePartition.system);

    expect(system, isNotEmpty);
    for (final group in system.values) {
      for (final MapEntry(key: name, value: setting)
          in group.settings.entries) {
        expect(setting.requireUserOptIn, isFalse, reason: name);
        expect(setting.locked, isFalse, reason: name);
        expect(setting.enforceOnStartup, isFalse, reason: name);
      }
    }
  });

  test('no preference is in both partitions', () async {
    final user = _names(await _load(PreferencePartition.user));
    final system = _names(await _load(PreferencePartition.system));

    expect(user.intersection(system), isEmpty);
  });

  test('retired preferences stay out', () async {
    final all = {
      ..._names(await _load(PreferencePartition.user)),
      ..._names(await _load(PreferencePartition.system)),
    };

    expect(all.intersection(retiredPreferences.toSet()), isEmpty);
  });
}
