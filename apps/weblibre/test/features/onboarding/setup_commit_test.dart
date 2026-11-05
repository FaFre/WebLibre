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
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_commit.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_steps.dart';
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

  @override
  Future<GeneralSettings> fetchSettings() async =>
      GeneralSettings.withDefaults();

  @override
  Future<void> updateSettings(
    UpdateGeneralSettingsFunc updateWithCurrent,
  ) async {}
}

class _EngineSettingsRepository extends EngineSettingsRepository {
  @override
  Stream<EngineSettings> build() => Stream.value(EngineSettings.withDefaults());

  @override
  Future<EngineSettings> fetchSettings() async => EngineSettings.withDefaults();

  @override
  Future<void> updateSettings(
    UpdateEngineSettingsFunc updateWithCurrent,
  ) async {}
}

class _OnboardingRepository extends OnboardingRepository {
  @override
  Future<void> pushRevision(int revision) async {}
}

class _SetupStepRunner extends SetupStepRunner {
  final scheduled = <SetupStep>{};

  /// Fails the next [schedule], as full storage would.
  bool failSchedule = false;

  @override
  Future<SetupStepOutcome> runOnce(SetupStep step) async =>
      SetupStepOutcome.done;

  @override
  Future<void> schedule(Set<SetupStep> steps) async {
    if (failSchedule) {
      failSchedule = false;
      throw StateError('storage full');
    }
    scheduled.addAll(steps);
  }

  @override
  Future<void> resume() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Storage<String, String> storage;
  late _SetupStepRunner runner;

  ProviderContainer createContainer() {
    storage = Storage.inMemory();
    runner = _SetupStepRunner();
    return ProviderContainer.test(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
        generalSettingsRepositoryProvider.overrideWith(
          _GeneralSettingsRepository.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(
          _EngineSettingsRepository.new,
        ),
        onboardingRepositoryProvider.overrideWith(_OnboardingRepository.new),
        setupStepRunnerProvider.overrideWith(() => runner),
      ],
    );
  }

  // The revision is pushed before the steps are scheduled. A commit failing
  // there has marked the onboarding complete (and so closed the draft); Done
  // then finishes it from the journal it left.
  test(
    'a commit failing after the revision is finished from its journal',
    () async {
      final container = createContainer();
      runner.failSchedule = true;
      const draft = SetupDraft(
        preset: SetupPreset.average,
        installUBlock: true,
      );

      await expectLater(
        container
            .read(setupCommitServiceProvider.notifier)
            .commit(draft, targetRevision: 1),
        throwsStateError,
      );
      expect(runner.scheduled, isEmpty);
      expect(await storage.read(setupCommitJournalKey), isNotNull);

      expect(
        await container
            .read(setupCommitServiceProvider.notifier)
            .resumeInterrupted(),
        isTrue,
      );
      expect(runner.scheduled, contains(SetupStep.installUBlock));
      expect(await storage.read(setupCommitJournalKey), isNull);
    },
  );

  group('the journal', () {
    const home = ModuleSurface.home;
    final arrangedHome = mergeModuleOrderWithDefaults(
      null,
      home.defaultModules,
    ).reversed.toList();
    final arrangedMenu = mergeMenuLayoutWithDefaults(null).reversed.toList();

    Map<String, dynamic> journalJson({required bool legacy}) => {
      'general': <String, Object?>{},
      'engine': <String, Object?>{},
      'hardeningBaseline': false,
      'layouts': {
        home.name: legacy
            ? encodeModuleOrder(arrangedHome)
            : [for (final entry in arrangedHome) entry.toJson()],
        'removedSurface': '[]',
      },
      'menuLayout': legacy
          ? encodeMenuLayout(arrangedMenu)
          : [for (final section in arrangedMenu) section.toJson()],
      'steps': [SetupStep.installUBlock.name],
      'targetRevision': 1,
    };

    for (final legacy in [false, true]) {
      test(
        legacy
            ? 'reads layouts stored as JSON text, as older versions wrote them'
            : 'reads typed layouts and skips unknown surfaces',
        () {
          final journal = SetupCommitJournal.fromJson(
            jsonDecode(jsonEncode(journalJson(legacy: legacy)))
                as Map<String, dynamic>,
          );
          expect(journal.layouts, {home: arrangedHome});
          expect(journal.menuLayout, arrangedMenu);
        },
      );
    }

    test('round-trips through JSON', () {
      final journal = SetupCommitJournal.fromJson(journalJson(legacy: false));
      final decoded = SetupCommitJournal.fromJson(
        jsonDecode(jsonEncode(journal.toJson())) as Map<String, dynamic>,
      );
      expect(decoded.layouts, journal.layouts);
      expect(decoded.menuLayout, journal.menuLayout);
    });

    // The revision is pushed before the steps are scheduled: a journal
    // left over from there must still be finished, not dropped.
    test('an older journal cut short after the revision is finished', () async {
      final container = createContainer();
      await storage.write(
        setupCommitJournalKey,
        jsonEncode(journalJson(legacy: true)),
        const StorageOptions(),
      );

      expect(
        await container
            .read(setupCommitServiceProvider.notifier)
            .resumeInterrupted(),
        isTrue,
      );

      expect(container.read(searchModuleOrderProvider(home)), arrangedHome);
      expect(container.read(menuLayoutProvider), arrangedMenu);
      expect(runner.scheduled, {SetupStep.installUBlock});
      expect(await storage.read(setupCommitJournalKey), isNull);
    });
  });

  // The browser has its menu and home layout built long before the
  // onboarding commits (Settings' "Not applied while hidden" watches the
  // menu). `persist` reads the store only on a provider's first build, so
  // the commit used to store the arrangement and invalidate the provider,
  // which rebuilt with what it had: the arrangement was lost.
  test('the commit applies the arranged menu and layouts to built '
      'providers', () async {
    final container = createContainer();
    const home = ModuleSurface.home;
    container
      ..listen(menuLayoutProvider, (_, _) {})
      ..listen(searchModuleOrderProvider(home), (_, _) {});
    final shippedMenu = container.read(menuLayoutProvider);
    final shippedHome = container.read(searchModuleOrderProvider(home));

    final arrangedMenu = [...shippedMenu.reversed];
    final arrangedHome = [...shippedHome.reversed];
    expect(arrangedMenu, isNot(shippedMenu));
    expect(arrangedHome, isNot(shippedHome));

    final draft = SetupDraft(
      preset: SetupPreset.average,
      menuLayout: arrangedMenu,
      layouts: {home: arrangedHome},
    );
    await container
        .read(setupCommitServiceProvider.notifier)
        .commit(draft, targetRevision: 1);

    expect(container.read(menuLayoutProvider), arrangedMenu);
    expect(container.read(searchModuleOrderProvider(home)), arrangedHome);
    // And stored, for the next start.
    expect(
      (await storage.read(menuLayoutStorageKey))?.data,
      encodeMenuLayout(arrangedMenu),
    );
    expect(
      (await storage.read(home.key))?.data,
      encodeModuleOrder(arrangedHome),
    );
  });
}
