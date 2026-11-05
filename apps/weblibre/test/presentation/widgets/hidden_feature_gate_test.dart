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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';
import 'package:weblibre/presentation/widgets/reveal_feature.dart';

/// The settings the test changes, standing in for the repository.
final _settings = NotifierProvider<_Settings, GeneralSettings>(_Settings.new);

class _Settings extends Notifier<GeneralSettings> {
  @override
  GeneralSettings build() =>
      // Expert settings hidden: `sync.custom_server` needs only that switch.
      GeneralSettings.withDefaults().withVisibilitySwitch(
        VisibilitySwitch.expertDetails,
        enabled: false,
      );

  void apply(UpdateGeneralSettingsFunc update) => state = update(state);
}

class _Save extends SaveGeneralSettingsController {
  @override
  Future<bool> save(UpdateGeneralSettingsFunc updateSettings) async {
    ref.read(_settings.notifier).apply(updateSettings);
    return true;
  }

  @override
  Future<bool> saveVisibility(UpdateGeneralSettingsFunc updateSettings) =>
      save(updateSettings);
}

/// A [KeptWhen] the tests have hold.
const _inPlace = KeptWhen.syncServerOverrideSet;

/// What a gate grays out.
final _grayed = find.byWidgetPredicate(
  (widget) => widget is Opacity && widget.opacity == hiddenFeatureOpacity,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  late ProviderContainer container;
  setUp(() {
    final Storage<String, String> storage = Storage.inMemory();
    container = ProviderContainer(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => ref.watch(_settings),
        ),
        saveGeneralSettingsControllerProvider.overrideWith(_Save.new),
        keptWhenHoldsProvider(_inPlace).overrideWithValue(true),
        // No onboarding open: the gates show the live settings.
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(OnboardingRepository.targetRevision),
        ),
      ],
    );
  });
  tearDown(() => container.dispose());

  bool expertShown() => container
      .read(_settings)
      .isVisibilitySwitchShown(VisibilitySwitch.expertDetails);

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );

  testWidgets('a hidden control is grayed out and asks before it changes', (
    tester,
  ) async {
    var toggled = 0;
    await pump(
      tester,
      HiddenFeatureGate.feature(
        FeatureId.syncCustomServer,
        child: SwitchListTile(
          title: const Text('Server override'),
          value: false,
          onChanged: (_) => toggled++,
        ),
      ),
    );

    expect(find.ancestor(of: find.byType(Switch), matching: _grayed), findsOne);

    // Cancel changes nothing, and is not remembered: the next tap asks again.
    await tester.tap(find.text('Server override'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text(l10n.visibilitySwitch_revealConfirm), findsOne);
    await tester.tap(find.text(l10n.common_cancel));
    await tester.pumpAndSettle();
    expect(toggled, 0);
    expect(expertShown(), isFalse);
    expect(container.read(declinedVisibilityRevealsProvider), isEmpty);

    // Show turns the switch on and nothing else: the setting is unchanged
    // until the user taps it again.
    await tester.tap(find.text('Server override'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.visibilitySwitch_revealConfirm));
    await tester.pumpAndSettle();
    expect(expertShown(), isTrue);
    expect(toggled, 0);
    expect(_grayed, findsNothing);

    await tester.tap(find.text('Server override'));
    await tester.pump();
    expect(toggled, 1);
  });

  testWidgets('a changed setting of a hidden feature says it is not '
      'applied', (tester) async {
    container.dispose();
    final Storage<String, String> storage = Storage.inMemory();
    container = ProviderContainer(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => ref.watch(_settings),
        ),
        saveGeneralSettingsControllerProvider.overrideWith(_Save.new),
        suspendedSettingsProvider.overrideWith(_JavaScriptSuspended.new),
      ],
    );

    await pump(
      tester,
      Column(
        children: [
          HiddenFeatureGate.feature(
            FeatureId.advancedJavascriptControl,
            hiddenSettings: const [HiddenSetting.javascript],
            child: const ListTile(title: Text('JavaScript')),
          ),
          HiddenFeatureGate.feature(
            FeatureId.advancedCustomUserAgent,
            hiddenSettings: const [HiddenSetting.userAgent],
            child: const ListTile(title: Text('User agent')),
          ),
        ],
      ),
    );

    // Only under the changed one; both are grayed out.
    expect(find.text(l10n.visibilitySwitch_notAppliedWhileHidden), findsOne);
    expect(_grayed, findsNWidgets(2));
  });

  testWidgets('a setting in place stays usable', (tester) async {
    var toggled = 0;
    await pump(
      tester,
      Column(
        children: [
          HiddenFeatureGate.feature(
            FeatureId.syncCustomServer,
            keptWhen: _inPlace,
            child: TextButton(
              onPressed: () => toggled++,
              child: const Text('kept'),
            ),
          ),
          HiddenFeatureGate.feature(
            FeatureId.syncCustomServer,
            inForce: true,
            child: TextButton(
              onPressed: () => toggled++,
              child: const Text('in force'),
            ),
          ),
        ],
      ),
    );

    expect(_grayed, findsNothing);
    await tester.tap(find.text('kept'));
    await tester.tap(find.text('in force'));
    await tester.pump();
    expect(toggled, 2);
  });

  testWidgets('an entry that opens a screen is grayed out but still opens', (
    tester,
  ) async {
    var opened = 0;
    await pump(
      tester,
      SettingsSectionList(
        query: '',
        sections: [
          SettingsSectionDefinition(
            title: 'Section',
            entries: [
              SettingsEntryDefinition(
                title: 'Overrides',
                feature: FeatureId.syncCustomServer,
                opensScreen: true,
                child: ListTile(
                  title: const Text('Overrides'),
                  onTap: () => opened++,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    expect(_grayed, findsOne);
    await tester.tap(find.text('Overrides'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.text(l10n.visibilitySwitch_revealConfirm), findsNothing);
  });

  testWidgets('a task-screen option is left out unless it is in force', (
    tester,
  ) async {
    await pump(
      tester,
      Column(
        children: [
          HiddenFeatureGate.feature(
            FeatureId.syncCustomServer,
            omitWhenHidden: true,
            child: const Text('left out'),
          ),
          HiddenFeatureGate.feature(
            FeatureId.syncCustomServer,
            omitWhenHidden: true,
            inForce: true,
            child: const Text('in force'),
          ),
        ],
      ),
    );

    expect(find.text('left out'), findsNothing);
    expect(find.text('in force'), findsOne);
    expect(_grayed, findsNothing);

    // Once shown it is there, like any control.
    container
        .read(_settings.notifier)
        .apply(
          (s) => s.withVisibilitySwitch(
            VisibilitySwitch.expertDetails,
            enabled: true,
          ),
        );
    await tester.pump();
    expect(find.text('left out'), findsOne);
  });

  testWidgets('a scope gates the controls below it, grayed out once', (
    tester,
  ) async {
    var toggled = 0;
    await pump(
      tester,
      HiddenFeatureScope(
        feature: FeatureId.syncCustomServer,
        child: HiddenFeatureGate(
          child: Column(
            children: [
              const Text('outer'),
              HiddenFeatureGate.feature(
                FeatureId.syncCustomServer,
                child: TextButton(
                  onPressed: () => toggled++,
                  child: const Text('inner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // The inner gate does not darken what the outer one already grayed out.
    expect(_grayed, findsOne);

    await tester.tap(find.text('inner'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(toggled, 0);
    expect(find.text(l10n.visibilitySwitch_revealConfirm), findsOne);
  });

  testWidgets('a hidden control can be reached and asked about by keyboard', (
    tester,
  ) async {
    var toggled = 0;
    await pump(
      tester,
      HiddenFeatureGate.feature(
        FeatureId.syncCustomServer,
        child: SwitchListTile(
          title: const Text('Server override'),
          value: false,
          onChanged: (_) => toggled++,
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text(l10n.visibilitySwitch_revealConfirm), findsOne);
    expect(toggled, 0);
  });

  testWidgets('an entry in force stays usable under a hiding scope', (
    tester,
  ) async {
    var toggled = 0;
    await pump(
      tester,
      HiddenFeatureScope(
        feature: FeatureId.syncCustomServer,
        child: SettingsSectionList(
          query: '',
          sections: [
            SettingsSectionDefinition(
              title: 'Section',
              entries: [
                SettingsEntryDefinition(
                  title: 'On',
                  inForce: true,
                  child: TextButton(
                    onPressed: () => toggled++,
                    child: const Text('On'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(_grayed, findsNothing);
    await tester.tap(find.text('On'));
    await tester.pump();
    expect(toggled, 1);
  });

  testWidgets('arrow keys onto a hidden radio option ask instead of picking', (
    tester,
  ) async {
    String? saved;
    await pump(
      tester,
      Consumer(
        builder: (context, ref, _) => RadioGroup<String>(
          groupValue: 'plain',
          onChanged: (value) async {
            if (value == 'hidden' &&
                !await mayPickHiddenOption(
                  context,
                  ref,
                  FeatureId.syncCustomServer,
                )) {
              return;
            }
            saved = value;
          },
          child: Column(
            children: [
              const RadioListTile<String>(value: 'plain', title: Text('plain')),
              HiddenFeatureGate.feature(
                FeatureId.syncCustomServer,
                child: const RadioListTile<String>(
                  value: 'hidden',
                  title: Text('hidden'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(saved, isNull);
    expect(find.text(l10n.visibilitySwitch_revealConfirm), findsOne);
  });
}

class _JavaScriptSuspended extends SuspendedSettings {
  @override
  Set<HiddenSetting> build() => {HiddenSetting.javascript};
}
