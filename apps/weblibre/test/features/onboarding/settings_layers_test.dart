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
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

/// The profile's general settings: AI shown and off.
class _GeneralSettingsRepository extends GeneralSettingsRepository {
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings = GeneralSettings.withDefaults();

  @override
  Stream<GeneralSettings> build() => Stream.value(settings);

  @override
  Future<GeneralSettings> fetchSettings() async => settings;

  @override
  Future<void> updateSettings(UpdateGeneralSettingsFunc update) async {
    settings = update(settings);
    state = AsyncData(settings);
  }
}

class _EngineSettingsRepository extends EngineSettingsRepository {
  // ignore: riverpod_lint/avoid_public_notifier_properties
  EngineSettings settings = EngineSettings.withDefaults();

  @override
  Stream<EngineSettings> build() => Stream.value(settings);

  @override
  Future<EngineSettings> fetchSettings() async => settings;

  @override
  Future<void> updateSettings(UpdateEngineSettingsFunc update) async {
    settings = update(settings);
    state = AsyncData(settings);
  }
}

/// [completedOnboardingRevisionProvider]'s stream, for the test to emit
/// into: null while a fresh onboarding is owed.
late StreamController<int?> _revision;

/// [emitRevision] false leaves the revision unknown until the test emits.
ProviderContainer _container({int? revision, bool emitRevision = true}) {
  _revision = StreamController<int?>();
  addTearDown(_revision.close);
  if (emitRevision) _revision.add(revision);

  final Storage<String, String> storage = Storage.inMemory();
  final container = ProviderContainer.test(
    overrides: [
      riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      generalSettingsRepositoryProvider.overrideWith(
        _GeneralSettingsRepository.new,
      ),
      engineSettingsRepositoryProvider.overrideWith(
        _EngineSettingsRepository.new,
      ),
      completedOnboardingRevisionProvider.overrideWith(
        (ref) => _revision.stream,
      ),
      toolbarButtonConfigsProvider.overrideWith(
        (ref, location) =>
            Stream.value(defaultToolbarButtonConfigsFor(location).value),
      ),
      watchContainersProvider.overrideWith((ref) => Stream.value(const [])),
      storedGestureSettingsProvider.overrideWithValue(
        GestureSettings.withDefaults(),
      ),
      storedProxyDiagnosticsSettingsProvider.overrideWithValue(
        ProxyDiagnosticsSettings.withDefaults(),
      ),
    ],
  );
  // What the app holds: the settings and the draft are kept alive anyway.
  container
    ..listen(generalSettingsRepositoryProvider, (_, _) {})
    ..listen(engineSettingsRepositoryProvider, (_, _) {})
    ..listen(setupDraftControllerProvider, (_, _) {});
  for (final location in ToolbarConfigLocation.values) {
    container.listen(toolbarButtonConfigsProvider(location), (_, _) {});
  }
  return container;
}

/// Lets the repository and revision streams deliver.
Future<void> _settle() => pumpEventQueue();

/// Reads [readLoadedSettingsSnapshot] as a gesture's reveal does.
final _loadedSnapshot = FutureProvider.autoDispose(
  (ref) => readLoadedSettingsSnapshot(ref, timeout: Duration.zero),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the draft', () {
    test('opens for a fresh onboarding', () async {
      final container = _container();
      await _settle();
      expect(container.read(setupDraftControllerProvider), isNotNull);
    });

    test('a review opens none, and its edits land in the profile', () async {
      final container = _container(revision: 1);
      await _settle();
      expect(container.read(setupDraftControllerProvider), isNull);

      // Nothing to file into.
      container
          .read(setupDraftControllerProvider.notifier)
          .editGeneral((s) => s.copyWith(enableLocalAiFeatures: false));
      expect(container.read(setupDraftControllerProvider), isNull);

      await container
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save((s) => s.copyWith(enableLocalAiFeatures: false));
      await _settle();
      expect(
        container.read(profileGeneralSettingsProvider).enableLocalAiFeatures,
        isFalse,
      );
    });

    test('closes once the onboarding is completed', () async {
      final container = _container();
      await _settle();
      container
          .read(setupDraftControllerProvider.notifier)
          .setInstallUBlock(false);

      _revision.add(OnboardingRepository.targetRevision);
      await _settle();

      expect(container.read(setupDraftControllerProvider), isNull);
    });

    test('survives the revision stream emitting again', () async {
      final container = _container();
      await _settle();
      container
          .read(setupDraftControllerProvider.notifier)
          .setInstallUBlock(false);
      final edited = container.read(setupDraftControllerProvider);

      // Drift re-emits when the table is written, with the same answer.
      _revision.add(null);
      await _settle();

      expect(container.read(setupDraftControllerProvider), same(edited));
    });

    test('waits for the revision to be known before opening', () async {
      final container = _container(emitRevision: false);
      await _settle();
      expect(container.read(setupDraftControllerProvider), isNull);

      _revision.addError(StateError('unreadable'));
      await _settle();
      expect(container.read(setupDraftControllerProvider), isNull);

      _revision.add(null);
      await _settle();
      expect(container.read(setupDraftControllerProvider), isNotNull);
    });
  });

  group('the live layer ignores an open draft', () {
    late ProviderContainer container;

    setUp(() async {
      container = _container();
      await _settle();
      container.read(setupDraftControllerProvider.notifier)
        ..selectPreset(SetupPreset.expert)
        ..editVisibility(
          (s) => s.withVisibilitySwitch(VisibilitySwitch.ai, enabled: false),
        )
        ..editEngine((s) => s.copyWith.fontSizeFactor(2))
        ..setLayout(ModuleSurface.home, const [])
        ..setMenuLayout(const [])
        ..setToolbarButtons(ToolbarConfigLocation.contextual, const []);
      await _settle();
    });

    test('the settings services behave by', () {
      final profile = container.read(profileGeneralSettingsProvider);
      final engine = container.read(profileEngineSettingsProvider);
      expect(profile, isNot(container.read(draftGeneralSettingsProvider)));

      expect(
        container.read(generalSettingsWithDefaultsProvider),
        profile.effective(),
      );
      expect(
        container.read(shownFeaturesProvider),
        profile.effective().shownFeatures,
      );
      expect(
        container.read(engineSettingsWithDefaultsProvider).fontSizeFactor,
        engine.fontSizeFactor,
      );
      expect(
        container.read(loadedEngineSettingsProvider)?.fontSizeFactor,
        engine.fontSizeFactor,
      );
    });

    test('the layouts the browser draws', () {
      expect(container.read(menuLayoutProvider), defaultMenuLayout);
      expect(container.read(effectiveMenuLayoutProvider), defaultMenuLayout);
      expect(
        container.read(searchModuleOrderProvider(ModuleSurface.home)),
        mergeModuleOrderWithDefaults(null, ModuleSurface.home.defaultModules),
      );
      for (final location in ToolbarConfigLocation.values) {
        expect(
          container.read(effectiveToolbarButtonConfigsProvider(location)).value,
          isNotEmpty,
          reason: location.name,
        );
      }
    });

    test("a gesture's reveal reads the profile", () async {
      final subscription = container.listen(_loadedSnapshot, (_, _) {});
      addTearDown(subscription.close);
      final snapshot = await container.read(_loadedSnapshot.future);

      expect(snapshot.general, container.read(profileGeneralSettingsProvider));
      expect(snapshot.engine, container.read(profileEngineSettingsProvider));
      expect(snapshot.menu, defaultMenuLayout);
      expect(
        snapshot.toolbars[ToolbarConfigLocation.contextual],
        defaultToolbarButtonConfigsFor(ToolbarConfigLocation.contextual).value,
      );
    });
  });

  // Only the onboarding and the edit and displayed layers may follow the
  // draft; everything else behaves by the profile.
  test('nothing outside the edit and displayed layers reads the draft', () {
    const draftProviders = [
      'setupDraftControllerProvider',
      'draftGeneralSettingsProvider',
      'draftEngineSettingsProvider',
    ];
    // Where the edit and displayed providers live, beside their profile and
    // live siblings. What these read at runtime is checked above.
    const allowed = {
      // the draft itself
      'lib/domain/setup_draft/setup_draft.dart',
      // stored* and displayed* general settings
      'lib/features/user/domain/repositories/general_settings.dart',
      // stored* and displayed* engine settings
      'lib/features/user/domain/repositories/engine_settings.dart',
      // storedSettingsSnapshot, SuspendedSettings
      'lib/features/settings/domain/providers/hidden_settings.dart',
      // the save controllers, settingsEditsAreLive
      'lib/features/settings/presentation/controllers/save_settings.dart',
      // ToolbarButtonLayout, displayedToolbarButtonConfigs
      'lib/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart',
      // EditedModuleOrder
      'lib/features/geckoview/features/search/domain/providers/search_module_order.dart',
      // EditedMenuLayout
      'lib/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart',
    };
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            !file.path.endsWith('.g.dart') &&
            !file.path.startsWith('lib/features/onboarding/') &&
            !allowed.contains(file.path) &&
            draftProviders.any(file.readAsStringSync().contains))
          file.path,
    ];
    expect(offenders, isEmpty);
  });
  // The browser draws and behaves by the live layer: an open draft never
  // shows in it. Only the editors read the edit and displayed layers, and
  // the toolbars the Toolbar & Layout preview shares with the browser pick
  // their layer by `isPreview` (toolbarButtonConfigsShownBy,
  // generalSettingsShownBy).
  test('the browser reads no edit or displayed layer', () {
    final layerProvider = RegExp(
      r'\b(displayed[A-Z]\w*|edited[A-Z]\w*|stored(General|Engine)Settings|'
      r'toolbarButtonLayout)Provider\b',
    );
    const allowed = {
      // The edit and displayed providers themselves.
      'lib/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart',
      // Editors: the menu's and the modules' arrangement views.
      'lib/features/geckoview/features/browser/features/menu/presentation/widgets/menu_layout_slivers.dart',
      'lib/features/geckoview/features/browser/features/menu/presentation/widgets/menu_reorder_view.dart',
      'lib/features/geckoview/features/search/presentation/widgets/search_module_reorder_view.dart',
      'lib/features/geckoview/features/search/presentation/widgets/module_surface_slivers.dart',
      // Settings screens.
      'lib/features/geckoview/features/open_link_tools/presentation/screens/unshortener_settings.dart',
      'lib/features/geckoview/features/open_link_tools/presentation/screens/url_cleaner_settings.dart',
    };
    final offenders = [
      for (final directory in [
        'lib/features/geckoview',
        'lib/features/browser_actions',
      ])
        for (final file in Directory(directory).listSync(recursive: true))
          if (file is File &&
              file.path.endsWith('.dart') &&
              !file.path.endsWith('.g.dart') &&
              !allowed.contains(file.path) &&
              layerProvider.hasMatch(file.readAsStringSync()))
            file.path,
    ];
    expect(offenders, isEmpty);
  });
}
