// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $browserRoute,
      $settingsRoute,
      $chatArchiveListRoute,
    ];

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
          path: 'about',
          name: 'AboutRoute',
          factory: $AboutRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'userAuth',
          name: 'UserAuthRoute',
          factory: $UserAuthRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'search/:searchText',
          name: 'SearchRoute',
          factory: $SearchRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'bangs',
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
        ),
        GoRouteData.$route(
          path: 'containers',
          name: 'ContainerListRoute',
          factory: $ContainerListRouteExtension._fromState,
        ),
      ],
    );

extension $BrowserRouteExtension on BrowserRoute {
  static BrowserRoute _fromState(GoRouterState state) => BrowserRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WebPageRouteExtension on WebPageRoute {
  static WebPageRoute _fromState(GoRouterState state) => WebPageRoute(
        url: state.pathParameters['url']!,
      );

  String get location => GoRouteData.$location(
        '/page/${Uri.encodeComponent(url)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AboutRouteExtension on AboutRoute {
  static AboutRoute _fromState(GoRouterState state) => AboutRoute();

  String get location => GoRouteData.$location(
        '/about',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $UserAuthRouteExtension on UserAuthRoute {
  static UserAuthRoute _fromState(GoRouterState state) => UserAuthRoute();

  String get location => GoRouteData.$location(
        '/userAuth',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SearchRouteExtension on SearchRoute {
  static SearchRoute _fromState(GoRouterState state) => SearchRoute(
        searchText:
            state.pathParameters['searchText']! ?? SearchRoute.emptySearchText,
      );

  String get location => GoRouteData.$location(
        '/search/${Uri.encodeComponent(searchText)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangCategoriesRouteExtension on BangCategoriesRoute {
  static BangCategoriesRoute _fromState(GoRouterState state) =>
      BangCategoriesRoute();

  String get location => GoRouteData.$location(
        '/bangs',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangSearchRouteExtension on BangSearchRoute {
  static BangSearchRoute _fromState(GoRouterState state) => BangSearchRoute(
        searchText: state.pathParameters['searchText']! ??
            BangSearchRoute.emptySearchText,
      );

  String get location => GoRouteData.$location(
        '/bangs/search/${Uri.encodeComponent(searchText)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BangCategoryRouteExtension on BangCategoryRoute {
  static BangCategoryRoute _fromState(GoRouterState state) => BangCategoryRoute(
        category: state.pathParameters['category']!,
      );

  String get location => GoRouteData.$location(
        '/bangs/category/${Uri.encodeComponent(category)}',
      );

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

extension $ContainerListRouteExtension on ContainerListRoute {
  static ContainerListRoute _fromState(GoRouterState state) =>
      ContainerListRoute();

  String get location => GoRouteData.$location(
        '/containers',
      );

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
          path: 'hardening',
          name: 'BrowserHardeningRoute',
          factory: $BrowserHardeningRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'group/:group',
              name: 'BrowserHardeningGroupRoute',
              factory: $BrowserHardeningGroupRouteExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $SettingsRouteExtension on SettingsRoute {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute();

  String get location => GoRouteData.$location(
        '/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BrowserHardeningRouteExtension on BrowserHardeningRoute {
  static BrowserHardeningRoute _fromState(GoRouterState state) =>
      BrowserHardeningRoute();

  String get location => GoRouteData.$location(
        '/settings/hardening',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $BrowserHardeningGroupRouteExtension on BrowserHardeningGroupRoute {
  static BrowserHardeningGroupRoute _fromState(GoRouterState state) =>
      BrowserHardeningGroupRoute(
        group: state.pathParameters['group']!,
      );

  String get location => GoRouteData.$location(
        '/settings/hardening/group/${Uri.encodeComponent(group)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatArchiveListRoute => GoRouteData.$route(
      path: '/chat_archive',
      name: 'ChatArchiveListRoute',
      factory: $ChatArchiveListRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'search',
          name: 'ChatArchiveSearchRoute',
          factory: $ChatArchiveSearchRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'detail/:fileName',
          name: 'ChatArchiveDetailRoute',
          factory: $ChatArchiveDetailRouteExtension._fromState,
        ),
      ],
    );

extension $ChatArchiveListRouteExtension on ChatArchiveListRoute {
  static ChatArchiveListRoute _fromState(GoRouterState state) =>
      ChatArchiveListRoute();

  String get location => GoRouteData.$location(
        '/chat_archive',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChatArchiveSearchRouteExtension on ChatArchiveSearchRoute {
  static ChatArchiveSearchRoute _fromState(GoRouterState state) =>
      ChatArchiveSearchRoute();

  String get location => GoRouteData.$location(
        '/chat_archive/search',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChatArchiveDetailRouteExtension on ChatArchiveDetailRoute {
  static ChatArchiveDetailRoute _fromState(GoRouterState state) =>
      ChatArchiveDetailRoute(
        fileName: state.pathParameters['fileName']!,
      );

  String get location => GoRouteData.$location(
        '/chat_archive/detail/${Uri.encodeComponent(fileName)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
