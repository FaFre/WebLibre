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
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/settings/presentation/screens/settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<List<SettingsSearchTarget>> targets(WidgetTester tester) async {
    late List<SettingsSearchTarget> result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            result = settingsSearchTargets(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  SettingsSearchTarget byTitle(List<SettingsSearchTarget> all, String title) =>
      all.singleWhere((target) => target.title == title);

  testWidgets('hidden settings on subscreens can be found', (tester) async {
    // Without an index entry a setting hidden on its subscreen could only be
    // shown again from Feature Control.
    final all = await targets(tester);

    expect(
      byTitle(all, l10n.openLinkTools_allowReferralTitle).feature,
      FeatureId.urlCleanerReviewAndReferral,
    );
    expect(
      byTitle(all, l10n.settings_fingerprintOverrideTargetsSection).feature,
      FeatureId.privacyFpOverrides,
    );
    expect(
      byTitle(all, l10n.proxy_routingGlobalProxyTitle).feature,
      FeatureId.connectionsGlobalRouting,
    );
  });

  testWidgets('Tor, gesture and experimental subscreens are indexed', (
    tester,
  ) async {
    // Each is a screen of its own below a category; without an index entry
    // the search could not find its settings, hidden or not (S1).
    final all = await targets(tester);

    final torAutostart = byTitle(all, l10n.tor_startAutomaticallyTitle);
    expect(torAutostart.feature, FeatureId.connectionsTorBasic);
    expect(torAutostart.category, l10n.settings_categoryProxyTitle);

    final liveFeedback = byTitle(all, l10n.gestures_liveFeedbackTitle);
    expect(liveFeedback.feature, FeatureId.inputDrawnGestures);
    expect(liveFeedback.category, l10n.settings_categoryGesturesTitle);

    final isolatedProcess = byTitle(
      all,
      l10n.settings_isolatedContentProcessTitle,
    );
    expect(isolatedProcess.feature, FeatureId.advancedExperimentalProcess);
    expect(isolatedProcess.category, l10n.settings_categoryAdvancedTitle);
  });

  testWidgets('a sync server override in place is not offered as hidden', (
    tester,
  ) async {
    final target = byTitle(
      await targets(tester),
      l10n.sync_entryServerOverridesTitle,
    );
    expect(target.feature, FeatureId.syncCustomServer);

    bool keptWith(GeneralSettings settings) {
      final container = ProviderContainer(
        overrides: [
          // No onboarding owed: no draft, the displayed layer is the live one.
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(OnboardingRepository.targetRevision),
          ),
          generalSettingsWithDefaultsProvider.overrideWith((ref) => settings),
        ],
      );
      // Disposed right away: the auto-disposed provider read here would
      // otherwise leave its disposal timer pending past the test.
      try {
        return container.read(keptWhenHoldsProvider(target.keptWhen!));
      } finally {
        container.dispose();
      }
    }

    expect(keptWith(GeneralSettings.withDefaults()), isFalse);
    expect(
      keptWith(
        GeneralSettings.withDefaults().copyWith(
          syncServerOverride: 'https://accounts.example',
        ),
      ),
      isTrue,
    );
  });
}
