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
import 'dart:convert';

import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/storage_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/data/providers/ublock_assets.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

part 'setup_steps.g.dart';

const ublockAddonId = 'uBlock0@raymondhill.net';

/// Riverpod storage key of an onboarding commit that has not finished (see
/// `SetupCommitService`). While it exists, no external step runs.
const setupCommitJournalKey = 'SetupCommitJournal';

/// The parts of the onboarding commit that reach outside the settings: they
/// can fail (no network, engine not ready) and so run after the settings
/// writes, each with its own checkpoint.
///
/// Only the commit schedules them. Nothing else ever installs uBlock Origin,
/// so an opt-out in the onboarding, or removing it afterwards, is final (acceptance
/// scenario 9): a removal also drops an install still waiting for its retry
/// ([SetupStepRunner.uBlockRemoved]).
enum SetupStep {
  /// The engine hardening baseline. The commit applies it inline and
  /// schedules this step only when that fails, so a refused preference write
  /// neither blocks the onboarding nor loses the baseline.
  hardeningBaseline,
  installUBlock,
  optimizedUBlockFilters,
}

/// How one run of a [SetupStep] ended.
enum SetupStepOutcome {
  done,

  /// Retried on the next start, and reported.
  failed,

  /// The user declined it when asked: dropped, never retried or reported.
  declined,
}

/// Steps that have not finished yet, and the outcome of the last run.
///
/// Persisted in the profile's riverpod storage with awaited writes rather than
/// `persist()`: the schedule is a checkpoint, and the commit has to know it
/// landed before it marks the onboarding complete. A step that fails stays
/// scheduled and is retried on the next start ([resume]); [failed] reports it.
@Riverpod(keepAlive: true)
class SetupStepRunner extends _$SetupStepRunner {
  static const storageKey = 'PendingSetupSteps';

  Future<void>? _running;

  /// Steps [cancel] dropped in this process. A run already under way holds
  /// its own copy of the schedule; this keeps it from running a cancelled
  /// step or writing it back.
  final _cancelled = <SetupStep>{};

  /// The runs of each step under way, so [cancel] can wait them out.
  final _executing = <SetupStep, List<Future<SetupStepOutcome>>>{};

  /// The steps that failed in the last run, for the UI to report.
  @override
  Set<SetupStep> build() => const {};

  Storage<String, String> get _storage =>
      ref.read(riverpodDatabaseStorageProvider);

  Future<Set<SetupStep>> pending() async {
    final data = await _storage.read(storageKey);
    if (data == null) return const {};
    try {
      final names = (jsonDecode(data.data) as List<dynamic>).cast<String>();
      final steps = SetupStep.values.asNameMap();
      return {for (final name in names) ?steps[name]};
    } catch (e, s) {
      logger.w('Unreadable pending setup steps', error: e, stackTrace: s);
      return const {};
    }
  }

  /// Replaces the schedule with [steps]. Awaited: the caller's next step
  /// depends on it.
  Future<void> schedule(Set<SetupStep> steps) async {
    // A new commit asks for these again, whatever was cancelled before.
    _cancelled.removeAll(steps);
    await _write(steps);
  }

  /// Drops [step] for good: it is no longer retried or reported. For when the
  /// user has since made the choice the step would make for them; a retry
  /// would then overwrite it.
  ///
  /// Completes only once no run of [step] is under way: a baseline already
  /// being applied writes its preferences one by one, and would otherwise
  /// land on top of the change the caller makes next.
  Future<void> cancel(SetupStep step) async {
    _cancelled.add(step);
    // A run that starts while this waits is a commit's, which asked for the
    // step again; only the ones under way now are waited for.
    await Future.wait([...?_executing[step]]);
    final scheduled = await pending();
    if (scheduled.contains(step)) await _write({...scheduled}..remove(step));
    if (ref.mounted && state.contains(step)) state = {...state}..remove(step);
  }

  /// The user removed uBlock Origin themselves. A retry of the install would
  /// put it back, and the filter lists would configure a blocker they no
  /// longer have: both are dropped, like a decline.
  Future<void> uBlockRemoved() async {
    await cancel(SetupStep.installUBlock);
    await cancel(SetupStep.optimizedUBlockFilters);
  }

  Future<void> _write(Set<SetupStep> steps) async {
    if (steps.isEmpty) {
      await _storage.delete(storageKey);
      return;
    }
    await _storage.write(
      storageKey,
      jsonEncode([for (final step in steps) step.name]),
      foreverStorageOptions,
    );
  }

  /// Takes [steps] off the schedule as it is stored now, not as the run
  /// read it: a commit that scheduled steps while the run was under way
  /// keeps them.
  Future<void> _drop(Set<SetupStep> steps) async {
    final scheduled = await pending();
    if (scheduled.intersection(steps).isEmpty) return;
    await _write(scheduled.difference(steps));
  }

  /// Whether [resume] was called while a run was under way. That run read
  /// the schedule when it started, so it runs once more for what was
  /// scheduled since.
  var _resumeAgain = false;

  /// Runs whatever is still scheduled, once at a time. Called right after the
  /// commit, and on every start until nothing is left. A call while a run is
  /// under way returns that run, which then runs again.
  Future<void> resume() {
    if (_running case final running?) {
      _resumeAgain = true;
      return running;
    }
    return _running = _runUntilCaughtUp().whenComplete(() {
      _running = null;
    });
  }

  Future<void> _runUntilCaughtUp() async {
    do {
      _resumeAgain = false;
      await _run();
    } while (_resumeAgain && ref.mounted);
  }

  Future<void> _run() async {
    // Steps belong to a finished onboarding: while its commit is still open
    // they wait, and the commit's resume runs them.
    if (await _storage.read(setupCommitJournalKey) != null) return;

    var remaining = (await pending()).difference(_cancelled);
    if (remaining.isEmpty) return;

    final failed = <SetupStep>{};
    for (final step in SetupStep.values) {
      remaining = remaining.difference(_cancelled);
      if (!remaining.contains(step)) continue;
      // The filter lists configure the blocker; without it they would only
      // make a later manual install look preconfigured.
      if (step == SetupStep.optimizedUBlockFilters &&
          failed.contains(SetupStep.installUBlock)) {
        failed.add(step);
        continue;
      }

      final outcome = await runOnce(step);
      if (!ref.mounted) return;
      switch (outcome) {
        case SetupStepOutcome.done:
          remaining = {...remaining}..remove(step);
          await _drop({step});
        case SetupStepOutcome.declined:
          // The user said no (the add-on permission prompt): final, like an
          // opt-out in the onboarding. Dropped with the steps that need it, and not
          // reported, or every start would ask again.
          final dropped = {step, ..._dependents(step)};
          remaining = remaining.difference(dropped);
          await _drop(dropped);
        case SetupStepOutcome.failed:
          failed.add(step);
      }
    }

    if (ref.mounted) state = failed.difference(_cancelled);
  }

  /// The steps that only make sense after [step].
  static Set<SetupStep> _dependents(SetupStep step) => switch (step) {
    SetupStep.installUBlock => const {SetupStep.optimizedUBlockFilters},
    SetupStep.hardeningBaseline || SetupStep.optimizedUBlockFilters => const {},
  };

  /// Runs [step] once, without scheduling it. A failure is logged.
  ///
  /// The returning-user uBlock page calls this directly, so it applies the
  /// same install and filter lists as the commit, but nothing retries it.
  Future<SetupStepOutcome> runOnce(SetupStep step) async {
    final run = _runOnce(step);
    final runs = _executing.putIfAbsent(step, () => [])..add(run);
    try {
      return await run;
    } finally {
      runs.remove(run);
      if (runs.isEmpty) _executing.remove(step);
    }
  }

  Future<SetupStepOutcome> _runOnce(SetupStep step) async {
    try {
      switch (step) {
        case SetupStep.hardeningBaseline:
          // A one-shot call, not a dependency: the runner outlives no part
          // of the preference repository.
          // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
          await ref
              .read(
                unifiedPreferenceSettingsRepositoryProvider(
                  PreferencePartition.user,
                ).notifier,
              )
              .apply();
          return SetupStepOutcome.done;
        case SetupStep.installUBlock:
          final addons = ref.read(browserAddonServiceProvider.notifier);
          // Installed by hand since the step was scheduled: nothing left to
          // do, and installing again would only ask for permissions again.
          if (await addons.isInstalled(ublockAddonId)) {
            return SetupStepOutcome.done;
          }
          final outcome = await addons.install(ublockAddonId);
          return switch (outcome) {
            AddonInstallOutcome.installed => SetupStepOutcome.done,
            AddonInstallOutcome.cancelled => SetupStepOutcome.declined,
            AddonInstallOutcome.failed => SetupStepOutcome.failed,
          };
        case SetupStep.optimizedUBlockFilters:
          final registry = await ref.read(ublockAssetsRegistryProvider.future);
          final optimized = UBlockFilterListSettings.optimizedDefaults(
            registry,
          );
          await ref
              .read(engineSettingsRepositoryProvider.notifier)
              .updateSettings(
                (current) =>
                    current.copyWith.ublockFilterListSettings(optimized),
              );
          return SetupStepOutcome.done;
      }
    } catch (e, s) {
      logger.w('Setup step ${step.name} failed', error: e, stackTrace: s);
      return SetupStepOutcome.failed;
    }
  }

  /// Clears the failure report once it has been shown.
  void acknowledgeFailures() => state = const {};
}
