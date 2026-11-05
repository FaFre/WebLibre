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
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/onboarding/domain/providers.dart';
import 'package:weblibre/features/onboarding/presentation/onboarding.dart';
import 'package:weblibre/features/onboarding/presentation/onboarding_step.dart';
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
        // No bang database: the search step shows no chips.
        bangListProvider.overrideWith((ref, _) => Stream.value(const [])),
        displayedDefaultSearchBangDataProvider.overrideWith(
          (ref) => Stream.value(null),
        ),
        toolbarButtonConfigsProvider.overrideWith(
          (ref, location) =>
              Stream.value(defaultToolbarButtonConfigsFor(location).value),
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

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Steps change without animation, one page built at a time.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the fresh onboarding', () {
    Future<void> pumpOnboarding(WidgetTester tester) async {
      await pumpApp(
        tester,
        const OnboardingScreen(
          currentRevision: -1,
          targetRevision: OnboardingRepository.targetRevision,
        ),
      );
      // Next stays disabled on Welcome until the EULA is accepted.
      container.read(eulaAcceptedProvider.notifier).accept(true);
      await tester.pumpAndSettle();
    }

    int pageCount(WidgetTester tester) => tester
        .widget<SmoothPageIndicator>(find.byType(SmoothPageIndicator))
        .count;

    int currentPage(WidgetTester tester) => tester
        .widget<PageView>(find.byType(PageView))
        .controller!
        .page!
        .round();

    Future<void> next(WidgetTester tester, {int times = 1}) async {
      for (var i = 0; i < times; i++) {
        await tester.tap(find.text(l10n.onboarding_actionNext));
        await tester.pumpAndSettle();
      }
    }

    Finder onScreen(String text) => find.text(text).hitTestable();

    Finder reviewRow() =>
        find.text(l10n.onboarding_privacySecurityRowSubtitle).hitTestable();

    ScrollPosition yourSetupScroll(WidgetTester tester) => tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(OnboardingStep.yourSetup.pageKey),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position;

    testWidgets('has six steps for Just browsing, seven for a preset that '
        'shows Advanced privacy', (tester) async {
      await pumpOnboarding(tester);
      expect(pageCount(tester), 6);

      draft().selectPreset(SetupPreset.advanced);
      await tester.pumpAndSettle();
      expect(pageCount(tester), 7);

      await next(tester, times: 4);
      expect(onScreen(l10n.onboarding_customizeGroupPrivacy), findsOne);

      // It follows the preset, not the setting.
      draft().setVisibilitySwitch(
        VisibilitySwitch.privacyAdvanced,
        enabled: false,
      );
      await tester.pumpAndSettle();
      expect(pageCount(tester), 7);
    });

    testWidgets('Advanced privacy shown on Your setup leaves the steps alone '
        'and opens Privacy & security from there', (tester) async {
      await pumpOnboarding(tester);
      await next(tester, times: 4);
      expect(onScreen(l10n.onboarding_yourSetupTitle), findsOne);
      expect(currentPage(tester), 4);
      expect(reviewRow(), findsNothing);

      // Scrolled down a little: the page stays as it is.
      await tester.drag(
        find.byKey(OnboardingStep.yourSetup.pageKey),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      final scrolled = yourSetupScroll(tester).pixels;
      expect(scrolled, greaterThan(0));

      draft().setVisibilitySwitch(
        VisibilitySwitch.privacyAdvanced,
        enabled: true,
      );
      await tester.pumpAndSettle();

      expect(pageCount(tester), 6);
      expect(currentPage(tester), 4);
      expect(yourSetupScroll(tester).pixels, scrolled);

      await tester.ensureVisible(
        find.text(l10n.onboarding_privacySecurityRowSubtitle),
      );
      await tester.pumpAndSettle();
      await tester.tap(reviewRow());
      await tester.pumpAndSettle();
      // Pushed over the flow, named by its app bar.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.onboarding_customizeGroupPrivacy),
        ),
        findsOne,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(currentPage(tester), 4);
      expect(reviewRow(), findsOne);
    });

    testWidgets('Advanced privacy hidden on Your setup keeps the step', (
      tester,
    ) async {
      await pumpOnboarding(tester);
      draft().selectPreset(SetupPreset.advanced);
      await tester.pumpAndSettle();
      await next(tester, times: 5);
      expect(currentPage(tester), 5);
      expect(onScreen(l10n.onboarding_yourSetupTitle), findsOne);

      draft().setVisibilitySwitch(
        VisibilitySwitch.privacyAdvanced,
        enabled: false,
      );
      await tester.pumpAndSettle();

      expect(pageCount(tester), 7);
      expect(currentPage(tester), 5);
      expect(onScreen(l10n.onboarding_yourSetupTitle), findsOne);
      expect(
        find.text(l10n.onboarding_privacySecurityRowSubtitle),
        findsNothing,
      );

      await tester.tap(find.text(l10n.onboarding_actionPrevious));
      await tester.pumpAndSettle();
      expect(onScreen(l10n.onboarding_customizeGroupPrivacy), findsOne);
    });

    testWidgets('the choices on Your setup lead back to their steps', (
      tester,
    ) async {
      await pumpOnboarding(tester);
      await next(tester, times: 4);

      await tester.tap(find.text(l10n.onboarding_tabBarPositionTitle));
      await tester.pumpAndSettle();
      expect(onScreen(l10n.onboarding_layoutStepTitle), findsOne);

      await next(tester);
      await tester.tap(find.text(l10n.onboarding_searchDefaultProviderLabel));
      await tester.pumpAndSettle();
      expect(onScreen(l10n.onboarding_searchStepTitle), findsOne);
    });
  });

  group('show or hide features', () {
    testWidgets('hiding Advanced privacy over a changed setting warns, and '
        'the setting applies again once shown', (tester) async {
      final hardened = FingerprintOverrides.hardenedDefaults().toString();
      draft()
        ..selectPreset(SetupPreset.advanced)
        ..editEngine(
          (s) => s.copyWith.fingerprintingProtectionOverrides(hardened),
        );
      String? applied() => container
          .read(displayedEngineSettingsProvider)
          .fingerprintingProtectionOverrides;
      expect(applied(), hardened);

      await pumpApp(tester, const CustomizeSetupScreen());
      final tile = find.widgetWithText(
        SwitchListTile,
        l10n.visibilitySwitch_privacyAdvancedLabel,
      );
      await tester.tap(tile);
      await tester.pumpAndSettle();

      final label = l10n.visibilitySwitch_privacyAdvancedLabel;
      expect(
        find.text(l10n.visibilitySwitch_hideWarningTitle(label)),
        findsOne,
      );

      // Cancel keeps it shown.
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(container.read(setupDraftControllerProvider)!.edits, isEmpty);

      await tester.tap(tile);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.visibilitySwitch_hideWarningConfirm));
      await tester.pumpAndSettle();

      // Hidden: the default applies, the choice is kept, and no restart is
      // offered before Done.
      expect(
        container
            .read(displayedGeneralSettingsProvider)
            .isVisibilitySwitchShown(VisibilitySwitch.privacyAdvanced),
        isFalse,
      );
      expect(
        applied(),
        EngineSettings.withDefaults().fingerprintingProtectionOverrides,
      );
      expect(
        container
            .read(storedEngineSettingsProvider)
            .fingerprintingProtectionOverrides,
        hardened,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        container.read(setupDraftControllerProvider)!.hasVisibilityChanges,
        isTrue,
      );

      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(applied(), hardened);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
