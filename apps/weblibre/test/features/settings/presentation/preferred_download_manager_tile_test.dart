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
import 'package:weblibre/features/settings/domain/providers/preferred_download_manager.dart';
import 'package:weblibre/features/settings/presentation/screens/general_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FakeChoice extends PreferredDownloadManagerChoice {
  _FakeChoice(this._value);

  PreferredDownloadManager? _value;
  int clears = 0;
  int builds = 0;

  @override
  Future<PreferredDownloadManager?> build() async {
    builds++;
    return _value;
  }

  @override
  Future<void> clear() async {
    clears++;
    _value = null;
    ref.invalidateSelf();
  }
}

Future<_FakeChoice> _pump(
  WidgetTester tester,
  PreferredDownloadManager? value, {
  bool useExternalDownloadManager = true,
}) async {
  final fake = _FakeChoice(value);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferredDownloadManagerChoiceProvider.overrideWith(() => fake),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(
            useExternalDownloadManager: useExternalDownloadManager,
          ),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PreferredDownloadManagerTile()),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return fake;
}

void main() {
  testWidgets('says how to set one when nothing is remembered', (tester) async {
    await _pump(tester, null);

    expect(
      find.text(
        'Not set — tick “Always use this app” the next time the chooser appears',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Clear preferred manager'), findsNothing);
  });

  testWidgets('names a remembered external app', (tester) async {
    await _pump(
      tester,
      PreferredDownloadManager(
        packageName: 'com.dv.adm',
        label: 'ADM',
        isThisApp: false,
      ),
    );

    expect(find.text('ADM'), findsOneWidget);
    expect(find.byTooltip('Clear preferred manager'), findsOneWidget);
  });

  testWidgets('says the browser still confirms each download', (tester) async {
    await _pump(
      tester,
      PreferredDownloadManager(
        packageName: 'eu.weblibre.gecko',
        label: 'WebLibre',
        isThisApp: true,
      ),
    );

    expect(
      find.text('WebLibre, with a confirmation before each download'),
      findsOneWidget,
    );
  });

  testWidgets('says when the remembered app is gone', (tester) async {
    await _pump(
      tester,
      PreferredDownloadManager(
        packageName: 'com.dv.adm',
        label: null,
        isThisApp: false,
      ),
    );

    expect(
      find.text('No longer installed (com.dv.adm) — asking every time'),
      findsOneWidget,
    );
  });

  testWidgets('clearing goes back to not set', (tester) async {
    final fake = await _pump(
      tester,
      PreferredDownloadManager(
        packageName: 'com.dv.adm',
        label: 'ADM',
        isThisApp: false,
      ),
    );

    await tester.tap(find.byTooltip('Clear preferred manager'));
    await tester.pumpAndSettle();

    expect(fake.clears, 1);
    expect(
      find.text(
        'Not set — tick “Always use this app” the next time the chooser appears',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says the row is unused while external managers are off', (
    tester,
  ) async {
    // A fresh profile: WebLibre downloads everything itself and no chooser
    // shows, so "tick it next time" would be wrong.
    await _pump(tester, null, useExternalDownloadManager: false);

    expect(
      find.text('Not set — only used with an external download manager'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Not set — tick “Always use this app” the next time the chooser appears',
      ),
      findsNothing,
    );
  });

  testWidgets('says a remembered app is inactive while the switch is off', (
    tester,
  ) async {
    await _pump(
      tester,
      PreferredDownloadManager(
        packageName: 'com.dv.adm',
        label: 'ADM',
        isThisApp: false,
      ),
      useExternalDownloadManager: false,
    );

    expect(
      find.text('ADM — not used while the external download manager is off'),
      findsOneWidget,
    );
    // Still clearable, so turning the switch back on starts from asking.
    expect(find.byTooltip('Clear preferred manager'), findsOneWidget);
  });

  testWidgets('names an uninstalled inactive app by its package', (
    tester,
  ) async {
    await _pump(
      tester,
      PreferredDownloadManager(
        packageName: 'com.dv.adm',
        label: null,
        isThisApp: false,
      ),
      useExternalDownloadManager: false,
    );

    expect(
      find.text(
        'com.dv.adm — not used while the external download manager is off',
      ),
      findsOneWidget,
    );
  });

  testWidgets('reads the choice again when the app resumes', (tester) async {
    final fake = await _pump(tester, null);
    final before = fake.builds;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(fake.builds, before + 1);
  });
}
