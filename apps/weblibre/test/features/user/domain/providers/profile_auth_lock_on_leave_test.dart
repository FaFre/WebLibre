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

import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';

/// The lock is decided when the app leaves and at the first sign of it coming
/// back, and the native cover is armed and lifted around that.
void main() {
  const profileId = '0190a000-0000-7000-8000-000000000001';
  const pigeonPrefix =
      'dev.flutter.pigeon.flutter_mozilla_components.GeckoProfileApi.';
  const localAuth = MethodChannel('plugins.flutter.io/local_auth');
  const codec = GeckoProfileApi.pigeonChannelCodec;

  /// What Dart sent the cover, in order: `arm:<armed>` and
  /// `release:<departure>:<afterFreshFrame>`.
  late List<String> sent;

  /// What native answers for the departure the window is back from.
  int? departure;

  /// A device prompt a test holds open; without one, every prompt passes.
  ///
  /// Made inside the test: awaiting a future completed in `setUp`, outside
  /// the test's fake-async zone, waits on a microtask the test never runs.
  Completer<bool>? heldPrompt;

  var now = DateTime(2026, 11, 23, 12);

  TestDefaultBinaryMessenger messenger() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void reply(String method, void Function(List<Object?> args) onCall) {
    messenger().setMockMessageHandler('$pigeonPrefix$method', (message) async {
      // A call without arguments sends no list at all.
      onCall(codec.decodeMessage(message) as List<Object?>? ?? const []);
      return codec.encodeMessage(<Object?>[null]);
    });
  }

  setUp(() {
    sent = [];
    departure = 1;
    heldPrompt = null;
    now = DateTime(2026, 11, 23, 12);

    reply('setBrowserLockCover', (args) => sent.add('arm:${args[0]}'));
    reply(
      'releaseBrowserLockCover',
      (args) => sent.add('release:${args[0]}:${args[1]}'),
    );
    messenger().setMockMessageHandler(
      '${pigeonPrefix}currentBrowserLockCoverDeparture',
      (message) async => codec.encodeMessage(<Object?>[departure]),
    );
    reply('recordSharedProfileUnlock', (_) {});
    reply('clearSharedProfileUnlock', (_) {});

    messenger().setMockMethodCallHandler(localAuth, (call) async {
      if (call.method != 'authenticate') return false;
      final held = heldPrompt;
      if (held == null) return true;
      return await held.future;
    });
  });

  tearDown(() {
    for (final method in [
      'setBrowserLockCover',
      'currentBrowserLockCoverDeparture',
      'releaseBrowserLockCover',
      'recordSharedProfileUnlock',
      'clearSharedProfileUnlock',
    ]) {
      messenger().setMockMessageHandler('$pigeonPrefix$method', null);
    }
    messenger().setMockMethodCallHandler(localAuth, null);
  });

  ProviderContainer containerFor(
    AuthSettings settings, {
    bool Function()? unreadable,
  }) {
    final container = ProviderContainer(
      overrides: [
        selectedProfileProvider.overrideWith((ref) {
          if (unreadable?.call() ?? false) {
            throw StateError('profile metadata unreadable');
          }
          return Profile(id: profileId, name: 'Work', authSettings: settings);
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final backgroundLock = AuthSettings.withDefaults(
    lockMethod: ProfileLockMethod.device,
  );
  final timeoutLock = AuthSettings.withDefaults(
    lockMethod: ProfileLockMethod.device,
    autoLockMode: AutoLockMode.timeout,
    timeout: const Duration(minutes: 1),
  );

  /// Runs [body] with the lock's clock reading [now].
  Future<void> onClock(Future<void> Function() body) =>
      withClock(Clock(() => now), body);

  Future<void> open(WidgetTester tester, ProviderContainer container) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final result = await container
        .read(profileAuthStateProvider.notifier)
        .authenticate(localizedTitle: 'Unlock', localizedReason: 'Unlock');
    await tester.idle();
    expect(result.passed, isTrue);
    expect(container.read(profileAuthStateProvider), isTrue);
  }

  Future<void> leave(WidgetTester tester) async {
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.idle();
  }

  /// Back on screen, before the window has focus: no frame drawn yet.
  Future<void> show(WidgetTester tester) async {
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.idle();
  }

  Future<void> focus(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.idle();
  }

  Future<void> frames(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      await tester.pump();
    }
  }

  testWidgets('a profile that locks on leaving locks while it is away', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);
      expect(sent, ['arm:true']);

      await leave(tester);

      // Locked before anything is drawn again, and no longer armed: the lock
      // screen is what the window shows next.
      expect(container.read(profileAuthStateProvider), isFalse);
      expect(sent, ['arm:true', 'arm:false']);

      // The cover stays until the frame showing the lock screen has been
      // rasterized: the third frame back.
      await show(tester);
      await frames(tester, 2);
      expect(sent.last, 'arm:false');

      await frames(tester, 1);
      expect(sent.last, 'release:1:true');

      await focus(tester);
    });
  });

  testWidgets('a timeout that ran out while away locks before the first '
      'frame back', (tester) async {
    await onClock(() async {
      final container = containerFor(timeoutLock);
      await open(tester, container);

      await leave(tester);
      expect(container.read(profileAuthStateProvider), isTrue);

      now = now.add(const Duration(minutes: 2));
      await show(tester);

      expect(container.read(profileAuthStateProvider), isFalse);
      expect(sent, ['arm:true', 'arm:false']);

      await frames(tester, 3);
      expect(sent.last, 'release:1:true');

      await focus(tester);
    });
  });

  testWidgets('back within the timeout lifts the cover at once', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(timeoutLock);
      await open(tester, container);

      await leave(tester);
      now = now.add(const Duration(seconds: 10));
      await show(tester);

      // No frame needed: the cover hides this same open profile.
      expect(container.read(profileAuthStateProvider), isTrue);
      expect(sent, ['arm:true', 'release:1:false']);

      await focus(tester);
    });
  });

  testWidgets('a prompt in flight keeps the cover until the decision', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);

      // Authorizing an action raises a prompt over the open profile.
      final prompt = heldPrompt = Completer<bool>();
      final action = container
          .read(localAuthenticationServiceProvider.notifier)
          .authenticate(
            authKey: 'action',
            localizedTitle: 'Confirm',
            localizedReason: 'Confirm',
          );

      await leave(tester);
      await show(tester);
      await frames(tester, 3);

      expect(container.read(profileAuthStateProvider), isTrue);
      expect(
        sent.where((call) => call.startsWith('release')),
        isEmpty,
        reason: 'the prompt may no longer hide the browser',
      );

      // The leave dropped the profile's unlock, and the prompt's answer does
      // not bring it back.
      prompt.complete(true);
      await action;
      await tester.idle();
      expect(container.read(profileAuthStateProvider), isFalse);

      await frames(tester, 3);
      expect(sent.last, 'release:1:true');

      await focus(tester);
    });
  });

  testWidgets('a profile that cannot be read is judged by the settings last '
      'read', (tester) async {
    await onClock(() async {
      var unreadable = false;
      final container = containerFor(timeoutLock, unreadable: () => unreadable);
      await open(tester, container);

      unreadable = true;
      container.invalidate(selectedProfileProvider);
      await tester.idle();

      // Within the timeout the unlock holds.
      await leave(tester);
      now = now.add(const Duration(seconds: 10));
      await show(tester);
      expect(container.read(profileAuthStateProvider), isTrue);
      expect(sent.last, 'release:1:false');
      await focus(tester);

      // Once it ran out, it does not.
      await leave(tester);
      departure = 2;
      now = now.add(const Duration(minutes: 2));
      await show(tester);
      expect(container.read(profileAuthStateProvider), isFalse);

      await frames(tester, 3);
      expect(sent.last, 'release:2:true');

      await focus(tester);
    });
  });

  testWidgets('a profile without a lock that cannot be read stays open', (
    tester,
  ) async {
    await onClock(() async {
      var unreadable = false;
      final container = containerFor(
        AuthSettings.withDefaults(),
        unreadable: () => unreadable,
      );
      await open(tester, container);

      unreadable = true;
      container.invalidate(selectedProfileProvider);
      await tester.idle();

      // Locked, it could not be unlocked: the lock screen reads the same
      // profile.
      await leave(tester);
      await show(tester);
      await frames(tester, 3);
      expect(container.read(profileAuthStateProvider), isTrue);

      await focus(tester);
    });
  });

  testWidgets('a return whose departure cannot be read still decides', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(timeoutLock);
      await open(tester, container);
      await leave(tester);

      messenger().setMockMessageHandler(
        '${pigeonPrefix}currentBrowserLockCoverDeparture',
        (message) async =>
            codec.encodeMessage(<Object?>['channel-error', 'gone', null]),
      );
      now = now.add(const Duration(minutes: 2));
      await show(tester);

      // The timeout that ran out applies. The cover has no departure to be
      // released by, and waits for the next return.
      expect(container.read(profileAuthStateProvider), isFalse);
      await frames(tester, 3);
      expect(sent.where((call) => call.startsWith('release')), isEmpty);

      await focus(tester);
    });
  });

  testWidgets('an unlock while a locked return waits lifts its cover at once', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);

      await leave(tester);
      await show(tester);
      await frames(tester, 3);
      expect(sent.last, 'release:1:true');

      // The lock screen's prompt passes while native still waits for a frame
      // of it: the browser that replaces it may draw through the image view
      // that wait is waiting out.
      await container
          .read(profileAuthStateProvider.notifier)
          .authenticate(localizedTitle: 'Unlock', localizedReason: 'Unlock');
      await tester.idle();

      expect(container.read(profileAuthStateProvider), isTrue);
      expect(sent.sublist(sent.lastIndexOf('release:1:true') + 1), [
        'arm:true',
        'release:1:false',
      ]);

      await focus(tester);
    });
  });

  testWidgets('an unlock before the locked release goes out replaces it', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);

      await leave(tester);
      await show(tester);
      await frames(tester, 1);

      await container
          .read(profileAuthStateProvider.notifier)
          .authenticate(localizedTitle: 'Unlock', localizedReason: 'Unlock');
      await tester.idle();
      await frames(tester, 3);

      expect(sent.where((call) => call.startsWith('release')), [
        'release:1:false',
      ]);

      await focus(tester);
    });
  });

  testWidgets('an unlock after leaving again releases no older departure', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);

      await leave(tester);
      await show(tester);
      await frames(tester, 3);
      expect(sent.last, 'release:1:true');

      // Gone again before the lock screen was unlocked: that departure is
      // over, and the next return decides for its own.
      await leave(tester);
      sent.clear();
      await container
          .read(profileAuthStateProvider.notifier)
          .authenticate(localizedTitle: 'Unlock', localizedReason: 'Unlock');
      await tester.idle();

      expect(sent.where((call) => call.startsWith('release')), isEmpty);
    });
  });

  testWidgets('a window that comes back to a kept engine lifts the cover', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);

      // Closed: the engine stays, and the next window reports
      // `detached → resumed`, with no `hidden → inactive` on the way.
      await leave(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await tester.idle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.idle();

      await frames(tester, 3);
      expect(container.read(profileAuthStateProvider), isFalse);
      expect(sent.last, 'release:1:true');
    });
  });

  testWidgets('the release names the departure the window came back from', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(timeoutLock);
      await open(tester, container);

      await leave(tester);
      departure = 7;
      await show(tester);

      expect(sent.last, 'release:7:false');

      await focus(tester);
    });
  });

  testWidgets('a return that finds the window gone again releases nothing', (
    tester,
  ) async {
    await onClock(() async {
      final container = containerFor(backgroundLock);
      await open(tester, container);

      await leave(tester);
      // Out of sight again by the time native answers: that departure's
      // cover waits for the return after it.
      departure = null;
      await show(tester);
      await frames(tester, 3);

      expect(sent.where((call) => call.startsWith('release')), isEmpty);

      await focus(tester);
    });
  });

  testWidgets('an until-restart unlock is never armed', (tester) async {
    await onClock(() async {
      final container = containerFor(
        AuthSettings.withDefaults(
          lockMethod: ProfileLockMethod.device,
          autoLockMode: AutoLockMode.startup,
        ),
      );
      await open(tester, container);

      await leave(tester);
      await show(tester);

      expect(container.read(profileAuthStateProvider), isTrue);
      expect(sent, isNot(contains('arm:true')));

      await focus(tester);
    });
  });
}
