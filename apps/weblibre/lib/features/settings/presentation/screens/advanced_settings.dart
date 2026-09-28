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
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/dialogs/user_agent_restart_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart';

List<SettingsSectionDefinition> advancedSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_contentIdentitySectionTitle,
      keywords: settingsKeywords(l10n.settings_contentIdentitySectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_javascriptTitle,
          subtitle: l10n.settings_indexJavascriptSubtitle,
          keywords: settingsKeywords(l10n.settings_javascriptKeywords),
          child: const _JavaScriptTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_userAgentLabel,
          subtitle: l10n.settings_indexUserAgentSubtitle,
          keywords: settingsKeywords(l10n.settings_userAgentLabelKeywords),
          child: const _UserAgentTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_enterpriseRootsTitle,
          subtitle: l10n.settings_indexEnterpriseRootsSubtitle,
          keywords: settingsKeywords(l10n.settings_enterpriseRootsKeywords),
          child: const _EnterpriseRootsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_experimentalSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_experimentalFeaturesTitle,
          subtitle: l10n.settings_experimentalFeaturesSubtitle,
          keywords: settingsKeywords(
            l10n.settings_experimentalFeaturesKeywords,
          ),
          child: const _ExperimentalSettingsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_developerToolsSectionTitle,
      keywords: settingsKeywords(l10n.settings_developerToolsSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_unmountGeckoViewTitle,
          subtitle: l10n.settings_indexUnmountGeckoViewSubtitle,
          keywords: settingsKeywords(l10n.settings_unmountGeckoViewKeywords),
          child: const _UnmountGeckoViewOffRouteTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_iconCacheTitle,
          subtitle: l10n.settings_iconCacheSubtitle,
          keywords: settingsKeywords(l10n.settings_iconCacheKeywords),
          child: const _IconCacheTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_mlDownloadsTitle,
          subtitle: l10n.settings_mlDownloadsSubtitle,
          keywords: settingsKeywords(l10n.settings_mlDownloadsKeywords),
          child: const _MlCacheTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_errorLogsTitle,
          subtitle: l10n.settings_errorLogsSubtitle,
          keywords: settingsKeywords(l10n.settings_errorLogsKeywords),
          child: const _ErrorLogsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_dartVmTitle,
          subtitle: l10n.settings_dartVmSubtitle,
          keywords: settingsKeywords(l10n.settings_dartVmKeywords),
          child: const _DartVmTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_resetUiTitle,
          subtitle: l10n.settings_resetUiSubtitle,
          keywords: settingsKeywords(l10n.settings_resetUiKeywords),
          child: const _ResetUITile(),
        ),
      ],
    ),
  ];
}

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_advancedTitle,
      subtitle: l10n.settings_advancedSubtitle,
      icon: MdiIcons.tuneVertical,
      sections: advancedSettingsSections(context),
    );
  }
}

class _JavaScriptTile extends HookConsumerWidget {
  const _JavaScriptTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final javascriptEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.javascriptEnabled),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_javascriptTitle),
      subtitle: Text(l10n.settings_javascriptSubtitle),
      // ignore: deprecated_member_use use this icon for now
      secondary: const Icon(MdiIcons.languageJavascript),
      value: javascriptEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.javascriptEnabled(value),
            );
      },
    );
  }
}

class _UserAgentTile extends HookConsumerWidget {
  const _UserAgentTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAgent = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.userAgent),
    );

    final userAgentTextController = useTextEditingController(
      text: userAgent,
      keys: [userAgent],
    );
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.cardAccountDetails),
      title: TextField(
        controller: userAgentTextController,
        decoration: InputDecoration(
          labelText: l10n.settings_userAgentLabel,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Mozilla/5.0 …',
        ),
        onSubmitted: (value) async {
          final trimmed = value.trim();

          await ref
              .read(saveEngineSettingsControllerProvider.notifier)
              .save(
                (currentSettings) => currentSettings.copyWith.userAgent(
                  trimmed.isEmpty ? null : trimmed,
                ),
              );

          if (context.mounted) {
            final restart = await showUserAgentRestartDialog(context);

            if (restart == true) {
              await exitApp(ref.container);
            }
          }
        },
      ),
    );
  }
}

class _EnterpriseRootsTile extends HookConsumerWidget {
  const _EnterpriseRootsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enterpriseRootsEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.enterpriseRootsEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_enterpriseRootsTitle),
      subtitle: Text(l10n.settings_enterpriseRootsSubtitle),
      secondary: const Icon(MdiIcons.certificate),
      value: enterpriseRootsEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.enterpriseRootsEnabled(value),
            );
      },
    );
  }
}

class _ExperimentalSettingsTile extends StatelessWidget {
  const _ExperimentalSettingsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_experimentalFeaturesTitle),
      subtitle: Text(l10n.settings_experimentalFeaturesSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.flaskOutline),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ExperimentalSettingsRoute().push(context);
      },
    );
  }
}

class _UnmountGeckoViewOffRouteTile extends HookConsumerWidget {
  const _UnmountGeckoViewOffRouteTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unmountGeckoViewOffRoute = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.unmountGeckoViewOffRoute,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_unmountGeckoViewTitle),
      subtitle: Text(l10n.settings_unmountGeckoViewSubtitle),
      secondary: const Icon(Icons.memory),
      value: unmountGeckoViewOffRoute,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.unmountGeckoViewOffRoute(value),
            );
      },
    );
  }
}

class _IconCacheTile extends HookConsumerWidget {
  const _IconCacheTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(
      iconCacheSizeMegabytesProvider.select((value) => value.value),
    );
    final l10n = AppLocalizations.of(context);

    return CustomListTile(
      title: l10n.settings_iconCacheTitle,
      subtitle: l10n.settings_iconCacheSubtitle,
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.image,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: DefaultTextStyle(
          style: GoogleFonts.robotoMono(
            textStyle: DefaultTextStyle.of(context).style,
          ),
          child: Table(
            columnWidths: const {0: FixedColumnWidth(100)},
            children: [
              TableRow(
                children: [
                  Text(l10n.settings_iconCacheSizeLabel),
                  Text(formatMegabytes(l10n, size ?? 0)),
                ],
              ),
            ],
          ),
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await ref.read(cacheRepositoryProvider.notifier).clearCache();
        },
        icon: const Icon(Icons.delete),
        label: Text(l10n.common_clear),
      ),
    );
  }
}

class _MlCacheTile extends HookWidget {
  const _MlCacheTile();

  Future<bool> _confirmClear(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_mlDownloadsClearDialogTitle),
        content: Text(l10n.settings_mlDownloadsClearDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.common_clear),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isClearing = useState(false);
    final l10n = AppLocalizations.of(context);

    return CustomListTile(
      title: l10n.settings_mlDownloadsTitle,
      subtitle: l10n.settings_mlDownloadsSubtitle,
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.memory,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: isClearing.value
            ? null
            : () async {
                if (!await _confirmClear(context)) {
                  return;
                }

                isClearing.value = true;
                try {
                  await GeckoMlService().clearMlCache();

                  if (context.mounted) {
                    showInfoMessage(
                      context,
                      l10n.settings_mlDownloadsClearedMessage,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showErrorMessage(
                      context,
                      l10n.settings_mlDownloadsClearFailedMessage('$e'),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    isClearing.value = false;
                  }
                }
              },
        icon: isClearing.value
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete),
        label: Text(
          isClearing.value ? l10n.settings_clearingAction : l10n.common_clear,
        ),
      ),
    );
  }
}

class _ErrorLogsTile extends StatelessWidget {
  const _ErrorLogsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Icon(
        Icons.bug_report,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(l10n.settings_errorLogsTitle),
      subtitle: Text(l10n.settings_errorLogsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ErrorLogsRoute().push(context);
      },
    );
  }
}

class _DartVmTile extends StatelessWidget {
  const _DartVmTile();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    return CustomListTile(
      title: l10n.settings_dartVmTitle,
      subtitle: l10n.settings_dartVmSubtitle,
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.bug_report,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          final serviceProtocolInfo = await Service.getInfo();

          await Clipboard.setData(
            ClipboardData(
              text:
                  serviceProtocolInfo.serverUri?.toString() ??
                  l10n.settings_dartVmCopyErrorFallback,
            ),
          );

          if (context.mounted) {
            showInfoMessage(context, l10n.settings_serviceUrlCopiedMessage);
          }
        },
        icon: const Icon(Icons.copy),
        label: Text(l10n.common_copy),
      ),
    );
  }
}

class _ResetUITile extends ConsumerWidget {
  const _ResetUITile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return CustomListTile(
      title: l10n.settings_resetUiTitle,
      subtitle: l10n.settings_resetUiSubtitle,
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.bug_report,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () {
          ref.read(appStateKeyProvider.notifier).reset();
        },
        icon: const Icon(Icons.restore),
        label: Text(l10n.common_reset),
      ),
    );
  }
}
