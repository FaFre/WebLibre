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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/dialogs/url_cleaner_restore_defaults_dialog.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/attribution_link.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

List<SettingsSectionDefinition> urlCleanerSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.openLinkTools_urlCleanerOverviewSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_indexUrlCleanerDescriptionTitle,
          subtitle: l10n.openLinkTools_indexUrlCleanerDescriptionSubtitle,
          keywords: settingsKeywords(
            l10n.openLinkTools_indexUrlCleanerDescriptionKeywords,
          ),
          child: const _UrlCleanerDescriptionTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.openLinkTools_urlCleanerBehaviorSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_urlCleanerEnabledTitle,
          subtitle: l10n.openLinkTools_urlCleanerEnabledSubtitle,
          keywords: settingsKeywords(
            l10n.openLinkTools_urlCleanerEnabledKeywords,
          ),
          child: const _UrlCleanerEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.openLinkTools_autoApplyTitle,
          subtitle: l10n.openLinkTools_autoApplySubtitle,
          keywords: settingsKeywords(l10n.openLinkTools_autoApplyKeywords),
          child: const _UrlCleanerAutoApplyTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.openLinkTools_allowReferralTitle,
          subtitle: l10n.openLinkTools_allowReferralSubtitle,
          keywords: settingsKeywords(l10n.openLinkTools_allowReferralKeywords),
          child: const _UrlCleanerAllowReferralTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.openLinkTools_urlCleanerCatalogSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_autoUpdateCatalogTitle,
          subtitle: l10n.openLinkTools_autoUpdateCatalogSubtitle,
          child: const _UrlCleanerAutoUpdateTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.openLinkTools_updateCatalogTitle,
          subtitle: l10n.openLinkTools_indexUrlCleanerUpdateCatalogSubtitle,
          child: const _UrlCleanerUpdateButton(),
        ),
        SettingsEntryDefinition(
          title: l10n.openLinkTools_restoreDefaultsButtonTitle,
          subtitle: l10n.openLinkTools_restoreDefaultsButtonSubtitle,
          child: const _UrlCleanerRestoreDefaultsButton(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.openLinkTools_urlCleanerAttributionSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_indexUrlCleanerAttributionTitle,
          subtitle: l10n.openLinkTools_indexUrlCleanerAttributionSubtitle,
          child: const _UrlCleanerAttributionTile(),
        ),
      ],
    ),
  ];
}

class UrlCleanerSettingsScreen extends StatelessWidget {
  const UrlCleanerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.openLinkTools_urlCleanerSettingsTitle,
      subtitle: l10n.openLinkTools_urlCleanerSettingsSubtitle,
      icon: MdiIcons.broom,
      sections: urlCleanerSettingsSections(context),
    );
  }
}

class _UrlCleanerDescriptionTile extends StatelessWidget {
  const _UrlCleanerDescriptionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.openLinkTools_descriptionLabel),
      subtitle: Text(l10n.openLinkTools_urlCleanerDescriptionBody),
      leading: const Icon(MdiIcons.broom),
    );
  }
}

class _UrlCleanerEnabledTile extends HookConsumerWidget {
  const _UrlCleanerEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.urlCleanerEnabled),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.openLinkTools_urlCleanerEnabledTitle),
      subtitle: Text(l10n.openLinkTools_urlCleanerEnabledSubtitle),
      secondary: const Icon(MdiIcons.broom),
      value: enabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((current) => current.copyWith(urlCleanerEnabled: value));
      },
    );
  }
}

class _UrlCleanerAutoApplyTile extends HookConsumerWidget {
  const _UrlCleanerAutoApplyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final autoApply = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.urlCleanerAutoApply),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.openLinkTools_autoApplyTitle),
      subtitle: Text(l10n.openLinkTools_autoApplySubtitle),
      secondary: const Icon(MdiIcons.autoFix),
      value: autoApply,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((current) => current.copyWith(urlCleanerAutoApply: value));
      },
    );
  }
}

class _UrlCleanerAllowReferralTile extends HookConsumerWidget {
  const _UrlCleanerAllowReferralTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allowReferral = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.urlCleanerAllowReferralMarketing,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.openLinkTools_allowReferralTitle),
      subtitle: Text(l10n.openLinkTools_allowReferralSubtitle),
      secondary: const Icon(MdiIcons.cashMultiple),
      value: allowReferral,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (current) =>
                  current.copyWith(urlCleanerAllowReferralMarketing: value),
            );
      },
    );
  }
}

class _UrlCleanerAutoUpdateTile extends HookConsumerWidget {
  const _UrlCleanerAutoUpdateTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final autoUpdate = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.urlCleanerAutoUpdate),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.openLinkTools_autoUpdateCatalogTitle),
      subtitle: Text(l10n.openLinkTools_autoUpdateCatalogSubtitle),
      secondary: const Icon(MdiIcons.update),
      value: autoUpdate,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((current) => current.copyWith(urlCleanerAutoUpdate: value));
      },
    );
  }
}

class _UrlCleanerUpdateButton extends HookConsumerWidget {
  const _UrlCleanerUpdateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isUpdating = useState(false);
    final lastCheckEpochMs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.urlCleanerLastCheckEpochMs,
      ),
    );
    final lastUpdateWasAuto = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.urlCleanerLastUpdateWasAuto,
      ),
    );
    final lastUpdateAsync = useFuture(
      useMemoized(
        () => ref.read(urlCleanerCatalogServiceProvider.notifier).lastUpdate(),
        [lastCheckEpochMs],
      ),
    );
    final lastUpdate = lastUpdateAsync.data;

    final lastCheck = lastCheckEpochMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastCheckEpochMs)
        : null;

    final format = ref.read(formatProvider.notifier);
    final subtitle = [
      if (lastUpdate == null)
        l10n.openLinkTools_lastUpdateNotAvailable
      else if (lastUpdateWasAuto)
        l10n.openLinkTools_lastAutoUpdateWithDate(format.shortDate(lastUpdate))
      else
        l10n.openLinkTools_lastUpdateWithDate(format.shortDate(lastUpdate)),
      if (lastCheck != null)
        l10n.openLinkTools_lastCheckWithDate(format.shortDate(lastCheck)),
    ].join('\n');

    return ListTile(
      title: Text(l10n.openLinkTools_updateCatalogTitle),
      subtitle: Text(subtitle),
      leading: const Icon(MdiIcons.cloudDownload),
      trailing: isUpdating.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: isUpdating.value
          ? null
          : () async {
              isUpdating.value = true;
              try {
                await ref
                    .read(urlCleanerCatalogServiceProvider.notifier)
                    .updateCatalog();
                if (context.mounted) {
                  showInfoMessage(
                    context,
                    l10n.openLinkTools_catalogUpdatedMessage,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showErrorMessage(
                    context,
                    l10n.openLinkTools_updateFailedWithError('$e'),
                  );
                }
              } finally {
                isUpdating.value = false;
              }
            },
    );
  }
}

class _UrlCleanerRestoreDefaultsButton extends HookConsumerWidget {
  const _UrlCleanerRestoreDefaultsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.openLinkTools_restoreDefaultsButtonTitle),
      subtitle: Text(l10n.openLinkTools_restoreDefaultsButtonSubtitle),
      leading: const Icon(MdiIcons.restore),
      onTap: () async {
        final confirmed = await showUrlCleanerRestoreDefaultsDialog(context);

        if (confirmed == true) {
          final defaultSettings = GeneralSettings.withDefaults();

          await ref
              .read(urlCleanerCatalogServiceProvider.notifier)
              .restoreBundledCatalog();

          await ref
              .read(saveGeneralSettingsControllerProvider.notifier)
              .save(
                (current) => current.copyWith(
                  urlCleanerEnabled: defaultSettings.urlCleanerEnabled,
                  urlCleanerAutoApply: defaultSettings.urlCleanerAutoApply,
                  urlCleanerAllowReferralMarketing:
                      defaultSettings.urlCleanerAllowReferralMarketing,
                  urlCleanerCatalogUrl: defaultSettings.urlCleanerCatalogUrl,
                  urlCleanerHashUrl: defaultSettings.urlCleanerHashUrl,
                  urlCleanerAutoUpdate: defaultSettings.urlCleanerAutoUpdate,
                  urlCleanerLastCheckEpochMs:
                      defaultSettings.urlCleanerLastCheckEpochMs,
                  urlCleanerLastUpdateWasAuto:
                      defaultSettings.urlCleanerLastUpdateWasAuto,
                ),
              );
        }
      },
    );
  }
}

class _UrlCleanerAttributionTile extends StatelessWidget {
  const _UrlCleanerAttributionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.primary,
    );

    return ListTile(
      title: RichText(
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textColor),
          children: [
            TextSpan(text: l10n.openLinkTools_clearUrlAttributionText),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: AttributionLink(
                label: 'https://docs.clearurls.xyz/latest/specs/rules/',
                url: 'https://docs.clearurls.xyz/latest/specs/rules/',
                style: linkStyle,
              ),
            ),
          ],
        ),
      ),
      leading: const Icon(MdiIcons.informationOutline),
      dense: false,
    );
  }
}
