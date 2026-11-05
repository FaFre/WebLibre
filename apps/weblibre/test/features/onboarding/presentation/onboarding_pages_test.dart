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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/onboarding/presentation/onboarding_step.dart';
import 'package:weblibre/features/onboarding/presentation/pages/preset.dart';
import 'package:weblibre/features/onboarding/presentation/pages/privacy_security.dart';
import 'package:weblibre/features/onboarding/presentation/pages/your_setup.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';
import 'package:weblibre/presentation/widgets/highlight_pulse.dart';

class _GeneralSettingsRepository extends GeneralSettingsRepository {
  @override
  Stream<GeneralSettings> build() =>
      Stream.value(GeneralSettings.withDefaults());
}

class _EngineSettingsRepository extends EngineSettingsRepository {
  @override
  Stream<EngineSettings> build() => Stream.value(EngineSettings.withDefaults());
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  late ProviderContainer container;
  setUp(() {
    container = ProviderContainer(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
        // A fresh onboarding: the draft is open.
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(null),
        ),
        displayedDefaultSearchBangDataProvider.overrideWith(
          (ref) => Stream.value(null),
        ),
        connectionsInUseProvider.overrideWithValue(false),
        watchContainersProvider.overrideWith((ref) => Stream.value(const [])),
        // The draft's general and engine settings, every other store at
        // its defaults.
        storedSettingsSnapshotProvider.overrideWith(
          (ref) => SettingsSnapshot(
            general: ref.watch(storedGeneralSettingsProvider),
            engine: ref.watch(storedEngineSettingsProvider),
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
  });
  tearDown(() => container.dispose());

  SetupDraftController draft() =>
      container.read(setupDraftControllerProvider.notifier);
  SetupDraft state() => container.read(setupDraftControllerProvider)!;

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    double height = 2400,
  }) async {
    tester.view.physicalSize = Size(1080, height);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: page),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('preset page', () {
    testWidgets('says the choice can be changed and what each adds', (
      tester,
    ) async {
      await pump(tester, const PresetPage());

      expect(find.text(l10n.onboarding_presetChangeLater), findsOne);
      expect(find.text(l10n.onboarding_presetAdvancedIncludes), findsOne);
      expect(find.text(l10n.onboarding_presetExpertIncludes), findsOne);
    });

    testWidgets('a change that drops shown or hidden features offers Undo', (
      tester,
    ) async {
      draft()
        ..editGeneral((s) => s.copyWith(pureBlack: true))
        ..setVisibilitySwitch(VisibilitySwitch.treeTabs, enabled: true);
      final previous = state();
      await pump(tester, const PresetPage());

      await tester.tap(find.text(l10n.onboarding_presetAdvancedTitle));
      await tester.pump();
      expect(state().preset, SetupPreset.advanced);
      // The setting stays; only the visibility edit is dropped.
      expect(state().edits, hasLength(1));
      expect(state().hasVisibilityChanges, isFalse);
      expect(find.text(l10n.onboarding_presetChangeResetVisibility), findsOne);

      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_undo));
      await tester.pumpAndSettle();
      expect(state(), same(previous));
    });

    testWidgets('a change that drops nothing says nothing', (tester) async {
      // Settings and protection choices survive a preset change.
      draft()
        ..editGeneral((s) => s.copyWith(pureBlack: true))
        ..setInstallUBlock(false)
        ..setMenuLayout(const []);
      await pump(tester, const PresetPage());

      await tester.tap(find.text(l10n.onboarding_presetExpertTitle));
      await tester.pump();
      expect(state().preset, SetupPreset.expert);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  testWidgets('showing a feature from a grayed control is a visibility '
      'edit, which a preset change drops', (tester) async {
    await pump(
      tester,
      HiddenFeatureGate.feature(
        FeatureId.syncCustomServer,
        child: SwitchListTile(
          title: const Text('Server override'),
          value: false,
          onChanged: (_) {},
        ),
      ),
    );
    // Just browsing hides the expert details the row needs.
    expect(
      container
          .read(displayedGeneralSettingsProvider)
          .isFeatureShown(FeatureId.syncCustomServer),
      isFalse,
    );

    await tester.tap(find.text('Server override'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm));
    await tester.pumpAndSettle();

    expect(state().edits.single.kind, SetupEditKind.visibility);
    expect(state().hasVisibilityChanges, isTrue);
    expect(
      container
          .read(displayedGeneralSettingsProvider)
          .isFeatureShown(FeatureId.syncCustomServer),
      isTrue,
    );
  });

  group('preset changes that suspend settings', () {
    final hardened = FingerprintOverrides.hardenedDefaults().toString();
    String? appliedOverrides() => container
        .read(displayedEngineSettingsProvider)
        .fingerprintingProtectionOverrides;

    testWidgets('a preset that hides a changed setting asks first', (
      tester,
    ) async {
      draft()
        ..selectPreset(SetupPreset.advanced)
        ..editEngine(
          (s) => s.copyWith.fingerprintingProtectionOverrides(hardened),
        );
      await pump(tester, const PresetPage());
      final averageLabel = l10n.onboarding_presetAverageTitle;
      final title = l10n.onboarding_presetChangeStopsApplyingTitle(
        averageLabel,
      );

      await tester.tap(find.text(averageLabel));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOne);
      expect(
        find.text(l10n.settings_indexAdvancedFingerprintingProtectionTitle),
        findsOne,
      );

      // Cancel keeps the preset, and the setting applying.
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(state().preset, SetupPreset.advanced);
      expect(appliedOverrides(), hardened);

      await tester.tap(find.text(averageLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboarding_presetChangeConfirm));
      await tester.pumpAndSettle();
      expect(state().preset, SetupPreset.average);
      // Kept, but not applying while Advanced privacy is hidden.
      expect(
        container
            .read(storedEngineSettingsProvider)
            .fingerprintingProtectionOverrides,
        hardened,
      );
      expect(
        appliedOverrides(),
        EngineSettings.withDefaults().fingerprintingProtectionOverrides,
      );

      // Shown again by the preset, it applies again without asking.
      await tester.tap(find.text(l10n.onboarding_presetAdvancedTitle));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(appliedOverrides(), hardened);
    });

    testWidgets("a preset's own values are not taken for changes", (
      tester,
    ) async {
      draft().selectPreset(SetupPreset.expert);
      await pump(tester, const PresetPage());

      await tester.tap(find.text(l10n.onboarding_presetAverageTitle));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(state().preset, SetupPreset.average);
    });
  });

  group('privacy & security', () {
    testWidgets('Secure DNS names the resolver only where one is used', (
      tester,
    ) async {
      draft().selectPreset(SetupPreset.expert);
      await pump(tester, const PrivacySecurityStepPage(), height: 6000);
      final engine = container.read(displayedEngineSettingsProvider);
      expect(engine.dohSettingsMode, DohSettingsMode.increased);
      final provider = BuiltInDohProviders.values
          .firstWhere((p) => p.url == engine.dohProviderUrl)
          .name;
      expect(
        find.text(
          l10n.onboarding_dohCurrentSubtitle(
            l10n.settings_increasedProtectionTitle,
            provider,
          ),
        ),
        findsOne,
      );

      // Default Protection is Gecko's native DNS: the mode alone.
      for (final (mode, label) in [
        (DohSettingsMode.geckoDefault, l10n.settings_defaultProtectionTitle),
        (DohSettingsMode.off, l10n.settings_protectionOffTitle),
      ]) {
        draft().editEngine((s) => s.copyWith.dohSettingsMode(mode));
        await tester.pumpAndSettle();
        expect(find.text(label), findsOne, reason: mode.name);
        expect(find.textContaining(provider), findsNothing, reason: mode.name);
      }
    });

    testWidgets('warns while more than one language is set', (tester) async {
      draft().selectPreset(SetupPreset.expert);
      draft().editEngine((s) => s.copyWith.locales(['en-US']));
      await pump(tester, const PrivacySecurityStepPage(), height: 6000);
      final title = find.text(l10n.onboarding_severalLanguagesTitle);
      expect(title, findsNothing);

      draft().editEngine((s) => s.copyWith.locales(['en-US', 'de-DE']));
      await tester.pumpAndSettle();
      expect(title, findsOne);
      expect(find.textContaining('en-US, de-DE'), findsOne);
      expect(find.text(l10n.onboarding_reviewLanguages), findsOne);
    });
  });

  group('your setup', () {
    // Tall enough for the whole summary, so every row can be tapped.
    Future<void> pumpYourSetup(WidgetTester tester) =>
        pump(tester, const YourSetupPage(), height: 9000);

    bool switchValue(WidgetTester tester, String title) => tester
        .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
        .value;

    Finder hiddenRow(String label) =>
        find.widgetWithText(ListTile, label).hitTestable();

    testWidgets('a hidden feature opens its switch in Show or hide features', (
      tester,
    ) async {
      await pumpYourSetup(tester);
      final treeTabs = l10n.visibilitySwitch_treeTabsLabel;
      expect(find.text(l10n.onboarding_yourSetupHiddenForNowTitle), findsOne);

      await tester.tap(hiddenRow(treeTabs));
      await tester.pumpAndSettle();

      // Show or hide features, scrolled to the switch and highlighting it.
      final tile = find.widgetWithText(SwitchListTile, treeTabs);
      expect(tile.hitTestable(), findsOne);
      expect(
        tester
            .widget<HighlightPulse>(
              find.ancestor(of: tile, matching: find.byType(HighlightPulse)),
            )
            .active,
        isTrue,
      );
      expect(switchValue(tester, treeTabs), isFalse);

      await tester.tap(tile);
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Shown now: off the hidden list.
      expect(hiddenRow(treeTabs), findsNothing);
    });

    testWidgets('a switch a goal stands for is offered by the goal alone', (
      tester,
    ) async {
      await pumpYourSetup(tester);

      // Average hides containers; their goal is off and is the only row.
      expect(hiddenRow(l10n.visibilitySwitch_containersLabel), findsNothing);
      expect(
        switchValue(tester, l10n.onboarding_goalKeepAccountsApart),
        isFalse,
      );

      // Connections and on-device AI are hidden too, but their goals ask for
      // more than showing them: a setup, AI itself. Both are listed.
      for (final (label, goal) in [
        (
          l10n.visibilitySwitch_connectionsLabel,
          l10n.onboarding_goalSetUpConnections,
        ),
        (l10n.visibilitySwitch_aiLabel, l10n.onboarding_aiUseOnDeviceTitle),
      ]) {
        expect(hiddenRow(label), findsOne, reason: label);
        expect(switchValue(tester, goal), isFalse, reason: goal);
      }

      await tester.tap(
        find.widgetWithText(
          SwitchListTile,
          l10n.onboarding_goalSetUpConnections,
        ),
      );
      await tester.pumpAndSettle();
      expect(switchValue(tester, l10n.onboarding_goalSetUpConnections), isTrue);
      expect(hiddenRow(l10n.visibilitySwitch_connectionsLabel), findsNothing);
    });

    testWidgets('Show or hide features stays when nothing is hidden', (
      tester,
    ) async {
      draft().selectPreset(SetupPreset.expert);
      await pumpYourSetup(tester);

      expect(
        find.text(l10n.onboarding_yourSetupHiddenForNowTitle),
        findsNothing,
      );
      await tester.tap(find.text(l10n.onboarding_showHideFeaturesAction));
      await tester.pumpAndSettle();
      expect(find.byType(CustomizeSetupScreen), findsOne);
      // Visibility only: no configuration rows.
      expect(find.text(l10n.onboarding_toolbarLayoutTitle), findsNothing);
      expect(find.text(l10n.onboarding_ublockInstallTitle), findsNothing);
      expect(find.text(l10n.onboarding_aiUseOnDeviceTitle), findsNothing);
    });

    testWidgets('Just browsing can change every protection choice', (
      tester,
    ) async {
      await pumpYourSetup(tester);
      expect(state().preset, SetupPreset.average);

      Finder tile(String title) => find.widgetWithText(SwitchListTile, title);
      final hardening = tile(l10n.onboarding_webEngineHardeningTitle);
      final install = tile(l10n.onboarding_ublockInstallTitle);
      final filters = tile(l10n.onboarding_ublockApplyDefaultsTitle);
      expect(find.text(l10n.onboarding_ublockInstallOnDoneSubtitle), findsOne);
      for (final finder in [hardening, install, filters]) {
        expect(tester.widget<SwitchListTile>(finder).value, isTrue);
      }

      // Keep uBlock Origin, decline its filters.
      await tester.tap(filters);
      await tester.pumpAndSettle();
      expect(state().installsUBlock, isTrue);
      expect(state().appliesOptimizedUBlockFilters, isFalse);

      await tester.tap(hardening);
      await tester.pumpAndSettle();
      expect(state().appliesHardeningBaseline, isFalse);

      // Without the install, the filters cannot be chosen.
      await tester.tap(install);
      await tester.pumpAndSettle();
      expect(state().installsUBlock, isFalse);
      expect(tester.widget<SwitchListTile>(filters).onChanged, isNull);
    });

    testWidgets('the choices lead back to their steps', (tester) async {
      final opened = <OnboardingStep>[];
      await pump(tester, YourSetupPage(onOpenStep: opened.add), height: 9000);

      await tester.tap(find.text(l10n.onboarding_searchDefaultProviderLabel));
      await tester.tap(
        find.text(l10n.onboarding_searchDefaultAutocompleteLabel),
      );
      await tester.tap(find.text(l10n.onboarding_tabBarPositionTitle));
      expect(opened, [
        OnboardingStep.search,
        OnboardingStep.search,
        OnboardingStep.layout,
      ]);
    });

    testWidgets('turning on-device AI on opens its notice under the goal, '
        'with no row added above it', (tester) async {
      final aiRow = find.widgetWithText(
        ListTile,
        l10n.visibilitySwitch_aiLabel,
      );
      final goal = find.widgetWithText(
        SwitchListTile,
        l10n.onboarding_aiUseOnDeviceTitle,
      );
      await pumpYourSetup(tester);

      // Tinkerer shows its controls but leaves it off.
      draft().selectPreset(SetupPreset.advanced);
      await tester.pumpAndSettle();
      expect(switchValue(tester, l10n.onboarding_aiUseOnDeviceTitle), isFalse);
      expect(find.text(l10n.onboarding_aiWarningTitle), findsNothing);

      await tester.tap(goal);
      await tester.pumpAndSettle();

      expect(switchValue(tester, l10n.onboarding_aiUseOnDeviceTitle), isTrue);
      expect(find.text(l10n.onboarding_aiWarningTitle), findsOne);
      expect(
        tester.getTopLeft(find.text(l10n.onboarding_aiWarningTitle)).dy,
        greaterThan(tester.getTopLeft(goal).dy),
        reason: 'the notice opens below the switch',
      );
      // No row is added above the switch the finger is on.
      expect(aiRow, findsNothing);
    });
  });
}
