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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/profile_password_dialogs.dart';
import 'package:weblibre/features/user/domain/services/profile_password.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('a check that cannot record its result denies and stays usable', (
    tester,
  ) async {
    // A profile directory that does not exist: the wrong attempt cannot be
    // written, so the gate throws instead of answering.
    final profileDir = Directory(
      p.join(Directory.systemTemp.path, 'weblibre-missing-${tester.hashCode}'),
    );
    // Any verifier fails to match without running Argon2; what matters is
    // that recording the failure throws.
    final settings = AuthSettings.withDefaults(
      lockMethod: ProfileLockMethod.password,
      passwordVerifier: 'not-a-verifier',
    );

    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showProfilePasswordDialog(
                context,
                profileDir: profileDir,
                settings: settings,
                title: 'Back up',
                departureCount: () => 0,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.text('Confirm'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(
      find.text('Could not check the password. Try again.'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    // Still open and nothing granted.
    expect(result, isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('a wrong password leaves the cursor in the field', (
    tester,
  ) async {
    // Checking disables the field, which takes its focus and the keyboard;
    // the next attempt must not need a tap first.
    final profileDir = Directory.systemTemp.createTempSync('weblibre-refocus');
    addTearDown(() => profileDir.deleteSync(recursive: true));
    // Fails to match without running Argon2, so the attempt is recorded as
    // a plain wrong password.
    final settings = AuthSettings.withDefaults(
      lockMethod: ProfileLockMethod.password,
      passwordVerifier: 'not-a-verifier',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showProfilePasswordDialog(
              context,
              profileDir: profileDir,
              settings: settings,
              title: 'Back up',
              departureCount: () => 0,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.pump();

    bool fieldHasFocus() => tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;

    // What the field being disabled for the check does. Done by hand: no
    // frame runs here while the check does, so it is never disabled.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(fieldHasFocus(), isFalse);

    await tester.runAsync(() async {
      await tester.tap(find.text('Confirm'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    // The frame that enables the field again, then the focus asked for
    // after it.
    await tester.pump();
    await tester.pump();

    expect(find.text('Wrong password'), findsOneWidget);
    expect(fieldHasFocus(), isTrue);
  });

  Future<bool?> runRightPassword(
    WidgetTester tester, {
    required int Function() departureCount,
  }) async {
    final profileDir = Directory(
      p.join(Directory.systemTemp.path, 'weblibre-missing-${tester.hashCode}'),
    );
    final verifier = await tester.runAsync(
      () => createProfilePasswordVerifier('secret'),
    );
    final settings = AuthSettings.withDefaults(
      lockMethod: ProfileLockMethod.password,
      passwordVerifier: verifier,
    );

    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showProfilePasswordDialog(
                context,
                profileDir: profileDir,
                settings: settings,
                title: 'Back up',
                departureCount: departureCount,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'secret');
    await tester.pump();

    await tester.runAsync(() async {
      await tester.tap(find.text('Confirm'));
      // Argon2 runs for real here.
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (result != null) break;
      }
    });
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('a right password authorizes', (tester) async {
    expect(await runRightPassword(tester, departureCount: () => 0), isTrue);
  });

  testWidgets('leaving the app during the check does not authorize', (
    tester,
  ) async {
    // Home pressed while Argon2 runs: the count differs between the read
    // before the check and the one after it.
    var departures = 0;
    final result = await runRightPassword(
      tester,
      departureCount: () => departures++,
    );

    expect(result, isNull);
    expect(
      find.text(
        'WebLibre was closed or switched away from during the check. '
        'Enter the password again.',
      ),
      findsOneWidget,
    );
  });
}
