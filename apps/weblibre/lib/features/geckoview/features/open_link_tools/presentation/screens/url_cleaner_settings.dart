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
import 'package:weblibre/utils/ui_helper.dart';

const List<SettingsSectionDefinition> urlCleanerSettingsSections = [
  SettingsSectionDefinition(
    title: 'Overview',
    entries: [
      SettingsEntryDefinition(
        title: 'Description',
        subtitle: 'Tracking parameter removal and offline redirect cleanup',
        keywords: ['tracking parameters', 'redirects'],
        child: _UrlCleanerDescriptionTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Behavior',
    entries: [
      SettingsEntryDefinition(
        title: 'Enable URL Cleaner',
        subtitle: 'Remove tracking parameters from URLs',
        keywords: ['clean urls'],
        child: _UrlCleanerEnabledTile(),
      ),
      SettingsEntryDefinition(
        title: 'Auto-apply',
        subtitle: 'Automatically replace URL with cleaned version',
        keywords: ['auto apply'],
        child: _UrlCleanerAutoApplyTile(),
      ),
      SettingsEntryDefinition(
        title: 'Allow referral marketing',
        subtitle: 'Keep referral and affiliate tracking parameters',
        keywords: ['affiliate', 'referral'],
        child: _UrlCleanerAllowReferralTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Catalog',
    entries: [
      SettingsEntryDefinition(
        title: 'Auto-update catalog',
        subtitle: 'Check for rule updates weekly',
        child: _UrlCleanerAutoUpdateTile(),
      ),
      SettingsEntryDefinition(
        title: 'Update catalog',
        subtitle: 'Fetch the latest URL cleaner rules',
        child: _UrlCleanerUpdateButton(),
      ),
      SettingsEntryDefinition(
        title: 'Restore defaults',
        subtitle: 'Reset to bundled catalog and default settings',
        child: _UrlCleanerRestoreDefaultsButton(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Attribution',
    entries: [
      SettingsEntryDefinition(
        title: 'Attribution',
        subtitle: 'Credits and source links',
        child: _UrlCleanerAttributionTile(),
      ),
    ],
  ),
];

class UrlCleanerSettingsScreen extends StatelessWidget {
  const UrlCleanerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'URL Cleaner',
      subtitle: 'URL cleanup behavior, rule catalog updates, and attribution.',
      icon: MdiIcons.broom,
      sections: urlCleanerSettingsSections,
    );
  }
}

class _UrlCleanerDescriptionTile extends StatelessWidget {
  const _UrlCleanerDescriptionTile();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Description'),
      subtitle: Text(
        'This module removes tracking, referrer and other useless parameters from the URL. '
        'It also allows for common offline URL redirections.',
      ),
      leading: Icon(MdiIcons.broom),
    );
  }
}

class _UrlCleanerEnabledTile extends HookConsumerWidget {
  const _UrlCleanerEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.urlCleanerEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enable URL Cleaner'),
      subtitle: const Text('Remove tracking parameters from URLs'),
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
    final autoApply = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.urlCleanerAutoApply),
    );

    return SwitchListTile.adaptive(
      title: const Text('Auto-apply'),
      subtitle: const Text('Automatically replace URL with cleaned version'),
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
    final allowReferral = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.urlCleanerAllowReferralMarketing,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Allow referral marketing'),
      subtitle: const Text('Keep referral and affiliate tracking parameters'),
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
    final autoUpdate = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.urlCleanerAutoUpdate),
    );

    return SwitchListTile.adaptive(
      title: const Text('Auto-update catalog'),
      subtitle: const Text('Check for rule updates weekly'),
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

    final subtitle = StringBuffer(
      lastUpdate == null
          ? 'Last update: not available'
          : 'Last update: ${ref.read(formatProvider.notifier).shortDate(lastUpdate)}',
    );
    if (lastCheck != null) {
      subtitle.write(
        '\nLast check: ${ref.read(formatProvider.notifier).shortDate(lastCheck)}',
      );
    }
    if (lastUpdateWasAuto) {
      subtitle.write(' (auto)');
    }

    return ListTile(
      title: const Text('Update catalog'),
      subtitle: Text(subtitle.toString()),
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
                  showInfoMessage(context, 'Catalog updated');
                }
              } catch (e) {
                if (context.mounted) {
                  showErrorMessage(context, 'Update failed: $e');
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
    return ListTile(
      title: const Text('Restore defaults'),
      subtitle: const Text('Reset to bundled catalog and default settings'),
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
            const TextSpan(text: 'This module is based on the ClearURL rules:'),
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
