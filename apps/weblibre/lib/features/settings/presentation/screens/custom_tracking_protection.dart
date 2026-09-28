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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> customTrackingProtectionSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_allowlistExceptionsSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_indexAllowlistExceptionsTitle,
          subtitle: l10n.settings_indexAllowlistExceptionsSubtitle,
          child: const _AllowlistSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_cookiesSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_cookiesSectionTitle,
          subtitle: l10n.settings_indexCookiesSubtitle,
          child: const _CookiesSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_trackingContentSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_indexTrackingContentTitle,
          subtitle: l10n.settings_indexTrackingContentSubtitle,
          child: const _TrackingContentSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_trackersSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_trackersSectionTitle,
          subtitle: l10n.settings_indexTrackersSubtitle,
          child: const _TrackersSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_advancedFingerprintingProtectionSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_indexAdvancedFingerprintingProtectionTitle,
          subtitle: l10n.settings_indexAdvancedFingerprintingProtectionSubtitle,
          child: const _AdvancedFingerprintingSection(),
        ),
      ],
    ),
  ];
}

class CustomTrackingProtectionScreen extends StatelessWidget {
  const CustomTrackingProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_customTrackingProtectionTitle,
      subtitle: l10n.settings_customTrackingProtectionSubtitle,
      icon: MdiIcons.shieldEditOutline,
      sections: customTrackingProtectionSections(context),
    );
  }
}

class _AllowlistSection extends HookConsumerWidget {
  const _AllowlistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowListBaseline = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.allowListBaseline),
    );
    final allowListConvenience = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.allowListConvenience),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(l10n.settings_fixMajorIssuesTitle),
          subtitle: Text(l10n.settings_fixMajorIssuesSubtitle),
          secondary: const Icon(MdiIcons.shieldCheck),
          value: allowListBaseline,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.allowListBaseline(value));
          },
        ),
        SwitchListTile.adaptive(
          title: Text(l10n.settings_fixMinorIssuesTitle),
          subtitle: Text(l10n.settings_fixMinorIssuesSubtitle),
          secondary: const Icon(MdiIcons.shieldHalfFull),
          value: allowListConvenience,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.allowListConvenience(value));
          },
        ),
      ],
    );
  }
}

class _CookiesSection extends HookConsumerWidget {
  const _CookiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockCookies = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockCookies),
    );
    final customCookiePolicy = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.customCookiePolicy),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(l10n.settings_blockCookiesTitle),
          subtitle: Text(l10n.settings_blockCookiesSubtitle),
          secondary: const Icon(MdiIcons.cookie),
          value: blockCookies,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockCookies(value));
          },
        ),
        if (blockCookies)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(l10n.settings_cookiePolicyTitle),
                  contentPadding: EdgeInsets.zero,
                ),
                DropdownMenu<CustomCookiePolicy>(
                  initialSelection: customCookiePolicy,
                  width: double.infinity,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.totalProtection,
                      label: l10n.settings_cookiePolicyTotalProtectionLabel,
                      leadingIcon: const Icon(MdiIcons.shieldLock),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.crossSiteTrackers,
                      label: l10n.settings_cookiePolicyCrossSiteTrackersLabel,
                      leadingIcon: const Icon(MdiIcons.accountGroup),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.unvisited,
                      label: l10n.settings_cookiePolicyUnvisitedLabel,
                      leadingIcon: const Icon(MdiIcons.webOff),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.thirdParty,
                      label: l10n.settings_cookiePolicyThirdPartyLabel,
                      leadingIcon: const Icon(MdiIcons.cookieOff),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.allCookies,
                      label: l10n.settings_cookiePolicyAllCookiesLabel,
                      leadingIcon: const Icon(MdiIcons.cookieRemove),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value != null) {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save((s) => s.copyWith.customCookiePolicy(value));
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrackingContentSection extends HookConsumerWidget {
  const _TrackingContentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockTrackingContent = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockTrackingContent),
    );
    final trackingContentScope = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.trackingContentScope),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(l10n.settings_blockTrackingContentTitle),
          subtitle: Text(l10n.settings_blockTrackingContentSubtitle),
          secondary: const Icon(MdiIcons.scriptTextOutline),
          value: blockTrackingContent,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockTrackingContent(value));
          },
        ),
        if (blockTrackingContent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(l10n.settings_trackingScopeApplyToTitle),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TrackingScope>(
                    segments: [
                      ButtonSegment(
                        value: TrackingScope.all,
                        label: Text(l10n.settings_trackingScopeAllTabsLabel),
                      ),
                      ButtonSegment(
                        value: TrackingScope.privateOnly,
                        label: Text(
                          l10n.settings_trackingScopePrivateOnlyLabel,
                        ),
                      ),
                    ],
                    selected: {trackingContentScope},
                    onSelectionChanged: (value) async {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save(
                            (s) => s.copyWith.trackingContentScope(value.first),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrackersSection extends HookConsumerWidget {
  const _TrackersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockCryptominers = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockCryptominers),
    );
    final blockFingerprinters = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockFingerprinters),
    );
    final blockRedirectTrackers = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockRedirectTrackers),
    );
    final blockAdsAnalyticsSocialTrackers = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.blockAdsAnalyticsSocialTrackers,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(l10n.settings_adsAnalyticsSocialTrackersTitle),
          subtitle: Text(l10n.settings_adsAnalyticsSocialTrackersSubtitle),
          secondary: const Icon(Icons.block),
          value: blockAdsAnalyticsSocialTrackers,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockAdsAnalyticsSocialTrackers(value));
          },
        ),
        SwitchListTile.adaptive(
          title: Text(l10n.settings_cryptominersTitle),
          subtitle: Text(l10n.settings_cryptominersSubtitle),
          secondary: const Icon(MdiIcons.currencyBtc),
          value: blockCryptominers,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockCryptominers(value));
          },
        ),
        SwitchListTile.adaptive(
          title: Text(l10n.settings_knownFingerprintersTitle),
          subtitle: Text(l10n.settings_knownFingerprintersSubtitle),
          secondary: const Icon(MdiIcons.fingerprint),
          value: blockFingerprinters,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockFingerprinters(value));
          },
        ),
        SwitchListTile.adaptive(
          title: Text(l10n.settings_redirectTrackersTitle),
          subtitle: Text(l10n.settings_redirectTrackersSubtitle),
          secondary: const Icon(MdiIcons.routerNetwork),
          value: blockRedirectTrackers,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockRedirectTrackers(value));
          },
        ),
      ],
    );
  }
}

class _AdvancedFingerprintingSection extends HookConsumerWidget {
  const _AdvancedFingerprintingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockSuspectedFingerprinters = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.blockSuspectedFingerprinters,
      ),
    );
    final suspectedFingerprintersScope = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.suspectedFingerprintersScope,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(l10n.settings_suspectedFingerprintersTitle),
          subtitle: Text(l10n.settings_suspectedFingerprintersSubtitle),
          secondary: const Icon(MdiIcons.shieldSearch),
          value: blockSuspectedFingerprinters,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockSuspectedFingerprinters(value));
          },
        ),
        if (blockSuspectedFingerprinters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(l10n.settings_trackingScopeApplyToTitle),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TrackingScope>(
                    segments: [
                      ButtonSegment(
                        value: TrackingScope.all,
                        label: Text(l10n.settings_trackingScopeAllTabsLabel),
                      ),
                      ButtonSegment(
                        value: TrackingScope.privateOnly,
                        label: Text(
                          l10n.settings_trackingScopePrivateOnlyLabel,
                        ),
                      ),
                    ],
                    selected: {suspectedFingerprintersScope},
                    onSelectionChanged: (value) async {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save(
                            (s) => s.copyWith.suspectedFingerprintersScope(
                              value.first,
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
