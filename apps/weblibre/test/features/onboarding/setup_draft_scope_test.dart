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
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_draft.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_draft_scope.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/module_surface_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
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
  // The scope overrides the settings providers with the draft providers,
  // which read the live settings from the root. Riverpod detects cycles by
  // provider, so a draft provider watching the provider the scope overrides
  // threw a CircularDependencyError on every rebuild after the first.
  testWidgets('draft edits rebuild the scoped settings without a cycle', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
      ],
    );
    addTearDown(container.dispose);

    late ProviderContainer scoped;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SetupDraftScope(
            step: SetupDraftStep.customize,
            child: Consumer(
              builder: (context, ref, _) {
                scoped = ProviderScope.containerOf(context);
                // What the settings widgets read: the stored values, which a
                // hidden feature does not reset. The effective ones are
                // watched too, for the cycle.
                ref
                  ..watch(generalSettingsWithDefaultsProvider)
                  ..watch(engineSettingsWithDefaultsProvider);
                final ai = ref.watch(
                  storedGeneralSettingsProvider.select(
                    (s) => s.enableLocalAiFeatures,
                  ),
                );
                final lna = ref.watch(
                  storedEngineSettingsProvider.select(
                    (s) => s.lnaBlocking ?? false,
                  ),
                );
                return Text('ai=$ai lna=$lna');
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The draft starts from the preset, not from the code defaults.
    final initialAi = container
        .read(draftGeneralSettingsProvider)
        .enableLocalAiFeatures;
    final initialLna =
        container.read(draftEngineSettingsProvider).lnaBlocking ?? false;
    expect(find.text('ai=$initialAi lna=$initialLna'), findsOneWidget);

    // Twice each: the first edit builds the draft providers' dependents, the
    // second rebuilds them with those dependents in place.
    for (final round in [1, 2]) {
      final ai = round.isOdd ? !initialAi : initialAi;
      final lna = round.isOdd ? !initialLna : initialLna;
      await scoped
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save((current) => current.copyWith.enableLocalAiFeatures(ai));
      await scoped
          .read(saveEngineSettingsControllerProvider.notifier)
          .save((current) => current.copyWith.lnaBlocking(lna));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Riverpod keeps the error in the provider; reading it rethrows.
      expect(
        () => container.read(draftGeneralSettingsProvider),
        returnsNormally,
      );
      expect(
        () => container.read(draftEngineSettingsProvider),
        returnsNormally,
      );
      expect(find.text('ai=$ai lna=$lna'), findsOneWidget);
    }

    // The live settings never saw the draft.
    expect(
      container.read(generalSettingsWithDefaultsProvider).enableLocalAiFeatures,
      GeneralSettings.withDefaults().enableLocalAiFeatures,
    );
  });

  // The module layout screens list only modules whose feature is shown: the
  // surface skips the others when drawn, so a switch for them did nothing
  // (Average preset: the Containers module stayed offered on the new tab
  // page while containers were hidden).
  testWidgets('module layout leaves out modules of hidden features', (
    tester,
  ) async {
    // Tall enough to build every row of the list.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(setupDraftControllerProvider.notifier)
        .selectPreset(SetupPreset.average);

    late ProviderContainer scoped;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SetupDraftScope(
            step: SetupDraftStep.customize,
            child: Builder(
              builder: (context) {
                scoped = ProviderScope.containerOf(context);
                return const ModuleSurfaceSettingsScreen(
                  surface: ModuleSurface.newTab,
                  title: 'New tab',
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(draftGeneralSettingsProvider)
          .isFeatureShown(FeatureId.containerCore),
      isFalse,
    );
    expect(find.text('Containers'), findsNothing);
    expect(find.text('Shortcuts'), findsOneWidget);

    await scoped
        .read(saveGeneralSettingsControllerProvider.notifier)
        .save(
          (current) => current.withVisibilitySwitch(
            VisibilitySwitch.containers,
            enabled: true,
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Containers'), findsOneWidget);
  });

  // Pages pushed from the onboarding edit the draft too. They once shared the
  // scope's container, which refreshes its providers while the first of its
  // scopes builds: Customize's, below Toolbar & layout. Switching the tab bar
  // position there then marked the Toolbar & layout page dirty from inside
  // another route's build.
  testWidgets('pages pushed in the draft scope rebuild without a build-phase '
      'error', (tester) async {
    final container = ProviderContainer(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    // The onboarding screen holds the draft while it is open.
    container.listen(setupDraftControllerProvider, (_, _) {});

    Widget page(String name, {Widget? next}) => Consumer(
      builder: (context, ref, _) {
        final position = ref.watch(
          storedGeneralSettingsProvider.select((s) => s.tabBarPosition),
        );
        final stacking = ref.watch(effectiveTabBarStackingModeProvider);
        return Scaffold(
          appBar: AppBar(title: Text(name)),
          body: Column(
            children: [
              Text('$name ${position.name} ${stacking.name}'),
              if (next != null)
                TextButton(
                  onPressed: () => pushInSetupDraftScope<void>(context, next),
                  child: Text('open $name'),
                ),
              for (final value in [
                TabBarPositionSetting.top,
                TabBarPositionSetting.bottom,
              ])
                TextButton(
                  onPressed: () => ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save((s) => s.copyWith.tabBarPosition(value)),
                  child: Text('$name ${value.name}'),
                ),
            ],
          ),
        );
      },
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SetupDraftScope(
            step: SetupDraftStep.customize,
            // Your setup, then Customize, then Toolbar & layout.
            child: page(
              'summary',
              next: page('customize', next: page('toolbar')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open summary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open customize'));
    await tester.pumpAndSettle();

    for (final value in ['top', 'bottom', 'top', 'bottom']) {
      await tester.tap(find.text('toolbar $value'));
      // A frame before the zero-delay timers Riverpod falls back on, as on
      // a device: the refresh then runs while the first scope builds.
      tester.binding
        ..handleBeginFrame(null)
        ..handleDrawFrame();
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.textContaining('toolbar $value '), findsOne);
      expect(
        container.read(draftGeneralSettingsProvider).tabBarPosition.name,
        value,
      );
    }

    // Back on the summary, the draft holds the last choice.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('summary bottom '), findsOne);
  });
}
