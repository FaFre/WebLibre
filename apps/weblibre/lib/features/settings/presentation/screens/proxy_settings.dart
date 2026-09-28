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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_log_level_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> proxySettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_proxySectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_proxyConnectionsTitle,
          subtitle: l10n.settings_proxyConnectionsSubtitle,
          keywords: settingsKeywords(l10n.settings_proxyConnectionsKeywords),
          child: const _ProxyConnectionsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_proxyRoutingTitle,
          subtitle: l10n.settings_proxyRoutingSubtitle,
          keywords: settingsKeywords(l10n.settings_proxyRoutingKeywords),
          child: const _ProxyRoutingTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_proxyLogsTitle,
          subtitle: l10n.settings_indexProxyLogsSubtitle,
          keywords: settingsKeywords(l10n.settings_proxyLogsKeywords),
          child: const _ProxyLogsTile(),
        ),
      ],
    ),
  ];
}

class ProxySettingsScreen extends StatelessWidget {
  const ProxySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_proxyTitle,
      subtitle: l10n.settings_proxySubtitle,
      icon: MdiIcons.lanConnect,
      sections: proxySettingsSections(context),
    );
  }
}

class _ProxyConnectionsTile extends StatelessWidget {
  const _ProxyConnectionsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.lanConnect),
      title: Text(l10n.settings_proxyConnectionsTitle),
      subtitle: Text(l10n.settings_proxyConnectionsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      onTap: () async {
        await const SingboxProxyProfilesRoute().push(context);
      },
    );
  }
}

class _ProxyRoutingTile extends StatelessWidget {
  const _ProxyRoutingTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.route_outlined),
      title: Text(l10n.settings_proxyRoutingTitle),
      subtitle: Text(l10n.settings_proxyRoutingSubtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      onTap: () async {
        await const ProxyRoutingSettingsRoute().push(context);
      },
    );
  }
}

/// Links to the log rather than reproducing its settings here.
///
/// The verbosity control belongs with the log it fills — it is only ever
/// changed because of what the log does or does not show, and a level raised
/// for one diagnosis has to be put back afterwards from the same place. What
/// this entry owes the user is the current level, so a verbose one left on is
/// visible from the settings list without opening anything.
class _ProxyLogsTile extends ConsumerWidget {
  const _ProxyLogsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logLevel = ref
        .watch(proxyDiagnosticsSettingsWithDefaultsProvider)
        .logLevel;

    return ListTile(
      leading: Icon(
        logLevel.isVerbose
            ? MdiIcons.textBoxSearchOutline
            : MdiIcons.textBoxOutline,
        color: logLevel.isVerbose ? Theme.of(context).colorScheme.error : null,
      ),
      title: Text(l10n.settings_proxyLogsTitle),
      subtitle: Text(logLevel.recordingSummary(context)),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      onTap: () async {
        await const SingboxProxyLogsRoute().push(context);
      },
    );
  }
}
