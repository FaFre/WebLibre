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
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/onboarding/presentation/pages/preset.dart';
import 'package:weblibre/features/onboarding/presentation/pages/your_setup.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
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

    testWidgets('a change that drops Customize changes offers Undo', (
      tester,
    ) async {
      draft().editGeneral(
        SetupDraftStep.customize,
        (s) => s.copyWith(pureBlack: true),
      );
      final previous = state();
      await pump(tester, const PresetPage());

      await tester.tap(find.text(l10n.onboarding_presetAdvancedTitle));
      await tester.pump();
      expect(state().preset, SetupPreset.advanced);
      expect(state().customizeEdits, isEmpty);
      expect(find.text(l10n.onboarding_presetChangeResetCustomize), findsOne);

      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_undo));
      await tester.pumpAndSettle();
      expect(state(), same(previous));
    });

    testWidgets('a change that drops nothing says nothing', (tester) async {
      await pump(tester, const PresetPage());

      await tester.tap(find.text(l10n.onboarding_presetExpertTitle));
      await tester.pump();
      expect(state().preset, SetupPreset.expert);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('your setup', () {
    // Tall enough for the whole summary, so every row can be tapped.
    Future<void> pumpYourSetup(WidgetTester tester) =>
        pump(tester, const YourSetupPage(), height: 6000);

    bool switchValue(WidgetTester tester, String title) => tester
        .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
        .value;

    Finder hiddenRow(String label) =>
        find.widgetWithText(ListTile, label).hitTestable();

    testWidgets('a hidden feature opens its switch in Customize', (
      tester,
    ) async {
      await pumpYourSetup(tester);
      final treeTabs = l10n.visibilitySwitch_treeTabsLabel;
      expect(find.text(l10n.onboarding_yourSetupHiddenForNowTitle), findsOne);

      await tester.tap(hiddenRow(treeTabs));
      await tester.pumpAndSettle();

      // Customize, scrolled to the switch and highlighting it.
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

    testWidgets('Customize stays when nothing is hidden', (tester) async {
      draft().selectPreset(SetupPreset.expert);
      await pumpYourSetup(tester);

      expect(
        find.text(l10n.onboarding_yourSetupHiddenForNowTitle),
        findsNothing,
      );
      await tester.tap(find.text(l10n.onboarding_customizeAction));
      await tester.pumpAndSettle();
      expect(find.byType(CustomizeSetupScreen), findsOne);
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
