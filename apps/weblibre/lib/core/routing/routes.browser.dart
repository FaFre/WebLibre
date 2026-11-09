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

@TypedGoRoute<BrowserRoute>(
  name: BrowserRoute.name,
  path: '/browser',
  routes: [
    TypedGoRoute<SearchRoute>(
      name: 'SearchRoute',
      path: 'search/:tabType/:searchText',
    ),
    TypedGoRoute<TabViewRoute>(name: 'TabViewRoute', path: 'tab_view'),
    TypedGoRoute<KeyboardShortcutsOverviewRoute>(
      name: 'KeyboardShortcutsOverviewRoute',
      path: 'keyboard_shortcuts',
    ),
    TypedGoRoute<ContextMenuRoute>(
      name: 'ContextMenuRoute',
      path: 'context_menu',
    ),
    TypedGoRoute<ContainerDraftRoute>(
      name: ContainerDraftRoute.name,
      path: 'container_draft',
    ),
    TypedGoRoute<ContainerListRoute>(
      name: ContainerListRoute.name,
      path: 'containers',
      routes: [
        TypedGoRoute<ContainerCreateRoute>(
          name: ContainerCreateRoute.name,
          path: 'create/:containerData',
        ),
        TypedGoRoute<ContainerEditRoute>(
          name: ContainerEditRoute.name,
          path: 'edit/:containerData',
        ),
      ],
    ),
    TypedGoRoute<ContainerSelectionRoute>(
      name: ContainerSelectionRoute.name,
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

enum TabType { regular, private, child, isolated }

class SearchRoute extends GoRouteData with $SearchRoute {
  static const String emptySearchText = ' ';

  final TabType tabType;

  //This should be nullable but isnt allowed by go_router
  final String searchText;

  final bool launchedFromIntent;

  final bool autoSubmitSearch;

  /// When provided, the search screen will load URLs into this existing tab
  /// instead of creating a new tab. This also changes the UI to show
  /// site-specific bangs instead of the tab type selector.
  final String? tabId;

  /// When provided, the search screen picks the page shown beside this tab in
  /// split view: a chosen open tab or a submitted URL is paired with it.
  final String? splitWithTabId;

  const SearchRoute({
    required this.tabType,
    this.searchText = SearchRoute.emptySearchText,
    this.launchedFromIntent = false,
    this.autoSubmitSearch = false,
    this.tabId,
    this.splitWithTabId,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchScreen(
      tabType: tabType,
      initialSearchText: (searchText.isEmpty || searchText == emptySearchText)
          ? null
          : searchText,
      launchedFromIntent: launchedFromIntent,
      autoSubmitSearch: autoSubmitSearch,
      tabId: tabId,
      splitWithTabId: splitWithTabId,
    );
  }
}

/// The container screens, reachable only while containers are shown. The
/// router's top-level redirect sends them to the browser otherwise: it has
/// the router's `ref`, where a route's own redirect would need
/// `ProviderScope.containerOf`.
const containerRouteNames = {
  ContainerDraftRoute.name,
  ContainerListRoute.name,
  ContainerSelectionRoute.name,
  ContainerEditRoute.name,
  ContainerCreateRoute.name,
};

class ContainerDraftRoute extends GoRouteData with $ContainerDraftRoute {
  static const name = 'ContainerDraftRoute';

  const ContainerDraftRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerDraftSuggestionsScreen();
  }
}

class ContainerListRoute extends GoRouteData with $ContainerListRoute {
  static const name = 'ContainerListRoute';

  const ContainerListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerListScreen();
  }
}

class ContainerSelectionRoute extends GoRouteData
    with $ContainerSelectionRoute {
  static const name = 'ContainerSelectionRoute';

  const ContainerSelectionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerSelectionScreen();
  }
}

class ContainerEditRoute extends GoRouteData with $ContainerEditRoute {
  static const name = 'ContainerEditRoute';

  final String containerData;

  const ContainerEditRoute({required this.containerData});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.edit(
      initialContainer: ContainerDataWithCount.fromJson(
        jsonDecode(containerData) as Map<String, dynamic>,
      ),
    );
  }
}

class ContainerCreateRoute extends GoRouteData with $ContainerCreateRoute {
  static const name = 'ContainerCreateRoute';

  final String containerData;
  final String tabIds;

  ContainerCreateRoute({required this.containerData, this.tabIds = '[]'});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final tabIdsList = jsonDecode(tabIds) as List;
    final tabIdsSet = tabIdsList.cast<String>().toSet();

    return ContainerEditScreen.create(
      initialContainer: ContainerData.fromJson(
        jsonDecode(containerData) as Map<String, dynamic>,
      ),
      tabIds: tabIdsSet.isNotEmpty ? tabIdsSet : null,
    );
  }
}

class ContextMenuRoute extends GoRouteData with $ContextMenuRoute {
  final String hitResult;

  /// The tab the long press happened in, which in split view is not
  /// necessarily the one the address bar shows.
  final String tabId;

  const ContextMenuRoute({required this.hitResult, required this.tabId});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder: (_) => ContextMenuDialog(
        hitResult: HitResultJson.fromJson(hitResult),
        sourceTabId: tabId,
      ),
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
  final String? contextId;
  final String? containerMode;

  const OpenSharedContentRoute({
    this.sharedUrl = 'about:blank',
    this.contextId,
    this.containerMode,
  });

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      builder: (_) => OpenSharedContent(
        sharedUrl: Uri.tryParse(sharedUrl) ?? Uri.parse('about:blank'),
        contextId: contextId,
        containerMode: IntentContainerMode.fromWireValue(
          containerMode,
          contextId: contextId,
        ),
      ),
    );
  }
}

class TabViewRoute extends GoRouteData with $TabViewRoute {
  const TabViewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      // Edge to edge: the tray's header and action bar run behind the system
      // bars themselves (#651).
      useSafeArea: false,
      builder: (_) => const TabViewScreen(),
    );
  }
}

class KeyboardShortcutsOverviewRoute extends GoRouteData
    with $KeyboardShortcutsOverviewRoute {
  const KeyboardShortcutsOverviewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const KeyboardShortcutsOverviewDialog());
  }
}

class SelectProfileRoute extends GoRouteData with $SelectProfileRoute {
  const SelectProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(builder: (_) => const SelectProfileDialog());
  }
}
