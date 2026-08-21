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
 */
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_restore.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';

/// The screen the first-run "Restore from Backup" flow opens.
///
/// It used to open without a `forcedOverwriteTarget`, which asked for a *new
/// user's name* and then built one — leaving the profile the user had just
/// created empty and unreachable behind it, and dropping the lock they had just
/// configured, because a clone is a fresh `Profile` with no auth settings.
void main() {
  final target = Profile(
    id: '0199a0b1-1111-7111-8111-111111111111',
    name: 'a',
    authSettings: AuthSettings.withDefaults(authenticationRequired: true),
  );

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: screen)));
    await tester.pump();
  }

  testWidgets(
    'a fixed target replaces that profile instead of naming a new one',
    (tester) async {
      await pump(
        tester,
        ProfileRestoreScreen(
          backupFileUri: Uri.parse('content://backups/archive.weblibre'),
          forcedOverwriteTarget: target,
          adoptArchiveName: true,
        ),
      );

      expect(find.text('Restoring into "a"'), findsOneWidget);

      // The symptom that gave the bug away: a name field means a *new* user.
      expect(find.widgetWithText(TextFormField, 'Name'), findsNothing);
      // Nor a choice of which user — there is exactly one answer at first run.
      expect(find.text('Profile to replace'), findsNothing);
      expect(find.text('Create a new profile'), findsNothing);
      // The password is asked for by the maintenance process, not here.
      expect(
        find.widgetWithText(ObscurableTextField, 'Password'),
        findsNothing,
      );
    },
  );

  testWidgets('without a fixed target the clone path still offers both', (
    tester,
  ) async {
    await pump(
      tester,
      ProfileRestoreScreen(
        backupFileUri: Uri.parse('content://backups/archive.weblibre'),
      ),
    );

    expect(find.text('Create a new profile'), findsOneWidget);
    expect(find.text('Replace an existing profile'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
    // Not a `TextFormField`: the password uses the reveal-toggle field the
    // maintenance restore screen uses, so a long archive password can be checked
    // before it is submitted.
    expect(
      find.widgetWithText(ObscurableTextField, 'Password'),
      findsOneWidget,
    );
    expect(find.text('Restoring into "a"'), findsNothing);
  });
}
