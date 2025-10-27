// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $aboutRoute,
  $onboardingRoute,
  $settingsRoute,
  $browserRoute,
  $bangCategoriesRoute,
  $feedListRoute,
];

RouteBase get $aboutRoute => GoRouteData.$route(
  path: '/about',
  name: 'AboutRoute',
  factory: $AboutRoute._fromState,
);

mixin $AboutRoute on GoRouteData {
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

RouteBase get $onboardingRoute => GoRouteData.$route(
  path: '/onboarding/:currentRevision/:targetRevision',
  name: 'OnboardingRoute',
  factory: $OnboardingRoute._fromState,
);

mixin $OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) => OnboardingRoute(
    currentRevision: int.parse(state.pathParameters['currentRevision']!),
    targetRevision: int.parse(state.pathParameters['targetRevision']!),
  );

  OnboardingRoute get _self => this as OnboardingRoute;

  @override
  String get location => GoRouteData.$location(
    '/onboarding/${Uri.encodeComponent(_self.currentRevision.toString())}/${Uri.encodeComponent(_self.targetRevision.toString())}',
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

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  name: 'SettingsRoute',
  factory: $SettingsRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'general',
      name: 'GeneralSettingsRoute',
      factory: $GeneralSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'bang',
      name: 'BangSettingsRoute',
      factory: $BangSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'web_engine',
      name: 'WebEngineSettingsRoute',
      factory: $WebEngineSettingsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'hardening',
          name: 'WebEngineHardeningRoute',
          factory: $WebEngineHardeningRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'group/:group',
              name: 'WebEngineHardeningGroupRoute',
              factory: $WebEngineHardeningGroupRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'doh',
          name: 'DohSettingsRoute',
          factory: $DohSettingsRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'fingerprint',
          name: 'FingerprintSettingsRoute',
          factory: $FingerprintSettingsRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'locales',
          name: 'LocaleSettingsRoute',
          factory: $LocaleSettingsRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'developer',
      name: 'DeveloperSettingsRoute',
      factory: $DeveloperSettingsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'addon_collection',
          name: 'AddonCollectionRoute',
          factory: $AddonCollectionRoute._fromState,
        ),
      ],
    ),
  ],
);

mixin $SettingsRoute on GoRouteData {
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

mixin $GeneralSettingsRoute on GoRouteData {
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

mixin $BangSettingsRoute on GoRouteData {
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

mixin $WebEngineSettingsRoute on GoRouteData {
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

mixin $WebEngineHardeningRoute on GoRouteData {
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

mixin $WebEngineHardeningGroupRoute on GoRouteData {
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

mixin $DohSettingsRoute on GoRouteData {
  static DohSettingsRoute _fromState(GoRouterState state) => DohSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/web_engine/doh');

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

mixin $FingerprintSettingsRoute on GoRouteData {
  static FingerprintSettingsRoute _fromState(GoRouterState state) =>
      FingerprintSettingsRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/web_engine/fingerprint');

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

mixin $LocaleSettingsRoute on GoRouteData {
  static LocaleSettingsRoute _fromState(GoRouterState state) =>
      LocaleSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/web_engine/locales');

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

mixin $DeveloperSettingsRoute on GoRouteData {
  static DeveloperSettingsRoute _fromState(GoRouterState state) =>
      DeveloperSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/developer');

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

mixin $AddonCollectionRoute on GoRouteData {
  static AddonCollectionRoute _fromState(GoRouterState state) =>
      AddonCollectionRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/developer/addon_collection');

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
  factory: $BrowserRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search/:tabType/:searchText',
      name: 'SearchRoute',
      factory: $SearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tor_proxy',
      name: 'TorProxyRoute',
      factory: $TorProxyRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'history',
      name: 'HistoryRoute',
      factory: $HistoryRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'context_menu',
      name: 'ContextMenuRoute',
      factory: $ContextMenuRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'container_draft',
      name: 'ContainerDraftRoute',
      factory: $ContainerDraftRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'containers',
      name: 'ContainerListRoute',
      factory: $ContainerListRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'create',
          name: 'ContainerCreateRoute',
          factory: $ContainerCreateRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'edit',
          name: 'ContainerEditRoute',
          factory: $ContainerEditRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'select_container',
      name: 'ContainerSelectionRoute',
      factory: $ContainerSelectionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tab_tree/:rootTabId',
      name: 'TabTreeRoute',
      factory: $TabTreeRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'open_content',
      name: 'OpenSharedContentRoute',
      factory: $OpenSharedContentRoute._fromState,
    ),
  ],
);

mixin $BrowserRoute on GoRouteData {
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

mixin $SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) => SearchRoute(
    tabType: _$TabTypeEnumMap._$fromName(state.pathParameters['tabType']!)!,
    searchText:
        state.pathParameters['searchText'] ?? SearchRoute.emptySearchText,
    launchedFromIntent:
        _$convertMapValue(
          'launched-from-intent',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
  );

  SearchRoute get _self => this as SearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/search/${Uri.encodeComponent(_$TabTypeEnumMap[_self.tabType]!)}/${Uri.encodeComponent(_self.searchText)}',
    queryParams: {
      if (_self.launchedFromIntent != false)
        'launched-from-intent': _self.launchedFromIntent.toString(),
    },
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
  TabType.child: 'child',
};

mixin $TorProxyRoute on GoRouteData {
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

mixin $HistoryRoute on GoRouteData {
  static HistoryRoute _fromState(GoRouterState state) => HistoryRoute();

  @override
  String get location => GoRouteData.$location('/history');

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

mixin $ContextMenuRoute on GoRouteData {
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

mixin $ContainerDraftRoute on GoRouteData {
  static ContainerDraftRoute _fromState(GoRouterState state) =>
      ContainerDraftRoute();

  @override
  String get location => GoRouteData.$location('/container_draft');

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

mixin $ContainerListRoute on GoRouteData {
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

mixin $ContainerCreateRoute on GoRouteData {
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

mixin $ContainerEditRoute on GoRouteData {
  static ContainerEditRoute _fromState(GoRouterState state) =>
      ContainerEditRoute(state.extra as ContainerDataWithCount);

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

mixin $ContainerSelectionRoute on GoRouteData {
  static ContainerSelectionRoute _fromState(GoRouterState state) =>
      ContainerSelectionRoute();

  @override
  String get location => GoRouteData.$location('/select_container');

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

mixin $TabTreeRoute on GoRouteData {
  static TabTreeRoute _fromState(GoRouterState state) =>
      TabTreeRoute(state.pathParameters['rootTabId']!);

  TabTreeRoute get _self => this as TabTreeRoute;

  @override
  String get location => GoRouteData.$location(
    '/tab_tree/${Uri.encodeComponent(_self.rootTabId)}',
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

mixin $OpenSharedContentRoute on GoRouteData {
  static OpenSharedContentRoute _fromState(GoRouterState state) =>
      OpenSharedContentRoute(
        sharedUrl: state.uri.queryParameters['shared-url'] ?? 'about:blank',
      );

  OpenSharedContentRoute get _self => this as OpenSharedContentRoute;

  @override
  String get location => GoRouteData.$location(
    '/open_content',
    queryParams: {
      if (_self.sharedUrl != 'about:blank') 'shared-url': _self.sharedUrl,
    },
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

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}

RouteBase get $bangCategoriesRoute => GoRouteData.$route(
  path: '/bangs',
  name: 'BangRoute',
  factory: $BangCategoriesRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search/:searchText',
      name: 'BangSearchRoute',
      factory: $BangSearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'category/:category',
      name: 'BangCategoryRoute',
      factory: $BangCategoryRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':subCategory',
          name: 'BangSubCategoryRoute',
          factory: $BangSubCategoryRoute._fromState,
        ),
      ],
    ),
  ],
);

mixin $BangCategoriesRoute on GoRouteData {
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

mixin $BangSearchRoute on GoRouteData {
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

mixin $BangCategoryRoute on GoRouteData {
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

mixin $BangSubCategoryRoute on GoRouteData {
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
  factory: $FeedListRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'add',
      name: 'FeedAddRoute',
      factory: $FeedAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'articles/:feedId',
      name: 'FeedArticleListRoute',
      factory: $FeedArticleListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'article/:articleId',
      name: 'FeedArticleRoute',
      factory: $FeedArticleRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'create/:feedId',
      name: 'FeedCreateRoute',
      factory: $FeedCreateRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'available/:feedsJson',
      name: 'SelectFeedDialogRoute',
      factory: $SelectFeedDialogRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'edit/:feedId',
      name: 'FeedEditRoute',
      factory: $FeedEditRoute._fromState,
    ),
  ],
);

mixin $FeedListRoute on GoRouteData {
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

mixin $FeedAddRoute on GoRouteData {
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

mixin $FeedArticleListRoute on GoRouteData {
  static FeedArticleListRoute _fromState(GoRouterState state) =>
      FeedArticleListRoute(feedId: Uri.parse(state.pathParameters['feedId']!));

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

mixin $FeedArticleRoute on GoRouteData {
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

mixin $FeedCreateRoute on GoRouteData {
  static FeedCreateRoute _fromState(GoRouterState state) =>
      FeedCreateRoute(feedId: Uri.parse(state.pathParameters['feedId']!));

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

mixin $SelectFeedDialogRoute on GoRouteData {
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

mixin $FeedEditRoute on GoRouteData {
  static FeedEditRoute _fromState(GoRouterState state) =>
      FeedEditRoute(feedId: Uri.parse(state.pathParameters['feedId']!));

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
