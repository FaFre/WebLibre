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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';
import 'package:weblibre/features/onboarding/domain/services/preset_bindings.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

part 'setup_draft.g.dart';

/// What a general settings edit of the onboarding changes. A preset change
/// keeps the [setting] edits and drops the [visibility] ones: the preset
/// decides what is shown, and nothing else.
enum SetupEditKind {
  /// A settings write: the Search and Layout answers, and everything the
  /// settings screens save (`SaveGeneralSettingsController.save`).
  setting,

  /// A visibility switch change: "Show or hide features", the goals that
  /// show features, and showing a hidden feature from a grayed control.
  visibility,
}

/// One general settings edit of the onboarding, kept in the order made.
typedef SetupEdit = ({SetupEditKind kind, UpdateGeneralSettingsFunc edit});

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
    this.edits = const [],
    this.engineEdits = const [],
    this.layouts = const {},
    this.toolbarButtons = const {},
    this.menuLayout,
    this.hardeningBaseline,
    this.installUBlock,
    this.optimizedUBlockFilters,
  });

  final SetupPreset preset;

  /// The setups the user asked to open after the commit
  /// ([SetupGoal.opensAfterCommit]). Other goals are no state of their own:
  /// they are the settings they name ([goalSelected]).
  final Set<SetupGoal> goals;

  /// Every general settings edit, in the order made: applied in that order,
  /// so the latest explicit choice wins whichever screen made it (the Layout
  /// step's tab bar position and the Toolbar & layout editor's, say).
  final List<SetupEdit> edits;
  final List<UpdateEngineSettingsFunc> engineEdits;

  /// Module layouts rearranged in the onboarding, by surface.
  final Map<ModuleSurface, List<ModuleOrderEntry>> layouts;

  /// Toolbar buttons changed in the onboarding, the whole set of each
  /// toolbar changed. A toolbar not in here keeps the profile's buttons.
  final Map<ToolbarConfigLocation, List<ToolbarButtonConfig>> toolbarButtons;

  /// The browser menu as arranged in the onboarding; null keeps the
  /// profile's.
  final List<MenuSectionEntry>? menuLayout;

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

  /// Whether a preset change would drop something: a feature shown or
  /// hidden, by a switch or a goal that shows features. Everything else, the
  /// goals that open after the commit included, stays
  /// ([SetupDraftController.selectPreset]).
  bool get hasVisibilityChanges =>
      edits.any((edit) => edit.kind == SetupEditKind.visibility);

  /// Whether [goal] is on, given [applied], this draft applied
  /// ([applyGeneral]). Read from the settings, so it never disagrees with
  /// the visibility switches: a goal that shows features is on while all of them are
  /// shown, on-device AI while it is shown and turned on. A requested setup
  /// is on while it is asked for and what it needs is shown; hidden again
  /// with its switch, it is off and does not open.
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

  /// [settings] with the preset, what the requested setups need shown, and
  /// then every edit ([edits]) in the order made. Idempotent: applying it to
  /// its own result changes nothing.
  ///
  /// A requested setup's switches are applied on their own rather than as an
  /// edit, so they follow the request: they stay shown when the preset
  /// changes, and go when the request is withdrawn unless the preset or an
  /// edit shows them too. They come before the edits, so a later explicit
  /// hide still wins ([SetupDraftController.setGoal] shows them again with
  /// an edit when the setup is asked for after that).
  GeneralSettings applyGeneral(GeneralSettings settings) {
    var updated = applyGeneralPreset(settings, preset);
    for (final goal in goals) {
      for (final visibilitySwitch in goal.switches) {
        updated = updated.withVisibilitySwitch(visibilitySwitch, enabled: true);
      }
    }
    for (final (kind: _, :edit) in edits) {
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

  /// This draft started again from [preset], which decides what is shown and
  /// nothing else: the visibility edits (switches, goals that show features
  /// or turn on AI) were relative to the old preset and are dropped
  /// ([hasVisibilityChanges]). Every settings edit, the engine edits, the
  /// arrangements and the hardening and uBlock Origin choices stay: a
  /// setting the new preset hides stops applying and comes back when it is
  /// shown (H1), which the preset step warns about first. So do the setups
  /// asked for after the commit, and what they need shown ([applyGeneral]);
  /// a setup whose switches were hidden was turned off there, and stays off.
  SetupDraft withPreset(SetupPreset preset) {
    final applied = applyGeneral(GeneralSettings.withDefaults());
    return copyWith(
      preset: preset,
      goals: {
        for (final goal in goals)
          if (goalSelected(goal, applied)) goal,
      },
      edits: [
        for (final edit in edits)
          if (edit.kind == SetupEditKind.setting) edit,
      ],
    );
  }

  /// The layout the commit writes for [surface], or null to leave it alone
  /// (rule 2: only where the preset differs from the code default, or the
  /// user rearranged it in the onboarding).
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

/// The onboarding's draft: open while a fresh onboarding is owed, null
/// otherwise.
///
/// It opens and closes by itself, from the profile's onboarding revision
/// rather than from a route or widget: a profile that never completed an
/// onboarding gets a fresh draft, and the commit's `pushRevision` closes it.
/// A review after an update has a revision, so it never gets one and its
/// edits land in the profile directly. Kept alive because the edit layer's
/// kept-alive providers (`storedGeneralSettings` and the save controllers)
/// follow it.
///
/// [build] must watch nothing but that one answer, and keeps the open draft
/// across its rebuilds: while the revision is unknown (reloading, failed) the
/// draft stays as it is, open or closed, rather than dropping the user's
/// choices and every edit made until it is known again.
///
/// Only the edit and displayed layers may read it, never the live layer
/// services behave by: nothing reaches the browser before Done.
@Riverpod(keepAlive: true)
class SetupDraftController extends _$SetupDraftController {
  @override
  SetupDraft? build() {
    final owed = ref.watch(
      completedOnboardingRevisionProvider.select(
        (revision) => revision.hasValue ? revision.value == null : null,
      ),
    );
    return switch (owed) {
      true => stateOrNull ?? const SetupDraft(preset: SetupPreset.average),
      false => null,
      null => stateOrNull,
    };
  }

  /// Starts again from [preset] ([SetupDraft.withPreset]).
  void selectPreset(SetupPreset preset) {
    final draft = state;
    if (draft == null || preset == draft.preset) return;
    state = draft.withPreset(preset);
  }

  /// Files a settings write ([SetupEditKind.setting]).
  void editGeneral(UpdateGeneralSettingsFunc edit) =>
      _edit(SetupEditKind.setting, edit);

  /// Files a visibility switch change ([SetupEditKind.visibility]): an edit
  /// that only shows or hides features, and that a preset change drops.
  void editVisibility(UpdateGeneralSettingsFunc edit) =>
      _edit(SetupEditKind.visibility, edit);

  /// Shows or hides [visibilitySwitch], as "Show or hide features" does
  /// ([GeneralSettings.withVisibilitySwitch]).
  void setVisibilitySwitch(
    VisibilitySwitch visibilitySwitch, {
    required bool enabled,
  }) => editVisibility(
    (current) =>
        current.withVisibilitySwitch(visibilitySwitch, enabled: enabled),
  );

  void _edit(SetupEditKind kind, UpdateGeneralSettingsFunc edit) => _update(
    (draft) =>
        draft.copyWith(edits: [...draft.edits, (kind: kind, edit: edit)]),
  );

  void editEngine(UpdateEngineSettingsFunc edit) => _update(
    (draft) => draft.copyWith(engineEdits: [...draft.engineEdits, edit]),
  );

  /// Puts [previous] back, for an Undo of the change that left [changed]:
  /// only while nothing else has changed the draft since, so a late Undo
  /// never throws newer changes away.
  void undo({required SetupDraft changed, required SetupDraft previous}) {
    if (!ref.mounted || !identical(state, changed)) return;
    state = previous;
  }

  /// A goal that shows features sets their visibility switches, like
  /// "Show or hide features" does. On-device AI is turned on or off; turning it off keeps
  /// its controls shown. A setup that opens after the commit is remembered
  /// for then, and shows what it needs ([SetupDraft.applyGeneral]);
  /// withdrawing it only cancels the setup.
  void setGoal(SetupGoal goal, {required bool selected}) {
    final draft = state;
    if (draft == null) return;

    if (goal.opensAfterCommit) {
      final updated = draft.copyWith(
        goals: selected
            ? {...draft.goals, goal}
            : ({...draft.goals}..remove(goal)),
      );
      state = updated;
      // A visibility edit made before can still hide what the setup needs:
      // asking for it now is the later, explicit choice.
      if (selected && !_draftShows(updated, goal.switches)) {
        _showSwitches(goal.switches);
      }
      return;
    }

    if (goal.turnsOnLocalAi) {
      // One edit: AI turned on is shown, and a preset change drops both.
      editVisibility((current) {
        final updated = current.copyWith(enableLocalAiFeatures: selected);
        return selected ? _withShown(updated, goal.switches) : updated;
      });
      return;
    }

    editVisibility((current) {
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

  /// Whether [draft] shows [switches]. The preset writes every visibility
  /// switch, so the settings it is applied over do not change the answer,
  /// apart from the legacy settings two switches inherit, which only ever
  /// hide more: the defaults show everything.
  static bool _draftShows(SetupDraft draft, List<VisibilitySwitch> switches) {
    final applied = draft.applyGeneral(GeneralSettings.withDefaults());
    return switches.every(applied.isVisibilitySwitchShown);
  }

  void _showSwitches(List<VisibilitySwitch> switches) =>
      editVisibility((current) => _withShown(current, switches));

  static GeneralSettings _withShown(
    GeneralSettings settings,
    List<VisibilitySwitch> switches,
  ) => switches.fold(
    settings,
    (updated, visibilitySwitch) =>
        updated.withVisibilitySwitch(visibilitySwitch, enabled: true),
  );

  void setLayout(ModuleSurface surface, List<ModuleOrderEntry> layout) =>
      _update(
        (draft) => draft.copyWith(layouts: {...draft.layouts, surface: layout}),
      );

  void setToolbarButtons(
    ToolbarConfigLocation location,
    List<ToolbarButtonConfig> configs,
  ) => _update(
    (draft) => draft.copyWith(
      toolbarButtons: {...draft.toolbarButtons, location: configs},
    ),
  );

  void setMenuLayout(List<MenuSectionEntry> layout) =>
      _update((draft) => draft.copyWith(menuLayout: layout));

  void setHardeningBaseline(bool value) =>
      _update((draft) => draft.copyWith(hardeningBaseline: value));

  void setInstallUBlock(bool value) =>
      _update((draft) => draft.copyWith(installUBlock: value));

  void setOptimizedUBlockFilters(bool value) =>
      _update((draft) => draft.copyWith(optimizedUBlockFilters: value));

  /// Applies [change] to the open draft; nothing while none is open.
  void _update(SetupDraft Function(SetupDraft draft) change) {
    final draft = state;
    if (draft != null) state = change(draft);
  }
}

/// The general settings as they will be after the commit: the profile's
/// with the draft applied, or the profile's while no draft is open. What the
/// onboarding's settings widgets show.
@Riverpod(keepAlive: true)
GeneralSettings draftGeneralSettings(Ref ref) {
  final draft = ref.watch(setupDraftControllerProvider);
  final profile = ref.watch(profileGeneralSettingsProvider);
  return draft?.applyGeneral(profile) ?? profile;
}

/// Like [draftGeneralSettings], for the engine settings.
@Riverpod(keepAlive: true)
EngineSettings draftEngineSettings(Ref ref) {
  final draft = ref.watch(setupDraftControllerProvider);
  final profile = ref.watch(profileEngineSettingsProvider);
  return draft?.applyEngine(profile) ?? profile;
}
