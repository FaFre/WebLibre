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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/onboarding/domain/services/preset_bindings.dart';
import 'package:weblibre/features/onboarding/presentation/utils/setup_preset_l10n.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/customize_setup.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/feature_control_inputs.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/dialogs/hide_feature_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/visibility_switch_l10n.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// What the settings search indexes for Feature Control: one entry per
/// visibility switch. The screen itself is the onboarding's "Show or hide
/// features" component.
List<SettingsSectionDefinition> featureControlSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_featureControlSectionTitle,
      entries: [
        for (final visibilitySwitch in VisibilitySwitch.values)
          SettingsEntryDefinition.searchOnly(
            title: visibilitySwitch.label(context),
            subtitle: visibilitySwitch.description(context),
          ),
      ],
    ),
  ];
}

/// [current] with the visibility switches [preset] starts a new install with,
/// and nothing else of the preset: only what is shown changes (P1). Hidden
/// first, then shown, so a switch a shown feature needs stays on
/// ([GeneralSettings.withVisibilitySwitch]).
GeneralSettings withPresetVisibility(
  GeneralSettings current,
  SetupPreset preset,
) {
  final target = {
    for (final visibilitySwitch in VisibilitySwitch.values)
      visibilitySwitch: presetSwitchValue(visibilitySwitch, preset),
  };
  var updated = current;
  for (final enabled in [false, true]) {
    for (final MapEntry(key: visibilitySwitch, value: on) in target.entries) {
      if (on == enabled &&
          updated.isVisibilitySwitchShown(visibilitySwitch) != on) {
        updated = updated.withVisibilitySwitch(visibilitySwitch, enabled: on);
      }
    }
  }
  return updated;
}

/// [current] with what a switch change from [before] to [after] wrote put
/// back: every visibility switch it changed, the ones a shown feature needed
/// included, and the legacy settings it turned on
/// ([GeneralSettings.withVisibilitySwitch]). Everything else in [current]
/// stays as it is now.
GeneralSettings revertVisibilityChange(
  GeneralSettings current, {
  required GeneralSettings before,
  required GeneralSettings after,
}) {
  final switches = {...current.visibilitySwitches};
  for (final visibilitySwitch in VisibilitySwitch.values) {
    final prior = before.visibilitySwitches[visibilitySwitch];
    if (prior == after.visibilitySwitches[visibilitySwitch]) continue;
    if (prior == null) {
      switches.remove(visibilitySwitch);
    } else {
      switches[visibilitySwitch] = prior;
    }
  }
  return current.copyWith(
    visibilitySwitches: switches,
    showContainerUi: before.showContainerUi != after.showContainerUi
        ? before.showContainerUi
        : current.showContainerUi,
    showIsolatedTabUi: before.showIsolatedTabUi != after.showIsolatedTabUi
        ? before.showIsolatedTabUi
        : current.showIsolatedTabUi,
  );
}

/// Whether hiding [visibilitySwitch] hides something the user already set
/// up, which keeps working and stays within reach (P5): worth saying so.
bool _setUpBehind(
  FeatureControlInputs inputs,
  VisibilitySwitch visibilitySwitch,
) => switch (visibilitySwitch) {
  VisibilitySwitch.connections => inputs.connectionsInUse,
  VisibilitySwitch.containers => inputs.hasContainers,
  _ => false,
};

void _sayWhatKeepsWorking(
  BuildContext context,
  FeatureControlInputs inputs,
  Iterable<VisibilitySwitch> hidden,
) {
  if (!hidden.any((s) => _setUpBehind(inputs, s))) return;
  showInfoMessage(
    context,
    AppLocalizations.of(context).settings_featureControlHiddenInUse,
  );
}

/// Before one switch changes, in Feature Control and in the onboarding's
/// "Show or hide features" alike ([VisibilitySwitchChange]). Hiding a
/// feature whose changed settings would stop applying asks first, and that
/// confirmation also says what keeps working; without one, a snackbar says
/// it afterwards. Showing one never asks: the changes that apply again are
/// the user's own, so a snackbar names them with an Undo. A restart is
/// offered instead when one of them is read only at engine start, so two
/// prompts never stack.
///
/// In the onboarding nothing is applied before Done, so no restart is
/// offered there ([settingsEditsAreLiveProvider]).
Future<Future<void> Function(BuildContext context)?> prepareSwitchChange(
  BuildContext context,
  WidgetRef ref,
  FeatureControlInputs inputs,
  VisibilitySwitch visibilitySwitch, {
  required bool enabled,
}) async {
  // The callback below runs after the save, from the switch's own context.
  final container = ref.container;
  final live = ref.read(settingsEditsAreLiveProvider);
  final stored = inputs.stored;
  final next = stored.general.withVisibilitySwitch(
    visibilitySwitch,
    enabled: enabled,
  );

  if (enabled) {
    final applyingAgain = settingsApplyingAgain(stored, next);
    return (BuildContext context) async {
      if (live && applyingAgain.any((setting) => setting.appliesOnRestart)) {
        await offerRestartForStartupSettings(context, container, applyingAgain);
        return;
      }
      if (applyingAgain.isEmpty) return;

      // Read before the await: the switch may be gone when Undo is tapped.
      final save = ref.read(saveGeneralSettingsControllerProvider.notifier);
      final undo = await showUndoMessage(
        context,
        AppLocalizations.of(context).settings_featureControlShownApplyingAgain,
      );
      if (!undo) return;
      final saved = await save.saveVisibility(
        (current) => revertVisibilityChange(
          current,
          before: stored.general,
          after: next,
        ),
      );
      if (!saved && context.mounted) {
        showErrorMessage(
          context,
          AppLocalizations.of(context).onboarding_customizeSaveFailed,
        );
      }
    };
  }

  final stopping = settingsStoppingToApply(stored, next);
  if (stopping.isEmpty) {
    return (BuildContext context) {
      _sayWhatKeepsWorking(context, inputs, [visibilitySwitch]);
      return Future<void>.value();
    };
  }
  if (!await confirmHidingChangedSettings(
    context,
    featureLabel: visibilitySwitch.label(context),
    settings: stopping,
    setUpKeepsWorking: _setUpBehind(inputs, visibilitySwitch),
  )) {
    return null;
  }
  return (BuildContext context) => live
      ? offerRestartForStartupSettings(context, container, stopping)
      : Future<void>.value();
}

/// Settings > Feature Control: the current visibility switches, changed
/// one at a time or all at once by applying a preset. No preset is stored,
/// so none is reapplied beyond the switches; locked features are locked here
/// too.
class FeatureControlSettingsScreen extends ConsumerWidget {
  const FeatureControlSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Loaded before anything is tapped ([featureControlInputsProvider]).
    final inputs = ref.watch(featureControlInputsProvider);

    return SettingsCustomScrollScaffold(
      title: l10n.settings_categoryFeatureControlTitle,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settings_featureControlIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _ApplyPreset(inputs: inputs),
                const SizedBox(height: 24),
                CustomizeSetupView(
                  onChange:
                      (context, ref, visibilitySwitch, {required enabled}) =>
                          prepareSwitchChange(
                            context,
                            ref,
                            inputs,
                            visibilitySwitch,
                            enabled: enabled,
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One row per preset; each sets the switches the way that preset starts a
/// new install, after a confirmation listing what changes.
class _ApplyPreset extends ConsumerWidget {
  const _ApplyPreset({required this.inputs});

  final FeatureControlInputs inputs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SetupSection(
      title: l10n.settings_featureControlApplyPresetTitle,
      supportingText: l10n.settings_featureControlApplyPresetSubtitle,
      children: [
        for (final preset in SetupPreset.values)
          ListTile(
            leading: Icon(preset.icon),
            title: Text(preset.label(context)),
            subtitle: Text(preset.description(context)),
            onTap: () => _applyPreset(context, ref, inputs, preset),
          ),
      ],
    );
  }
}

Future<void> _applyPreset(
  BuildContext context,
  WidgetRef ref,
  FeatureControlInputs inputs,
  SetupPreset preset,
) async {
  final l10n = AppLocalizations.of(context);
  final stored = inputs.stored;
  final current = stored.general;
  final result = withPresetVisibility(current, preset);

  List<VisibilitySwitch> becoming({required bool shown}) => [
    for (final visibilitySwitch in VisibilitySwitch.values)
      if (current.isVisibilitySwitchShown(visibilitySwitch) != shown &&
          result.isVisibilitySwitchShown(visibilitySwitch) == shown)
        visibilitySwitch,
  ];
  final shown = becoming(shown: true);
  final hidden = becoming(shown: false);
  final stopping = settingsStoppingToApply(stored, result);
  final applyingAgain = settingsApplyingAgain(stored, result);

  if (shown.isEmpty && hidden.isEmpty) {
    showInfoMessage(
      context,
      l10n.settings_featureControlApplyPresetUnchanged(preset.label(context)),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => _ApplyPresetDialog(
      preset: preset,
      shown: shown,
      hidden: hidden,
      stopping: stopping,
      applyingAgain: applyingAgain,
      setUpKeepsWorking: hidden.any((s) => _setUpBehind(inputs, s)),
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final saved = await ref
      .read(saveGeneralSettingsControllerProvider.notifier)
      .saveVisibility((current) => withPresetVisibility(current, preset));
  if (!context.mounted) return;
  if (!saved) {
    showErrorMessage(context, l10n.onboarding_customizeSaveFailed);
    return;
  }
  // The dialog said what keeps working.
  await offerRestartForStartupSettings(context, ref.container, [
    ...stopping,
    ...applyingAgain,
  ]);
}

class _ApplyPresetDialog extends StatelessWidget {
  const _ApplyPresetDialog({
    required this.preset,
    required this.shown,
    required this.hidden,
    required this.stopping,
    required this.applyingAgain,
    required this.setUpKeepsWorking,
  });

  final SetupPreset preset;
  final List<VisibilitySwitch> shown;
  final List<VisibilitySwitch> hidden;

  /// Changed settings that stop applying because their feature is hidden.
  final List<HiddenSetting> stopping;

  /// Changed settings that apply again because their feature is shown.
  final List<HiddenSetting> applyingAgain;

  /// Whether a feature to hide holds something set up and in use, which
  /// keeps working.
  final bool setUpKeepsWorking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    List<Widget> group(String title, List<VisibilitySwitch> switches) => [
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      for (final visibilitySwitch in switches)
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: Icon(visibilitySwitch.icon),
          title: Text(visibilitySwitch.label(context)),
        ),
    ];

    return AlertDialog(
      // Many switches, landscape or large text can outgrow the window.
      scrollable: true,
      icon: Icon(preset.icon),
      title: Text(
        l10n.settings_featureControlApplyPresetDialogTitle(
          preset.label(context),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settings_featureControlApplyPresetDialogContent),
          if (shown.isNotEmpty)
            ...group(l10n.settings_featureControlFeaturesToShow, shown),
          if (hidden.isNotEmpty)
            ...group(l10n.settings_featureControlFeaturesToHide, hidden),
          if (stopping.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Text(
                l10n.visibilitySwitch_stopsApplyingTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(l10n.visibilitySwitch_hideWarningContent(hidden.length)),
            HiddenSettingsList(settings: stopping),
          ],
          if (applyingAgain.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Text(
                l10n.visibilitySwitch_appliesAgainTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(l10n.visibilitySwitch_revealResumesIntro(shown.length)),
            HiddenSettingsList(settings: applyingAgain),
          ],
          if (setUpKeepsWorking) ...[
            const SizedBox(height: 16),
            Text(l10n.settings_featureControlKeepsWorking),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.settings_featureControlApplyPresetConfirm),
        ),
      ],
    );
  }
}
