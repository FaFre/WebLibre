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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

const List<SettingsSectionDefinition> proxyRoutingSettingsSections = [
  SettingsSectionDefinition(
    title: 'Regular Tabs',
    keywords: ['routing'],
    entries: [
      SettingsEntryDefinition(
        title: 'Regular Tabs Routing Mode',
        subtitle: 'Choose how regular tabs are routed through proxies',
        keywords: ['container', 'global'],
        child: _RegularTabsModeSection(),
      ),
      SettingsEntryDefinition(
        title: 'Proxy for global routing',
        subtitle: 'Selected proxy when global routing is enabled',
        keywords: ['proxy'],
        child: _GlobalRoutingProxySection(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Private Tabs',
    keywords: ['private', 'incognito'],
    entries: [
      SettingsEntryDefinition(
        title: 'Proxy for private tabs',
        subtitle: 'Selected proxy that carries private-tab traffic',
        keywords: ['proxy'],
        child: _PrivateTabsProxySection(),
      ),
    ],
  ),
];

class ProxyRoutingSettingsScreen extends StatelessWidget {
  const ProxyRoutingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Proxy Routing',
      subtitle: 'Choose which proxy carries regular and private tab traffic.',
      icon: Icons.route_outlined,
      sections: proxyRoutingSettingsSections,
    );
  }
}

class _RegularTabsModeSection extends ConsumerWidget {
  const _RegularTabsModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(proxyRoutingSettingsWithDefaultsProvider);

    return RadioGroup<ProxyRegularTabRoutingMode>(
      groupValue: settings.regularTabsMode,
      onChanged: (value) async {
        if (value != null) {
          await ref
              .read(proxyRoutingSettingsRepositoryProvider.notifier)
              .updateSettings(
                (current) => current.copyWith(regularTabsMode: value),
              );
        }
      },
      child: const Column(
        children: [
          RadioListTile<ProxyRegularTabRoutingMode>.adaptive(
            value: ProxyRegularTabRoutingMode.container,
            title: Text('Container-Based Routing'),
            subtitle: Text(
              'Only tabs in containers with a proxy assigned are routed.',
            ),
          ),
          RadioListTile<ProxyRegularTabRoutingMode>.adaptive(
            value: ProxyRegularTabRoutingMode.all,
            title: Text('Global Routing'),
            subtitle: Text(
              'Route every regular tab through the selected proxy.',
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalRoutingProxySection extends ConsumerWidget {
  const _GlobalRoutingProxySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(proxyRoutingSettingsWithDefaultsProvider);
    if (settings.regularTabsMode != ProxyRegularTabRoutingMode.all) {
      return const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Not used in container-based routing'),
        subtitle: Text(
          'Switch to global routing above to pick the proxy that carries every regular tab.',
        ),
      );
    }

    final options = ref.watch(proxyConnectionOptionsProvider);
    return _ProxyConnectionPicker(
      options: options,
      selectedId: settings.regularTabsProxyConnectionId,
      onChanged: (id) => ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .updateSettings(
            (current) => current.copyWith(regularTabsProxyConnectionId: id),
          ),
    );
  }
}

class _PrivateTabsProxySection extends ConsumerWidget {
  const _PrivateTabsProxySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(proxyRoutingSettingsWithDefaultsProvider);
    final options = ref.watch(proxyConnectionOptionsProvider);
    return _ProxyConnectionPicker(
      options: options,
      selectedId: settings.privateTabsProxyConnectionId,
      onChanged: (id) => ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .updateSettings(
            (current) => current.copyWith(privateTabsProxyConnectionId: id),
          ),
    );
  }
}

class _ProxyConnectionPicker extends StatelessWidget {
  final List<ProxyConnectionOption> options;
  final ProxyConnectionId? selectedId;
  final ValueChanged<ProxyConnectionId?> onChanged;

  const _ProxyConnectionPicker({
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnknownSelection =
        selectedId != null && !options.any((option) => option.id == selectedId);

    return RadioGroup<ProxyConnectionId?>(
      groupValue: selectedId,
      onChanged: onChanged,
      child: Column(
        children: [
          const RadioListTile<ProxyConnectionId?>.adaptive(
            value: null,
            title: Text('None'),
            subtitle: Text('Use the normal browser connection'),
            secondary: Icon(Icons.public),
          ),
          if (hasUnknownSelection)
            ListTile(
              leading: Icon(
                Icons.warning_amber_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('Unknown proxy'),
              subtitle: const Text('The selected proxy no longer exists.'),
              trailing: TextButton(
                onPressed: () => onChanged(null),
                child: const Text('Clear'),
              ),
            ),
          for (final option in options)
            RadioListTile<ProxyConnectionId?>.adaptive(
              value: option.id,
              title: Text(option.title),
              subtitle: Text(option.subtitle),
              secondary: const Icon(Icons.route_outlined),
            ),
        ],
      ),
    );
  }
}
