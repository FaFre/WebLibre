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

@TypedGoRoute<TorProxyRoute>(
  name: 'TorProxyRoute',
  path: '/tor',
  routes: [
    TypedGoRoute<TorCountryPickerRoute>(
      name: 'TorCountryPickerRoute',
      path: 'country_picker',
    ),
  ],
)
class TorProxyRoute extends GoRouteData with $TorProxyRoute {
  const TorProxyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TorProxyScreen();
  }
}

class TorCountryPickerRoute extends GoRouteData with $TorCountryPickerRoute {
  final String title;
  final String? $extra;

  const TorCountryPickerRoute({required this.title, this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CountryPickerScreen(
      title: title,
      selectedCountryCode: $extra,
    );
  }
}
