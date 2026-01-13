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
    TypedGoRoute<AppearanceDisplaySettingsRoute>(
      name: 'AppearanceDisplaySettingsRoute',
      path: 'appearance_display',
    ),
    TypedGoRoute<PrivacySecuritySettingsRoute>(
      name: 'PrivacySecuritySettingsRoute',
      path: 'privacy_security',
    ),
    TypedGoRoute<SearchContentSettingsRoute>(
      name: 'SearchContentSettingsRoute',
      path: 'search_content',
    ),
    TypedGoRoute<TabsBehaviorSettingsRoute>(
      name: 'TabsBehaviorSettingsRoute',
      path: 'tabs_behavior',
    ),
    TypedGoRoute<FingerprintingSettingsRoute>(
      name: 'FingerprintingSettingsRoute',
      path: 'fingerprinting',
    ),
    TypedGoRoute<AdvancedSettingsRoute>(
      name: 'AdvancedSettingsRoute',
      path: 'advanced',
    ),
    TypedGoRoute<BangSettingsRoute>(name: 'BangSettingsRoute', path: 'bang'),
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
    TypedGoRoute<FingerprintSettingsRoute>(
      name: 'FingerprintSettingsRoute',
      path: 'fingerprint',
    ),
    TypedGoRoute<LocaleSettingsRoute>(
      name: 'LocaleSettingsRoute',
      path: 'locales',
    ),
    TypedGoRoute<AddonCollectionRoute>(
      name: 'AddonCollectionRoute',
      path: 'addon_collection',
    ),
  ],
)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class AppearanceDisplaySettingsRoute extends GoRouteData
    with $AppearanceDisplaySettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppearanceDisplaySettingsScreen();
  }
}

class PrivacySecuritySettingsRoute extends GoRouteData
    with $PrivacySecuritySettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PrivacySecuritySettingsScreen();
  }
}

class SearchContentSettingsRoute extends GoRouteData
    with $SearchContentSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SearchContentSettingsScreen();
  }
}

class TabsBehaviorSettingsRoute extends GoRouteData
    with $TabsBehaviorSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TabsBehaviorSettingsScreen();
  }
}

class FingerprintingSettingsRoute extends GoRouteData
    with $FingerprintingSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FingerprintingSettingsScreen();
  }
}

class AdvancedSettingsRoute extends GoRouteData with $AdvancedSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdvancedSettingsScreen();
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

class FingerprintSettingsRoute extends GoRouteData
    with $FingerprintSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FingerprintSettingsScreen();
  }
}

class LocaleSettingsRoute extends GoRouteData with $LocaleSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LocaleSettingsScreen();
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
