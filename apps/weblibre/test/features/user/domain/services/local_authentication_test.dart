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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  const channel = MethodChannel('plugins.flutter.io/local_auth');

  setUp(() {
    prompt = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'authenticate') return prompt.future;
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
      service.evictCacheOnBackground(leftForeground: true);

      expect(service.isCached(key), isTrue);
    },
  );

  test('remembering again replaces the policy the unlock follows', () {
    // What saving a changed lock does for the open profile: without it, the
    // startup-policy copy above would keep the session unlocked forever.
    service.remember(key, startupLock);
    service.remember(key, backgroundLock);
    service.evictCacheOnBackground(leftForeground: true);

    expect(service.isCached(key), isFalse);
  });

  test('forget drops the unlock', () {
    service.remember(key, startupLock);
    service.forget(key);

    expect(service.isCached(key), isFalse);
  });

  group('while a system prompt is showing', () {
    const other = 'profile_access::other';

    test('the inactive state it causes does not evict', () async {
      service.remember(key, backgroundLock);

      final answer = service.authenticate(
        authKey: other,
        localizedReason: 'test',
      );
      service.evictCacheOnBackground(leftForeground: false);
      expect(service.isCached(key), isTrue);

      prompt.complete(true);
      await answer;
    });

    test('leaving the app still evicts', () async {
      service.remember(key, backgroundLock);

      final answer = service.authenticate(
        authKey: other,
        localizedReason: 'test',
      );
      service.evictCacheOnBackground(leftForeground: true);
      expect(service.isCached(key), isFalse);

      prompt.complete(false);
      await answer;
    });

    test('a passed prompt is recorded before it counts as settled', () async {
      final answer = service.authenticate(
        authKey: other,
        localizedReason: 'test',
        alsoRemember: {key: backgroundLock},
      );

      // What the resume check does: wait for the prompt, then look.
      var cachedWhenSettled = false;
      final resumeCheck = service.promptsSettled().then((_) {
        cachedWhenSettled = service.isCached(key);
      });

      prompt.complete(true);
      expect(await answer, isTrue);
      await resumeCheck;

      expect(cachedWhenSettled, isTrue);
      // The action's own profile is not cached: sensitive actions ask fresh.
      expect(service.isCached(other), isFalse);
    });

    test('a refused prompt records nothing', () async {
      final answer = service.authenticate(
        authKey: other,
        localizedReason: 'test',
        alsoRemember: {key: backgroundLock},
      );

      prompt.complete(false);
      expect(await answer, isFalse);
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

  test('a plain inactive counts as leaving', () {
    // The notification shade: inactive without hidden or paused. It evicts,
    // so a password check running across it must not count.
    final before = service.departureCount;
    service.evictCacheOnBackground(leftForeground: false);
    expect(service.departureCount, before + 1);
  });

  test('the inactive caused by our own prompt does not count', () async {
    final answer = service.authenticate(
      authKey: 'profile_access::other',
      localizedReason: 'test',
    );
    final before = service.departureCount;
    service.evictCacheOnBackground(leftForeground: false);
    expect(service.departureCount, before);

    prompt.complete(true);
    await answer;
  });
}
