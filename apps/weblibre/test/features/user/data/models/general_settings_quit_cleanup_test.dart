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
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  group('automatic browsing data deletion', () {
    test('reads settings saved as "Incognito Mode"', () {
      final settings = GeneralSettings.fromJson({
        'deleteBrowsingDataOnQuit': ['history', 'cookies'],
      });

      expect(settings.autoDeleteBrowsingData, {
        DeleteBrowsingDataType.history,
        DeleteBrowsingDataType.cookies,
      });
    });

    test('is off by default', () {
      expect(GeneralSettings.withDefaults().autoDeleteBrowsingData, isNull);
    });

    test('round-trips under the original storage key', () {
      final settings = GeneralSettings.withDefaults(
        autoDeleteBrowsingData: {DeleteBrowsingDataType.downloads},
        confirmBeforeQuit: false,
      );

      final json = settings.toJson();
      expect(json['deleteBrowsingDataOnQuit'], ['downloads']);

      final restored = GeneralSettings.fromJson(json);
      expect(restored.autoDeleteBrowsingData, {
        DeleteBrowsingDataType.downloads,
      });
      expect(restored.confirmBeforeQuit, isFalse);
    });

    test('Quit asks for confirmation by default', () {
      expect(GeneralSettings.withDefaults().confirmBeforeQuit, isTrue);
    });
  });
}
