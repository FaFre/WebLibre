part of 'routes.dart';

@TypedGoRoute<FeedListRoute>(
  name: 'FeedListRoute',
  path: '/feeds',
  routes: [
    TypedGoRoute<FeedAddRoute>(name: FeedAddRoute.name, path: 'add'),
    TypedGoRoute<FeedArticleListRoute>(
      name: 'FeedArticleListRoute',
      path: 'articles/:feedId',
    ),
    TypedGoRoute<FeedArticleRoute>(
      name: 'FeedArticleRoute',
      path: 'article/:articleId',
    ),
    TypedGoRoute<FeedCreateRoute>(
      name: 'FeedCreateRoute',
      path: 'create/:feedId',
    ),
    TypedGoRoute<SelectFeedDialogRoute>(
      name: 'SelectFeedDialogRoute',
      path: 'available/:feedsJson',
    ),
    TypedGoRoute<FeedEditRoute>(name: 'FeedEditRoute', path: 'edit/:feedId'),
  ],
)
class FeedListRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FeedListScreen();
  }
}

class FeedCreateRoute extends GoRouteData {
  final Uri feedId;

  FeedCreateRoute({required this.feedId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedEditScreen.create(feedId: feedId);
  }
}

class SelectFeedDialogRoute extends GoRouteData {
  final String feedsJson;

  const SelectFeedDialogRoute({required this.feedsJson});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final feedUris = Set<Uri>.from(
      (jsonDecode(feedsJson) as List<dynamic>).map(
        (url) => Uri.parse(url as String),
      ),
    );

    return DialogPage(builder: (_) => SelectFeedDialog(feedUris: feedUris));
  }
}

class FeedEditRoute extends GoRouteData {
  final Uri feedId;

  const FeedEditRoute({required this.feedId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedEditScreen.edit(feedId: feedId);
  }
}

class FeedAddRoute extends GoRouteData {
  final Uri? $extra;

  static const name = 'FeedAddRoute';

  const FeedAddRoute({this.$extra});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => AddFeedDialog(initialUri: $extra));
  }
}

class FeedArticleListRoute extends GoRouteData {
  final Uri feedId;

  FeedArticleListRoute({required this.feedId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedArticleListScreen(feedId: feedId);
  }
}

class FeedArticleRoute extends GoRouteData {
  final String articleId;

  FeedArticleRoute({required this.articleId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedArticleScreen(articleId: articleId);
  }
}
