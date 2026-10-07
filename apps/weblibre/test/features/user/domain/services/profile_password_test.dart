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
import 'package:path/path.dart' as p;
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';

void main() {
  group('profile password verifier', () {
    test('opens only under the password it was made with', () async {
      final verifier = await createProfilePasswordVerifier('correct horse');

      expect(verifier, isNot(contains('correct horse')));
      expect(await matchesProfilePassword(verifier, 'correct horse'), isTrue);
      expect(await matchesProfilePassword(verifier, 'wrong'), isFalse);
      expect(await matchesProfilePassword(verifier, ''), isFalse);
    });

    test('a damaged verifier keeps the profile locked', () async {
      expect(await matchesProfilePassword('not base64 !!', 'x'), isFalse);
    });
  });

  group('ProfilePasswordGate', () {
    late Directory dir;
    late DateTime now;
    final settings = AuthSettings.withDefaults(
      lockMethod: ProfileLockMethod.password,
      passwordVerifier: 'secret',
    );

    ProfilePasswordGate gate() => ProfilePasswordGate(
      dir,
      now: () => now,
      matches: (verifier, password) async => password == verifier,
    );

    File attemptsFile() => File(p.join(dir.path, profileLockAttemptsFileName));

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('profile_password_test');
      now = DateTime.utc(2026, 10, 7, 12);
    });

    tearDown(() async {
      await dir.delete(recursive: true);
    });

    Future<ProfilePasswordCheck> failTimes(int count) async {
      late ProfilePasswordCheck last;
      for (var i = 0; i < count; i++) {
        last = await gate().check(settings, 'wrong');
      }
      return last;
    }

    test('accepts the right password', () async {
      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordAccepted>(),
      );
    });

    test('the first wrong attempts cost nothing', () async {
      final result = await failTimes(4);

      expect(
        result,
        isA<ProfilePasswordRejected>().having(
          (r) => r.retryAfter,
          'retryAfter',
          isNull,
        ),
      );
    });

    test('the fifth wrong attempt starts a wait', () async {
      final result = await failTimes(5);

      expect(
        result,
        isA<ProfilePasswordRejected>().having(
          (r) => r.retryAfter,
          'retryAfter',
          const Duration(seconds: 30),
        ),
      );

      // Even the right password is not checked during the wait.
      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordThrottled>().having(
          (r) => r.retryAfter,
          'retryAfter',
          const Duration(seconds: 30),
        ),
      );
    });

    test('the wait survives a new gate, as after the app is killed', () async {
      await failTimes(5);
      now = now.add(const Duration(seconds: 10));

      expect(
        await ProfilePasswordGate(
          dir,
          now: () => now,
          matches: (_, _) async => true,
        ).check(settings, 'secret'),
        isA<ProfilePasswordThrottled>(),
      );
    });

    test('waits double with every further wrong attempt', () async {
      await failTimes(5);
      now = now.add(const Duration(seconds: 30));

      expect(
        await gate().check(settings, 'wrong'),
        isA<ProfilePasswordRejected>().having(
          (r) => r.retryAfter,
          'retryAfter',
          const Duration(minutes: 1),
        ),
      );
    });

    test('the right password after the wait clears the record', () async {
      await failTimes(5);
      now = now.add(const Duration(seconds: 30));

      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordAccepted>(),
      );
      expect(attemptsFile().existsSync(), isFalse);

      // A fresh run of free attempts.
      expect(
        await gate().check(settings, 'wrong'),
        isA<ProfilePasswordRejected>().having(
          (r) => r.retryAfter,
          'retryAfter',
          isNull,
        ),
      );
    });

    test('setting the clock back does not end the wait', () async {
      await failTimes(5);
      now = now.subtract(const Duration(days: 1));

      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordThrottled>(),
      );
    });

    test('a damaged record imposes one wait that then ends', () async {
      await attemptsFile().writeAsString('{not json');

      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordThrottled>(),
      );

      now = now.add(const Duration(seconds: 30));
      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordAccepted>(),
      );
    });

    test('a password lock without a verifier never opens', () async {
      expect(
        await gate().check(
          AuthSettings.withDefaults(lockMethod: ProfileLockMethod.password),
          'anything',
        ),
        isA<ProfilePasswordRejected>(),
      );
    });

    test('overlapping checks are each counted', () async {
      // Five dialogs' worth of checks in flight at once, each slow enough to
      // overlap the others. Without serializing, all of them read a count of
      // zero and the fifth never starts a wait.
      ProfilePasswordGate slowGate() => ProfilePasswordGate(
        dir,
        now: () => now,
        matches: (verifier, password) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return password == verifier;
        },
      );

      final results = await Future.wait([
        for (var i = 0; i < 5; i++) slowGate().check(settings, 'wrong'),
      ]);

      expect(
        results.last,
        isA<ProfilePasswordRejected>().having(
          (r) => r.retryAfter,
          'retryAfter',
          const Duration(seconds: 30),
        ),
      );
    });

    test('a check that throws does not hold up the next one', () async {
      final failing = ProfilePasswordGate(
        dir,
        now: () => now,
        matches: (_, _) async => throw StateError('verifier exploded'),
      );

      await expectLater(
        failing.check(settings, 'secret'),
        throwsA(isA<StateError>()),
      );
      expect(
        await gate().check(settings, 'secret'),
        isA<ProfilePasswordAccepted>(),
      );
    });

    test('a record that cannot be written fails the check', () async {
      // The dialog turns this into an error and keeps the action denied.
      final unwritable = ProfilePasswordGate(
        Directory(p.join(dir.path, 'missing', 'profile')),
        now: () => now,
        matches: (verifier, password) async => password == verifier,
      );

      await expectLater(
        unwritable.check(settings, 'wrong'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('caps the wait at an hour', () {
      expect(profilePasswordDelayAfter(4), isNull);
      expect(profilePasswordDelayAfter(5), const Duration(seconds: 30));
      expect(profilePasswordDelayAfter(100), const Duration(hours: 1));
    });
  });
}
