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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profileId = '0190a000-0000-7000-8000-000000000001';
  const getShared =
      'dev.flutter.pigeon.flutter_mozilla_components.GeckoProfileApi.getSharedProfileUnlock';

  /// What native answers for the window's unlock.
  SharedProfileUnlock? windowUnlock;

  setUp(() {
    windowUnlock = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(getShared, (message) async {
          const codec = GeckoProfileApi.pigeonChannelCodec;
          return codec.encodeMessage(<Object?>[windowUnlock]);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(getShared, null);
  });

  ProviderContainer containerFor(AuthSettings settings) {
    final container = ProviderContainer(
      overrides: [
        selectedProfileProvider.overrideWith(
          (ref) => Profile(id: profileId, name: 'Work', authSettings: settings),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final timeoutLock = AuthSettings.withDefaults(
    lockMethod: ProfileLockMethod.password,
    autoLockMode: AutoLockMode.timeout,
    timeout: const Duration(minutes: 1),
  );

  test('a window unlock that still holds opens the browser', () async {
    final container = containerFor(timeoutLock);
    windowUnlock = SharedProfileUnlock(
      mode: SharedUnlockMode.timeout,
      timeoutMs: 60000,
      ageMs: 20000,
    );

    final adopted = await container
        .read(profileAuthStateProvider.notifier)
        .adoptSharedUnlock();

    expect(adopted, isTrue);
    expect(container.read(profileAuthStateProvider), isTrue);
    expect(
      container
          .read(localAuthenticationServiceProvider.notifier)
          .isCached(profileAccessAuthKey(profileId)),
      isTrue,
    );
  });

  test('a window unlock older than this timeout does not', () async {
    final container = containerFor(timeoutLock);
    windowUnlock = SharedProfileUnlock(
      mode: SharedUnlockMode.timeout,
      // Native held it under a longer timeout than the profile has now.
      timeoutMs: 600000,
      ageMs: 90000,
    );

    final adopted = await container
        .read(profileAuthStateProvider.notifier)
        .adoptSharedUnlock();

    expect(adopted, isFalse);
    expect(container.read(profileAuthStateProvider), isFalse);
  });

  test('a background-mode profile never adopts one', () async {
    final container = containerFor(
      AuthSettings.withDefaults(lockMethod: ProfileLockMethod.password),
    );
    windowUnlock = SharedProfileUnlock(
      mode: SharedUnlockMode.startup,
      timeoutMs: 0,
      ageMs: 0,
    );

    final adopted = await container
        .read(profileAuthStateProvider.notifier)
        .adoptSharedUnlock();

    expect(adopted, isFalse);
  });

  test('nothing to adopt stays locked', () async {
    final container = containerFor(timeoutLock);

    final adopted = await container
        .read(profileAuthStateProvider.notifier)
        .adoptSharedUnlock();

    expect(adopted, isFalse);
    expect(container.read(profileAuthStateProvider), isFalse);
  });
}
