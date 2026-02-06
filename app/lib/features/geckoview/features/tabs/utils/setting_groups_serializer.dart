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

// ignore_for_file: avoid_dynamic_calls wo know what we do

import 'package:weblibre/features/geckoview/features/preferences/data/models/preference_setting.dart';

enum PreferencePartition {
  user('user'),
  system('system');

  final String key;

  const PreferencePartition(this.key);
}

Map<String, PreferenceSettingGroup> deserializePreferenceSettingGroups(
  PreferencePartition partition,
  Map<String, dynamic> content,
) {
  final parititonedContent = content[partition.key] as Map<String, dynamic>;

  return parititonedContent.map(
    (key, value) => MapEntry(
      key,
      PreferenceSettingGroup(
        description: value['description'] as String?,
        settings: (value['preferences'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            PreferenceSetting.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
    ),
  );
}
