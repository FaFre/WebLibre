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
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/presentation/widgets/auth_gate.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _NoOtherProfiles extends ProfileRepository {
  @override
  Future<List<Profile>> build() async => const [];
}

/// The password field asks for the keyboard only once the window has focus:
/// Android takes down a keyboard asked for before that.
void main() {
  const pigeonPrefix =
      'dev.flutter.pigeon.flutter_mozilla_components.GeckoProfileApi.';
  const codec = GeckoProfileApi.pigeonChannelCodec;
  const pigeonMethods = [
    'getSharedProfileUnlock',
    'setBrowserLockCover',
    'currentBrowserLockCoverDeparture',
    'releaseBrowserLockCover',
  ];

  TestDefaultBinaryMessenger messenger() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    // No shared unlock, no departure: every call answers null.
    for (final method in pigeonMethods) {
      messenger().setMockMessageHandler(
        '$pigeonPrefix$method',
        (message) async => codec.encodeMessage(<Object?>[null]),
      );
    }
  });

  tearDown(() {
    for (final method in pigeonMethods) {
      messenger().setMockMessageHandler('$pigeonPrefix$method', null);
    }
  });

  Future<void> pumpLockScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedProfileProvider.overrideWith(
            (ref) => Profile(
              id: '0190a000-0000-7000-8000-000000000001',
              name: 'Work',
              authSettings: AuthSettings.withDefaults(
                lockMethod: ProfileLockMethod.password,
              ),
            ),
          ),
          profileRepositoryProvider.overrideWith(_NoOtherProfiles.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LockScreen(),
        ),
      ),
    );
    // The profile resolves, the field is built, and the screen's own start
    // (shared unlock, then the prompt a password profile refuses) runs: it is
    // queued as a timer.
    for (var i = 0; i < 3; i++) {
      await tester.pump(Duration.zero);
    }
  }

  bool fieldFocused(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;

  testWidgets('built while the window comes back, the field waits for the '
      'window to have focus', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await pumpLockScreen(tester);
    await tester.pump();

    expect(fieldFocused(tester), isFalse);
    expect(tester.testTextInput.isVisible, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(fieldFocused(tester), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('built in a focused window, the field takes the focus at once', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpLockScreen(tester);
    await tester.pump();

    expect(fieldFocused(tester), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('the focus is taken once, not again on every return', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpLockScreen(tester);
    await tester.pump();
    expect(fieldFocused(tester), isTrue);

    // Someone dismisses it and the window loses and regains focus, e.g. for
    // the notification shade.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(fieldFocused(tester), isFalse);
  });
}
