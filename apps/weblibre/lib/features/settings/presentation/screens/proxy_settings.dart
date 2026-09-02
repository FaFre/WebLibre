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
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

const List<SettingsSectionDefinition> proxySettingsSections = [
  SettingsSectionDefinition(
    title: 'Proxy',
    entries: [
      SettingsEntryDefinition(
        title: 'Proxy Connections',
        subtitle: 'Manage proxy profiles and connections',
        keywords: [
          'sing-box',
          'socks',
          'vpn',
          'wireguard',
          'tor',
          'onion',
          'bridges',
          'obfs4',
          'snowflake',
        ],
        child: _ProxyConnectionsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Proxy Routing',
        subtitle: 'Choose which proxy carries regular and private tabs',
        keywords: ['routing', 'container'],
        child: _ProxyRoutingTile(),
      ),
      SettingsEntryDefinition(
        title: 'Proxy Logs',
        subtitle: 'Read the proxy log and set how much it records',
        keywords: [
          'log',
          'logging',
          'logs',
          'diagnostics',
          'debug',
          'trace',
          'verbose',
          'troubleshoot',
          'level',
        ],
        child: _ProxyLogsTile(),
      ),
    ],
  ),
];

class ProxySettingsScreen extends StatelessWidget {
  const ProxySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Proxy',
      subtitle: 'Manage proxy connections and choose which tabs use them.',
      icon: MdiIcons.lanConnect,
      sections: proxySettingsSections,
    );
  }
}

class _ProxyConnectionsTile extends StatelessWidget {
  const _ProxyConnectionsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MdiIcons.lanConnect),
      title: const Text('Proxy Connections'),
      subtitle: const Text('Manage proxy profiles and connections'),
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
    return ListTile(
      leading: const Icon(Icons.route_outlined),
      title: const Text('Proxy Routing'),
      subtitle: const Text(
        'Choose which proxy carries regular and private tabs',
      ),
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
      title: const Text('Proxy Logs'),
      subtitle: Text(
        logLevel.isVerbose
            ? 'Recording ${logLevel.label.toLowerCase()} — this slows browsing'
            : 'Recording ${logLevel.label.toLowerCase()}',
      ),
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
