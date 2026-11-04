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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';
import 'package:weblibre/features/onboarding/domain/services/preset_bindings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'setup_draft.g.dart';

/// Which onboarding step a settings edit came from. A preset change keeps the
/// Basics answers and discards the Customize changes made on top of the old
/// preset.
enum SetupDraftStep { basics, customize }

/// Everything the onboarding will write, held until Done.
///
/// Nothing in here touches the live settings. The commit applies it once
/// ([SetupDraft.applyGeneral] and friends are pure), so going back or changing
/// the preset before Done leaves nothing behind. The preset itself is
/// never stored: after the commit the draft is discarded.
@CopyWith()
final class SetupDraft {
  const SetupDraft({
    required this.preset,
    this.goals = const {},
    this.basicsEdits = const [],
    this.customizeEdits = const [],
    this.engineEdits = const [],
    this.layouts = const {},
    this.hardeningBaseline,
    this.installUBlock,
    this.optimizedUBlockFilters,
  });

  final SetupPreset preset;

  /// The setups the user asked to open after the commit
  /// ([SetupGoal.opensAfterCommit]). Other goals are no state of their own:
  /// they are the settings they name ([goalSelected]).
  final Set<SetupGoal> goals;

  /// Edits from Basics (search provider, tab bar position), in order.
  final List<UpdateGeneralSettingsFunc> basicsEdits;

  /// Edits from Customize and the settings screens it opens, in order.
  final List<UpdateGeneralSettingsFunc> customizeEdits;
  final List<UpdateEngineSettingsFunc> engineEdits;

  /// Module layouts rearranged in Customize, by surface.
  final Map<ModuleSurface, List<ModuleOrderEntry>> layouts;

  /// Overrides for the parts that are not plain settings; null takes the
  /// preset's value.
  final bool? hardeningBaseline;
  final bool? installUBlock;
  final bool? optimizedUBlockFilters;

  /// Whether the commit applies the recommended hardening preferences.
  bool get appliesHardeningBaseline =>
      hardeningBaseline ??
      presetValueIs(
        FeatureId.privacyEngineHardeningBaseline,
        preset,
        PolicyToken.enabled,
      );

  /// Whether the commit installs uBlock Origin (`recommend_install`).
  bool get installsUBlock =>
      installUBlock ??
      presetValueIs(
        FeatureId.extensionsUblockStarter,
        preset,
        PolicyToken.recommendInstall,
      );

  /// Whether the commit applies uBlock Origin's optimized filter lists. Only
  /// with the install: the lists configure the blocker being installed.
  bool get appliesOptimizedUBlockFilters =>
      installsUBlock &&
      (optimizedUBlockFilters ??
          presetValueIs(
            FeatureId.extensionsUblockOptimizedFilters,
            preset,
            PolicyToken.recommend,
          ));

  /// Whether a preset change would drop something: Customize changes, goals
  /// that show features, rearranged layouts, the hardening or uBlock Origin
  /// choices. The Basics answers and the goals that open after the commit
  /// stay.
  bool get hasCustomizeChanges =>
      customizeEdits.isNotEmpty ||
      engineEdits.isNotEmpty ||
      layouts.isNotEmpty ||
      hardeningBaseline != null ||
      installUBlock != null ||
      optimizedUBlockFilters != null;

  /// Whether [goal] is on, given [applied], this draft applied
  /// ([applyGeneral]). Read from the settings, so it never disagrees with
  /// Customize: a goal that shows features is on while all of them are
  /// shown, on-device AI while it is shown and turned on. A requested setup
  /// is on while it is asked for and what it needs is shown; hidden again in
  /// Customize, it is off and does not open.
  bool goalSelected(SetupGoal goal, GeneralSettings applied) {
    final shown = goal.switches.every(applied.isVisibilitySwitchShown);
    if (goal.opensAfterCommit) return goals.contains(goal) && shown;
    if (goal.turnsOnLocalAi) return shown && applied.enableLocalAiFeatures;
    return shown;
  }

  /// The setups to open after the commit, given [applied]: the selected
  /// ones ([goalSelected]), in [SetupGoal] order.
  List<SetupGoal> setupsToOpen(GeneralSettings applied) => [
    for (final goal in SetupGoal.values)
      if (goal.opensAfterCommit && goalSelected(goal, applied)) goal,
  ];

  /// [settings] with the preset, the Basics answers, what the requested
  /// setups need shown, and the Customize changes (goals that show features
  /// included) applied, in that order. Idempotent: applying it to its own
  /// result changes nothing.
  ///
  /// A requested setup's switches are applied on their own rather than as a
  /// Customize change, so they follow the request: they stay shown when the
  /// preset changes, and go when the request is withdrawn unless the preset
  /// or Customize shows them too.
  GeneralSettings applyGeneral(GeneralSettings settings) {
    var updated = applyGeneralPreset(settings, preset);
    for (final edit in basicsEdits) {
      updated = edit(updated);
    }
    for (final goal in goals) {
      for (final visibilitySwitch in goal.switches) {
        updated = updated.withVisibilitySwitch(visibilitySwitch, enabled: true);
      }
    }
    for (final edit in customizeEdits) {
      updated = edit(updated);
    }
    return updated;
  }

  EngineSettings applyEngine(EngineSettings settings) {
    var updated = applyEnginePreset(settings, preset);
    for (final edit in engineEdits) {
      updated = edit(updated);
    }
    return updated;
  }

  /// The layout the commit writes for [surface], or null to leave it alone
  /// (rule 2: only where the preset differs from the code default, or the
  /// user rearranged it in Customize).
  List<ModuleOrderEntry>? layoutFor(ModuleSurface surface) {
    if (layouts[surface] case final layout?) return layout;
    if (surface != ModuleSurface.newTab) return null;

    final definition = presetNewTabLayout(preset);
    if (definition == null) return null;

    return mergeModuleOrderWithDefaults([
      for (final (:type, :visible) in definition)
        ModuleOrderEntry(type: type, visible: visible),
    ], surface.defaultModules);
  }
}

/// The onboarding's draft. The onboarding screen watches it while it is
/// mounted, which includes every route Customize pushes over it, so it ends
/// with the onboarding; [discard] ends it right after the commit, and a fresh
/// onboarding starts a fresh one.
@Riverpod()
class SetupDraftController extends _$SetupDraftController {
  @override
  SetupDraft build() => const SetupDraft(preset: SetupPreset.average);

  /// Starts again from [preset]. Basics answers and the setups asked for
  /// after the commit stay, and so does what those setups need shown
  /// ([SetupDraft.applyGeneral]); everything changed in Customize, goals that
  /// show features or turn on AI included, was relative to the old preset
  /// and is dropped ([SetupDraft.hasCustomizeChanges]). A setup whose
  /// switches were hidden in Customize was turned off there, and stays off.
  void selectPreset(SetupPreset preset) {
    if (preset == state.preset) return;
    final applied = state.applyGeneral(GeneralSettings.withDefaults());
    state = SetupDraft(
      preset: preset,
      goals: {
        for (final goal in state.goals)
          if (state.goalSelected(goal, applied)) goal,
      },
      basicsEdits: state.basicsEdits,
    );
  }

  void editGeneral(SetupDraftStep step, UpdateGeneralSettingsFunc edit) {
    state = switch (step) {
      SetupDraftStep.basics => state.copyWith(
        basicsEdits: [...state.basicsEdits, edit],
      ),
      SetupDraftStep.customize => state.copyWith(
        customizeEdits: [...state.customizeEdits, edit],
      ),
    };
  }

  void editEngine(UpdateEngineSettingsFunc edit) {
    state = state.copyWith(engineEdits: [...state.engineEdits, edit]);
  }

  /// Puts [previous] back, for an Undo of the change that left [changed]:
  /// only while nothing else has changed the draft since, so a late Undo
  /// never throws newer changes away.
  void undo({required SetupDraft changed, required SetupDraft previous}) {
    if (!ref.mounted || !identical(state, changed)) return;
    state = previous;
  }

  /// A goal that shows features sets their visibility switches, like
  /// Customize does. On-device AI is turned on or off; turning it off keeps
  /// its controls shown. A setup that opens after the commit is remembered
  /// for then, and shows what it needs ([SetupDraft.applyGeneral]);
  /// withdrawing it only cancels the setup.
  void setGoal(SetupGoal goal, {required bool selected}) {
    if (goal.opensAfterCommit) {
      state = state.copyWith(
        goals: selected
            ? {...state.goals, goal}
            : ({...state.goals}..remove(goal)),
      );
      // A Customize change made before can still hide what the setup needs:
      // asking for it now is the later, explicit choice.
      if (selected && !_draftShows(goal.switches)) {
        _showSwitches(goal.switches);
      }
      return;
    }

    if (goal.turnsOnLocalAi) {
      editGeneral(SetupDraftStep.customize, (current) {
        final updated = current.copyWith(enableLocalAiFeatures: selected);
        return selected ? _withShown(updated, goal.switches) : updated;
      });
      return;
    }

    editGeneral(SetupDraftStep.customize, (current) {
      var updated = current;
      for (final visibilitySwitch in goal.switches) {
        updated = updated.withVisibilitySwitch(
          visibilitySwitch,
          enabled: selected,
        );
      }
      return updated;
    });
  }

  /// Whether the draft shows [switches]. The preset writes every visibility
  /// switch, so the settings it is applied over do not change the answer,
  /// apart from the legacy settings two switches inherit, which only ever
  /// hide more: the defaults show everything.
  bool _draftShows(List<VisibilitySwitch> switches) {
    final applied = state.applyGeneral(GeneralSettings.withDefaults());
    return switches.every(applied.isVisibilitySwitchShown);
  }

  void _showSwitches(List<VisibilitySwitch> switches) => editGeneral(
    SetupDraftStep.customize,
    (current) => _withShown(current, switches),
  );

  static GeneralSettings _withShown(
    GeneralSettings settings,
    List<VisibilitySwitch> switches,
  ) => switches.fold(
    settings,
    (updated, visibilitySwitch) =>
        updated.withVisibilitySwitch(visibilitySwitch, enabled: true),
  );

  void setLayout(ModuleSurface surface, List<ModuleOrderEntry> layout) {
    state = state.copyWith(layouts: {...state.layouts, surface: layout});
  }

  void setHardeningBaseline(bool value) {
    state = state.copyWith(hardeningBaseline: value);
  }

  void setInstallUBlock(bool value) {
    state = state.copyWith(installUBlock: value);
  }

  void setOptimizedUBlockFilters(bool value) {
    state = state.copyWith(optimizedUBlockFilters: value);
  }

  void discard() => ref.invalidateSelf();
}

/// The general settings as they will be after the commit: the live settings
/// with the draft applied. What the onboarding's settings widgets show.
///
/// Reads the repository, never `storedGeneralSettingsProvider` or
/// `generalSettingsWithDefaultsProvider`: the draft scope overrides those
/// with this provider, and Riverpod detects
/// cycles by provider rather than by container. Watching it here would make
/// every rebuild after the first one throw a CircularDependencyError, although
/// the root and the scoped element are different.
@Riverpod()
GeneralSettings draftGeneralSettings(Ref ref) {
  final draft = ref.watch(setupDraftControllerProvider);
  final live = ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.value ?? GeneralSettings.withDefaults(),
    ),
  );
  return draft.applyGeneral(live);
}

/// Like [draftGeneralSettings], for the engine settings, and for the same
/// reason reading the repository rather than `storedEngineSettingsProvider`
/// or `engineSettingsWithDefaultsProvider`.
@Riverpod()
EngineSettings draftEngineSettings(Ref ref) {
  final draft = ref.watch(setupDraftControllerProvider);
  final live = ref.watch(
    engineSettingsRepositoryProvider.select(
      (value) => value.value ?? EngineSettings.withDefaults(),
    ),
  );
  return draft.applyEngine(live);
}
