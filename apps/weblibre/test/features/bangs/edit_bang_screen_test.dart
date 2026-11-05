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
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/presentation/screens/edit.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> pump(WidgetTester tester, {Bang? bang}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No onboarding owed: no draft, the displayed layer is the live one.
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(OnboardingRepository.targetRevision),
          ),
          // Expert details hidden: the format flags are hidden.
          generalSettingsWithDefaultsProvider.overrideWithValue(
            GeneralSettings.withDefaults().withVisibilitySwitch(
              VisibilitySwitch.expertDetails,
              enabled: false,
            ),
          ),
          bangCategoriesProvider.overrideWith(
            (ref) => Stream.value(const <String, List<String>>{}),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditBangScreen(initialBang: bang),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('aliases are always offered; hidden format flags are not', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text(l10n.bangs_fieldAdditionalTriggersLabel), findsOne);
    expect(find.text(l10n.bangs_flagsLabel), findsNothing);
  });

  testWidgets('a bang that already uses format flags keeps them', (
    tester,
  ) async {
    await pump(
      tester,
      bang: Bang(
        websiteName: 'Example',
        domain: 'example.com',
        trigger: 'ex',
        urlTemplate: 'https://example.com/?q={{{s}}}',
        searxngApi: false,
        format: {BangFormat.openBasePath},
      ),
    );

    await tester.dragUntilVisible(
      find.text(l10n.bangs_flagsLabel),
      find.byType(Scrollable).first,
      const Offset(0, -100),
    );
    expect(find.text(l10n.bangs_flagsLabel), findsOne);
  });
}
