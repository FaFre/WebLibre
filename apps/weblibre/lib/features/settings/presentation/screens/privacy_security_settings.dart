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
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/delete_data.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/services/package_label_resolver.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/presentation/utils/delete_browsing_data_type_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/exit_app.dart';

List<SettingsSectionDefinition> privacySecuritySettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionTrackingProtectionTitle,
      keywords: settingsKeywords(
        l10n.settings_privacySectionTrackingProtectionKeywords,
      ),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_enhancedTrackingProtectionTitle,
          subtitle: l10n.settings_indexEnhancedTrackingProtectionSubtitle,
          keywords: settingsKeywords(
            l10n.settings_enhancedTrackingProtectionKeywords,
          ),
          child: const _EnhancedTrackingProtectionSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_contentBlockingDatabaseTitle,
          subtitle: l10n.settings_indexContentBlockingDatabaseSubtitle,
          keywords: settingsKeywords(
            l10n.settings_contentBlockingDatabaseKeywords,
          ),
          child: const _ContentBlockingDatabaseTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_bounceTrackingProtectionTitle,
          subtitle: l10n.settings_indexBounceTrackingProtectionSubtitle,
          keywords: settingsKeywords(
            l10n.settings_bounceTrackingProtectionKeywords,
          ),
          child: const _BounceTrackingProtectionTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_queryParameterStrippingTitle,
          subtitle: l10n.settings_indexQueryParameterStrippingSubtitle,
          keywords: settingsKeywords(
            l10n.settings_queryParameterStrippingKeywords,
          ),
          child: const _QueryParameterStrippingSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_trackingProtectionExceptionsTitle,
          subtitle: l10n.settings_trackingProtectionExceptionsTileSubtitle,
          keywords: settingsKeywords(
            l10n.settings_trackingProtectionExceptionsKeywords,
          ),
          child: const _TrackingProtectionExceptionsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_uBlockFilterListsTileTitle,
          subtitle: l10n.settings_uBlockFilterListsTileSubtitle,
          keywords: settingsKeywords(
            l10n.settings_uBlockFilterListsTileKeywords,
          ),
          child: const _UBlockFilterListsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionFingerprintingTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_browserLanguagesTitle,
          subtitle: l10n.settings_indexBrowserLanguagesSubtitle,
          keywords: settingsKeywords(l10n.settings_browserLanguagesKeywords),
          child: const _BrowserLanguagesTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_fingerprintProtectionTitle,
          subtitle: l10n.settings_fingerprintProtectionTileSubtitle,
          keywords: settingsKeywords(
            l10n.settings_fingerprintProtectionKeywords,
          ),
          child: const _FingerprintProtectionTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_resistFingerprintingTileTitle,
          subtitle: l10n.settings_resistFingerprintingTileSubtitle,
          keywords: settingsKeywords(
            l10n.settings_resistFingerprintingTileKeywords,
          ),
          child: const _ResistFingerprintingTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionConnectionSecurityTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_httpsOnlyModeTitle,
          subtitle: l10n.settings_indexHttpsOnlyModeSubtitle,
          keywords: settingsKeywords(l10n.settings_httpsOnlyModeKeywords),
          child: const _HttpsOnlyModeSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_indexDnsOverHttpsTitle,
          subtitle: l10n.settings_indexDnsOverHttpsSubtitle,
          keywords: settingsKeywords(l10n.settings_indexDnsOverHttpsKeywords),
          child: const _DnsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionNetworkProtectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_lnaEnabledTitle,
          subtitle: l10n.settings_lnaEnabledSubtitle,
          keywords: settingsKeywords(l10n.settings_lnaEnabledKeywords),
          child: const _LnaEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_lnaBlockingTitle,
          subtitle: l10n.settings_indexLnaBlockingSubtitle,
          keywords: settingsKeywords(l10n.settings_lnaBlockingKeywords),
          child: const _LnaBlockingTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_lnaBlockTrackersTitle,
          subtitle: l10n.settings_indexLnaBlockTrackersSubtitle,
          keywords: settingsKeywords(l10n.settings_lnaBlockTrackersKeywords),
          child: const _LnaBlockTrackersTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionSignalsModesTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_screenshotProtectionTitle,
          subtitle: l10n.settings_indexScreenshotProtectionSubtitle,
          keywords: settingsKeywords(
            l10n.settings_screenshotProtectionKeywords,
          ),
          child: const _ScreenshotProtectionTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_allowPrivateTabScreenshotsTitle,
          subtitle: l10n.settings_indexAllowPrivateTabScreenshotsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_allowPrivateTabScreenshotsKeywords,
          ),
          child: const _AllowPrivateTabScreenshotsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_globalPrivacyControlTitle,
          subtitle: l10n.settings_indexGlobalPrivacyControlSubtitle,
          keywords: settingsKeywords(
            l10n.settings_globalPrivacyControlKeywords,
          ),
          child: const _GlobalPrivacyControlTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionAppOpeningProtectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_blockAppsOpeningBrowserTitle,
          subtitle: l10n.settings_indexAppOpeningProtectionSubtitle,
          keywords: settingsKeywords(
            l10n.settings_blockAppsOpeningBrowserKeywords,
          ),
          child: const _AppOpeningProtectionSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionDataManagementTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_deleteBrowsingDataTileTitle,
          subtitle: l10n.settings_indexDeleteBrowsingDataSubtitle,
          keywords: settingsKeywords(
            l10n.settings_deleteBrowsingDataTileKeywords,
          ),
          child: const _DeleteBrowsingDataTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_autoDeleteBrowsingDataTitle,
          subtitle: l10n.settings_autoDeleteBrowsingDataSubtitle,
          keywords: settingsKeywords(
            l10n.settings_autoDeleteBrowsingDataKeywords,
          ),
          child: const _AutoDeleteBrowsingDataSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_confirmBeforeQuitTitle,
          subtitle: l10n.settings_confirmBeforeQuitSubtitle,
          keywords: settingsKeywords(l10n.settings_confirmBeforeQuitKeywords),
          child: const _ConfirmBeforeQuitTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_autoClearHistoryTitle,
          subtitle: l10n.settings_indexAutoClearHistorySubtitle,
          keywords: settingsKeywords(l10n.settings_autoClearHistoryKeywords),
          child: const _AutoClearHistorySection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_autoClearUnassignedTabsTitle,
          subtitle: l10n.settings_indexAutoClearUnassignedTabsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_autoClearUnassignedTabsKeywords,
          ),
          child: const _AutoClearUnassignedTabsSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionSafeBrowsingTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_safeBrowsingMalwareTitle,
          subtitle: l10n.settings_indexSafeBrowsingMalwareSubtitle,
          keywords: settingsKeywords(l10n.settings_safeBrowsingMalwareKeywords),
          child: const _SafeBrowsingMalwareTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_safeBrowsingPhishingTitle,
          subtitle: l10n.settings_indexSafeBrowsingPhishingSubtitle,
          keywords: settingsKeywords(
            l10n.settings_safeBrowsingPhishingKeywords,
          ),
          child: const _SafeBrowsingPhishingTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_privacySectionAdvancedSecurityTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_webEngineHardeningTitle,
          subtitle: l10n.settings_indexWebEngineHardeningSubtitle,
          keywords: settingsKeywords(l10n.settings_webEngineHardeningKeywords),
          child: const _WebEngineHardeningTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_fissionEnabledTitle,
          subtitle: l10n.settings_indexFissionEnabledSubtitle,
          keywords: settingsKeywords(l10n.settings_fissionEnabledKeywords),
          child: const _FissionEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_extensionsWebApiTitle,
          subtitle: l10n.settings_indexExtensionsWebAPIEnabledSubtitle,
          keywords: settingsKeywords(l10n.settings_extensionsWebApiKeywords),
          child: const _ExtensionsWebAPIEnabledTile(),
        ),
      ],
    ),
  ];
}

class PrivacySecuritySettingsScreen extends StatelessWidget {
  const PrivacySecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_privacySecurityTitle,
      subtitle: l10n.settings_privacySecuritySubtitle,
      icon: MdiIcons.shieldLock,
      sections: privacySecuritySettingsSections(context),
    );
  }
}

class _TrackingProtectionExceptionsTile extends StatelessWidget {
  const _TrackingProtectionExceptionsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.shieldOffOutline),
      title: Text(l10n.settings_trackingProtectionExceptionsTitle),
      subtitle: Text(l10n.settings_trackingProtectionExceptionsTileSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await TrackingProtectionExceptionsRoute().push(context);
      },
    );
  }
}

class _AutoDeleteBrowsingDataSection extends HookConsumerWidget {
  const _AutoDeleteBrowsingDataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoDeleteBrowsingData = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.autoDeleteBrowsingData,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(l10n.settings_autoDeleteBrowsingDataTitle),
          subtitle: Text(l10n.settings_autoDeleteBrowsingDataSubtitle),
          secondary: const Icon(MdiIcons.deleteClockOutline),
          value: autoDeleteBrowsingData != null,
          onChanged: (value) async {
            await ref
                .read(saveGeneralSettingsControllerProvider.notifier)
                .save(
                  (currentSettings) => currentSettings.copyWith
                      .autoDeleteBrowsingData(value ? {} : null),
                );
          },
        ),
        if (autoDeleteBrowsingData != null)
          _DeleteBrowsingDataTypes(selectedTypes: autoDeleteBrowsingData),
      ],
    );
  }
}

class _DeleteBrowsingDataTypes extends HookConsumerWidget {
  final Set<DeleteBrowsingDataType> selectedTypes;

  const _DeleteBrowsingDataTypes({required this.selectedTypes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          for (final type in DeleteBrowsingDataType.values)
            CheckboxListTile.adaptive(
              value: selectedTypes.contains(type),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(type.label(context)),
              subtitle: type
                  .description(context)
                  .mapNotNull((description) => Text(description)),
              onChanged: (value) async {
                final notifier = ref.read(
                  saveGeneralSettingsControllerProvider.notifier,
                );

                if (value == true) {
                  await notifier.save(
                    (currentSettings) =>
                        currentSettings.copyWith.autoDeleteBrowsingData({
                          ...currentSettings.autoDeleteBrowsingData!,
                          type,
                        }),
                  );
                } else {
                  await notifier.save(
                    (currentSettings) =>
                        currentSettings.copyWith.autoDeleteBrowsingData(
                          {...currentSettings.autoDeleteBrowsingData!}
                            ..remove(type),
                        ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ConfirmBeforeQuitTile extends HookConsumerWidget {
  const _ConfirmBeforeQuitTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmBeforeQuit = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.confirmBeforeQuit),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_confirmBeforeQuitTitle),
      subtitle: Text(l10n.settings_confirmBeforeQuitSubtitle),
      secondary: const Icon(MdiIcons.power),
      value: confirmBeforeQuit,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((current) => current.copyWith.confirmBeforeQuit(value));
      },
    );
  }
}

class _DeleteBrowsingDataTile extends StatelessWidget {
  const _DeleteBrowsingDataTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_deleteBrowsingDataTileTitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.databaseRemove),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await showDeleteDataDialog(context);
      },
    );
  }
}

class _AutoClearHistorySection extends HookConsumerWidget {
  const _AutoClearHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAutoCleanInterval = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.historyAutoCleanInterval,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_autoClearHistoryTitle),
            subtitle: Text(l10n.settings_autoClearHistorySubtitle),
            leading: const Icon(MdiIcons.deleteClock),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: DropdownMenu<Duration>(
              initialSelection: historyAutoCleanInterval,
              inputDecorationTheme: InputDecorationTheme(
                prefixIconConstraints: BoxConstraints.tight(
                  const Size.square(24),
                ),
              ),
              width: double.infinity,
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: Duration.zero,
                  label: l10n.settings_durationNever,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 1),
                  label: l10n.settings_duration1Day,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 3),
                  label: l10n.settings_duration3Days,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 7),
                  label: l10n.settings_duration1Week,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 14),
                  label: l10n.settings_duration2Weeks,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 30),
                  label: l10n.settings_duration1Month,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 90),
                  label: l10n.settings_duration3Months,
                ),
              ],
              onSelected: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .historyAutoCleanInterval(value ?? Duration.zero),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoClearUnassignedTabsSection extends HookConsumerWidget {
  const _AutoClearUnassignedTabsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassignedTabsAutoCleanInterval = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.unassignedTabsAutoCleanInterval,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_autoClearUnassignedTabsTitle),
            subtitle: Text(l10n.settings_autoClearUnassignedTabsSubtitle),
            leading: const Icon(MdiIcons.tabRemove),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: DropdownMenu<Duration>(
              initialSelection: unassignedTabsAutoCleanInterval,
              inputDecorationTheme: InputDecorationTheme(
                prefixIconConstraints: BoxConstraints.tight(
                  const Size.square(24),
                ),
              ),
              width: double.infinity,
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: Duration.zero,
                  label: l10n.settings_durationNever,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 1),
                  label: l10n.settings_duration1Day,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 3),
                  label: l10n.settings_duration3Days,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 7),
                  label: l10n.settings_duration1Week,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 14),
                  label: l10n.settings_duration2Weeks,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 30),
                  label: l10n.settings_duration1Month,
                ),
                DropdownMenuEntry(
                  value: const Duration(days: 90),
                  label: l10n.settings_duration3Months,
                ),
              ],
              onSelected: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .unassignedTabsAutoCleanInterval(
                            value ?? Duration.zero,
                          ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalPrivacyControlTile extends HookConsumerWidget {
  const _GlobalPrivacyControlTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPrivacyControlEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.globalPrivacyControlEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_globalPrivacyControlTitle),
      secondary: const Icon(MdiIcons.incognitoCircleOff),
      value: globalPrivacyControlEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.globalPrivacyControlEnabled(value),
            );
      },
    );
  }
}

class _ScreenshotProtectionTile extends HookConsumerWidget {
  const _ScreenshotProtectionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.screenshotProtectionEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_screenshotProtectionTitle),
      subtitle: Text(l10n.settings_screenshotProtectionSubtitle),
      secondary: const Icon(MdiIcons.cameraOff),
      value: enabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.screenshotProtectionEnabled(value),
            );
      },
    );
  }
}

/// Opt-out from the secure window that private tabs apply by default.
///
/// Inert while [_ScreenshotProtectionTile] is on: that setting blocks capture
/// in every tab, so the stored preference here is shown but cannot take
/// effect. The tile stays visible with an explanation rather than silently
/// reverting the preference.
class _AllowPrivateTabScreenshotsTile extends HookConsumerWidget {
  const _AllowPrivateTabScreenshotsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allow = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.allowPrivateTabScreenshots,
      ),
    );
    final overridden = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.screenshotProtectionEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_allowPrivateTabScreenshotsTitle),
      subtitle: Text(
        overridden
            ? l10n.settings_allowPrivateTabScreenshotsOverriddenSubtitle
            : l10n.settings_allowPrivateTabScreenshotsSubtitle,
      ),
      secondary: const Icon(MdiIcons.incognito),
      value: allow,
      onChanged: overridden
          ? null
          : (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) => currentSettings.copyWith
                        .allowPrivateTabScreenshots(value),
                  );
            },
    );
  }
}

class _HttpsOnlyModeSection extends HookConsumerWidget {
  const _HttpsOnlyModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final httpsOnlyMode = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.httpsOnlyMode),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_httpsOnlyModeTitle),
            leading: const Icon(MdiIcons.lockOpen),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<HttpsOnlyMode>(
              segments: [
                ButtonSegment(
                  value: HttpsOnlyMode.disabled,
                  label: Text(l10n.settings_httpsOnlyModeDisabledLabel),
                ),
                ButtonSegment(
                  value: HttpsOnlyMode.enabled,
                  label: Text(l10n.settings_httpsOnlyModeEnabledLabel),
                ),
                ButtonSegment(
                  value: HttpsOnlyMode.privateOnly,
                  label: Text(l10n.settings_httpsOnlyModePrivateOnlyLabel),
                ),
              ],
              selected: {httpsOnlyMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.httpsOnlyMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DnsTile extends StatelessWidget {
  const _DnsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_dnsOverHttpsTileTitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.dns),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await DohSettingsRoute().push(context);
      },
    );
  }
}

class _EnhancedTrackingProtectionSection extends HookConsumerWidget {
  const _EnhancedTrackingProtectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingProtectionPolicy = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.trackingProtectionPolicy,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_enhancedTrackingProtectionTitle),
            leading: const Icon(MdiIcons.incognitoCircleOff),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: trackingProtectionPolicy,
            onChanged: (value) async {
              if (value != null) {
                // Save the policy change
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .trackingProtectionPolicy(value),
                    );
              }

              // Navigate to custom settings screen when Custom is selected
              if (value == TrackingProtectionPolicy.custom ||
                  (value == null &&
                      trackingProtectionPolicy ==
                          TrackingProtectionPolicy.custom)) {
                if (context.mounted) {
                  await CustomTrackingProtectionRoute().push(context);
                }
              }
            },
            child: Column(
              children: [
                RadioListTile<TrackingProtectionPolicy>.adaptive(
                  value: TrackingProtectionPolicy.none,
                  title: Text(l10n.settings_trackingProtectionDisabledLabel),
                ),
                RadioListTile<TrackingProtectionPolicy>.adaptive(
                  value: TrackingProtectionPolicy.recommended,
                  title: Text(l10n.settings_trackingProtectionStandardLabel),
                  subtitle: Text(
                    l10n.settings_trackingProtectionStandardSubtitle,
                  ),
                ),
                RadioListTile<TrackingProtectionPolicy>.adaptive(
                  value: TrackingProtectionPolicy.strict,
                  title: Text(l10n.settings_trackingProtectionStrictLabel),
                  subtitle: Text(
                    l10n.settings_trackingProtectionStrictSubtitle,
                  ),
                ),
                RadioListTile<TrackingProtectionPolicy>.adaptive(
                  value: TrackingProtectionPolicy.custom,
                  toggleable: true,
                  title: Text(l10n.settings_trackingProtectionCustomLabel),
                  subtitle: Text(
                    l10n.settings_trackingProtectionCustomSubtitle,
                  ),
                  secondary: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentBlockingDatabaseTile extends HookConsumerWidget {
  const _ContentBlockingDatabaseTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useContentBlockingDatabase = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.useContentBlockingDatabase,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_contentBlockingDatabaseTitle),
      subtitle: Text(l10n.settings_contentBlockingDatabaseSubtitle),
      secondary: const Icon(Icons.storage),
      value: useContentBlockingDatabase,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.useContentBlockingDatabase(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context, ref);
        }
      },
    );
  }
}

class _BounceTrackingProtectionTile extends HookConsumerWidget {
  const _BounceTrackingProtectionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bounceTrackingProtectionMode = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.contentBlocking.bounceTrackingProtectionMode,
      ),
    );

    final isEnabled = switch (bounceTrackingProtectionMode) {
      BounceTrackingProtectionMode.disabled => false,
      BounceTrackingProtectionMode.enabled => true,
      BounceTrackingProtectionMode.enabledStandby => false,
      BounceTrackingProtectionMode.enabledDryRun => false,
    };

    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_bounceTrackingProtectionTitle),
      subtitle: Text(l10n.settings_bounceTrackingProtectionSubtitle),
      secondary: const Icon(MdiIcons.securityNetwork),
      value: isEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.bounceTrackingProtectionMode(
                    value
                        ? BounceTrackingProtectionMode.enabled
                        : BounceTrackingProtectionMode.disabled,
                  ),
            );
        if (context.mounted) {
          await _showRestartDialog(context, ref);
        }
      },
    );
  }
}

class _QueryParameterStrippingSection extends HookConsumerWidget {
  const _QueryParameterStrippingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryParameterStripping = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.queryParameterStripping,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_queryParameterStrippingTitle),
            subtitle: Text(l10n.settings_queryParameterStrippingSubtitle),
            leading: const Icon(MdiIcons.closeNetwork),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<QueryParameterStripping>(
              segments: [
                ButtonSegment(
                  value: QueryParameterStripping.disabled,
                  label: Text(
                    l10n.settings_queryParameterStrippingDisabledLabel,
                  ),
                ),
                ButtonSegment(
                  value: QueryParameterStripping.enabled,
                  label: Text(
                    l10n.settings_queryParameterStrippingEnabledLabel,
                  ),
                ),
                ButtonSegment(
                  value: QueryParameterStripping.privateOnly,
                  label: Text(
                    l10n.settings_queryParameterStrippingPrivateOnlyLabel,
                  ),
                ),
              ],
              selected: {queryParameterStripping},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .queryParameterStripping(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WebEngineHardeningTile extends StatelessWidget {
  const _WebEngineHardeningTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_webEngineHardeningTitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.shieldLock),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await WebEngineHardeningRoute().push(context);
      },
    );
  }
}

class _UBlockFilterListsTile extends StatelessWidget {
  const _UBlockFilterListsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_uBlockFilterListsTileTitle),
      subtitle: Text(l10n.settings_uBlockFilterListsTileSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(Icons.filter_list),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await UBlockFilterListsRoute().push<void>(context);
      },
    );
  }
}

class _FissionEnabledTile extends HookConsumerWidget {
  const _FissionEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fissionEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.fissionEnabled),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_fissionEnabledTitle),
      subtitle: Text(l10n.settings_fissionEnabledSubtitle),
      secondary: const Icon(MdiIcons.shieldHalfFull),
      value: fissionEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.fissionEnabled(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context, ref);
        }
      },
    );
  }
}

class _SafeBrowsingMalwareTile extends HookConsumerWidget {
  const _SafeBrowsingMalwareTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeBrowsingMalwareEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.safeBrowsingMalwareEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_safeBrowsingMalwareTitle),
      subtitle: Text(l10n.settings_safeBrowsingMalwareSubtitle),
      secondary: const Icon(Icons.bug_report_outlined),
      value: safeBrowsingMalwareEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.safeBrowsingMalwareEnabled(value),
            );
      },
    );
  }
}

class _SafeBrowsingPhishingTile extends HookConsumerWidget {
  const _SafeBrowsingPhishingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeBrowsingPhishingEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.safeBrowsingPhishingEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_safeBrowsingPhishingTitle),
      subtitle: Text(l10n.settings_safeBrowsingPhishingSubtitle),
      secondary: const Icon(Icons.gpp_maybe_outlined),
      value: safeBrowsingPhishingEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.safeBrowsingPhishingEnabled(value),
            );
      },
    );
  }
}

class _ExtensionsWebAPIEnabledTile extends HookConsumerWidget {
  const _ExtensionsWebAPIEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extensionsWebAPIEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.extensionsWebAPIEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_extensionsWebApiTitle),
      subtitle: Text(l10n.settings_extensionsWebApiSubtitle),
      secondary: const Icon(Icons.extension),
      value: extensionsWebAPIEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.extensionsWebAPIEnabled(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context, ref);
        }
      },
    );
  }
}

Future<void> _showRestartDialog(BuildContext context, WidgetRef ref) async {
  final result = await showQuitBrowserDialog(context);
  if (result == true && context.mounted) {
    await exitApp(ProviderScope.containerOf(context));
  }
}

class _AppOpeningProtectionSection extends HookConsumerWidget {
  const _AppOpeningProtectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.blockExternalAppsEnabled,
      ),
    );
    final policies = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.externalAppIntentPolicies,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SettingSection(name: l10n.settings_appOpeningProtectionSectionHeader),
        SwitchListTile.adaptive(
          title: Text(l10n.settings_blockAppsOpeningBrowserTitle),
          subtitle: Text(l10n.settings_blockAppsOpeningBrowserSubtitle),
          secondary: const Icon(MdiIcons.appsBox),
          value: enabled,
          onChanged: (value) async {
            await ref
                .read(saveGeneralSettingsControllerProvider.notifier)
                .save(
                  (current) => current.copyWith.blockExternalAppsEnabled(value),
                );
          },
        ),
        if (enabled && policies.isNotEmpty)
          _ManagedAppPolicyList(policies: policies),
      ],
    );
  }
}

class _ManagedAppPolicyList extends HookConsumerWidget {
  final Map<String, IntentSourcePolicy> policies;

  const _ManagedAppPolicyList({required this.policies});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = policies.entries.toList(growable: false);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings_managedAppsSectionHeader,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          for (final entry in entries)
            _ManagedAppPolicyTile(
              packageName: entry.key,
              policy: entry.value,
              onAction: (action) async {
                final notifier = ref.read(
                  saveGeneralSettingsControllerProvider.notifier,
                );
                switch (action) {
                  case _PolicyAction.allow:
                    await notifier.save(
                      (current) => current.copyWith.externalAppIntentPolicies({
                        ...current.externalAppIntentPolicies,
                        entry.key: IntentSourcePolicy.allow,
                      }),
                    );
                  case _PolicyAction.block:
                    await notifier.save(
                      (current) => current.copyWith.externalAppIntentPolicies({
                        ...current.externalAppIntentPolicies,
                        entry.key: IntentSourcePolicy.block,
                      }),
                    );
                  case _PolicyAction.remove:
                    await notifier.save(
                      (current) => current.copyWith.externalAppIntentPolicies(
                        {...current.externalAppIntentPolicies}
                          ..remove(entry.key),
                      ),
                    );
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ManagedAppPolicyTile extends HookConsumerWidget {
  final String packageName;
  final IntentSourcePolicy policy;
  final Future<void> Function(_PolicyAction action) onAction;

  const _ManagedAppPolicyTile({
    required this.packageName,
    required this.policy,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = ref.watch(
      packageLabelProvider(packageName).select((value) => value.value),
    );
    final hasLabel = label != null && label.isNotEmpty;
    final l10n = AppLocalizations.of(context);
    final statusLabel = policy == IntentSourcePolicy.allow
        ? l10n.settings_managedAppAlwaysAllowedLabel
        : l10n.settings_managedAppAlwaysBlockedLabel;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        policy == IntentSourcePolicy.allow
            ? MdiIcons.checkCircleOutline
            : MdiIcons.cancel,
      ),
      title: Text(hasLabel ? label : packageName),
      subtitle: Text(hasLabel ? '$statusLabel · $packageName' : statusLabel),
      trailing: PopupMenuButton<_PolicyAction>(
        onSelected: onAction,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _PolicyAction.allow,
            child: Text(l10n.settings_managedAppActionAllow),
          ),
          PopupMenuItem(
            value: _PolicyAction.block,
            child: Text(l10n.settings_managedAppActionBlock),
          ),
          PopupMenuItem(
            value: _PolicyAction.remove,
            child: Text(l10n.common_remove),
          ),
        ],
      ),
    );
  }
}

enum _PolicyAction { allow, block, remove }

class _BrowserLanguagesTile extends StatelessWidget {
  const _BrowserLanguagesTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_browserLanguagesTileTitle),
      subtitle: Text(l10n.settings_browserLanguagesTileSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(Icons.translate),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await LocaleSettingsRoute().push(context);
      },
    );
  }
}

class _FingerprintProtectionTile extends StatelessWidget {
  const _FingerprintProtectionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_fingerprintProtectionTileTitle),
      subtitle: Text(l10n.settings_fingerprintProtectionTileSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.fingerprint),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await FingerprintSettingsRoute().push(context);
      },
    );
  }
}

class _ResistFingerprintingTile extends StatelessWidget {
  const _ResistFingerprintingTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_resistFingerprintingTileTitle),
      subtitle: Text(l10n.settings_resistFingerprintingTileSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.shieldLock),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const WebEngineHardeningGroupRoute(
          group: 'Resist Fingerprinting',
        ).push(context);
      },
    );
  }
}

class _LnaEnabledTile extends HookConsumerWidget {
  const _LnaEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lnaEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.lnaEnabled),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_lnaEnabledTitle),
      subtitle: Text(l10n.settings_lnaEnabledSubtitle),
      secondary: const Icon(MdiIcons.lanDisconnect),
      value: lnaEnabled ?? false,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) => currentSettings.copyWith.lnaEnabled(value),
            );
      },
    );
  }
}

class _LnaBlockingTile extends HookConsumerWidget {
  const _LnaBlockingTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lnaEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.lnaEnabled),
    );
    final lnaBlocking = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.lnaBlocking),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_lnaBlockingTitle),
      subtitle: Text(l10n.settings_lnaBlockingSubtitle),
      secondary: const Icon(MdiIcons.shieldLockOpen),
      value: lnaBlocking ?? false,
      onChanged: lnaEnabled == true
          ? (value) async {
              await ref
                  .read(saveEngineSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.lnaBlocking(value),
                  );
            }
          : null,
    );
  }
}

class _LnaBlockTrackersTile extends HookConsumerWidget {
  const _LnaBlockTrackersTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lnaEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.lnaEnabled),
    );
    final lnaBlockTrackers = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.lnaBlockTrackers),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_lnaBlockTrackersTitle),
      subtitle: Text(l10n.settings_lnaBlockTrackersSubtitle),
      secondary: const Icon(MdiIcons.shieldBug),
      value: lnaBlockTrackers ?? false,
      onChanged: lnaEnabled == true
          ? (value) async {
              await ref
                  .read(saveEngineSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.lnaBlockTrackers(value),
                  );
            }
          : null,
    );
  }
}
