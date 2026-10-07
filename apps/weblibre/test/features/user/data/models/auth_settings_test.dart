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
import 'package:weblibre/features/user/data/models/auth_settings.dart';

void main() {
  group('AuthSettings JSON', () {
    test('a lock written before lock methods existed is the device lock', () {
      final settings = AuthSettings.fromJson({
        'authenticationRequired': true,
        'autoLockMode': 'background',
        'timeout': 300000000,
      });

      expect(settings.lockMethod, ProfileLockMethod.device);
      expect(settings.authenticationRequired, isTrue);
    });

    test('an old unlocked profile stays unlocked', () {
      final settings = AuthSettings.fromJson({
        'authenticationRequired': false,
        'autoLockMode': 'background',
        'timeout': 300000000,
      });

      expect(settings.lockMethod, ProfileLockMethod.none);
    });

    test('keeps writing authenticationRequired for older builds', () {
      final json = AuthSettings.withDefaults(
        lockMethod: ProfileLockMethod.password,
        passwordVerifier: 'verifier',
      ).toJson();

      // An older build that reads this locks the profile with the device
      // prompt rather than opening it.
      expect(json['authenticationRequired'], isTrue);
      expect(json['lockMethod'], 'password');
    });

    test('round-trips a password lock', () {
      final settings = AuthSettings.withDefaults(
        lockMethod: ProfileLockMethod.password,
        passwordVerifier: 'verifier',
        autoLockMode: AutoLockMode.timeout,
      );

      expect(AuthSettings.fromJson(settings.toJson()), settings);
    });

    test('an unknown method from a newer build stays locked', () {
      final settings = AuthSettings.fromJson({
        'lockMethod': 'somethingNew',
        'authenticationRequired': true,
        'autoLockMode': 'background',
        'timeout': 300000000,
      });

      expect(settings.lockMethod, ProfileLockMethod.device);
    });
  });
}
