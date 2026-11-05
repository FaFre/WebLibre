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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/onboarding/domain/services/preset_bindings.dart';
import 'package:weblibre/features/onboarding/presentation/utils/setup_preset_l10n.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/customize_setup.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/settings/presentation/screens/feature_control_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FakeGeneralSettingsRepository extends GeneralSettingsRepository {
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings = GeneralSettings.withDefaults();

  /// Whether writes fail, like on a full storage.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  bool failing = false;

  @override
  Stream<GeneralSettings> build() => Stream.value(settings);

  @override
  Future<GeneralSettings> fetchSettings() => Future.value(settings);

  @override
  Future<void> updateSettings(UpdateGeneralSettingsFunc updateWithCurrent) {
    if (failing) return Future.error(StateError('disk full'));
    settings = updateWithCurrent(settings);
    state = AsyncData(settings);
    return Future.value();
  }
}

BuildContext _context(WidgetTester tester) =>
    tester.element(find.byType(FeatureControlSettingsScreen));

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('withPresetVisibility', () {
    for (final preset in SetupPreset.values) {
      test('${preset.name}: sets the switches and nothing else', () {
        final before = GeneralSettings.withDefaults().copyWith(pureBlack: true);
        final after = withPresetVisibility(before, preset);

        for (final visibilitySwitch in VisibilitySwitch.values) {
          expect(
            after.isVisibilitySwitchShown(visibilitySwitch),
            presetSwitchValue(visibilitySwitch, preset),
            reason: visibilitySwitch.name,
          );
        }
        expect(after.pureBlack, isTrue);
        expect(
          after.enableLocalAiFeatures,
          before.enableLocalAiFeatures,
          reason: 'a preset value that is not a switch',
        );
        expect(
          withPresetVisibility(after, preset).toJson().toString(),
          after.toJson().toString(),
        );
      });
    }
  });

  group('revertVisibilityChange', () {
    // Everything hidden, the legacy settings included, so turning any switch
    // on can turn others on with it.
    final hidden = GeneralSettings.withDefaults().copyWith(
      visibilitySwitches: {
        for (final visibilitySwitch in VisibilitySwitch.values)
          visibilitySwitch: false,
      },
      showContainerUi: false,
      showIsolatedTabUi: false,
    );

    test('undoes everything showing a switch turned on', () {
      // The Undo after showing a feature used to turn off only the switch
      // tapped. Showing containers also turns their legacy setting on, which
      // container indicators read alone, and that stayed on.
      for (final visibilitySwitch in VisibilitySwitch.values) {
        final shown = hidden.withVisibilitySwitch(
          visibilitySwitch,
          enabled: true,
        );
        final reverted = revertVisibilityChange(
          shown,
          before: hidden,
          after: shown,
        );
        expect(
          reverted.visibilitySwitches,
          hidden.visibilitySwitches,
          reason: visibilitySwitch.name,
        );
        expect(reverted.showContainerUi, isFalse);
        expect(reverted.showIsolatedTabUi, isFalse);
      }

      final containersShown = hidden.withVisibilitySwitch(
        VisibilitySwitch.containers,
        enabled: true,
      );
      expect(containersShown.showContainerUi, isTrue);
    });

    test('keeps what changed since', () {
      final shown = hidden.withVisibilitySwitch(
        VisibilitySwitch.containers,
        enabled: true,
      );
      final reverted = revertVisibilityChange(
        shown.copyWith(pureBlack: true),
        before: hidden,
        after: shown,
      );
      expect(reverted.pureBlack, isTrue);
      expect(reverted.showContainerUi, isFalse);
    });
  });

  test('every group holds a switch', () {
    // Settings shows only the switches: a group without one would be an
    // empty heading there.
    for (final group in CustomizeGroup.values) {
      expect(
        VisibilitySwitch.values.where((s) => customizeGroupOf(s) == group),
        isNotEmpty,
        reason: group.name,
      );
    }
  });

  group('screen', () {
    late _FakeGeneralSettingsRepository repository;

    Future<void> pumpScreen(
      WidgetTester tester, {
      bool connectionsInUse = false,
      bool failing = false,
      GeneralSettings? initial,
      EngineSettings? engine,
      List<ContainerDataWithCount> containers = const [],
      bool strictContainers = false,
    }) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      repository = _FakeGeneralSettingsRepository()
        ..failing = failing
        ..settings = initial ?? GeneralSettings.withDefaults();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // No onboarding owed: no draft, the displayed layer is the live one.
            completedOnboardingRevisionProvider.overrideWithValue(
              const AsyncData(OnboardingRepository.targetRevision),
            ),
            generalSettingsRepositoryProvider.overrideWith(() => repository),
            connectionsInUseProvider.overrideWithValue(connectionsInUse),
            watchContainersProvider.overrideWith(
              (ref) => Stream.value(containers),
            ),
            // The live general settings with every other store at its
            // defaults, and [engine] for the engine settings.
            storedSettingsSnapshotProvider.overrideWith(
              (ref) => SettingsSnapshot(
                general: ref.watch(storedGeneralSettingsProvider),
                engine: engine ?? EngineSettings.withDefaults(),
                gestures: GestureSettings.withDefaults(),
                keyboardShortcuts: KeyboardShortcutSettings.withDefaults(),
                proxyDiagnostics: ProxyDiagnosticsSettings.withDefaults(),
                toolbars: {
                  for (final location in ToolbarConfigLocation.values)
                    location: defaultToolbarButtonConfigsFor(location).value,
                },
                menu: defaultMenuLayout,
                strictContainers: strictContainers,
                appLinkContainers: false,
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FeatureControlSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapConnections(WidgetTester tester) async {
      final tile = find.widgetWithText(
        SwitchListTile,
        l10n.visibilitySwitch_connectionsLabel,
      );
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    bool shown(VisibilitySwitch visibilitySwitch) =>
        repository.settings.isVisibilitySwitchShown(visibilitySwitch);

    testWidgets('says what hiding does', (tester) async {
      await pumpScreen(tester);
      expect(find.text(l10n.settings_featureControlIntro), findsOne);
    });

    testWidgets('every preset is a full-width row with its description', (
      tester,
    ) async {
      await pumpScreen(tester);

      final card = find.ancestor(
        of: find.text(l10n.settings_featureControlApplyPresetTitle),
        matching: find.byType(SetupSection),
      );
      final fullWidth = tester.getSize(
        find.descendant(of: card, matching: find.byType(Card)),
      );
      final featureCard = tester.getSize(
        find
            .ancestor(
              of: find.text(l10n.visibilitySwitch_containersLabel),
              matching: find.byType(Card),
            )
            .first,
      );
      expect(fullWidth.width, featureCard.width);

      // The explanation sits under the heading, outside the card, which
      // holds only the preset rows.
      final supporting = find.descendant(
        of: card,
        matching: find.text(l10n.settings_featureControlApplyPresetSubtitle),
      );
      expect(supporting, findsOne);
      expect(
        find.ancestor(of: supporting, matching: find.byType(Card)),
        findsNothing,
      );

      for (final preset in SetupPreset.values) {
        expect(
          find.descendant(
            of: card,
            matching: find.widgetWithText(
              ListTile,
              preset.label(_context(tester)),
            ),
          ),
          findsOne,
        );
        expect(find.text(preset.description(_context(tester))), findsOne);
      }
    });

    testWidgets('a preset lists what changes before changing it', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.text(l10n.onboarding_presetAverageTitle).first);
      await tester.pumpAndSettle();
      expect(
        find.text(
          l10n.settings_featureControlApplyPresetDialogTitle(
            l10n.onboarding_presetAverageTitle,
          ),
        ),
        findsOne,
      );
      expect(find.text(l10n.settings_featureControlFeaturesToHide), findsOne);
      // Everything is shown already: nothing to show.
      expect(
        find.text(l10n.settings_featureControlFeaturesToShow),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.visibilitySwitch_containersLabel),
        ),
        findsOne,
      );

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(shown(VisibilitySwitch.containers), isTrue);

      await tester.tap(find.text(l10n.onboarding_presetAverageTitle).first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(l10n.settings_featureControlApplyPresetConfirm),
      );
      await tester.pumpAndSettle();
      for (final visibilitySwitch in VisibilitySwitch.values) {
        expect(
          shown(visibilitySwitch),
          presetSwitchValue(visibilitySwitch, SetupPreset.average),
          reason: visibilitySwitch.name,
        );
      }

      // Nothing set up was hidden, so nothing to reassure about.
      expect(find.text(l10n.settings_featureControlHiddenInUse), findsNothing);

      await tester.tap(find.text(l10n.onboarding_presetAverageTitle).first);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text(
          l10n.settings_featureControlApplyPresetUnchanged(
            l10n.onboarding_presetAverageTitle,
          ),
        ),
        findsOne,
      );
    });

    testWidgets('hiding connections in use says they keep working', (
      tester,
    ) async {
      await pumpScreen(tester, connectionsInUse: true);
      await tapConnections(tester);

      expect(shown(VisibilitySwitch.connections), isFalse);
      expect(find.text(l10n.settings_featureControlHiddenInUse), findsOne);
    });

    testWidgets('hiding something not in use says nothing', (tester) async {
      await pumpScreen(tester);

      await tapConnections(tester);

      expect(shown(VisibilitySwitch.connections), isFalse);
      expect(find.text(l10n.settings_featureControlHiddenInUse), findsNothing);
    });

    // A write that fails (full storage) is reported, and never confirmed as
    // done: the snackbar about what keeps working would be untrue.
    testWidgets('a switch that could not be saved says so', (tester) async {
      await pumpScreen(tester, connectionsInUse: true, failing: true);

      await tapConnections(tester);

      expect(shown(VisibilitySwitch.connections), isTrue);
      expect(find.text(l10n.onboarding_customizeSaveFailed), findsOne);
      expect(find.text(l10n.settings_featureControlHiddenInUse), findsNothing);
    });

    testWidgets('a preset that could not be saved says so', (tester) async {
      await pumpScreen(tester, connectionsInUse: true, failing: true);

      await tester.tap(find.text(l10n.onboarding_presetAverageTitle).first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(l10n.settings_featureControlApplyPresetConfirm),
      );
      await tester.pumpAndSettle();

      expect(shown(VisibilitySwitch.connections), isTrue);
      expect(find.text(l10n.onboarding_customizeSaveFailed), findsOne);
      expect(find.text(l10n.settings_featureControlHiddenInUse), findsNothing);
    });

    group('changed settings', () {
      final withoutJavaScript = EngineSettings.withDefaults(
        javascriptEnabled: false,
      );

      Future<void> tapSwitch(WidgetTester tester, String label) async {
        final tile = find.widgetWithText(SwitchListTile, label);
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }

      testWidgets('hiding a feature asks first, listing what stops '
          'applying', (tester) async {
        await pumpScreen(tester, engine: withoutJavaScript);

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        expect(
          find.text(
            l10n.visibilitySwitch_hideWarningTitle(
              l10n.visibilitySwitch_expertDetailsLabel,
            ),
          ),
          findsOne,
        );
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(l10n.settings_javascriptTitle),
          ),
          findsOne,
        );

        await tester.tap(find.text(l10n.common_cancel));
        await tester.pumpAndSettle();
        expect(shown(VisibilitySwitch.expertDetails), isTrue);

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        await tester.tap(find.text(l10n.visibilitySwitch_hideWarningConfirm));
        await tester.pumpAndSettle();
        expect(shown(VisibilitySwitch.expertDetails), isFalse);
      });

      testWidgets('hiding a feature with nothing changed does not ask', (
        tester,
      ) async {
        await pumpScreen(tester);

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        expect(find.byType(AlertDialog), findsNothing);
        expect(shown(VisibilitySwitch.expertDetails), isFalse);
      });

      Finder dialogButton(String label) => find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(label),
      );

      testWidgets('showing it again does not ask; a snackbar says what '
          'applies again and can undo it', (tester) async {
        await pumpScreen(
          tester,
          engine: withoutJavaScript,
          initial: GeneralSettings.withDefaults().withVisibilitySwitch(
            VisibilitySwitch.expertDetails,
            enabled: false,
          ),
        );

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        expect(find.byType(AlertDialog), findsNothing);
        expect(shown(VisibilitySwitch.expertDetails), isTrue);
        expect(
          find.text(l10n.settings_featureControlShownApplyingAgain),
          findsOne,
        );

        await tester.tap(find.text(l10n.common_undo));
        await tester.pumpAndSettle();
        expect(shown(VisibilitySwitch.expertDetails), isFalse);
      });

      testWidgets('showing a feature with nothing changed does not ask', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          initial: GeneralSettings.withDefaults().withVisibilitySwitch(
            VisibilitySwitch.expertDetails,
            enabled: false,
          ),
        );

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        expect(find.byType(AlertDialog), findsNothing);
        expect(shown(VisibilitySwitch.expertDetails), isTrue);
      });

      testWidgets('a change the engine reads at start offers a restart, '
          'hiding and showing alike', (tester) async {
        await pumpScreen(
          tester,
          engine: EngineSettings.withDefaults(fissionEnabled: false),
        );

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        await tester.tap(find.text(l10n.visibilitySwitch_hideWarningConfirm));
        await tester.pumpAndSettle();
        expect(shown(VisibilitySwitch.expertDetails), isFalse);
        expect(find.text(l10n.user_quitBrowserTitle), findsOne);

        await tester.tap(find.text(l10n.common_cancel));
        await tester.pumpAndSettle();

        // Showing asks nothing first; the restart is the one prompt, with
        // no snackbar stacked under it.
        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        expect(shown(VisibilitySwitch.expertDetails), isTrue);
        expect(find.text(l10n.user_quitBrowserTitle), findsOne);
        expect(
          find.text(l10n.settings_featureControlShownApplyingAgain),
          findsNothing,
        );
        await tester.tap(find.text(l10n.common_cancel));
        await tester.pumpAndSettle();
      });

      testWidgets('hiding a feature in use with changed settings says in '
          'the dialog what keeps working, not in a snackbar', (tester) async {
        // A container exists (set up, keeps working) and strict mode is on
        // (a changed setting that stops applying).
        await pumpScreen(
          tester,
          containers: [
            ContainerDataWithCount(
              id: 'work',
              name: 'Work',
              color: Colors.blue,
              orderKey: 'work',
              metadata: ContainerMetadata.withDefaults(
                contextualIdentity: 'work',
              ),
              tabCount: 1,
            ),
          ],
          strictContainers: true,
        );

        await tapSwitch(tester, l10n.visibilitySwitch_containersLabel);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(l10n.settings_featureControlKeepsWorking),
          ),
          findsOne,
        );
        await tester.tap(find.text(l10n.visibilitySwitch_hideWarningConfirm));
        await tester.pumpAndSettle();
        expect(shown(VisibilitySwitch.containers), isFalse);
        expect(
          find.text(l10n.settings_featureControlHiddenInUse),
          findsNothing,
        );
      });

      testWidgets('a change applied while running offers no restart', (
        tester,
      ) async {
        await pumpScreen(tester, engine: withoutJavaScript);

        await tapSwitch(tester, l10n.visibilitySwitch_expertDetailsLabel);
        await tester.tap(find.text(l10n.visibilitySwitch_hideWarningConfirm));
        await tester.pumpAndSettle();
        expect(find.text(l10n.user_quitBrowserTitle), findsNothing);
      });

      testWidgets('a preset lists the changes it stops from applying', (
        tester,
      ) async {
        await pumpScreen(tester, engine: withoutJavaScript);

        await tester.tap(find.text(l10n.onboarding_presetAverageTitle).first);
        await tester.pumpAndSettle();
        expect(find.text(l10n.visibilitySwitch_stopsApplyingTitle), findsOne);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(l10n.settings_javascriptTitle),
          ),
          findsOne,
        );
      });

      testWidgets('a preset lists the changes it makes apply again', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          engine: withoutJavaScript,
          initial: GeneralSettings.withDefaults().withVisibilitySwitch(
            VisibilitySwitch.expertDetails,
            enabled: false,
          ),
        );

        await tester.tap(find.text(l10n.onboarding_presetExpertTitle).first);
        await tester.pumpAndSettle();
        expect(find.text(l10n.visibilitySwitch_appliesAgainTitle), findsOne);
        expect(dialogButton(l10n.settings_javascriptTitle), findsOne);

        await tester.tap(
          dialogButton(l10n.settings_featureControlApplyPresetConfirm),
        );
        await tester.pumpAndSettle();
        expect(shown(VisibilitySwitch.expertDetails), isTrue);
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    testWidgets('a preset that hides connections in use says so', (
      tester,
    ) async {
      await pumpScreen(tester, connectionsInUse: true);

      await tester.tap(find.text(l10n.onboarding_presetAverageTitle).first);
      await tester.pumpAndSettle();
      // In the dialog, not in a snackbar afterwards.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.settings_featureControlKeepsWorking),
        ),
        findsOne,
      );
      await tester.tap(
        find.text(l10n.settings_featureControlApplyPresetConfirm),
      );
      await tester.pumpAndSettle();

      expect(shown(VisibilitySwitch.connections), isFalse);
      expect(find.text(l10n.settings_featureControlHiddenInUse), findsNothing);
      expect(find.text(l10n.onboarding_customizeSaveFailed), findsNothing);
    });
  });
}
