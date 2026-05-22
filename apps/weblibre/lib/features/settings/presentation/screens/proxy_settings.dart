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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

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
