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
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/list_format_l10n.dart';
import 'package:weblibre/presentation/utils/visibility_switch_l10n.dart';
import 'package:weblibre/presentation/widgets/highlight_pulse.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// The groups of the visibility switches, in display order. Few and broad:
/// every group needs at least one switch.
enum CustomizeGroup { privacy, tabs, layout, connections, more }

/// The group a visibility switch is listed in. Exhaustive, so a new switch
/// does not compile until it has a place.
CustomizeGroup customizeGroupOf(VisibilitySwitch visibilitySwitch) =>
    switch (visibilitySwitch) {
      VisibilitySwitch.privacyAdvanced => CustomizeGroup.privacy,
      VisibilitySwitch.containers ||
      VisibilitySwitch.isolatedTabs ||
      VisibilitySwitch.treeTabs ||
      VisibilitySwitch.profiles => CustomizeGroup.tabs,
      VisibilitySwitch.connections => CustomizeGroup.connections,
      VisibilitySwitch.layoutAdvanced ||
      VisibilitySwitch.gestures ||
      VisibilitySwitch.keyboardCustomization => CustomizeGroup.layout,
      VisibilitySwitch.ai ||
      VisibilitySwitch.webappStorage ||
      VisibilitySwitch.expertDetails => CustomizeGroup.more,
    };

/// The other switches some of [visibilitySwitch]'s features also need before
/// they are shown, e.g. per-container routing needs Containers and
/// Connections. Shown inline so turning one on is not a surprise.
Set<VisibilitySwitch> coRequiredSwitches(VisibilitySwitch visibilitySwitch) =>
    _coRequiredSwitches[visibilitySwitch]!;

/// [coRequiredSwitches] for every switch, worked out once: the registry is
/// constant.
final _coRequiredSwitches = {
  for (final visibilitySwitch in VisibilitySwitch.values)
    visibilitySwitch: {
      for (final feature in FeatureId.values)
        if (feature.policy.switches.contains(visibilitySwitch))
          for (final other in feature.policy.switches)
            if (other != visibilitySwitch) other,
    },
};

/// Called when the user changes [visibilitySwitch], before the change is
/// saved. Returns null to leave it unsaved (the user cancelled), or what to
/// do once it is saved.
typedef VisibilitySwitchChange =
    Future<Future<void> Function(BuildContext context)?> Function(
      BuildContext context,
      WidgetRef ref,
      VisibilitySwitch visibilitySwitch, {
      required bool enabled,
    });

/// The visibility switches alone: the onboarding's "Show or hide features"
/// and Settings > Feature Control. Configuration has steps of its own in the
/// onboarding (Layout, Privacy & security) and pages of its own in Settings.
/// A change goes through [SaveGeneralSettingsController.saveVisibility]: a
/// visibility edit in the draft while one is open, which a preset change
/// drops, and the profile otherwise.
class CustomizeSetupView extends HookConsumerWidget {
  const CustomizeSetupView({super.key, this.focus, this.onChange});

  /// The switch to scroll to and highlight once, when opened from a link to
  /// it (a hidden feature on the onboarding's Your setup).
  final VisibilitySwitch? focus;

  /// Warns about changes that stop applying when a feature is hidden, and
  /// says what keeps working or applies again (`prepareSwitchChange`).
  final VisibilitySwitchChange? onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(displayedGeneralSettingsProvider);

    List<Widget> childrenOf(CustomizeGroup group) => [
      for (final visibilitySwitch in VisibilitySwitch.values)
        if (customizeGroupOf(visibilitySwitch) == group)
          HighlightPulse(
            active: visibilitySwitch == focus,
            child: _VisibilitySwitchTile(
              visibilitySwitch: visibilitySwitch,
              settings: settings,
              onChange: onChange,
            ),
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in CustomizeGroup.values)
          if (childrenOf(group) case final children when children.isNotEmpty)
            SetupSection(
              title: switch (group) {
                CustomizeGroup.privacy => l10n.onboarding_customizeGroupPrivacy,
                CustomizeGroup.tabs => l10n.onboarding_customizeGroupTabs,
                CustomizeGroup.layout => l10n.onboarding_customizeGroupLayout,
                CustomizeGroup.connections =>
                  l10n.onboarding_customizeGroupConnections,
                CustomizeGroup.more => l10n.onboarding_customizeGroupOther,
              },
              children: children,
            ),
      ],
    );
  }
}

class _VisibilitySwitchTile extends ConsumerWidget {
  const _VisibilitySwitchTile({
    required this.visibilitySwitch,
    required this.settings,
    this.onChange,
  });

  final VisibilitySwitch visibilitySwitch;
  final GeneralSettings settings;
  final VisibilitySwitchChange? onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = settings.isVisibilitySwitchShown(visibilitySwitch);
    final alsoNeeded = [
      for (final other in coRequiredSwitches(visibilitySwitch))
        if (!settings.isVisibilitySwitchShown(other)) other,
    ];

    return SwitchListTile.adaptive(
      secondary: Icon(visibilitySwitch.icon),
      title: Text(visibilitySwitch.label(context)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(visibilitySwitch.description(context)),
          if (alsoNeeded.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.visibilitySwitch_alsoNeeds(
                  formatList(l10n, alsoNeeded.map((o) => o.label(context))),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
      value: value,
      onChanged: (enabled) async {
        final afterSave = onChange == null
            ? (BuildContext _) => Future<void>.value()
            : await onChange!(context, ref, visibilitySwitch, enabled: enabled);
        if (afterSave == null || !context.mounted) return;

        // The save controller files it in the draft while one is open and
        // writes the profile otherwise, so a toggle never drops silently.
        final saved = await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .saveVisibility(
              (current) => current.withVisibilitySwitch(
                visibilitySwitch,
                enabled: enabled,
              ),
            );
        if (!context.mounted) return;
        if (!saved) {
          showErrorMessage(context, l10n.onboarding_customizeSaveFailed);
        } else {
          await afterSave(context);
        }
      },
    );
  }
}
