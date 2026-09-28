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
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_connection_option_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> _proxyRoutingSettingsSections(
  AppLocalizations l10n,
) {
  return [
    SettingsSectionDefinition(
      title: l10n.proxy_routingSectionRegularTabs,
      keywords: settingsKeywords(l10n.proxy_routingSectionRegularTabsKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.proxy_routingRegularTabsModeTitle,
          subtitle: l10n.proxy_routingRegularTabsModeSubtitle,
          keywords: settingsKeywords(l10n.proxy_routingRegularTabsModeKeywords),
          child: const _RegularTabsModeSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.proxy_routingGlobalProxyTitle,
          subtitle: l10n.proxy_routingGlobalProxySubtitle,
          keywords: settingsKeywords(l10n.proxy_routingGlobalProxyKeywords),
          child: const _GlobalRoutingProxySection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.proxy_routingSectionPrivateTabs,
      keywords: settingsKeywords(l10n.proxy_routingSectionPrivateTabsKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.proxy_routingPrivateTabsProxyTitle,
          subtitle: l10n.proxy_routingPrivateTabsProxySubtitle,
          keywords: settingsKeywords(
            l10n.proxy_routingPrivateTabsProxyKeywords,
          ),
          child: const _PrivateTabsProxySection(),
        ),
      ],
    ),
  ];
}

class ProxyRoutingSettingsScreen extends StatelessWidget {
  const ProxyRoutingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.proxy_routingTitle,
      subtitle: l10n.proxy_routingSubtitle,
      icon: Icons.route_outlined,
      sections: _proxyRoutingSettingsSections(l10n),
    );
  }
}

class _RegularTabsModeSection extends ConsumerWidget {
  const _RegularTabsModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
      child: Column(
        children: [
          RadioListTile<ProxyRegularTabRoutingMode>.adaptive(
            value: ProxyRegularTabRoutingMode.container,
            title: Text(l10n.proxy_routingContainerBasedTitle),
            subtitle: Text(l10n.proxy_routingContainerBasedSubtitle),
          ),
          RadioListTile<ProxyRegularTabRoutingMode>.adaptive(
            value: ProxyRegularTabRoutingMode.all,
            title: Text(l10n.proxy_routingGlobalRoutingTitle),
            subtitle: Text(l10n.proxy_routingGlobalRoutingSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(proxyRoutingSettingsWithDefaultsProvider);
    if (settings.regularTabsMode != ProxyRegularTabRoutingMode.all) {
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.proxy_routingNotUsedTitle),
        subtitle: Text(l10n.proxy_routingNotUsedSubtitle),
      );
    }

    final options = ref.watch(proxyConnectionOptionsProvider);
    final optionsState = ref.watch(singboxProxyProfilesRepositoryProvider);
    return _ProxyConnectionPicker(
      options: options,
      optionsLoaded: optionsState.hasValue,
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
    final optionsState = ref.watch(singboxProxyProfilesRepositoryProvider);
    return _ProxyConnectionPicker(
      options: options,
      optionsLoaded: optionsState.hasValue,
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
  final bool optionsLoaded;
  final ProxyConnectionId? selectedId;
  final ValueChanged<ProxyConnectionId?> onChanged;

  const _ProxyConnectionPicker({
    required this.options,
    required this.optionsLoaded,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasUnknownSelection =
        selectedId != null &&
        optionsLoaded &&
        !proxyConnectionOptionExists(options, selectedId!);

    return RadioGroup<ProxyConnectionId?>(
      groupValue: selectedId,
      onChanged: onChanged,
      child: Column(
        children: [
          RadioListTile<ProxyConnectionId?>.adaptive(
            value: null,
            title: Text(l10n.proxy_routingNoneTitle),
            subtitle: Text(l10n.proxy_routingNoneSubtitle),
            secondary: const Icon(Icons.public),
          ),
          if (hasUnknownSelection)
            ListTile(
              leading: Icon(
                Icons.warning_amber_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l10n.proxy_unknownProxyTitle),
              subtitle: Text(l10n.proxy_routingUnknownProxySubtitle),
              trailing: TextButton(
                onPressed: () => onChanged(null),
                child: Text(l10n.common_clear),
              ),
            ),
          for (final option in options)
            RadioListTile<ProxyConnectionId?>.adaptive(
              value: option.id,
              title: Text(option.title),
              subtitle: Text(option.description(context)),
              secondary: const Icon(Icons.route_outlined),
            ),
        ],
      ),
    );
  }
}
