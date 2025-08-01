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

@TypedGoRoute<BrowserRoute>(
  name: BrowserRoute.name,
  path: '/',
  routes: [
    TypedGoRoute<SearchRoute>(
      name: 'SearchRoute',
      path: 'search/:tabType/:searchText',
    ),
    TypedGoRoute<TorProxyRoute>(name: 'TorProxyRoute', path: 'tor_proxy'),
    TypedGoRoute<ContextMenuRoute>(
      name: 'ContextMenuRoute',
      path: 'context_menu',
    ),
    TypedGoRoute<ContainerListRoute>(
      name: 'ContainerListRoute',
      path: 'containers',
      routes: [
        TypedGoRoute<ContainerCreateRoute>(
          name: 'ContainerCreateRoute',
          path: 'create',
        ),
        TypedGoRoute<ContainerEditRoute>(
          name: 'ContainerEditRoute',
          path: 'edit',
        ),
      ],
    ),
    TypedGoRoute<ContainerSelectionRoute>(
      name: 'ContainerSelectionRoute',
      path: 'select_container',
    ),
    TypedGoRoute<TabTreeRoute>(
      name: 'TabTreeRoute',
      path: 'tab_tree/:rootTabId',
    ),
  ],
)
class BrowserRoute extends GoRouteData with _$BrowserRoute {
  static const name = 'BrowserRoute';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowserScreen();
  }
}

enum TabType { regular, private, child }

class SearchRoute extends GoRouteData with _$SearchRoute {
  static const String emptySearchText = ' ';

  final TabType tabType;

  //This should be nullable but isnt allowed by go_router
  final String searchText;

  const SearchRoute({
    required this.tabType,
    this.searchText = SearchRoute.emptySearchText,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchScreen(
      tabType: tabType,
      initialSearchText: (searchText.isEmpty || searchText == emptySearchText)
          ? null
          : searchText,
    );
  }
}

class TorProxyRoute extends GoRouteData with _$TorProxyRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TorProxyScreen();
  }
}

class ContainerListRoute extends GoRouteData with _$ContainerListRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerListScreen();
  }
}

class ContainerSelectionRoute extends GoRouteData
    with _$ContainerSelectionRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerSelectionScreen();
  }
}

class ContainerEditRoute extends GoRouteData with _$ContainerEditRoute {
  final ContainerDataWithCount $extra;

  ContainerEditRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.edit(initialContainer: $extra);
  }
}

class ContainerCreateRoute extends GoRouteData with _$ContainerCreateRoute {
  final ContainerData $extra;

  ContainerCreateRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.create(initialContainer: $extra);
  }
}

class ContextMenuRoute extends GoRouteData with _$ContextMenuRoute {
  final String $extra;

  const ContextMenuRoute(this.$extra);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder: (_) =>
          ContextMenuDialog(hitResult: HitResultJson.fromJson($extra)),
    );
  }
}

class TabTreeRoute extends GoRouteData with _$TabTreeRoute {
  final String rootTabId;

  const TabTreeRoute(this.rootTabId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => TabTreeDialog(rootTabId));
  }
}
