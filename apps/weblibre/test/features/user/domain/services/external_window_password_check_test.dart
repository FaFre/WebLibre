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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/services/external_window_password_check.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

void main() {
  const profileId = '0190a000-0000-7000-8000-000000000001';

  late Directory dir;
  late String verifier;

  setUpAll(() async {
    verifier = await createProfilePasswordVerifier('secret');
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('weblibre-window-lock');
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  Future<void> lockWith(ProfileLockMethod method) => fs.writeProfileMetadata(
    dir,
    Profile(
      id: profileId,
      name: 'Work',
      authSettings: AuthSettings.withDefaults(
        lockMethod: method,
        passwordVerifier: method == ProfileLockMethod.password
            ? verifier
            : null,
      ),
    ),
  );

  ExternalWindowPasswordCheck checkIn(Directory? dir) =>
      ExternalWindowPasswordCheck(profileDir: (_) => dir);

  test('the right password unlocks', () async {
    await lockWith(ProfileLockMethod.password);

    final reply = await checkIn(dir).checkProfilePassword(profileId, 'secret');

    expect(reply.outcome, ProfilePasswordOutcome.accepted);
  });

  test('a wrong password counts against the same throttle', () async {
    await lockWith(ProfileLockMethod.password);

    final reply = await checkIn(dir).checkProfilePassword(profileId, 'wrong');

    expect(reply.outcome, ProfilePasswordOutcome.rejected);
    expect(
      File('${dir.path}/$profileLockAttemptsFileName').existsSync(),
      isTrue,
    );
  });

  test('a throttled profile is not checked', () async {
    await lockWith(ProfileLockMethod.password);
    final check = checkIn(dir);
    for (var i = 0; i < 5; i++) {
      await check.checkProfilePassword(profileId, 'wrong');
    }

    final reply = await check.checkProfilePassword(profileId, 'secret');

    expect(reply.outcome, ProfilePasswordOutcome.throttled);
    expect(reply.retryAfterMs, greaterThan(0));
  });

  test('a profile no longer locked by password is not unlocked here', () async {
    // The browser changed the lock while the window showed the old one.
    await lockWith(ProfileLockMethod.device);

    final reply = await checkIn(dir).checkProfilePassword(profileId, 'secret');

    expect(reply.outcome, ProfilePasswordOutcome.failed);
  });

  test('before a profile is active the window is told to ask again', () async {
    final reply = await checkIn(null).checkProfilePassword(profileId, 'secret');

    expect(reply.outcome, ProfilePasswordOutcome.unavailable);
  });
}
