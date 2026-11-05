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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/doh_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/locale_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/module_surface_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/toolbar_layout_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/list_format_l10n.dart';
import 'package:weblibre/presentation/utils/visibility_switch_l10n.dart';
import 'package:weblibre/presentation/widgets/highlight_pulse.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Where the [CustomizeSetupView] is shown. The same component is the
/// onboarding's Customize step and Settings > Feature Control.
enum CustomizeSetupMode {
  /// In the onboarding: every change goes into the draft,
  /// and the parts that are not plain settings (hardening, uBlock Origin) are
  /// offered too.
  onboarding,

  /// The live settings. Switches change one at a time; no preset is stored,
  /// so none can be reapplied.
  settings,
}

/// The groups of the Customize screen, in display order. Few and broad: in
/// Settings they hold only the switches, so every group needs at least one.
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

class CustomizeSetupView extends HookConsumerWidget {
  const CustomizeSetupView({
    super.key,
    required this.mode,
    this.focus,
    this.onChange,
  });

  final CustomizeSetupMode mode;

  /// The switch to scroll to and highlight once, when opened from a link to
  /// it (a hidden feature on the onboarding's Your setup).
  final VisibilitySwitch? focus;

  /// Settings uses it to warn about changes that stop applying when a
  /// feature is hidden, and to say what keeps working or applies again.
  final VisibilitySwitchChange? onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(displayedGeneralSettingsProvider);
    final onboarding = mode == CustomizeSetupMode.onboarding;

    // Each switch, followed in the onboarding by what it shows there, then
    // the group's own onboarding tiles.
    List<Widget> childrenOf(CustomizeGroup group) => [
      for (final visibilitySwitch in VisibilitySwitch.values)
        if (customizeGroupOf(visibilitySwitch) == group) ...[
          HighlightPulse(
            active: visibilitySwitch == focus,
            child: _VisibilitySwitchTile(
              visibilitySwitch: visibilitySwitch,
              settings: settings,
              onChange: onChange,
            ),
          ),
          if (onboarding)
            ..._onboardingTilesAfter(context, visibilitySwitch, settings),
        ],
      if (onboarding) ..._onboardingGroupTiles(context, group),
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
                CustomizeGroup.more => l10n.onboarding_customizeGroupMore,
              },
              children: children,
            ),
      ],
    );
  }
}

/// Opens [screen] over the onboarding. A plain route: the screens edit the
/// draft through the edit layer wherever they are built.
Future<void> pushSetupScreen(BuildContext context, Widget screen) =>
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));

/// What the onboarding's Customize step offers besides the switches: the
/// setup steps that are not plain settings (hardening, uBlock Origin) and the
/// configuration a new install starts from. Settings > Feature Control is
/// visibility only; all of this has its own settings page there.
///
/// These follow the switch that shows them.
List<Widget> _onboardingTilesAfter(
  BuildContext context,
  VisibilitySwitch visibilitySwitch,
  GeneralSettings settings,
) {
  final l10n = AppLocalizations.of(context);

  return switch (visibilitySwitch) {
    // The baseline is locked; the rest follow the Advanced privacy switch
    // above them, like Settings does.
    VisibilitySwitch.privacyAdvanced => [
      const _HardeningBaselineTile(),
      if (settings.isFeatureShown(FeatureId.privacyLocalNetworkBlockingSwitch))
        const _LocalNetworkBlockingTile(),
      if (settings.isFeatureShown(FeatureId.privacyFpHardenedDefaults))
        const _FingerprintHardeningTile(),
      if (settings.isFeatureShown(FeatureId.privacyDohProviderControl))
        _MoreSettingsTile(
          icon: MdiIcons.dns,
          title: l10n.onboarding_dohTitle,
          subtitle: l10n.onboarding_dohSubtitle,
          // The Settings screen itself, editing the draft.
          open: (context) =>
              pushSetupScreen(context, const DohSettingsScreen()),
        ),
      if (settings.isFeatureShown(FeatureId.privacyBrowserLanguages))
        _MoreSettingsTile(
          icon: Icons.translate,
          title: l10n.onboarding_privacyBrowserLanguagesTitle,
          subtitle: l10n.onboarding_privacyBrowserLanguagesSubtitle,
          open: (context) =>
              pushSetupScreen(context, const LocaleSettingsScreen()),
        ),
    ],
    VisibilitySwitch.ai => [
      if (settings.isFeatureShown(FeatureId.aiLocalAi)) const LocalAiTile(),
    ],
    _ => const [],
  };
}

/// The onboarding tiles of [group] that no switch shows, at the group's end.
List<Widget> _onboardingGroupTiles(BuildContext context, CustomizeGroup group) {
  final l10n = AppLocalizations.of(context);

  return switch (group) {
    CustomizeGroup.privacy => const [
      _UBlockInstallTile(),
      _UBlockFiltersTile(),
    ],
    CustomizeGroup.layout => [
      _MoreSettingsTile(
        icon: MdiIcons.dockBottom,
        title: l10n.onboarding_toolbarLayoutTitle,
        // The Settings screen itself, editing the draft; its rows that only
        // work on the live settings leave themselves out.
        open: (context) =>
            pushSetupScreen(context, const ToolbarLayoutSettingsScreen()),
      ),
      _MoreSettingsTile(
        icon: Icons.home_outlined,
        title: l10n.onboarding_customizeHomeSections,
        open: (context) => pushSetupScreen(
          context,
          ModuleSurfaceSettingsScreen(
            title: l10n.onboarding_customizeHomeSections,
          ),
        ),
      ),
      _MoreSettingsTile(
        icon: MdiIcons.tabPlus,
        title: l10n.onboarding_customizeNewTabSections,
        open: (context) => pushSetupScreen(
          context,
          ModuleSurfaceSettingsScreen(
            surface: ModuleSurface.newTab,
            title: l10n.onboarding_customizeNewTabSections,
          ),
        ),
      ),
    ],
    CustomizeGroup.tabs ||
    CustomizeGroup.connections ||
    CustomizeGroup.more => const [],
  };
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

        final saved = await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
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

class _MoreSettingsTile extends StatelessWidget {
  const _MoreSettingsTile({
    required this.icon,
    required this.title,
    required this.open,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Future<void> Function(BuildContext context) open;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => open(context),
    );
  }
}

class _HardeningBaselineTile extends ConsumerWidget {
  const _HardeningBaselineTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      setupDraftControllerProvider.select(
        (d) => d?.appliesHardeningBaseline ?? false,
      ),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.shieldLock),
      title: Text(l10n.onboarding_webEngineHardeningTitle),
      subtitle: Text(l10n.onboarding_webEngineHardeningSubtitle),
      value: value,
      onChanged: (value) => ref
          .read(setupDraftControllerProvider.notifier)
          .setHardeningBaseline(value),
    );
  }
}

class _LocalNetworkBlockingTile extends ConsumerWidget {
  const _LocalNetworkBlockingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      storedEngineSettingsProvider.select((s) => s.lnaBlocking ?? false),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.lanPending),
      title: Text(l10n.onboarding_blockAllLocalNetworkTitle),
      subtitle: Text(l10n.onboarding_blockAllLocalNetworkSubtitle),
      value: value,
      onChanged: (value) => ref
          .read(saveEngineSettingsControllerProvider.notifier)
          .save((current) => current.copyWith.lnaBlocking(value)),
    );
  }
}

class _FingerprintHardeningTile extends ConsumerWidget {
  const _FingerprintHardeningTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isHardened = ref.watch(
      storedEngineSettingsProvider.select(
        (s) =>
            s.fingerprintingProtectionOverrides ==
            FingerprintOverrides.hardenedDefaults().toString(),
      ),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.fingerprint),
          title: Text(l10n.onboarding_fingerprintProtectionTitle),
          subtitle: Text(l10n.onboarding_fingerprintProtectionSubtitle),
          value: isHardened,
          onChanged: (value) async {
            final overrides = value
                ? FingerprintOverrides.hardenedDefaults()
                : FingerprintOverrides.defaults();
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save(
                  (current) => current.copyWith
                      .fingerprintingProtectionOverrides(overrides.toString()),
                );
          },
        ),
        if (isHardened)
          // A caveat, not an error: the tertiary role, not the error one.
          _Notice(
            color: theme.colorScheme.tertiaryContainer,
            onColor: theme.colorScheme.onTertiaryContainer,
            title: l10n.onboarding_compatibilityWarningTitle,
            points: [
              l10n.onboarding_fingerprintWarningPoint1,
              l10n.onboarding_fingerprintWarningPoint2,
            ],
          ),
      ],
    );
  }
}

/// Turns the on-device models on, with the download notice `ai.local_ai`
/// confirms with in every preset.
class LocalAiTile extends ConsumerWidget {
  const LocalAiTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      storedGeneralSettingsProvider.select((s) => s.enableLocalAiFeatures),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.creation),
          title: Text(l10n.onboarding_aiUseOnDeviceTitle),
          subtitle: Text(l10n.onboarding_aiOnDeviceSubtitle),
          value: value,
          onChanged: (value) => ref
              .read(saveGeneralSettingsControllerProvider.notifier)
              .save((current) => current.copyWith.enableLocalAiFeatures(value)),
        ),
        if (value) const LocalAiNotice(),
      ],
    );
  }
}

/// What to know about on-device AI, under the switch that turns it on.
class LocalAiNotice extends StatelessWidget {
  const LocalAiNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return _Notice(
      color: theme.colorScheme.secondaryContainer,
      onColor: theme.colorScheme.onSecondaryContainer,
      title: l10n.onboarding_aiWarningTitle,
      points: [
        l10n.onboarding_aiWarningPoint1,
        l10n.onboarding_aiWarningPoint2,
        l10n.onboarding_aiWarningPoint3,
      ],
    );
  }
}

class _UBlockInstallTile extends ConsumerWidget {
  const _UBlockInstallTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(
      setupDraftControllerProvider.select((d) => d?.installsUBlock ?? false),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.advertisementsOff),
      title: Text(l10n.onboarding_ublockInstallTitle),
      subtitle: Text(l10n.onboarding_ublockInstallSubtitle),
      value: value,
      onChanged: (value) => ref
          .read(setupDraftControllerProvider.notifier)
          .setInstallUBlock(value),
    );
  }
}

class _UBlockFiltersTile extends ConsumerWidget {
  const _UBlockFiltersTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(setupDraftControllerProvider);

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.filterOutline),
      title: Text(l10n.onboarding_ublockApplyDefaultsTitle),
      subtitle: Text(l10n.onboarding_ublockApplyDefaultsSubtitle),
      value: draft?.appliesOptimizedUBlockFilters ?? false,
      onChanged: draft?.installsUBlock ?? false
          ? (value) => ref
                .read(setupDraftControllerProvider.notifier)
                .setOptimizedUBlockFilters(value)
          : null,
    );
  }
}

/// What to know about the switch above it, drawn as part of that row: it
/// starts at the row's text (past the 16 padding, 24 icon and 16 gap of the
/// list tile) and ends with its 24 end padding, so it reads as the row's
/// own detail rather than a panel of its own.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.color,
    required this.onColor,
    required this.title,
    required this.points,
  });

  final Color color;
  final Color onColor;
  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.fromSTEB(56, 0, 24, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: onColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final point in points) ...[
            const SizedBox(height: 8),
            Text(
              '• $point',
              style: theme.textTheme.bodySmall?.copyWith(color: onColor),
            ),
          ],
        ],
      ),
    );
  }
}
