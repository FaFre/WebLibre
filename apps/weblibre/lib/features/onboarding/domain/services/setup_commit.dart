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
import 'package:weblibre/core/storage_options.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_steps.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/utils/ordered_layout.dart';

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
    this.toolbarButtons = const {},
    this.menuLayout,
    required this.steps,
    required this.targetRevision,
  });

  /// Changed `GeneralSettings` JSON keys and their new values.
  final Map<String, Object?> general;

  /// Changed `EngineSettings` JSON keys and their new values.
  final Map<String, Object?> engine;
  final bool hardeningBaseline;

  /// The module layouts the commit writes, by surface. A surface this
  /// version does not know is skipped.
  @JsonKey(fromJson: _layoutsFromJson, toJson: _layoutsToJson)
  final Map<ModuleSurface, List<ModuleOrderEntry>> layouts;

  /// The whole button set of each toolbar the draft changed, by
  /// [ToolbarConfigLocation.name]. Absent from a journal an older version
  /// wrote.
  @_ToolbarButtonConfigConverter()
  final Map<String, List<ToolbarButtonConfig>> toolbarButtons;

  /// The menu arrangement, or null to leave the profile's. Absent from a
  /// journal an older version wrote.
  @JsonKey(fromJson: _menuLayoutFromJson, toJson: _menuLayoutToJson)
  final List<MenuSectionEntry>? menuLayout;
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
        surface: ?draft.layoutFor(surface),
    },
    toolbarButtons: {
      for (final MapEntry(key: location, value: configs)
          in draft.toolbarButtons.entries)
        location.name: configs,
    },
    menuLayout: draft.menuLayout,
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

/// A journal value that is a list, or — as a journal written before the
/// layouts were typed stored it — that list as JSON text. Such a journal can
/// be cut short after the onboarding was marked complete, and dropping it
/// then would lose the steps it still has to schedule.
Object? _jsonList(Object? json) => json is String ? jsonDecode(json) : json;

Map<ModuleSurface, List<ModuleOrderEntry>> _layoutsFromJson(
  Map<String, dynamic> json,
) {
  return {
    for (final surface in ModuleSurface.values)
      if (json[surface.name] case final Object value)
        surface: mergeModuleOrderWithDefaults(
          layoutEntriesFromJson(_jsonList(value), ModuleOrderEntry.fromJson),
          surface.defaultModules,
        ),
  };
}

Map<String, Object?> _layoutsToJson(
  Map<ModuleSurface, List<ModuleOrderEntry>> layouts,
) => {
  for (final MapEntry(key: surface, value: layout) in layouts.entries)
    surface.name: [for (final entry in layout) entry.toJson()],
};

List<MenuSectionEntry>? _menuLayoutFromJson(Object? json) => switch (json) {
  null => null,
  _ => mergeMenuLayoutWithDefaults(
    layoutEntriesFromJson(_jsonList(json), MenuSectionEntry.fromJson),
  ),
};

List<Object?>? _menuLayoutToJson(List<MenuSectionEntry>? layout) =>
    switch (layout) {
      null => null,
      final layout => [for (final section in layout) section.toJson()],
    };

/// A button as the journal stores it. Its long-press action goes by name, as
/// every persisted [BrowserAction] binding does; an action this version does
/// not know is dropped, which leaves the button's own long press.
final class _ToolbarButtonConfigConverter
    implements JsonConverter<ToolbarButtonConfig, Map<String, dynamic>> {
  const _ToolbarButtonConfigConverter();

  @override
  ToolbarButtonConfig fromJson(Map<String, dynamic> json) =>
      ToolbarButtonConfig(
        buttonId: json['buttonId'] as String,
        orderKey: json['orderKey'] as String,
        isVisible: json['isVisible'] as bool,
        fallbackId: json['fallbackId'] as String?,
        longPressAction: switch (json['longPressAction']) {
          final String name => BrowserAction.values.asNameMap()[name],
          _ => null,
        },
      );

  @override
  Map<String, dynamic> toJson(ToolbarButtonConfig config) => {
    'buttonId': config.buttonId,
    'orderKey': config.orderKey,
    'isVisible': config.isVisible,
    'fallbackId': config.fallbackId,
    'longPressAction': config.longPressAction?.name,
  };
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
/// 2. The journal is applied: settings, hardening, module layouts, toolbar
///    buttons, the menu. Each write is "set this to that", so applying it
///    again changes nothing. Hardening
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
      foreverStorageOptions,
    );
    await _apply(journal);

    unawaited(ref.read(setupStepRunnerProvider.notifier).resume());
  }

  /// Finishes a commit an earlier process started but did not complete.
  /// Returns whether there was one. A journal that cannot be read is dropped
  /// (logged). Cut short before the revision was pushed, the onboarding then
  /// shows again and its commit overwrites whatever the broken one had
  /// written; cut short after it, the onboarding counts as done and the steps
  /// the journal still had to schedule are lost. Journals written before the
  /// layouts were typed are read too ([_jsonList]) for that reason.
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

    for (final MapEntry(key: surface, value: layout)
        in journal.layouts.entries) {
      await _writeThrough(
        surface.key,
        encodeModuleOrder(layout),
        () => ref
            .read(searchModuleOrderProvider(surface).notifier)
            .replace(layout),
      );
    }

    final locations = ToolbarConfigLocation.values.asNameMap();
    for (final MapEntry(key: name, value: configs)
        in journal.toolbarButtons.entries) {
      final location = locations[name];
      if (location == null) continue;
      await ref
          .read(toolbarConfigRepositoryProvider(location))
          .saveAll(configs);
    }

    if (journal.menuLayout case final layout?) {
      await _writeThrough(
        menuLayoutStorageKey,
        encodeMenuLayout(layout),
        () => ref.read(menuLayoutProvider.notifier).replace(layout),
      );
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

  /// Stores [encoded] under [key] first, so a commit cut short is resumed
  /// from it, then hands it to the provider that persists there ([replace]):
  /// `persist` reads the store only on a provider's first build, and the
  /// provider may be built already (an invalidation would rebuild it with
  /// what it had).
  Future<void> _writeThrough(
    String key,
    String encoded,
    void Function() replace,
  ) async {
    await _storage.write(key, encoded, foreverStorageOptions);
    replace();
  }
}
