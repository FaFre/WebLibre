part of 'routes.dart';

@TypedGoRoute<BrowserRoute>(
  name: BrowserRoute.name,
  path: '/',
  routes: [
    TypedGoRoute<WebPageRoute>(name: 'WebPageRoute', path: 'page/:url'),
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
  ],
)
class BrowserRoute extends GoRouteData {
  static const name = 'BrowserRoute';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowserScreen();
  }
}

class WebPageRoute extends GoRouteData {
  final String url;
  final WebPageInfo? $extra;

  const WebPageRoute({required this.url, required this.$extra});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder: (_) => WebPageDialog(url: Uri.parse(url), precachedInfo: $extra),
    );
  }
}

enum TabType { regular, private }

class SearchRoute extends GoRouteData {
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
      initialSearchText:
          (searchText.isEmpty || searchText == emptySearchText)
              ? null
              : searchText,
    );
  }
}

class TorProxyRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TorProxyScreen();
  }
}

class ContainerListRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerListScreen();
  }
}

class ContainerEditRoute extends GoRouteData {
  final ContainerData $extra;

  ContainerEditRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.edit(initialContainer: $extra);
  }
}

class ContainerCreateRoute extends GoRouteData {
  final ContainerData $extra;

  ContainerCreateRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.create(initialContainer: $extra);
  }
}

class ContextMenuRoute extends GoRouteData {
  final String $extra;

  const ContextMenuRoute(this.$extra);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder:
          (_) => ContextMenuDialog(hitResult: HitResultJson.fromJson($extra)),
    );
  }
}
