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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/legacy_setting_fallbacks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an old snapshot gets the old fallbacks where it has no value', () {
    final payload = <String, dynamic>{
      'general': <String, dynamic>{},
      'engine': <String, dynamic>{'lnaBlocking': null},
    };

    restoreLegacySettingFallbacks(payload);

    final general = GeneralSettings.fromJson(
      payload['general'] as Map<String, dynamic>,
    );
    final engine = EngineSettings.fromJson(
      payload['engine'] as Map<String, dynamic>,
    );
    expect(general.enableLocalAiFeatures, isTrue);
    expect(general.urlCleanerAutoApply, isFalse);
    expect(engine.lnaBlocking, isFalse);
  });

  test('explicit values and missing sections are left alone', () {
    final payload = <String, dynamic>{
      'engine': <String, dynamic>{'lnaBlocking': true},
    };

    restoreLegacySettingFallbacks(payload);

    expect(payload, {
      'engine': {'lnaBlocking': true},
    });
  });

  // What makes a missing or null value mean "old data": a current snapshot
  // always carries these explicitly.
  test('current settings always write these settings explicitly', () {
    final sections = {
      'general': GeneralSettings.withDefaults().toJson(),
      'engine': EngineSettings.withDefaults().toJson(),
    };
    for (final (:partition, :key, value: _) in legacySettingFallbacks) {
      expect(sections[partition]![key], isNotNull, reason: '$partition.$key');
    }
  });
}
