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
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/reveal_feature.dart';

class _FakeGeneralSettingsRepository extends GeneralSettingsRepository {
  _FakeGeneralSettingsRepository(this.settings);

  // A test fake: the test reads back what the reveal turned on.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings;

  /// Fails every write, as a full disk would.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  bool failWrites = false;

  @override
  Stream<GeneralSettings> build() => Stream.value(settings);

  @override
  Future<GeneralSettings> fetchSettings() => Future.value(settings);

  @override
  Future<void> updateSettings(UpdateGeneralSettingsFunc updateWithCurrent) {
    if (failWrites) return Future.error(StateError('disk full'));
    settings = updateWithCurrent(settings);
    state = AsyncData(settings);
    return Future.value();
  }
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  late ProviderContainer container;
  late _FakeGeneralSettingsRepository repository;
  // What the last trigger's askToRevealFeature returned.
  bool? revealed;

  // Manual connection setup needs Connections and Expert settings. [engine]
  // is what is stored: changes that Expert settings, hidden, stop applying.
  Future<void> pumpTrigger(
    WidgetTester tester, {
    bool connectionsShown = false,
    EngineSettings? engine,
  }) async {
    final Storage<String, String> storage = Storage.inMemory();
    revealed = null;
    repository = _FakeGeneralSettingsRepository(
      GeneralSettings.withDefaults()
          .withVisibilitySwitch(
            VisibilitySwitch.connections,
            enabled: connectionsShown,
          )
          .withVisibilitySwitch(VisibilitySwitch.expertDetails, enabled: false),
    );
    container = ProviderContainer(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
        generalSettingsRepositoryProvider.overrideWith(() => repository),
        profileSettingsSnapshotProvider.overrideWith(
          (ref) => SettingsSnapshot(
            general: repository.settings,
            engine: engine ?? EngineSettings.withDefaults(),
            gestures: GestureSettings.withDefaults(),
            keyboardShortcuts: KeyboardShortcutSettings.withDefaults(),
            proxyDiagnostics: ProxyDiagnosticsSettings.withDefaults(),
            toolbars: {
              for (final location in ToolbarConfigLocation.values)
                location: defaultToolbarButtonConfigsFor(location).value,
            },
            menu: defaultMenuLayout,
            strictContainers: false,
            appLinkContainers: false,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
                    revealed = await askToRevealFeature(
                      context,
                      container,
                      FeatureId.connectionsManualProxyConfig,
                    );
                  },
                  child: const Text('trigger'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool shown(VisibilitySwitch visibilitySwitch) =>
      repository.settings.isVisibilitySwitchShown(visibilitySwitch);

  testWidgets('a feature behind two hidden switches names both', (
    tester,
  ) async {
    // "Show" turns both on, so the dialog has to say so, and "Cancel"
    // declines both.
    await pumpTrigger(tester);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.visibilitySwitch_revealTitle(2)), findsOne);
    expect(find.text(l10n.visibilitySwitch_revealIntro(2)), findsOne);
    expect(find.text(l10n.visibilitySwitch_connectionsLabel), findsOne);
    expect(find.text(l10n.visibilitySwitch_expertDetailsLabel), findsOne);
    expect(find.text(l10n.visibilitySwitch_revealOutcome(2)), findsOne);

    await tester.tap(find.text(l10n.common_cancel));
    await tester.pumpAndSettle();

    expect(container.read(declinedVisibilityRevealsProvider), {
      VisibilitySwitch.connections,
      VisibilitySwitch.expertDetails,
    });
  });

  testWidgets('a "Show" that cannot be saved says so and stays hidden', (
    tester,
  ) async {
    await pumpTrigger(tester, connectionsShown: true);
    repository.failWrites = true;

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm));
    await tester.pumpAndSettle();

    // The binding's action must not run with its feature still hidden.
    expect(revealed, isFalse);
    expect(shown(VisibilitySwitch.expertDetails), isFalse);
    expect(find.text(l10n.visibilitySwitch_showFailed), findsOne);
  });

  testWidgets('dismissing the dialog is no answer and asks again', (
    tester,
  ) async {
    await pumpTrigger(tester);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    // Back, like a tap outside the dialog, closes it without an answer.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(l10n.visibilitySwitch_revealConfirm), findsNothing);
    expect(container.read(declinedVisibilityRevealsProvider), isEmpty);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    expect(find.text(l10n.visibilitySwitch_revealTitle(2)), findsOne);
  });

  testWidgets('one hidden feature is named and described as a feature', (
    tester,
  ) async {
    // Someone who never chose to hide it may not know what it is: the
    // dialog says it is a feature, and what that feature does.
    await pumpTrigger(tester, connectionsShown: true);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.visibilitySwitch_revealTitle(1)), findsOne);
    expect(find.text(l10n.visibilitySwitch_revealIntro(1)), findsOne);
    expect(find.text(l10n.visibilitySwitch_expertDetailsLabel), findsOne);
    expect(find.text(l10n.visibilitySwitch_expertDetailsDescription), findsOne);
    expect(find.text(l10n.visibilitySwitch_connectionsLabel), findsNothing);

    await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm));
    await tester.pumpAndSettle();
    expect(shown(VisibilitySwitch.expertDetails), isTrue);
  });

  testWidgets('after a decline the note offers Show', (tester) async {
    await pumpTrigger(tester);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.common_cancel));
    await tester.pumpAndSettle();

    // Asked once: the next time only the note appears, with Show on it.
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    expect(find.text(l10n.visibilitySwitch_revealTitle(2)), findsNothing);
    expect(find.text(l10n.visibilitySwitch_stillHiddenNote), findsOne);

    await tester.tap(
      find.widgetWithText(SnackBarAction, l10n.visibilitySwitch_revealConfirm),
    );
    await tester.pumpAndSettle();

    expect(shown(VisibilitySwitch.connections), isTrue);
    expect(shown(VisibilitySwitch.expertDetails), isTrue);
    expect(container.read(declinedVisibilityRevealsProvider), isEmpty);
  });

  testWidgets("a note's Show that cannot be saved keeps the decline", (
    tester,
  ) async {
    await pumpTrigger(tester);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.common_cancel));
    await tester.pumpAndSettle();

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    repository.failWrites = true;
    await tester.tap(
      find.widgetWithText(SnackBarAction, l10n.visibilitySwitch_revealConfirm),
    );
    await tester.pumpAndSettle();

    expect(shown(VisibilitySwitch.connections), isFalse);
    expect(shown(VisibilitySwitch.expertDetails), isFalse);
    expect(find.text(l10n.visibilitySwitch_showFailed), findsOne);
    // Still hidden, still declined: the next binding gets the note again,
    // not the full dialog.
    expect(container.read(declinedVisibilityRevealsProvider), {
      VisibilitySwitch.connections,
      VisibilitySwitch.expertDetails,
    });

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    expect(find.text(l10n.visibilitySwitch_revealTitle(2)), findsNothing);
  });

  group('changes that apply again are listed before Show', () {
    final restartNote = find.text(
      l10n.visibilitySwitch_takesEffectAfterRestart,
    );

    testWidgets('a JavaScript change alone, with no restart', (tester) async {
      // Not read at engine start, so nothing would offer a restart; it is
      // listed all the same.
      await pumpTrigger(
        tester,
        connectionsShown: true,
        engine: EngineSettings.withDefaults(javascriptEnabled: false),
      );

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.visibilitySwitch_revealResumesIntro(1)), findsOne);
      expect(find.text(l10n.settings_javascriptTitle), findsOne);
      expect(restartNote, findsNothing);

      await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm));
      await tester.pumpAndSettle();
      expect(shown(VisibilitySwitch.expertDetails), isTrue);
      expect(find.text(l10n.user_quitBrowserTitle), findsNothing);
    });

    testWidgets('changes now and after a restart, marked apart', (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        connectionsShown: true,
        engine: EngineSettings.withDefaults(
          javascriptEnabled: false,
        ).copyWith.userAgent('Custom/1.0'),
      );

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.settings_javascriptTitle), findsOne);
      expect(find.text(l10n.settings_userAgentLabel), findsOne);
      // Only the user agent waits for a restart.
      expect(restartNote, findsOne);
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, l10n.settings_userAgentLabel),
          matching: restartNote,
        ),
        findsOne,
      );

      // Shown, the restart is offered.
      await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm));
      await tester.pumpAndSettle();
      expect(shown(VisibilitySwitch.expertDetails), isTrue);
      expect(find.text(l10n.user_quitBrowserTitle), findsOne);
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
    });

    testWidgets("the note's Show asks first when changes would apply", (
      tester,
    ) async {
      await pumpTrigger(
        tester,
        connectionsShown: true,
        engine: EngineSettings.withDefaults(javascriptEnabled: false),
      );

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          SnackBarAction,
          l10n.visibilitySwitch_revealConfirm,
        ),
      );
      await tester.pumpAndSettle();

      // Not shown yet: the dialog lists what would apply again.
      expect(shown(VisibilitySwitch.expertDetails), isFalse);
      expect(find.text(l10n.settings_javascriptTitle), findsOne);

      // Cancel there leaves it hidden, and is no new decline.
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(shown(VisibilitySwitch.expertDetails), isFalse);

      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          SnackBarAction,
          l10n.visibilitySwitch_revealConfirm,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm).last);
      await tester.pumpAndSettle();
      expect(shown(VisibilitySwitch.expertDetails), isTrue);
      expect(container.read(declinedVisibilityRevealsProvider), isEmpty);
    });
  });
}
