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
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_visibility.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/contextual_toolbar_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/menu_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/module_surface_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/toolbar_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
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

/// The profile's toolbar buttons, which the onboarding must leave alone.
class _LiveToolbarButtons implements ToolbarButtonConfigRepository {
  final calls = <Symbol>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    calls.add(invocation.memberName);
    return Future<void>.value();
  }
}

/// No engine in a widget test: the button screen's sample buttons ask for
/// the selected tab, which waits for one.
class _EngineReadyState extends EngineReadyState {
  @override
  bool build() => true;
}

class _FakeWindowSizeClass extends WindowSizeClassController {
  @override
  WindowSizeClass build() => WindowSizeClass.fromSize(const Size(392, 850));
}

/// A router for the Toolbar & Layout screen and the editor screens it opens
/// full screen, by their typed routes.
GoRouter _layoutRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const ToolbarLayoutSettingsScreen()),
    GoRoute(
      path: const ContextualToolbarSettingsRoute().location,
      builder: (context, state) =>
          const ContextualToolbarSettingsRoute().build(context, state),
    ),
    GoRoute(
      path: const MenuLayoutSettingsRoute().location,
      builder: (context, state) =>
          const MenuLayoutSettingsRoute().build(context, state),
    ),
  ],
);

void main() {
  // The settings widgets edit the draft through the edit layer and draw it
  // through the displayed layer, both global: every edit rebuilds them, and
  // the live layer never moves.
  testWidgets('draft edits rebuild the edit and displayed layers', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(null),
        ),
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              // What the settings widgets read: the stored values, which a
              // hidden feature does not reset, and the displayed ones.
              ref
                ..watch(displayedGeneralSettingsProvider)
                ..watch(displayedEngineSettingsProvider);
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
      await container
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save((current) => current.copyWith.enableLocalAiFeatures(ai));
      await container
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
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(null),
        ),
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ModuleSurfaceSettingsScreen(
            surface: ModuleSurface.newTab,
            title: 'New tab',
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

    await container
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

  // Pages pushed from the onboarding edit the draft too. They once shared a
  // scope's container, which refreshed its providers while the first of its
  // scopes built: switching the tab bar position under Toolbar & layout then
  // marked the page below dirty from inside another route's build. Plain
  // routes over global providers must stay free of that.
  testWidgets('pages pushed over the onboarding rebuild without a build-phase '
      'error', (tester) async {
    final container = ProviderContainer(
      overrides: [
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(null),
        ),
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    Widget page(String name, {Widget? next}) => Consumer(
      builder: (context, ref, _) {
        final position = ref.watch(
          storedGeneralSettingsProvider.select((s) => s.tabBarPosition),
        );
        final stacking = ref.watch(displayedTabBarStackingModeProvider);
        return Scaffold(
          appBar: AppBar(title: Text(name)),
          body: Column(
            children: [
              Text('$name ${position.name} ${stacking.name}'),
              if (next != null)
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).push<void>(MaterialPageRoute(builder: (_) => next)),
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
          // Your setup, then the Layout step, then Toolbar & layout.
          home: page('summary', next: page('customize', next: page('toolbar'))),
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

  // The button editors work in the onboarding as they do in the settings,
  // inline in the Toolbar & Layout editor, and file every change into the
  // draft.
  testWidgets('toolbar buttons are edited in the draft', (tester) async {
    tester.view.physicalSize = const Size(392, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final live = _LiveToolbarButtons();
    final container = ProviderContainer(
      overrides: [
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(null),
        ),
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
        windowSizeClassControllerProvider.overrideWith(
          _FakeWindowSizeClass.new,
        ),
        toolbarButtonConfigsProvider.overrideWith(
          (ref, location) =>
              Stream.value(defaultToolbarButtonConfigsFor(location).value),
        ),
        toolbarConfigRepositoryProvider.overrideWith((ref, location) => live),
        engineReadyStateProvider.overrideWith(_EngineReadyState.new),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(setupDraftControllerProvider.notifier)
        .editGeneral(
          (s) => s.copyWith(
            tabBarPosition: TabBarPositionSetting.bottom,
            tabBarShowContextualBar: true,
          ),
        );

    // The browser had read the profile's buttons before the onboarding
    // opened. They must stay the profile's while the draft changes its own.
    const contextual = ToolbarConfigLocation.contextual;
    final profileButtons = defaultToolbarButtonConfigsFor(contextual);
    expect(container.read(toolbarConfigRepositoryProvider(contextual)), live);
    container.listen(toolbarButtonConfigsProvider(contextual), (_, _) {});
    await tester.pump();
    expect(
      container.read(effectiveToolbarButtonConfigsProvider(contextual)),
      profileButtons,
    );
    expect(
      container.read(profileToolbarButtonConfigsProvider(contextual)),
      profileButtons,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _layoutRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    List<ToolbarButtonConfig>? drafted() => container
        .read(setupDraftControllerProvider)!
        .toolbarButtons[ToolbarConfigLocation.contextual];
    Finder switchesIn(Finder editor) =>
        find.descendant(of: editor, matching: find.byType(Switch));

    // Inline: the contextual toolbar's part edits its buttons.
    final tabCount = find.descendant(
      of: find.byType(ContextualToolbar),
      matching: find.byWidgetPredicate(
        (w) => w is PreviewPartRegion && w.part == LayoutPart.tabView,
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tapAt(tester.getCenter(tabCount));
      await tester.pumpAndSettle();
    }
    expect(
      tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
      LayoutPart.contextualToolbar,
    );
    final inline = find.descendant(
      of: find.byType(LayoutPartSettings),
      matching: find.byType(ToolbarButtonConfigEditor),
    );
    // The buttons sit below the section's own settings.
    await tester.drag(
      find
          .descendant(
            of: find.byType(LayoutPartSettings),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    final firstSwitch = switchesIn(inline).first;
    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();

    final shownBefore = defaultToolbarButtonConfigsFor(
      ToolbarConfigLocation.contextual,
    ).value.where((c) => c.isVisible).length;
    expect(drafted(), isNotNull);
    expect(drafted()!.where((c) => c.isVisible), hasLength(shownBefore - 1));

    // From the settings list: the same editor, opened beside the preview
    // and scrolled to the buttons.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    final row = find.text('Customize Toolbar Buttons');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(ContextualToolbarSettingsScreen), findsNothing);
    expect(find.byType(LayoutPreview), findsOneWidget);
    expect(
      tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
      LayoutPart.contextualToolbar,
    );

    await tester.tap(switchesIn(inline).hitTestable().first);
    await tester.pumpAndSettle();
    expect(drafted()!.where((c) => c.isVisible), hasLength(shownBefore - 2));

    // Reset, as on the button screen: back to the defaults, in the draft.
    await tester.tap(
      find.descendant(
        of: find.byType(LayoutPartSettings),
        matching: find.byTooltip('Show menu'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset to Defaults'));
    await tester.pumpAndSettle();
    expect(
      drafted(),
      defaultToolbarButtonConfigsFor(ToolbarConfigLocation.contextual).value,
    );

    // On a screen of its own, for more room: still the draft's buttons.
    await tester.tap(
      find.descendant(
        of: find.byType(LayoutPartSettings),
        matching: find.byTooltip('Show menu'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open full screen'));
    await tester.pumpAndSettle();
    final screen = find.byType(ContextualToolbarSettingsScreen);
    expect(screen, findsOneWidget);
    await tester.tap(
      switchesIn(
        find.descendant(
          of: screen,
          matching: find.byType(ToolbarButtonConfigEditor),
        ),
      ).hitTestable().first,
    );
    await tester.pumpAndSettle();
    expect(drafted()!.where((c) => c.isVisible), hasLength(shownBefore - 1));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(screen, findsNothing);

    // Nothing reached the profile.
    expect(live.calls, isEmpty);

    // And the root still has the profile's buttons, with the onboarding
    // open and after it closed: what the commit writes through.
    void expectProfileButtons() {
      expect(container.read(toolbarConfigRepositoryProvider(contextual)), live);
      expect(
        container.read(effectiveToolbarButtonConfigsProvider(contextual)),
        profileButtons,
      );
      expect(
        container.read(profileToolbarButtonConfigsProvider(contextual)),
        profileButtons,
      );
    }

    await tester.tap(switchesIn(inline).hitTestable().first);
    await tester.pumpAndSettle();
    expect(drafted(), isNot(profileButtons.value));
    expectProfileButtons();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expectProfileButtons();
  });

  // The menu is arranged in the onboarding as after it, inline beside the
  // preview, and the arrangement waits in the draft.
  testWidgets('the menu is arranged in the draft', (tester) async {
    tester.view.physicalSize = const Size(392, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final Storage<String, String> storage = Storage.inMemory();
    final container = ProviderContainer(
      overrides: [
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(null),
        ),
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
        windowSizeClassControllerProvider.overrideWith(
          _FakeWindowSizeClass.new,
        ),
        toolbarButtonConfigsProvider.overrideWith(
          (ref, location) =>
              Stream.value(defaultToolbarButtonConfigsFor(location).value),
        ),
        toolbarConfigRepositoryProvider.overrideWith(
          (ref, location) => _LiveToolbarButtons(),
        ),
        engineReadyStateProvider.overrideWith(_EngineReadyState.new),
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
        menuConnectionSectionShownProvider.overrideWith((ref, _) => false),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(setupDraftControllerProvider.notifier)
        .editVisibility(
          (s) => s.withVisibilitySwitch(
            VisibilitySwitch.layoutAdvanced,
            enabled: true,
          ),
        );
    expect(
      container
          .read(draftGeneralSettingsProvider)
          .isFeatureShown(FeatureId.layoutMenuCustomization),
      isTrue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _layoutRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    final row = find.widgetWithText(ListTile, 'Customize Menu');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(
      tester.widget<LayoutPartSettings>(find.byType(LayoutPartSettings)).part,
      LayoutPart.menu,
    );

    await tester.tap(find.byTooltip('Hide').hitTestable().first);
    await tester.pumpAndSettle();

    final drafted = container.read(setupDraftControllerProvider)!.menuLayout;
    expect(drafted, isNotNull);
    expect(
      drafted!.where((section) => section.visible),
      hasLength(
        defaultMenuLayout.where((section) => section.visible).length - 1,
      ),
    );
    // On a screen of its own and back: each picks up where the other left
    // off, rather than write its own stale arrangement over the other's.
    int hiddenSections() => container
        .read(setupDraftControllerProvider)!
        .menuLayout!
        .where((section) => !section.visible)
        .length;
    await tester.tap(
      find.descendant(
        of: find.byType(LayoutPartSettings),
        matching: find.byTooltip('Show menu'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open full screen'));
    await tester.pumpAndSettle();
    final screen = find.byType(MenuLayoutSettingsScreen);
    expect(screen, findsOneWidget);
    await tester.tap(
      find
          .descendant(of: screen, matching: find.byTooltip('Hide'))
          .hitTestable()
          .first,
    );
    await tester.pumpAndSettle();
    expect(hiddenSections(), 2);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Hide').hitTestable().first);
    await tester.pumpAndSettle();
    expect(hiddenSections(), 3);

    // Nothing reached the profile.
    expect(container.read(menuLayoutProvider), defaultMenuLayout);
    // (Riverpod writes the profile's default arrangement when it is built.)
    expect(
      (await storage.read(menuLayoutStorageKey))?.data,
      anyOf(isNull, encodeMenuLayout(defaultMenuLayout)),
    );
  });
}
