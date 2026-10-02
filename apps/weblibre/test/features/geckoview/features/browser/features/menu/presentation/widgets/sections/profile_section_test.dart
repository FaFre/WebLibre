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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/sections/profile_section.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/presentation/utils/quit_browser.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Holds the settings in memory, so a test can start from any of them and see
/// what the quit flow saved.
class _FakeGeneralSettingsRepository extends GeneralSettingsRepository {
  _FakeGeneralSettingsRepository(this.settings);

  // A test fake: the test reads back what the quit flow saved.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings;

  @override
  Stream<GeneralSettings> build() => Stream.value(settings);

  @override
  Future<GeneralSettings> fetchSettings() => Future.value(settings);

  @override
  Future<void> updateSettings(UpdateGeneralSettingsFunc updateWithCurrent) {
    settings = updateWithCurrent(settings);
    return Future.value();
  }
}

/// One teardown [ExitAppCallback] call.
typedef _Exit = ({
  ProviderContainer container,
  Set<DeleteBrowsingDataType>? deleteBrowsingData,
});

/// Opens the menu sheet the way the browser does, so the quit row runs inside a
/// modal route that is torn down the moment it is tapped.
///
/// Only [MenuItemType.quitBrowser] is rendered on purpose: a section that also
/// holds Profile or Sync calls `ref.watch` during build, which initializes the
/// lazy provider container early and hides the bug this test covers.
Future<_FakeGeneralSettingsRepository> _pumpMenu(
  WidgetTester tester, {
  required List<_Exit> exits,
  GeneralSettings? settings,
}) async {
  final repository = _FakeGeneralSettingsRepository(
    settings ?? GeneralSettings.withDefaults(),
  );

  Future<void> onExit(
    ProviderContainer container, {
    Set<DeleteBrowsingDataType>? deleteBrowsingData,
  }) {
    exits.add((container: container, deleteBrowsingData: deleteBrowsingData));
    return Future.value();
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(() => repository),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => ProfileSection(
                  items: const [MenuItemType.quitBrowser],
                  onExit: onExit,
                ),
              ),
              child: const Text('open menu'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open menu'));
  await tester.pumpAndSettle();

  expect(find.byType(ProfileSection), findsOneWidget);

  return repository;
}

CheckboxListTile _checkbox(WidgetTester tester, String label) => tester
    .widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, label));

void main() {
  testWidgets('confirmed quit survives the sheet disposing the section', (
    tester,
  ) async {
    final exits = <_Exit>[];

    await _pumpMenu(tester, exits: exits);

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    // The sheet is gone — and with it the section — while the confirmation is
    // still up. Anything the quit callback needs has to have been captured
    // before the pop.
    expect(find.byType(ProfileSection), findsNothing);
    expect(find.text('Quit Browser'), findsOneWidget);
    expect(exits, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, 'Quit'));
    await tester.pumpAndSettle();

    expect(exits, hasLength(1));
    expect(exits.single.container, isNotNull);
    expect(exits.single.deleteBrowsingData, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling the confirmation does not quit', (tester) async {
    final exits = <_Exit>[];

    await _pumpMenu(tester, exits: exits);

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(exits, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long press quits without a confirmation', (tester) async {
    final exits = <_Exit>[];

    await _pumpMenu(tester, exits: exits);

    await tester.longPress(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    expect(find.text('Quit Browser'), findsNothing);
    expect(exits, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('quit deletes the data chosen for automatic deletion', (
    tester,
  ) async {
    final exits = <_Exit>[];

    await _pumpMenu(
      tester,
      exits: exits,
      settings: GeneralSettings.withDefaults(
        autoDeleteBrowsingData: {
          DeleteBrowsingDataType.tabs,
          DeleteBrowsingDataType.history,
        },
      ),
    );

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    // The confirmation says what is about to go, and the automatic deletion
    // cannot be unticked there.
    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.text('Delete browsing data'));
    await tester.pumpAndSettle();

    expect(_checkbox(tester, 'Open tabs').value, isTrue);
    expect(_checkbox(tester, 'Open tabs').onChanged, isNull);
    expect(_checkbox(tester, 'Browsing history').value, isTrue);
    expect(_checkbox(tester, 'Cookies and site data').value, isFalse);

    await tester.tap(find.widgetWithText(TextButton, 'Quit'));
    await tester.pumpAndSettle();

    expect(exits.single.deleteBrowsingData, {
      DeleteBrowsingDataType.tabs,
      DeleteBrowsingDataType.history,
    });
  });

  testWidgets('long press skips the question but still deletes', (
    tester,
  ) async {
    final exits = <_Exit>[];

    await _pumpMenu(
      tester,
      exits: exits,
      settings: GeneralSettings.withDefaults(
        autoDeleteBrowsingData: {DeleteBrowsingDataType.cookies},
      ),
    );

    await tester.longPress(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    expect(exits.single.deleteBrowsingData, {DeleteBrowsingDataType.cookies});
  });

  testWidgets('"Don\'t ask again" turns the confirmation off', (tester) async {
    final exits = <_Exit>[];

    final repository = await _pumpMenu(tester, exits: exits);

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Don't ask again"));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Quit'));
    await tester.pumpAndSettle();

    expect(repository.settings.confirmBeforeQuit, isFalse);
    expect(exits, hasLength(1));
  });

  testWidgets('cancelling keeps the confirmation on even when ticked', (
    tester,
  ) async {
    final exits = <_Exit>[];

    final repository = await _pumpMenu(tester, exits: exits);

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Don't ask again"));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(repository.settings.confirmBeforeQuit, isTrue);
    expect(exits, isEmpty);
  });

  testWidgets('quits without asking once the confirmation is off', (
    tester,
  ) async {
    final exits = <_Exit>[];

    await _pumpMenu(
      tester,
      exits: exits,
      settings: GeneralSettings.withDefaults(confirmBeforeQuit: false),
    );

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();

    expect(find.text("Don't ask again"), findsNothing);
    expect(exits, hasLength(1));
  });

  testWidgets('data picked in the dialog is deleted on this Quit only', (
    tester,
  ) async {
    final exits = <_Exit>[];

    final repository = await _pumpMenu(
      tester,
      exits: exits,
      settings: GeneralSettings.withDefaults(
        autoDeleteBrowsingData: {DeleteBrowsingDataType.history},
      ),
    );

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.text('Delete browsing data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cookies and site data'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Quit'));
    await tester.pumpAndSettle();

    expect(exits.single.deleteBrowsingData, {
      DeleteBrowsingDataType.history,
      DeleteBrowsingDataType.cookies,
    });
    // Never saved: the next Quit deletes only the automatic selection again.
    expect(repository.settings.autoDeleteBrowsingData, {
      DeleteBrowsingDataType.history,
    });
  });

  testWidgets('one-time deletion works with automatic deletion off', (
    tester,
  ) async {
    final exits = <_Exit>[];

    await _pumpMenu(tester, exits: exits);

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing selected'), findsOneWidget);

    await tester.tap(find.text('Delete browsing data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open tabs'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Quit'));
    await tester.pumpAndSettle();

    expect(exits.single.deleteBrowsingData, {DeleteBrowsingDataType.tabs});
  });

  testWidgets('cancelling drops what was picked', (tester) async {
    final exits = <_Exit>[];

    await _pumpMenu(tester, exits: exits);

    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete browsing data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open tabs'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(exits, isEmpty);

    // Asked again, the dialog starts from nothing.
    await tester.tap(find.text('open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit Browser'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing selected'), findsOneWidget);
  });
}
