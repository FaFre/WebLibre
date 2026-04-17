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
part of 'routes.dart';

@TypedGoRoute<AddonManagerRoute>(
  name: 'AddonManagerRoute',
  path: '/addons',
  routes: [
    TypedGoRoute<AddonDetailsRoute>(
      name: 'AddonDetailsRoute',
      path: 'details/:addonId',
    ),
    TypedGoRoute<AddonPermissionsRoute>(
      name: 'AddonPermissionsRoute',
      path: 'permissions/:addonId',
    ),
    TypedGoRoute<AddonInternalSettingsRoute>(
      name: 'AddonInternalSettingsRoute',
      path: 'settings/:addonId',
    ),
  ],
)
class AddonManagerRoute extends GoRouteData with $AddonManagerRoute {
  const AddonManagerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddonManagerScreen();
  }
}

class AddonDetailsRoute extends GoRouteData with $AddonDetailsRoute {
  final String addonId;

  const AddonDetailsRoute({required this.addonId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AddonDetailsScreen(addonId: addonId);
  }
}

class AddonPermissionsRoute extends GoRouteData with $AddonPermissionsRoute {
  final String addonId;

  const AddonPermissionsRoute({required this.addonId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AddonPermissionsScreen(addonId: addonId);
  }
}

class AddonInternalSettingsRoute extends GoRouteData
    with $AddonInternalSettingsRoute {
  final String addonId;

  const AddonInternalSettingsRoute({required this.addonId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AddonInternalSettingsScreen(addonId: addonId);
  }
}
