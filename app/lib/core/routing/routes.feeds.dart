part of 'routes.dart';

@TypedGoRoute<FeedListRoute>(
  name: 'FeedListRoute',
  path: '/feeds',
  routes: [
    TypedGoRoute<FeedArticleListRoute>(
      name: 'FeedArticleListRoute',
      path: 'articles/:feedId',
    ),
    TypedGoRoute<FeedArticleRoute>(
      name: 'FeedArticleRoute',
      path: 'article/:articleId',
    ),
    TypedGoRoute<FeedCreateRoute>(name: 'FeedCreateRoute', path: 'create'),
  ],
)
class FeedListRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FeedListScreen();
  }
}

class FeedCreateRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedEditScreen.create(initialFeed: state.extra! as FeedData);
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
