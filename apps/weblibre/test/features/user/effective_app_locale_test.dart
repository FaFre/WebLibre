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
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

void main() {
  group('effectiveAppLocale', () {
    Locale? resolve(String? appLocale) {
      final container = ProviderContainer(
        overrides: [
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults(appLocale: appLocale),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container.read(effectiveAppLocaleProvider);
    }

    test('an unset language falls back to English, not the system', () {
      expect(defaultAppLocale, 'en');
      expect(resolve(null), const Locale('en'));
    });

    test(
      'an explicit system choice lets Flutter resolve the system locale',
      () {
        expect(resolve(appLocaleSystem), isNull);
      },
    );

    test('an explicit language wins', () {
      expect(resolve('de'), const Locale('de'));
    });

    test('an unsupported language follows the system locale', () {
      expect(resolve('xx'), isNull);
    });
  });
}
