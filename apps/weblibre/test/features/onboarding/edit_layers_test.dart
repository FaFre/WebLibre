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

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

class _GeneralSettingsRepository extends GeneralSettingsRepository {
  @override
  Stream<GeneralSettings> build() =>
      Stream.value(GeneralSettings.withDefaults());
}

class _EngineSettingsRepository extends EngineSettingsRepository {
  @override
  Stream<EngineSettings> build() => Stream.value(EngineSettings.withDefaults());
}

/// A store whose writes land only when the test lets them, and which emits
/// only what has landed.
class _SlowToolbarStore
    with SerializedSaveAll
    implements ToolbarButtonConfigRepository {
  _SlowToolbarStore(this.stored);

  List<ToolbarButtonConfig> stored;
  final _changes = StreamController<List<ToolbarButtonConfig>>.broadcast();
  final pending = <Completer<void>>[];
  final written = <List<ToolbarButtonConfig>>[];
  bool fail = false;

  @override
  Stream<List<ToolbarButtonConfig>> watchAll() async* {
    yield stored;
    yield* _changes.stream;
  }

  @override
  Future<void> writeChanged(List<ToolbarButtonConfig> configs) async {
    final landed = Completer<void>();
    pending.add(landed);
    await landed.future;
    if (fail) throw StateError('full');
    written.add(configs);
    stored = configs;
    _changes.add(configs);
  }

  @override
  Future<void> seedMissingDefaults() async {}

  /// Lets the oldest write land.
  void land() => pending.removeAt(0).complete();
}

const _contextual = ToolbarConfigLocation.contextual;

ProviderContainer _container({
  required int? revision,
  _SlowToolbarStore? store,
}) {
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
      completedOnboardingRevisionProvider.overrideWithValue(
        AsyncData(revision),
      ),
      if (store != null) ...[
        toolbarConfigRepositoryProvider.overrideWith((ref, _) => store),
        toolbarButtonConfigsProvider.overrideWith((ref, _) => store.watchAll()),
      ] else
        toolbarButtonConfigsProvider.overrideWith(
          (ref, location) =>
              Stream.value(defaultToolbarButtonConfigsFor(location).value),
        ),
    ],
  );
  container
    ..listen(generalSettingsRepositoryProvider, (_, _) {})
    ..listen(engineSettingsRepositoryProvider, (_, _) {});
  return container;
}

List<String> _shown(List<ToolbarButtonConfig> configs) => [
  for (final config in sortedToolbarButtons(configs))
    if (config.isVisible) config.buttonId,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('toolbar edits outside the onboarding', () {
    late _SlowToolbarStore store;
    late ProviderContainer container;
    final defaults = defaultToolbarButtonConfigsFor(_contextual).value;

    setUp(() async {
      store = _SlowToolbarStore(defaults);
      container = _container(revision: 3, store: store);
      container.listen(toolbarButtonLayoutProvider(_contextual), (_, _) {});
      await pumpEventQueue();
    });

    ToolbarButtonLayout layout() =>
        container.read(toolbarButtonLayoutProvider(_contextual).notifier);
    List<ToolbarButtonConfig> shownLayout() =>
        container.read(toolbarButtonLayoutProvider(_contextual)).value;

    test('two edits before the store catches up keep both', () async {
      final first = _shown(defaults)[0];
      final second = _shown(defaults)[1];

      final writes = [
        layout().setVisibility(first, visible: false),
        layout().setVisibility(second, visible: false),
      ];
      expect(_shown(shownLayout()), isNot(contains(first)));
      expect(_shown(shownLayout()), isNot(contains(second)));

      // The first write lands and the store emits it: the editor still shows
      // the second edit on top.
      await pumpEventQueue();
      store.land();
      await pumpEventQueue();
      expect(_shown(shownLayout()), isNot(contains(first)));
      expect(_shown(shownLayout()), isNot(contains(second)));

      store.land();
      await Future.wait(writes);
      await pumpEventQueue();

      // In order, the last one complete.
      expect(store.written, hasLength(2));
      expect(_shown(store.written.last), isNot(contains(first)));
      expect(_shown(store.written.last), isNot(contains(second)));
      expect(shownLayout(), store.stored);
    });

    test('a failed write falls back to the store', () async {
      final first = _shown(defaults)[0];
      store.fail = true;

      final write = layout().setVisibility(first, visible: false);
      expect(_shown(shownLayout()), isNot(contains(first)));

      await pumpEventQueue();
      store.land();
      await expectLater(write, throwsStateError);
      await pumpEventQueue();

      expect(_shown(shownLayout()), contains(first));
    });
  });

  // Every edit writes the whole set: computed from the defaults shown while
  // loading, it would overwrite what the user arranged.
  group('toolbar edits before the store has loaded', () {
    // What the user arranged: everything hidden.
    final arranged = [
      for (final config in defaultToolbarButtonConfigsFor(_contextual).value)
        config.copyWith(isVisible: false),
    ];
    late StreamController<List<ToolbarButtonConfig>> stream;
    late _SlowToolbarStore store;
    late ProviderContainer container;

    setUp(() async {
      stream = StreamController();
      addTearDown(stream.close);
      store = _SlowToolbarStore(arranged);
      container = ProviderContainer.test(
        overrides: [
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(OnboardingRepository.targetRevision),
          ),
          toolbarConfigRepositoryProvider.overrideWith((ref, _) => store),
          toolbarButtonConfigsProvider.overrideWith((ref, _) => stream.stream),
        ],
      );
      container.listen(toolbarButtonLayoutProvider(_contextual), (_, _) {});
      await pumpEventQueue();
    });

    test('wait for it, and start from the stored buttons', () async {
      final shownByDefault = _shown(
        defaultToolbarButtonConfigsFor(_contextual).value,
      ).first;
      // Shown in the meantime: the defaults.
      expect(
        _shown(container.read(toolbarButtonLayoutProvider(_contextual)).value),
        contains(shownByDefault),
      );

      final edit = container
          .read(toolbarButtonLayoutProvider(_contextual).notifier)
          .setVisibility(shownByDefault, visible: true);
      await pumpEventQueue();
      expect(store.pending, isEmpty);

      stream.add(arranged);
      await pumpEventQueue();
      store.land();
      await edit;

      // Only the one button changed.
      expect(_shown(store.written.single), [shownByDefault]);
    });

    test('write nothing once it failed', () async {
      final edit = container
          .read(toolbarButtonLayoutProvider(_contextual).notifier)
          .setVisibility(arranged.first.buttonId, visible: true);
      stream.addError(StateError('unreadable'));

      await expectLater(edit, throwsStateError);
      await pumpEventQueue();
      expect(store.pending, isEmpty);
      expect(store.written, isEmpty);
    });
  });

  group('with a draft open', () {
    late ProviderContainer container;

    setUp(() async {
      container = _container(revision: null);
      // The editors are auto-disposed: held as the screens hold them.
      container
        ..listen(toolbarButtonLayoutProvider(_contextual), (_, _) {})
        ..listen(displayedToolbarButtonConfigsProvider(_contextual), (_, _) {})
        ..listen(editedModuleOrderProvider(ModuleSurface.home), (_, _) {})
        ..listen(editedMenuLayoutProvider, (_, _) {});
      await pumpEventQueue();
    });

    test('the editors change the draft, never the profile', () async {
      final defaults = defaultToolbarButtonConfigsFor(_contextual).value;
      final hidden = _shown(defaults).first;
      await container
          .read(toolbarButtonLayoutProvider(_contextual).notifier)
          .setVisibility(hidden, visible: false);
      container
          .read(editedModuleOrderProvider(ModuleSurface.home).notifier)
          .toggleVisibility(
            container
                .read(searchModuleOrderProvider(ModuleSurface.home))
                .first
                .type,
          );
      container
          .read(editedMenuLayoutProvider.notifier)
          .toggleSectionVisibility(defaultMenuLayout.first.type);

      final draft = container.read(setupDraftControllerProvider)!;
      expect(
        _shown(draft.toolbarButtons[_contextual]!),
        isNot(contains(hidden)),
      );
      expect(
        _shown(container.read(toolbarButtonLayoutProvider(_contextual)).value),
        isNot(contains(hidden)),
      );
      expect(draft.layouts[ModuleSurface.home], isNotNull);
      expect(
        container.read(editedModuleOrderProvider(ModuleSurface.home)),
        draft.layouts[ModuleSurface.home],
      );
      expect(container.read(editedMenuLayoutProvider), draft.menuLayout);

      // The profile and the live layer stay as they were.
      expect(
        container.read(profileToolbarButtonConfigsProvider(_contextual)).value,
        defaults,
      );
      expect(
        container
            .read(effectiveToolbarButtonConfigsProvider(_contextual))
            .value,
        defaults,
      );
      expect(
        container.read(searchModuleOrderProvider(ModuleSurface.home)),
        mergeModuleOrderWithDefaults(null, ModuleSurface.home.defaultModules),
      );
      expect(container.read(menuLayoutProvider), defaultMenuLayout);
    });

    test(
      'the displayed layer shows the draft, the live layer does not',
      () async {
        await container
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (s) => s.withVisibilitySwitch(
                VisibilitySwitch.layoutAdvanced,
                enabled: true,
              ),
            );

        final drafted = container
            .read(draftGeneralSettingsProvider)
            .effective();
        expect(container.read(displayedGeneralSettingsProvider), drafted);
        expect(
          container.read(displayedShownFeaturesProvider),
          drafted.shownFeatures,
        );
        expect(
          container.read(generalSettingsWithDefaultsProvider),
          container.read(profileGeneralSettingsProvider).effective(),
        );
        expect(
          container.read(generalSettingsWithDefaultsProvider),
          isNot(drafted),
        );
        // Saved into the draft, not the profile.
        expect(
          container.read(setupDraftControllerProvider)!.edits,
          hasLength(1),
        );
        expect(container.read(settingsEditsAreLiveProvider), isFalse);
      },
    );
  });
}
