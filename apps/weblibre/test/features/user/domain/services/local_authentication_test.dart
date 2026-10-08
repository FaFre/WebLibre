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
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = 'profile_access::test';

  final startupLock = AuthSettings.withDefaults(
    lockMethod: ProfileLockMethod.device,
    autoLockMode: AutoLockMode.startup,
  );
  final backgroundLock = AuthSettings.withDefaults(
    lockMethod: ProfileLockMethod.device,
  );

  late ProviderContainer container;
  late LocalAuthenticationService service;

  /// The answer the next system prompt gives; completed by the test.
  late Completer<bool> prompt;

  /// The arguments the last system prompt was raised with.
  Map<Object?, Object?>? promptArguments;

  const channel = MethodChannel('plugins.flutter.io/local_auth');

  setUp(() {
    prompt = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'authenticate') {
            promptArguments = call.arguments as Map<Object?, Object?>;
            return await prompt.future;
          }
          return false;
        });

    container = ProviderContainer();
    service = container.read(localAuthenticationServiceProvider.notifier);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() => container.dispose());

  test(
    'an unlock remembered under the startup policy survives the background',
    () {
      service.remember(key, startupLock);
      service.evictCacheOnBackground();

      expect(service.isCached(key), isTrue);
    },
  );

  test('remembering again replaces the policy the unlock follows', () {
    // What saving a changed lock does for the open profile: without it, the
    // startup-policy copy above would keep the session unlocked forever.
    service.remember(key, startupLock);
    service.remember(key, backgroundLock);
    service.evictCacheOnBackground();

    expect(service.isCached(key), isFalse);
  });

  test('forget drops the unlock', () {
    service.remember(key, startupLock);
    service.forget(key);

    expect(service.isCached(key), isFalse);
  });

  group('while a system prompt is showing', () {
    const other = 'profile_access::other';

    test('leaving the app still evicts', () async {
      service.remember(key, backgroundLock);

      final answer = service.authenticate(
        authKey: other,
        localizedTitle: 'title',
        localizedReason: 'test',
      );
      service.evictCacheOnBackground();
      expect(service.isCached(key), isFalse);

      prompt.complete(false);
      await answer;
    });

    test('a passed prompt is recorded before it counts as settled', () async {
      final answer = service.authenticate(
        authKey: other,
        localizedTitle: 'title',
        localizedReason: 'test',
        alsoRemember: {key: backgroundLock},
      );

      // What the resume check does: wait for the prompt, then look.
      var cachedWhenSettled = false;
      final resumeCheck = service.promptsSettled().then((_) {
        cachedWhenSettled = service.isCached(key);
      });

      prompt.complete(true);
      expect((await answer).passed, isTrue);
      await resumeCheck;

      expect(cachedWhenSettled, isTrue);
      // The action's own profile is not cached: sensitive actions ask fresh.
      expect(service.isCached(other), isFalse);
    });

    test('a refused prompt records nothing', () async {
      final answer = service.authenticate(
        authKey: other,
        localizedTitle: 'title',
        localizedReason: 'test',
        alsoRemember: {key: backgroundLock},
      );

      prompt.complete(false);
      expect(await answer, isA<DeviceAuthDeclined>());
      expect(service.isCached(key), isFalse);
    });
  });

  test('leaving the app is noticed without the browser view', () {
    // The lock screen and the profile screens have no BrowserView, so the
    // service tracks the lifecycle itself.
    final binding = TestWidgetsFlutterBinding.instance;
    service.remember(key, backgroundLock);
    final before = service.departureCount;

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    expect(service.departureCount, greaterThan(before));
    expect(service.isCached(key), isFalse);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  test('a plain inactive is not leaving', () {
    // The notification shade, a permission dialog, another window in split
    // screen: focus lost, nothing hidden. The person never left.
    final binding = TestWidgetsFlutterBinding.instance;
    service.remember(key, backgroundLock);
    final before = service.departureCount;

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(service.departureCount, before);
    expect(service.isCached(key), isTrue);
  });

  test('the prompt is titled in the app language, without a hint', () async {
    // `local_auth`'s own title and hint are English whatever the language.
    final answer = service.authenticate(
      authKey: key,
      localizedTitle: 'Identität bestätigen',
      localizedReason: 'Profil entsperren',
    );
    prompt.complete(true);
    await answer;

    expect(promptArguments?['signInTitle'], 'Identität bestätigen');
    expect(promptArguments?['biometricHint'], '');
    expect(promptArguments?['localizedReason'], 'Profil entsperren');
  });

  group('a prompt the system refused', () {
    DeviceAuthResult resultOf(LocalAuthExceptionCode code) =>
        deviceAuthResultOf(LocalAuthException(code: code));

    DeviceAuthFailure? failureOf(LocalAuthExceptionCode code) =>
        switch (resultOf(code)) {
          DeviceAuthFailed(:final failure) => failure,
          _ => null,
        };

    test('says when no screen lock is set up', () {
      expect(
        failureOf(LocalAuthExceptionCode.noCredentialsSet),
        DeviceAuthFailure.noScreenLock,
      );
      // The prompt also takes the screen lock, so these only fail without
      // one.
      expect(
        failureOf(LocalAuthExceptionCode.noBiometricsEnrolled),
        DeviceAuthFailure.noScreenLock,
      );
    });

    test('says when it is locked out', () {
      expect(
        failureOf(LocalAuthExceptionCode.temporaryLockout),
        DeviceAuthFailure.lockedOut,
      );
      expect(
        failureOf(LocalAuthExceptionCode.biometricLockout),
        DeviceAuthFailure.lockedOut,
      );
    });

    test('says when it could not run', () {
      expect(
        failureOf(LocalAuthExceptionCode.deviceError),
        DeviceAuthFailure.unavailable,
      );
    });

    test('says nothing about a prompt that was closed', () {
      for (final code in [
        LocalAuthExceptionCode.userCanceled,
        LocalAuthExceptionCode.systemCanceled,
        LocalAuthExceptionCode.uiUnavailable,
      ]) {
        expect(resultOf(code), isA<DeviceAuthDeclined>(), reason: code.name);
      }
    });
  });

  group('sharing with Custom Tab and PWA windows', () {
    const pigeonPrefix =
        'dev.flutter.pigeon.flutter_mozilla_components.GeckoProfileApi';

    /// What reached native, as `method(args)`.
    late List<String> shared;

    setUp(() {
      shared = [];
      for (final method in [
        'recordSharedProfileUnlock',
        'clearSharedProfileUnlock',
      ]) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('$pigeonPrefix.$method', (message) async {
              const codec = GeckoProfileApi.pigeonChannelCodec;
              final args = codec.decodeMessage(message)! as List<Object?>;
              shared.add('$method(${args.join(', ')})');
              return codec.encodeMessage(<Object?>[null]);
            });
      }
    });

    tearDown(() {
      for (final method in [
        'recordSharedProfileUnlock',
        'clearSharedProfileUnlock',
      ]) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('$pigeonPrefix.$method', null);
      }
    });

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('an until-restart unlock is shared', () async {
      service.remember(key, startupLock);
      await settle();

      expect(shared, [
        'recordSharedProfileUnlock(test, SharedUnlockMode.startup, 300000, 0)',
      ]);
    });

    test('an adopted unlock is shared with its age', () async {
      final timeoutLock = AuthSettings.withDefaults(
        lockMethod: ProfileLockMethod.password,
        autoLockMode: AutoLockMode.timeout,
        timeout: const Duration(minutes: 1),
      );

      service.remember(
        key,
        timeoutLock,
        unlockedAt: DateTime.now().subtract(const Duration(seconds: 20)),
      );
      await settle();

      expect(shared, hasLength(1));
      final args = shared.single.split(', ');
      expect(args[1], 'SharedUnlockMode.timeout');
      expect(args[2], '60000');
      // The window's clock keeps running from when the unlock was made.
      expect(
        int.parse(args[3].replaceAll(')', '')),
        greaterThanOrEqualTo(20000),
      );
    });

    test('a background-mode unlock takes back what the windows had', () async {
      service.remember(key, backgroundLock);
      await settle();

      expect(shared, ['clearSharedProfileUnlock(test)']);
    });

    test('forgetting takes it back', () async {
      service.forget(key);
      await settle();

      expect(shared, ['clearSharedProfileUnlock(test)']);
    });

    test('only profile unlocks are shared', () async {
      service.remember('backup::test', startupLock);
      await settle();

      expect(shared, isEmpty);
    });
  });
}
