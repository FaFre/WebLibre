// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $aboutRoute,
  $settingsRoute,
  $browserRoute,
  $bangCategoriesRoute,
  $feedListRoute,
];

RouteBase get $aboutRoute => GoRouteData.$route(
  path: '/about',
  name: 'AboutRoute',

  factory: _$AboutRoute._fromState,
);

mixin _$AboutRoute on GoRouteData {
  static AboutRoute _fromState(GoRouterState state) => AboutRoute();

  @override
  String get location => GoRouteData.$location('/about');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  name: 'SettingsRoute',

  factory: _$SettingsRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'general',
      name: 'GeneralSettingsRoute',

      factory: _$GeneralSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'bang',
      name: 'BangSettingsRoute',

      factory: _$BangSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'web_engine',
      name: 'WebEngineSettingsRoute',

      factory: _$WebEngineSettingsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'hardening',
          name: 'WebEngineHardeningRoute',

          factory: _$WebEngineHardeningRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'group/:group',
              name: 'WebEngineHardeningGroupRoute',

              factory: _$WebEngineHardeningGroupRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

mixin _$SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$GeneralSettingsRoute on GoRouteData {
  static GeneralSettingsRoute _fromState(GoRouterState state) =>
      GeneralSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/general');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$BangSettingsRoute on GoRouteData {
  static BangSettingsRoute _fromState(GoRouterState state) =>
      BangSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/bang');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$WebEngineSettingsRoute on GoRouteData {
  static WebEngineSettingsRoute _fromState(GoRouterState state) =>
      WebEngineSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/web_engine');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$WebEngineHardeningRoute on GoRouteData {
  static WebEngineHardeningRoute _fromState(GoRouterState state) =>
      WebEngineHardeningRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/web_engine/hardening');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$WebEngineHardeningGroupRoute on GoRouteData {
  static WebEngineHardeningGroupRoute _fromState(GoRouterState state) =>
      WebEngineHardeningGroupRoute(group: state.pathParameters['group']!);

  WebEngineHardeningGroupRoute get _self =>
      this as WebEngineHardeningGroupRoute;

  @override
  String get location => GoRouteData.$location(
    '/settings/web_engine/hardening/group/${Uri.encodeComponent(_self.group)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $browserRoute => GoRouteData.$route(
  path: '/',
  name: 'BrowserRoute',

  factory: _$BrowserRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'page/:url',
      name: 'WebPageRoute',

      factory: _$WebPageRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'search/:tabType/:searchText',
      name: 'SearchRoute',

      factory: _$SearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tor_proxy',
      name: 'TorProxyRoute',

      factory: _$TorProxyRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'context_menu',
      name: 'ContextMenuRoute',

      factory: _$ContextMenuRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'containers',
      name: 'ContainerListRoute',

      factory: _$ContainerListRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'create',
          name: 'ContainerCreateRoute',

          factory: _$ContainerCreateRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'edit',
          name: 'ContainerEditRoute',

          factory: _$ContainerEditRoute._fromState,
        ),
      ],
    ),
  ],
);

mixin _$BrowserRoute on GoRouteData {
  static BrowserRoute _fromState(GoRouterState state) => BrowserRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$WebPageRoute on GoRouteData {
  static WebPageRoute _fromState(GoRouterState state) => WebPageRoute(
    url: state.pathParameters['url']!,
    $extra: state.extra as WebPageInfo?,
  );

  WebPageRoute get _self => this as WebPageRoute;

  @override
  String get location =>
      GoRouteData.$location('/page/${Uri.encodeComponent(_self.url)}');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin _$SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) => SearchRoute(
    tabType: _$TabTypeEnumMap._$fromName(state.pathParameters['tabType']!)!,
    searchText:
        state.pathParameters['searchText'] ?? SearchRoute.emptySearchText,
  );

  SearchRoute get _self => this as SearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/search/${Uri.encodeComponent(_$TabTypeEnumMap[_self.tabType]!)}/${Uri.encodeComponent(_self.searchText)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$TabTypeEnumMap = {
  TabType.regular: 'regular',
  TabType.private: 'private',
};

mixin _$TorProxyRoute on GoRouteData {
  static TorProxyRoute _fromState(GoRouterState state) => TorProxyRoute();

  @override
  String get location => GoRouteData.$location('/tor_proxy');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$ContextMenuRoute on GoRouteData {
  static ContextMenuRoute _fromState(GoRouterState state) =>
      ContextMenuRoute(state.extra as String);

  ContextMenuRoute get _self => this as ContextMenuRoute;

  @override
  String get location => GoRouteData.$location('/context_menu');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin _$ContainerListRoute on GoRouteData {
  static ContainerListRoute _fromState(GoRouterState state) =>
      ContainerListRoute();

  @override
  String get location => GoRouteData.$location('/containers');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$ContainerCreateRoute on GoRouteData {
  static ContainerCreateRoute _fromState(GoRouterState state) =>
      ContainerCreateRoute(state.extra as ContainerData);

  ContainerCreateRoute get _self => this as ContainerCreateRoute;

  @override
  String get location => GoRouteData.$location('/containers/create');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin _$ContainerEditRoute on GoRouteData {
  static ContainerEditRoute _fromState(GoRouterState state) =>
      ContainerEditRoute(state.extra as ContainerData);

  ContainerEditRoute get _self => this as ContainerEditRoute;

  @override
  String get location => GoRouteData.$location('/containers/edit');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

RouteBase get $bangCategoriesRoute => GoRouteData.$route(
  path: '/bangs',
  name: 'BangRoute',

  factory: _$BangCategoriesRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search/:searchText',
      name: 'BangSearchRoute',

      factory: _$BangSearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'category/:category',
      name: 'BangCategoryRoute',

      factory: _$BangCategoryRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':subCategory',
          name: 'BangSubCategoryRoute',

          factory: _$BangSubCategoryRoute._fromState,
        ),
      ],
    ),
  ],
);

mixin _$BangCategoriesRoute on GoRouteData {
  static BangCategoriesRoute _fromState(GoRouterState state) =>
      BangCategoriesRoute();

  @override
  String get location => GoRouteData.$location('/bangs');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$BangSearchRoute on GoRouteData {
  static BangSearchRoute _fromState(GoRouterState state) => BangSearchRoute(
    searchText:
        state.pathParameters['searchText'] ?? BangSearchRoute.emptySearchText,
  );

  BangSearchRoute get _self => this as BangSearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/search/${Uri.encodeComponent(_self.searchText)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$BangCategoryRoute on GoRouteData {
  static BangCategoryRoute _fromState(GoRouterState state) =>
      BangCategoryRoute(category: state.pathParameters['category']!);

  BangCategoryRoute get _self => this as BangCategoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/category/${Uri.encodeComponent(_self.category)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$BangSubCategoryRoute on GoRouteData {
  static BangSubCategoryRoute _fromState(GoRouterState state) =>
      BangSubCategoryRoute(
        category: state.pathParameters['category']!,
        subCategory: state.pathParameters['subCategory']!,
      );

  BangSubCategoryRoute get _self => this as BangSubCategoryRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/category/${Uri.encodeComponent(_self.category)}/${Uri.encodeComponent(_self.subCategory)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $feedListRoute => GoRouteData.$route(
  path: '/feeds',
  name: 'FeedListRoute',

  factory: _$FeedListRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'add',
      name: 'FeedAddRoute',

      factory: _$FeedAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'articles/:feedId',
      name: 'FeedArticleListRoute',

      factory: _$FeedArticleListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'article/:articleId',
      name: 'FeedArticleRoute',

      factory: _$FeedArticleRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'create/:feedId',
      name: 'FeedCreateRoute',

      factory: _$FeedCreateRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'available/:feedsJson',
      name: 'SelectFeedDialogRoute',

      factory: _$SelectFeedDialogRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'edit/:feedId',
      name: 'FeedEditRoute',

      factory: _$FeedEditRoute._fromState,
    ),
  ],
);

mixin _$FeedListRoute on GoRouteData {
  static FeedListRoute _fromState(GoRouterState state) => FeedListRoute();

  @override
  String get location => GoRouteData.$location('/feeds');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$FeedAddRoute on GoRouteData {
  static FeedAddRoute _fromState(GoRouterState state) =>
      FeedAddRoute($extra: state.extra as Uri?);

  FeedAddRoute get _self => this as FeedAddRoute;

  @override
  String get location => GoRouteData.$location('/feeds/add');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin _$FeedArticleListRoute on GoRouteData {
  static FeedArticleListRoute _fromState(GoRouterState state) =>
      FeedArticleListRoute(feedId: Uri.parse(state.pathParameters['feedId']!)!);

  FeedArticleListRoute get _self => this as FeedArticleListRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/articles/${Uri.encodeComponent(_self.feedId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$FeedArticleRoute on GoRouteData {
  static FeedArticleRoute _fromState(GoRouterState state) =>
      FeedArticleRoute(articleId: state.pathParameters['articleId']!);

  FeedArticleRoute get _self => this as FeedArticleRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/article/${Uri.encodeComponent(_self.articleId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$FeedCreateRoute on GoRouteData {
  static FeedCreateRoute _fromState(GoRouterState state) =>
      FeedCreateRoute(feedId: Uri.parse(state.pathParameters['feedId']!)!);

  FeedCreateRoute get _self => this as FeedCreateRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/create/${Uri.encodeComponent(_self.feedId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$SelectFeedDialogRoute on GoRouteData {
  static SelectFeedDialogRoute _fromState(GoRouterState state) =>
      SelectFeedDialogRoute(feedsJson: state.pathParameters['feedsJson']!);

  SelectFeedDialogRoute get _self => this as SelectFeedDialogRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/available/${Uri.encodeComponent(_self.feedsJson)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$FeedEditRoute on GoRouteData {
  static FeedEditRoute _fromState(GoRouterState state) =>
      FeedEditRoute(feedId: Uri.parse(state.pathParameters['feedId']!)!);

  FeedEditRoute get _self => this as FeedEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/edit/${Uri.encodeComponent(_self.feedId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
