part of 'routes.dart';

@TypedGoRoute<BrowserRoute>(
  name: 'BrowserRoute',
  path: '/',
  routes: [
    TypedGoRoute<WebPageRoute>(name: 'WebPageRoute', path: 'page/:url'),
    TypedGoRoute<SearchRoute>(name: 'SearchRoute', path: 'search/:searchText'),
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
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowserScreen();
  }
}

class WebPageRoute extends GoRouteData {
  final String url;

  const WebPageRoute({required this.url});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder:
          (_) => WebPageDialog(
            url: Uri.parse(url),
            precachedInfo: state.extra as WebPageInfo?,
          ),
    );
  }
}

class SearchRoute extends GoRouteData {
  static const String emptySearchText = ' ';

  //This should be nullable but isnt allowed by go_router
  final String searchText;

  const SearchRoute({this.searchText = SearchRoute.emptySearchText});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchScreen(
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
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.edit(
      initialContainer: state.extra! as ContainerData,
    );
  }
}

class ContainerCreateRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.create(
      initialContainer: state.extra! as ContainerData,
    );
  }
}

class ContextMenuRoute extends GoRouteData {
  const ContextMenuRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder:
          (_) => ContextMenuDialog(
            hitResult: HitResultJson.fromJson(state.extra! as String),
          ),
    );
  }
}
