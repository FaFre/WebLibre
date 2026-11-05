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
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/remembered_prompt.dart';

class _FakeGeneralSettingsRepository extends GeneralSettingsRepository {
  _FakeGeneralSettingsRepository(this.settings);

  // A test fake: the test reads back what the prompt remembered.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings;

  @override
  Stream<GeneralSettings> build() => Stream.value(settings);

  @override
  Future<GeneralSettings> fetchSettings() => Future.value(settings);

  @override
  Future<void> updateSettings(UpdateGeneralSettingsFunc updateWithCurrent) {
    settings = updateWithCurrent(settings);
    state = AsyncData(settings);
    return Future.value();
  }
}

void main() {
  late _FakeGeneralSettingsRepository repository;
  late bool? lastResult;

  Future<void> pumpPromptButton(
    WidgetTester tester, {
    GeneralSettings? settings,
  }) async {
    repository = _FakeGeneralSettingsRepository(
      settings ?? GeneralSettings.withDefaults(),
    );
    lastResult = null;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          generalSettingsRepositoryProvider.overrideWith(() => repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              // Loads the settings, as the app has by the time anything asks.
              ref.watch(generalSettingsWithDefaultsProvider);
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    lastResult = await confirmUnlessRemembered(
                      context,
                      ref.read,
                      RememberedPrompt.closeAllTabs,
                      title: 'Close all tabs?',
                      content: 'Body',
                      confirmLabel: 'Close',
                    );
                  },
                  child: const Text('ask'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('ticking "Don\'t ask again" remembers the go-ahead', (
    tester,
  ) async {
    await pumpPromptButton(tester);

    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    expect(find.text('Close all tabs?'), findsOneWidget);

    await tester.tap(find.text("Don't ask again"));
    await tester.pump();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(lastResult, isTrue);
    expect(
      repository.settings.rememberedAnswer<PromptConfirmation>(
        RememberedPrompt.closeAllTabs,
      ),
      PromptConfirmation.confirmed,
    );

    // The next time goes ahead without a dialog.
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    expect(find.text('Close all tabs?'), findsNothing);
    expect(lastResult, isTrue);
  });

  testWidgets('remembers the answer when the asking widget is gone', (
    tester,
  ) async {
    repository = _FakeGeneralSettingsRepository(GeneralSettings.withDefaults());
    lastResult = null;
    final showAsker = ValueNotifier(true);
    addTearDown(showAsker.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          generalSettingsRepositoryProvider.overrideWith(() => repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              ref.watch(generalSettingsWithDefaultsProvider);
              return Scaffold(
                body: ValueListenableBuilder(
                  valueListenable: showAsker,
                  builder: (context, show, _) => show
                      // Like a menu item: its own ref, gone once the dialog
                      // closes the menu.
                      ? Consumer(
                          builder: (context, ref, _) => TextButton(
                            onPressed: () async {
                              lastResult = await confirmUnlessRemembered(
                                context,
                                ref.read,
                                RememberedPrompt.closeAllTabs,
                                title: 'Close all tabs?',
                                content: 'Body',
                                confirmLabel: 'Close',
                              );
                            },
                            child: const Text('ask'),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    showAsker.value = false;
    await tester.pump();
    expect(find.text('ask'), findsNothing);

    await tester.tap(find.text("Don't ask again"));
    await tester.pump();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(lastResult, isTrue);
    expect(
      repository.settings.rememberedAnswer<PromptConfirmation>(
        RememberedPrompt.closeAllTabs,
      ),
      PromptConfirmation.confirmed,
    );
  });

  testWidgets('cancelling with the box ticked remembers nothing', (
    tester,
  ) async {
    await pumpPromptButton(tester);

    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Don't ask again"));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(lastResult, isFalse);
    expect(repository.settings.rememberedPrompts, isEmpty);
  });

  testWidgets('answering without the box ticked asks again next time', (
    tester,
  ) async {
    await pumpPromptButton(tester);

    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(lastResult, isTrue);
    expect(repository.settings.rememberedPrompts, isEmpty);

    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    expect(find.text('Close all tabs?'), findsOneWidget);
  });
}
