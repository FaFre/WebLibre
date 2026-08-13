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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';

/// Which routes name a given proxy connection.
///
/// Counts rather than a formatted string: the connection menu has room for
/// about thirty characters and renders the counted kinds as an icon with the
/// number beside it, so the shape of the answer is the caller's business.
class ProxyConnectionUsage with FastEquatable {
  /// The global route carries regular tabs through this connection.
  final bool routesRegularTabs;

  /// The private-tab route uses this connection.
  final bool routesPrivateTabs;

  /// Containers whose own route names this connection.
  final int containerCount;

  /// Isolation *groups* routed through this connection — an isolated tab plus
  /// whatever it opened share one route, so this counts groups, not tabs.
  final int isolatedGroupCount;

  ProxyConnectionUsage({
    required this.routesRegularTabs,
    required this.routesPrivateTabs,
    required this.containerCount,
    required this.isolatedGroupCount,
  });

  /// Whether nothing routes through this connection. Turning it on or off then
  /// changes nothing the user can observe.
  bool get isUnused =>
      !routesRegularTabs &&
      !routesPrivateTabs &&
      containerCount == 0 &&
      isolatedGroupCount == 0;

  @override
  List<Object?> get hashParameters => [
    routesRegularTabs,
    routesPrivateTabs,
    containerCount,
    isolatedGroupCount,
  ];
}

/// Find every route that names [id].
///
/// Two things depend on this being complete. It is what makes toggling a
/// connection read as a consequence ("Blocked · Regular tabs") rather than a
/// switch with no visible effect, and — via [ProxyConnectionUsage.isUnused] —
/// it decides whether a profile is listed in the connection menu at all, since
/// a subscription import can leave dozens behind.
///
/// So a kind of route that is not counted here does not merely go unmentioned:
/// the connection carrying it disappears from the menu and the routes it does
/// carry are reported as unused. Every place a [ProxyConnectionId] can be
/// persisted has to be represented below.
ProxyConnectionUsage proxyConnectionUsage({
  required ProxyConnectionId id,
  required ProxyRoutingSettings routingSettings,
  required List<ContainerDataWithCount> containers,
}) {
  return ProxyConnectionUsage(
    routesRegularTabs:
        routingSettings.regularTabsMode == ProxyRegularTabRoutingMode.all &&
        routingSettings.regularTabsProxyConnectionId == id,
    routesPrivateTabs: routingSettings.privateTabsProxyConnectionId == id,
    containerCount: containers
        .where((container) => container.metadata.proxyConnectionId == id)
        .length,
    isolatedGroupCount: routingSettings.isolationContextRoutes.values
        .where((route) => route == id)
        .length,
  );
}
