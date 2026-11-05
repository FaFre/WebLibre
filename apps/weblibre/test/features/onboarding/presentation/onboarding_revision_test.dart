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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/onboarding/presentation/onboarding.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FakeGeneralSettingsRepository extends GeneralSettingsRepository {
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings = GeneralSettings.withDefaults().copyWith
      .enableLocalAiFeatures(false);

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

class _FakeOnboardingRepository extends OnboardingRepository {
  // ignore: riverpod_lint/avoid_public_notifier_properties
  final pushed = <int>[];

  @override
  Future<void> pushRevision(int revision) async => pushed.add(revision);
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('a revision 1 profile is asked about on-device AI alone', (
    tester,
  ) async {
    final settings = _FakeGeneralSettingsRepository();
    final onboarding = _FakeOnboardingRepository();
    final Storage<String, String> storage = Storage.inMemory();
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(
            currentRevision: 1,
            targetRevision: OnboardingRepository.targetRevision,
          ),
        ),
        GoRoute(
          path: const BrowserRoute().location,
          builder: (_, _) => const Text('browser'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
          generalSettingsRepositoryProvider.overrideWith(() => settings),
          onboardingRepositoryProvider.overrideWith(() => onboarding),
          // What the router read before it showed the review.
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(1),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboarding_aiFeaturesTitle), findsOne);
    // One page: Done right away, no Next.
    expect(find.text(l10n.onboarding_actionNext), findsNothing);
    expect(find.text(l10n.onboarding_aiWarningTitle), findsNothing);

    await tester.tap(find.text(l10n.onboarding_aiUseOnDeviceTitle));
    await tester.pumpAndSettle();
    expect(settings.settings.enableLocalAiFeatures, isTrue);
    expect(find.text(l10n.onboarding_aiWarningTitle), findsOne);

    await tester.tap(find.text(l10n.common_done));
    await tester.pumpAndSettle();
    expect(onboarding.pushed, [OnboardingRepository.targetRevision]);
    // Done leaves for the browser.
    expect(find.text('browser'), findsOne);
  });
}
