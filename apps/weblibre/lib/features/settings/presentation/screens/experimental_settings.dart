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
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/exit_app.dart';

List<SettingsSectionDefinition> experimentalSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_runtimeStartupSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_isolatedContentProcessTitle,
          subtitle: l10n.settings_indexIsolatedContentProcessSubtitle,
          keywords: settingsKeywords(
            l10n.settings_isolatedContentProcessKeywords,
          ),
          child: const _IsolatedProcessEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_appZygoteProcessTitle,
          subtitle: l10n.settings_indexAppZygoteProcessSubtitle,
          keywords: settingsKeywords(l10n.settings_appZygoteProcessKeywords),
          child: const _AppZygoteProcessEnabledTile(),
        ),
      ],
    ),
  ];
}

class ExperimentalSettingsScreen extends StatelessWidget {
  const ExperimentalSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_experimentalTitle,
      subtitle: l10n.settings_experimentalSubtitle,
      icon: MdiIcons.flaskOutline,
      sections: experimentalSettingsSections(context),
    );
  }
}

class _IsolatedProcessEnabledTile extends HookConsumerWidget {
  const _IsolatedProcessEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isolatedProcessEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.isolatedProcessEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_isolatedContentProcessTitle),
      subtitle: Text(l10n.settings_isolatedContentProcessSubtitle),
      secondary: const Icon(MdiIcons.shieldCheck),
      value: isolatedProcessEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.isolatedProcessEnabled(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context);
        }
      },
    );
  }
}

class _AppZygoteProcessEnabledTile extends HookConsumerWidget {
  const _AppZygoteProcessEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appZygoteProcessEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.appZygoteProcessEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_appZygoteProcessTitle),
      subtitle: Text(l10n.settings_appZygoteProcessSubtitle),
      secondary: const Icon(MdiIcons.rocketLaunch),
      value: appZygoteProcessEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.appZygoteProcessEnabled(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context);
        }
      },
    );
  }
}

Future<void> _showRestartDialog(BuildContext context) async {
  final result = await showQuitBrowserDialog(context);
  if (result == true && context.mounted) {
    await exitApp(ProviderScope.containerOf(context));
  }
}
