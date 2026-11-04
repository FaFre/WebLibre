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

import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_draft.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_steps.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

part 'setup_commit.g.dart';

/// Everything an onboarding commit writes, resolved to plain values.
///
/// Written durably before the first setting is touched, so a commit the
/// process did not live to finish can be finished on the next start with the
/// user's original choices — the draft itself is in memory and gone by then.
/// Settings are stored as the keys the commit changes, not whole objects, so
/// finishing later never reverts something else that wrote in between.
@JsonSerializable()
final class SetupCommitJournal {
  const SetupCommitJournal({
    required this.general,
    required this.engine,
    required this.hardeningBaseline,
    required this.layouts,
    required this.steps,
    required this.targetRevision,
  });

  /// Changed `GeneralSettings` JSON keys and their new values.
  final Map<String, Object?> general;

  /// Changed `EngineSettings` JSON keys and their new values.
  final Map<String, Object?> engine;
  final bool hardeningBaseline;

  /// Encoded module layouts by [ModuleSurface.name].
  final Map<String, String> layouts;
  final Set<SetupStep> steps;
  final int targetRevision;

  /// Resolves [draft] against the settings it will be written over.
  factory SetupCommitJournal.resolve(
    SetupDraft draft, {
    required GeneralSettings general,
    required EngineSettings engine,
    required int targetRevision,
  }) => SetupCommitJournal(
    general: _changedKeys(
      _plainJson(general.toJson()),
      _plainJson(draft.applyGeneral(general).toJson()),
    ),
    engine: _changedKeys(
      _plainJson(engine.toJson()),
      _plainJson(draft.applyEngine(engine).toJson()),
    ),
    hardeningBaseline: draft.appliesHardeningBaseline,
    layouts: {
      for (final surface in ModuleSurface.values)
        if (draft.layoutFor(surface) case final layout?)
          surface.name: encodeModuleOrder(layout),
    },
    steps: {
      if (draft.installsUBlock) SetupStep.installUBlock,
      if (draft.appliesOptimizedUBlockFilters) SetupStep.optimizedUBlockFilters,
    },
    targetRevision: targetRevision,
  );

  /// [current] with the journal's general settings written over it.
  GeneralSettings applyGeneral(GeneralSettings current) =>
      GeneralSettings.fromJson({..._plainJson(current.toJson()), ...general});

  /// [current] with the journal's engine settings written over it.
  EngineSettings applyEngine(EngineSettings current) =>
      EngineSettings.fromJson({..._plainJson(current.toJson()), ...engine});

  factory SetupCommitJournal.fromJson(Map<String, dynamic> json) =>
      _$SetupCommitJournalFromJson(json);

  Map<String, dynamic> toJson() => _$SetupCommitJournalToJson(this);
}

/// [json] as plain JSON values (maps, lists, scalars), the way the settings
/// store them: nested models are encoded through their own `toJson`.
Map<String, Object?> _plainJson(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

/// The keys of [after] whose value differs from [before].
Map<String, Object?> _changedKeys(
  Map<String, Object?> before,
  Map<String, Object?> after,
) => {
  for (final MapEntry(:key, :value) in after.entries)
    if (jsonEncode(before[key]) != jsonEncode(value)) key: value,
};

/// Applies an onboarding draft, once, and finishes an interrupted one.
///
/// 1. The draft is resolved against the current settings into a
///    [SetupCommitJournal], which is written durably.
/// 2. The journal is applied: settings, hardening, module layouts. Each write
///    is "set this to that", so applying it again changes nothing. Hardening
///    the engine refuses does not stop the commit: it becomes an external
///    step ([SetupStep.hardeningBaseline]).
/// 3. The onboarding revision is pushed: from here on onboarding never shows
///    again.
/// 4. The external steps are scheduled, then the journal is deleted.
/// 5. The external steps run. One that fails stays scheduled for the next
///    start and is reported. [SetupStepRunner] runs nothing while a journal is
///    still open, so they never run ahead of an unfinished onboarding.
///
/// If the process dies anywhere in 2–4, [resumeInterrupted] finishes the
/// journal on the next start, before the router decides whether onboarding
/// is owed.
///
/// Visibility switches and module layouts are written as plain values: none
/// of the clean-up the old container and isolated-tab tiles ran is triggered
/// (P1).
@Riverpod(keepAlive: true)
class SetupCommitService extends _$SetupCommitService {
  static const _journalOptions = StorageOptions(
    cacheTime: StorageCacheTime.unsafe_forever,
  );

  @override
  void build() {}

  Storage<String, String> get _storage =>
      // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
      ref.read(riverpodDatabaseStorageProvider);

  Future<void> commit(SetupDraft draft, {required int targetRevision}) async {
    final (general, engine) = await (
      ref.read(generalSettingsRepositoryProvider.notifier).fetchSettings(),
      ref.read(engineSettingsRepositoryProvider.notifier).fetchSettings(),
    ).wait;

    final journal = SetupCommitJournal.resolve(
      draft,
      general: general,
      engine: engine,
      targetRevision: targetRevision,
    );

    await _storage.write(
      setupCommitJournalKey,
      jsonEncode(journal.toJson()),
      _journalOptions,
    );
    await _apply(journal);

    unawaited(ref.read(setupStepRunnerProvider.notifier).resume());
  }

  /// Finishes a commit an earlier process started but did not complete.
  /// Returns whether there was one. A journal that cannot be read is dropped
  /// (logged): the onboarding then shows again and its commit overwrites
  /// whatever the broken one had written.
  Future<bool> resumeInterrupted() async {
    final data = await _storage.read(setupCommitJournalKey);
    if (data == null) return false;

    final SetupCommitJournal journal;
    try {
      journal = SetupCommitJournal.fromJson(
        jsonDecode(data.data) as Map<String, dynamic>,
      );
    } catch (e, s) {
      logger.e('Unreadable onboarding commit journal', error: e, stackTrace: s);
      await _storage.delete(setupCommitJournalKey);
      return false;
    }

    logger.i('Finishing an interrupted onboarding commit');
    await _apply(journal);
    unawaited(ref.read(setupStepRunnerProvider.notifier).resume());
    return true;
  }

  Future<void> _apply(SetupCommitJournal journal) async {
    if (journal.general.isNotEmpty) {
      await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings(journal.applyGeneral);
    }
    if (journal.engine.isNotEmpty) {
      await ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings(journal.applyEngine);
    }

    // Through the step runner, and scheduled as a step when it fails: a
    // baseline the engine refuses would otherwise fail this commit, every
    // retry and every resume at the same point, and the onboarding could
    // never finish. As a step it is retried on each start and reported.
    final runner = ref.read(setupStepRunnerProvider.notifier);
    final hardeningFailed =
        journal.hardeningBaseline &&
        await runner.runOnce(SetupStep.hardeningBaseline) !=
            SetupStepOutcome.done;

    final surfaces = ModuleSurface.values.asNameMap();
    for (final MapEntry(key: name, value: encoded) in journal.layouts.entries) {
      final surface = surfaces[name];
      if (surface == null) continue;
      await _storage.write(surface.key, encoded, moduleOrderStorageOptions);
      ref.invalidate(searchModuleOrderProvider(surface));
    }

    await ref
        .read(onboardingRepositoryProvider.notifier)
        .pushRevision(journal.targetRevision);

    await runner.schedule({
      ...journal.steps,
      if (hardeningFailed) SetupStep.hardeningBaseline,
    });
    await _storage.delete(setupCommitJournalKey);
  }
}
