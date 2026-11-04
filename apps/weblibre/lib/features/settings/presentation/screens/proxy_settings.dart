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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/proxy/domain/providers/connection_activity.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_log_level_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';

part 'proxy_settings.g.dart';

/// Whether a global route is set: all regular tabs, or the private tabs,
/// through a connection. Routing them is `connections.global_routing`;
/// a route already in place keeps its entries, which is how it is
/// seen and undone (P5).
final globalRouteInUse = proxyRoutingSettingsWithDefaultsProvider.select(
  (s) =>
      s.regularTabsMode == ProxyRegularTabRoutingMode.all ||
      s.privateTabsProxyConnectionId != null,
);

/// Whether there are connections to come back to: a saved profile, a global
/// route, one running, or Tor set up in any way ([torInUse] — autostart that
/// failed and container or isolated-group routes included). The Proxy
/// category then stays in Settings even while connections are hidden, so the
/// existing ones keep their status, repair and stop controls (P5); the list
/// itself hides adding new ones.
@Riverpod()
bool connectionsInUse(Ref ref) {
  // All watched up front, not behind `||`, so none is dropped and reloaded
  // as another one changes.
  final hasProfiles = ref.watch(
    singboxProxyProfilesRepositoryProvider.select(
      (profiles) => profiles.value?.isNotEmpty ?? false,
    ),
  );
  final globalRoute = ref.watch(globalRouteInUse);
  final active = ref.watch(anyConnectionActiveProvider);
  final tor = ref.watch(torInUseProvider);

  return hasProfiles || globalRoute || active || tor;
}

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
          opensScreen: true,
          child: const _ProxyConnectionsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_proxyRoutingTitle,
          feature: FeatureId.connectionsGlobalRouting,
          keptWhen: globalRouteInUse,
          subtitle: l10n.settings_proxyRoutingSubtitle,
          keywords: settingsKeywords(l10n.settings_proxyRoutingKeywords),
          opensScreen: true,
          child: const _ProxyRoutingTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_proxyLogsTitle,
          subtitle: l10n.settings_indexProxyLogsSubtitle,
          keywords: settingsKeywords(l10n.settings_proxyLogsKeywords),
          opensScreen: true,
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

    // While a connection is in use everything here stays usable, so it can
    // be checked and stopped (P5).
    return HiddenFeatureScope(
      feature: FeatureId.connectionsImportVpnProxy,
      keptWhen: connectionsInUseProvider,
      child: SettingsDetailScaffold(
        title: l10n.settings_proxyTitle,
        subtitle: l10n.settings_proxySubtitle,
        icon: MdiIcons.lanConnect,
        sections: proxySettingsSections(context),
      ),
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
    final logLevel = ref.watch(storedProxyDiagnosticsSettingsProvider).logLevel;

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
