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
  path: '/browser',
  routes: [
    TypedGoRoute<SearchRoute>(
      name: 'SearchRoute',
      path: 'search/:tabType/:searchText',
    ),
    TypedGoRoute<TorProxyRoute>(name: 'TorProxyRoute', path: 'tor_proxy'),
    TypedGoRoute<HistoryRoute>(name: 'HistoryRoute', path: 'history'),
    TypedGoRoute<TabViewRoute>(name: 'TabViewRoute', path: 'tab_view'),
    TypedGoRoute<ContextMenuRoute>(
      name: 'ContextMenuRoute',
      path: 'context_menu',
    ),
    TypedGoRoute<ContainerDraftRoute>(
      name: 'ContainerDraftRoute',
      path: 'container_draft',
    ),
    TypedGoRoute<ContainerListRoute>(
      name: 'ContainerListRoute',
      path: 'containers',
      routes: [
        TypedGoRoute<ContainerCreateRoute>(
          name: 'ContainerCreateRoute',
          path: 'create/:containerData',
        ),
        TypedGoRoute<ContainerEditRoute>(
          name: 'ContainerEditRoute',
          path: 'edit/:containerData',
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
    TypedGoRoute<OpenSharedContentRoute>(
      name: 'OpenSharedContentRoute',
      path: 'open_content',
    ),
    TypedGoRoute<SelectProfileRoute>(
      name: 'SelectProfileRoute',
      path: 'profile',
    ),
    TypedGoRoute<ProfileListRoute>(
      name: 'ProfileListRoute',
      path: 'profiles',
      routes: [
        TypedGoRoute<EditProfileRoute>(name: 'ProfileEditScreen', path: 'edit'),
        TypedGoRoute<CreateProfileRoute>(
          name: 'CreateProfileRoute',
          path: 'create',
        ),
      ],
    ),
  ],
)
class BrowserRoute extends GoRouteData with $BrowserRoute {
  static const name = 'BrowserRoute';

  const BrowserRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowserScreen();
  }
}

enum TabType { regular, private, child }

class SearchRoute extends GoRouteData with $SearchRoute {
  static const String emptySearchText = ' ';

  final TabType tabType;

  //This should be nullable but isnt allowed by go_router
  final String searchText;

  final bool launchedFromIntent;

  const SearchRoute({
    required this.tabType,
    this.searchText = SearchRoute.emptySearchText,
    this.launchedFromIntent = false,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchScreen(
      tabType: tabType,
      initialSearchText: (searchText.isEmpty || searchText == emptySearchText)
          ? null
          : searchText,
      launchedFromIntent: launchedFromIntent,
    );
  }
}

class TorProxyRoute extends GoRouteData with $TorProxyRoute {
  const TorProxyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TorProxyScreen();
  }
}

class ContainerDraftRoute extends GoRouteData with $ContainerDraftRoute {
  const ContainerDraftRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerDraftSuggestionsScreen();
  }
}

class ContainerListRoute extends GoRouteData with $ContainerListRoute {
  const ContainerListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerListScreen();
  }
}

class ContainerSelectionRoute extends GoRouteData
    with $ContainerSelectionRoute {
  const ContainerSelectionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerSelectionScreen();
  }
}

class ContainerEditRoute extends GoRouteData with $ContainerEditRoute {
  final String containerData;

  const ContainerEditRoute({required this.containerData});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.edit(
      initialContainer: ContainerData.fromJson(
        jsonDecode(containerData) as Map<String, dynamic>,
      ),
    );
  }
}

class ContainerCreateRoute extends GoRouteData with $ContainerCreateRoute {
  final String containerData;

  ContainerCreateRoute({required this.containerData});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.create(
      initialContainer: ContainerData.fromJson(
        jsonDecode(containerData) as Map<String, dynamic>,
      ),
    );
  }
}

class ContextMenuRoute extends GoRouteData with $ContextMenuRoute {
  final String hitResult;

  const ContextMenuRoute({required this.hitResult});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder: (_) =>
          ContextMenuDialog(hitResult: HitResultJson.fromJson(hitResult)),
    );
  }
}

class TabTreeRoute extends GoRouteData with $TabTreeRoute {
  final String rootTabId;

  const TabTreeRoute(this.rootTabId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => TabTreeDialog(rootTabId));
  }
}

class OpenSharedContentRoute extends GoRouteData with $OpenSharedContentRoute {
  final String sharedUrl;

  const OpenSharedContentRoute({this.sharedUrl = 'about:blank'});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder: (_) => OpenSharedContent(
        sharedUrl: Uri.tryParse(sharedUrl) ?? Uri.parse('about:blank'),
      ),
    );
  }
}

class HistoryRoute extends GoRouteData with $HistoryRoute {
  const HistoryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HistoryScreen();
  }
}

class TabViewRoute extends GoRouteData with $TabViewRoute {
  const TabViewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const TabViewScreen());
  }
}

class SelectProfileRoute extends GoRouteData with $SelectProfileRoute {
  const SelectProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => SelectProfileDialog());
  }
}

class ProfileListRoute extends GoRouteData with $ProfileListRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileListScreen();
  }
}

class CreateProfileRoute extends GoRouteData with $CreateProfileRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileEditScreen(profile: null);
  }
}

class EditProfileRoute extends GoRouteData with $EditProfileRoute {
  final String profile;

  const EditProfileRoute({required this.profile});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileEditScreen(
      profile: Profile.fromJson(jsonDecode(profile) as Map<String, dynamic>),
    );
  }
}
