// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $aboutRoute,
  $userAuthRoute,
  $settingsRoute,
  $browserRoute,
  $bangCategoriesRoute,
  $feedListRoute,
];

RouteBase get $aboutRoute => GoRouteData.$route(
  path: '/about',
  name: 'AboutRoute',

  factory: $AboutRouteExtension._fromState,
);

extension $AboutRouteExtension on AboutRoute {
  static AboutRoute _fromState(GoRouterState state) => AboutRoute();

  String get location => GoRouteData.$location('/about');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $userAuthRoute => GoRouteData.$route(
  path: '/userAuth',
  name: 'UserAuthRoute',

  factory: $UserAuthRouteExtension._fromState,
);

extension $UserAuthRouteExtension on UserAuthRoute {
  static UserAuthRoute _fromState(GoRouterState state) => UserAuthRoute();

  String get location => GoRouteData.$location('/userAuth');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  name: 'SettingsRoute',

  factory: $SettingsRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'general',
      name: 'GeneralSettingsRoute',

      factory: $GeneralSettingsRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'bang',
      name: 'BangSettingsRoute',

      factory: $BangSettingsRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'web_engine',
      name: 'WebEngineSettingsRoute',

      factory: $WebEngineSettingsRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'hardening',
          name: 'WebEngineHardeningRoute',

          factory: $WebEngineHardeningRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'group/:group',
              name: 'WebEngineHardeningGroupRoute',

              factory: $WebEngineHardeningGroupRouteExtension._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute();

  String get location => GoRouteData.$location('/settings');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $GeneralSettingsRouteExtension on GeneralSettingsRoute {
  static GeneralSettingsRoute _fromState(GoRouterState state) =>
      GeneralSettingsRoute();

  String get location => GoRouteData.$location('/settings/general');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangSettingsRouteExtension on BangSettingsRoute {
  static BangSettingsRoute _fromState(GoRouterState state) =>
      BangSettingsRoute();

  String get location => GoRouteData.$location('/settings/bang');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WebEngineSettingsRouteExtension on WebEngineSettingsRoute {
  static WebEngineSettingsRoute _fromState(GoRouterState state) =>
      WebEngineSettingsRoute();

  String get location => GoRouteData.$location('/settings/web_engine');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WebEngineHardeningRouteExtension on WebEngineHardeningRoute {
  static WebEngineHardeningRoute _fromState(GoRouterState state) =>
      WebEngineHardeningRoute();

  String get location =>
      GoRouteData.$location('/settings/web_engine/hardening');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WebEngineHardeningGroupRouteExtension
    on WebEngineHardeningGroupRoute {
  static WebEngineHardeningGroupRoute _fromState(GoRouterState state) =>
      WebEngineHardeningGroupRoute(group: state.pathParameters['group']!);

  String get location => GoRouteData.$location(
    '/settings/web_engine/hardening/group/${Uri.encodeComponent(group)}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $browserRoute => GoRouteData.$route(
  path: '/',
  name: 'BrowserRoute',

  factory: $BrowserRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'page/:url',
      name: 'WebPageRoute',

      factory: $WebPageRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'search/:searchText',
      name: 'SearchRoute',

      factory: $SearchRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'tor_proxy',
      name: 'TorProxyRoute',

      factory: $TorProxyRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'context_menu',
      name: 'ContextMenuRoute',

      factory: $ContextMenuRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'containers',
      name: 'ContainerListRoute',

      factory: $ContainerListRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'create',
          name: 'ContainerCreateRoute',

          factory: $ContainerCreateRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'edit',
          name: 'ContainerEditRoute',

          factory: $ContainerEditRouteExtension._fromState,
        ),
      ],
    ),
  ],
);

extension $BrowserRouteExtension on BrowserRoute {
  static BrowserRoute _fromState(GoRouterState state) => BrowserRoute();

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WebPageRouteExtension on WebPageRoute {
  static WebPageRoute _fromState(GoRouterState state) => WebPageRoute(
    url: state.pathParameters['url']!,
    $extra: state.extra as WebPageInfo?,
  );

  String get location =>
      GoRouteData.$location('/page/${Uri.encodeComponent(url)}');

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $SearchRouteExtension on SearchRoute {
  static SearchRoute _fromState(GoRouterState state) => SearchRoute(
    searchText:
        state.pathParameters['searchText'] ?? SearchRoute.emptySearchText,
  );

  String get location =>
      GoRouteData.$location('/search/${Uri.encodeComponent(searchText)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $TorProxyRouteExtension on TorProxyRoute {
  static TorProxyRoute _fromState(GoRouterState state) => TorProxyRoute();

  String get location => GoRouteData.$location('/tor_proxy');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ContextMenuRouteExtension on ContextMenuRoute {
  static ContextMenuRoute _fromState(GoRouterState state) =>
      ContextMenuRoute(state.extra as String);

  String get location => GoRouteData.$location('/context_menu');

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $ContainerListRouteExtension on ContainerListRoute {
  static ContainerListRoute _fromState(GoRouterState state) =>
      ContainerListRoute();

  String get location => GoRouteData.$location('/containers');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ContainerCreateRouteExtension on ContainerCreateRoute {
  static ContainerCreateRoute _fromState(GoRouterState state) =>
      ContainerCreateRoute(state.extra as ContainerData);

  String get location => GoRouteData.$location('/containers/create');

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $ContainerEditRouteExtension on ContainerEditRoute {
  static ContainerEditRoute _fromState(GoRouterState state) =>
      ContainerEditRoute(state.extra as ContainerData);

  String get location => GoRouteData.$location('/containers/edit');

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $bangCategoriesRoute => GoRouteData.$route(
  path: '/bangs',
  name: 'BangRoute',

  factory: $BangCategoriesRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search/:searchText',
      name: 'BangSearchRoute',

      factory: $BangSearchRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'category/:category',
      name: 'BangCategoryRoute',

      factory: $BangCategoryRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: ':subCategory',
          name: 'BangSubCategoryRoute',

          factory: $BangSubCategoryRouteExtension._fromState,
        ),
      ],
    ),
  ],
);

extension $BangCategoriesRouteExtension on BangCategoriesRoute {
  static BangCategoriesRoute _fromState(GoRouterState state) =>
      BangCategoriesRoute();

  String get location => GoRouteData.$location('/bangs');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangSearchRouteExtension on BangSearchRoute {
  static BangSearchRoute _fromState(GoRouterState state) => BangSearchRoute(
    searchText:
        state.pathParameters['searchText'] ?? BangSearchRoute.emptySearchText,
  );

  String get location =>
      GoRouteData.$location('/bangs/search/${Uri.encodeComponent(searchText)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangCategoryRouteExtension on BangCategoryRoute {
  static BangCategoryRoute _fromState(GoRouterState state) =>
      BangCategoryRoute(category: state.pathParameters['category']!);

  String get location =>
      GoRouteData.$location('/bangs/category/${Uri.encodeComponent(category)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangSubCategoryRouteExtension on BangSubCategoryRoute {
  static BangSubCategoryRoute _fromState(GoRouterState state) =>
      BangSubCategoryRoute(
        category: state.pathParameters['category']!,
        subCategory: state.pathParameters['subCategory']!,
      );

  String get location => GoRouteData.$location(
    '/bangs/category/${Uri.encodeComponent(category)}/${Uri.encodeComponent(subCategory)}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $feedListRoute => GoRouteData.$route(
  path: '/feeds',
  name: 'FeedListRoute',

  factory: $FeedListRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'add',
      name: 'FeedAddRoute',

      factory: $FeedAddRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'articles/:feedId',
      name: 'FeedArticleListRoute',

      factory: $FeedArticleListRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'article/:articleId',
      name: 'FeedArticleRoute',

      factory: $FeedArticleRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'create/:feedId',
      name: 'FeedCreateRoute',

      factory: $FeedCreateRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'available/:feedsJson',
      name: 'SelectFeedDialogRoute',

      factory: $SelectFeedDialogRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'edit/:feedId',
      name: 'FeedEditRoute',

      factory: $FeedEditRouteExtension._fromState,
    ),
  ],
);

extension $FeedListRouteExtension on FeedListRoute {
  static FeedListRoute _fromState(GoRouterState state) => FeedListRoute();

  String get location => GoRouteData.$location('/feeds');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FeedAddRouteExtension on FeedAddRoute {
  static FeedAddRoute _fromState(GoRouterState state) =>
      FeedAddRoute($extra: state.extra as Uri?);

  String get location => GoRouteData.$location('/feeds/add');

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

extension $FeedArticleListRouteExtension on FeedArticleListRoute {
  static FeedArticleListRoute _fromState(GoRouterState state) =>
      FeedArticleListRoute(feedId: Uri.parse(state.pathParameters['feedId']!)!);

  String get location => GoRouteData.$location(
    '/feeds/articles/${Uri.encodeComponent(feedId.toString())}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FeedArticleRouteExtension on FeedArticleRoute {
  static FeedArticleRoute _fromState(GoRouterState state) =>
      FeedArticleRoute(articleId: state.pathParameters['articleId']!);

  String get location =>
      GoRouteData.$location('/feeds/article/${Uri.encodeComponent(articleId)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FeedCreateRouteExtension on FeedCreateRoute {
  static FeedCreateRoute _fromState(GoRouterState state) =>
      FeedCreateRoute(feedId: Uri.parse(state.pathParameters['feedId']!)!);

  String get location => GoRouteData.$location(
    '/feeds/create/${Uri.encodeComponent(feedId.toString())}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SelectFeedDialogRouteExtension on SelectFeedDialogRoute {
  static SelectFeedDialogRoute _fromState(GoRouterState state) =>
      SelectFeedDialogRoute(feedsJson: state.pathParameters['feedsJson']!);

  String get location => GoRouteData.$location(
    '/feeds/available/${Uri.encodeComponent(feedsJson)}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FeedEditRouteExtension on FeedEditRoute {
  static FeedEditRoute _fromState(GoRouterState state) =>
      FeedEditRoute(feedId: Uri.parse(state.pathParameters['feedId']!)!);

  String get location => GoRouteData.$location(
    '/feeds/edit/${Uri.encodeComponent(feedId.toString())}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
