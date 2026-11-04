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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_steps.dart';
import 'package:weblibre/features/user/data/providers.dart';

/// An add-on service whose install ends as [outcome], without the network.
class _FakeAddons extends BrowserAddonService {
  _FakeAddons(this.outcome);

  final AddonInstallOutcome outcome;

  // Holds the install open until the test completes it, when set.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  Completer<void>? hold;

  @override
  Future<AddonInstallOutcome> install(String addonGuid) async {
    await hold?.future;
    return outcome;
  }
}

/// An engine that refuses the hardening baseline, or applies it slowly.
class _FakePreferences extends UnifiedPreferenceSettingsRepository {
  _FakePreferences(this.engine);

  final _FakeEngine engine;

  @override
  Stream<Map<String, PreferenceSettingGroup>> build(
    PreferencePartition partition,
  ) => const Stream.empty();

  @override
  Future<void> apply() async {
    engine.applying = true;
    await engine.hold?.future;
    engine.applying = false;
    engine.applied++;
    if (engine.refuses) throw StateError('engine refused');
  }
}

class _FakeEngine {
  bool refuses = true;
  bool applying = false;
  int applied = 0;

  /// Holds the baseline open until completed, when set.
  Completer<void>? hold;
}

ProviderContainer _runner(
  AddonInstallOutcome outcome, {
  _FakeAddons? addons,
  _FakeEngine? engine,
}) {
  final Storage<String, String> storage = Storage.inMemory();
  final container = ProviderContainer(
    overrides: [
      riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      unifiedPreferenceSettingsRepositoryProvider.overrideWith2(
        (_) => _FakePreferences(engine ?? _FakeEngine()),
      ),
      browserAddonServiceProvider.overrideWith(
        () => addons ?? _FakeAddons(outcome),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  const uBlockSteps = {
    SetupStep.installUBlock,
    SetupStep.optimizedUBlockFilters,
  };

  test('a declined install is dropped with its filters, unreported', () async {
    // Declining the permission prompt is an answer: retried, it would ask
    // again on every start.
    final container = _runner(AddonInstallOutcome.cancelled);
    final runner = container.read(setupStepRunnerProvider.notifier);

    await runner.schedule(uBlockSteps);
    await runner.resume();

    expect(await runner.pending(), isEmpty);
    expect(container.read(setupStepRunnerProvider), isEmpty);
  });

  test('a failed install stays scheduled and is reported', () async {
    final container = _runner(AddonInstallOutcome.failed);
    final runner = container.read(setupStepRunnerProvider.notifier);

    await runner.schedule(uBlockSteps);
    await runner.resume();

    expect(await runner.pending(), uBlockSteps);
    expect(container.read(setupStepRunnerProvider), uBlockSteps);
  });

  test('a cancelled step is neither retried nor reported', () async {
    // The user set hardening up themselves after setup: retrying the
    // baseline would overwrite that.
    final container = _runner(AddonInstallOutcome.installed);
    final runner = container.read(setupStepRunnerProvider.notifier);

    await runner.schedule({SetupStep.hardeningBaseline});
    await runner.cancel(SetupStep.hardeningBaseline);
    await runner.resume();

    expect(await runner.pending(), isEmpty);
    expect(container.read(setupStepRunnerProvider), isEmpty);
  });

  test('a run under way does not write a cancelled step back', () async {
    final addons = _FakeAddons(AddonInstallOutcome.installed)
      ..hold = Completer();
    final container = _runner(AddonInstallOutcome.installed, addons: addons);
    final runner = container.read(setupStepRunnerProvider.notifier);

    // The engine refuses the baseline, so it fails and stays in the run's copy of
    // the schedule; it is cancelled while the run waits on the install.
    await runner.schedule({
      SetupStep.hardeningBaseline,
      SetupStep.installUBlock,
    });
    final run = runner.resume();
    await pumpEventQueue();
    await runner.cancel(SetupStep.hardeningBaseline);
    addons.hold!.complete();
    await run;

    expect(await runner.pending(), isEmpty);
    expect(container.read(setupStepRunnerProvider), isEmpty);
  });

  test('a new commit schedules a cancelled step again', () async {
    final container = _runner(AddonInstallOutcome.failed);
    final runner = container.read(setupStepRunnerProvider.notifier);

    await runner.cancel(SetupStep.installUBlock);
    await runner.schedule({SetupStep.installUBlock});
    await runner.resume();

    expect(await runner.pending(), {SetupStep.installUBlock});
  });

  test('cancelling waits out a baseline being applied', () async {
    // The user's change is written right after the cancel; a baseline still
    // writing its preferences would land on top of it.
    final engine = _FakeEngine()
      ..refuses = false
      ..hold = Completer();
    final container = _runner(AddonInstallOutcome.installed, engine: engine);
    final runner = container.read(setupStepRunnerProvider.notifier);

    await runner.schedule({SetupStep.hardeningBaseline});
    final run = runner.resume();
    await pumpEventQueue();
    expect(engine.applying, isTrue);

    var cancelled = false;
    final cancel = runner
        .cancel(SetupStep.hardeningBaseline)
        .then((_) => cancelled = true);
    await pumpEventQueue();
    expect(cancelled, isFalse);

    engine.hold!.complete();
    await cancel;
    expect(engine.applying, isFalse);
    expect(engine.applied, 1);
    await run;
    expect(await runner.pending(), isEmpty);
  });
}
