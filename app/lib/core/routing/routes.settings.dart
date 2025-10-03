/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

@TypedGoRoute<SettingsRoute>(
  name: 'SettingsRoute',
  path: '/settings',
  routes: [
    TypedGoRoute<GeneralSettingsRoute>(
      name: 'GeneralSettingsRoute',
      path: 'general',
    ),
    TypedGoRoute<BangSettingsRoute>(name: 'BangSettingsRoute', path: 'bang'),
    TypedGoRoute<WebEngineSettingsRoute>(
      name: 'WebEngineSettingsRoute',
      path: 'web_engine',
      routes: [
        TypedGoRoute<WebEngineHardeningRoute>(
          name: 'WebEngineHardeningRoute',
          path: 'hardening',
          routes: [
            TypedGoRoute<WebEngineHardeningGroupRoute>(
              name: 'WebEngineHardeningGroupRoute',
              path: 'group/:group',
            ),
          ],
        ),
        TypedGoRoute<DohSettingsRoute>(name: 'DohSettingsRoute', path: 'doh'),
      ],
    ),
    TypedGoRoute<DeveloperSettingsRoute>(
      name: 'DeveloperSettingsRoute',
      path: 'developer',
      routes: [
        TypedGoRoute<AddonCollectionRoute>(
          name: 'AddonCollectionRoute',
          path: 'addon_collection',
        ),
      ],
    ),
  ],
)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class GeneralSettingsRoute extends GoRouteData with $GeneralSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GeneralSettingsScreen();
  }
}

class BangSettingsRoute extends GoRouteData with $BangSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangSettingsScreen();
  }
}

class DohSettingsRoute extends GoRouteData with $DohSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DohSettingsScreen();
  }
}

class WebEngineSettingsRoute extends GoRouteData with $WebEngineSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineSettingsScreen();
  }
}

class DeveloperSettingsRoute extends GoRouteData with $DeveloperSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DeveloperSettingsScreen();
  }
}

class AddonCollectionRoute extends GoRouteData with $AddonCollectionRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddonCollectionScreen();
  }
}

class WebEngineHardeningRoute extends GoRouteData
    with $WebEngineHardeningRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineHardeningScreen();
  }
}

class WebEngineHardeningGroupRoute extends GoRouteData
    with $WebEngineHardeningGroupRoute {
  final String group;

  const WebEngineHardeningGroupRoute({required this.group});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WebEngineHardeningGroupScreen(groupName: group);
  }
}
