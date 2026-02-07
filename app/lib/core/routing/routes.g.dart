// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $aboutRoute,
  $onboardingRoute,
  $bangMenuRoute,
  $bookmarksRoute,
  $browserRoute,
  $feedListRoute,
  $historyRoute,
  $profileListRoute,
  $settingsRoute,
  $torProxyRoute,
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

RouteBase get $bangMenuRoute => GoRouteData.$route(
  path: '/bangs',
  name: 'BangRoute',
  factory: $BangMenuRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'user',
      name: 'UserBangsRoute',
      factory: $UserBangsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'new',
          name: 'NewUserBangRoute',
          factory: $NewUserBangRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'edit',
          name: 'EditUserBangRoute',
          factory: $EditUserBangRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'search/:searchText',
      name: 'BangSearchRoute',
      factory: $BangSearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'categories',
      name: 'BangCategoriesRoute',
      factory: $BangCategoriesRoute._fromState,
      routes: [
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
    ),
  ],
);

mixin $BangMenuRoute on GoRouteData {
  static BangMenuRoute _fromState(GoRouterState state) => const BangMenuRoute();

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

mixin $UserBangsRoute on GoRouteData {
  static UserBangsRoute _fromState(GoRouterState state) =>
      const UserBangsRoute();

  @override
  String get location => GoRouteData.$location('/bangs/user');

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

mixin $NewUserBangRoute on GoRouteData {
  static NewUserBangRoute _fromState(GoRouterState state) =>
      const NewUserBangRoute();

  @override
  String get location => GoRouteData.$location('/bangs/user/new');

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

mixin $EditUserBangRoute on GoRouteData {
  static EditUserBangRoute _fromState(GoRouterState state) => EditUserBangRoute(
    initialBang: state.uri.queryParameters['initial-bang']!,
  );

  EditUserBangRoute get _self => this as EditUserBangRoute;

  @override
  String get location => GoRouteData.$location(
    '/bangs/user/edit',
    queryParams: {'initial-bang': _self.initialBang},
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

mixin $BangCategoriesRoute on GoRouteData {
  static BangCategoriesRoute _fromState(GoRouterState state) =>
      const BangCategoriesRoute();

  @override
  String get location => GoRouteData.$location('/bangs/categories');

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
    '/bangs/categories/category/${Uri.encodeComponent(_self.category)}',
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
    '/bangs/categories/category/${Uri.encodeComponent(_self.category)}/${Uri.encodeComponent(_self.subCategory)}',
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

RouteBase get $bookmarksRoute => GoRouteData.$route(
  path: '/bookmarks',
  name: 'BookmarksRoute',
  factory: $BookmarksRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'list/:entryGuid',
      name: 'BookmarkListRoute',
      factory: $BookmarkListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'createFolder',
      name: 'BookmarkFolderAddRoute',
      factory: $BookmarkFolderAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'editFolder',
      name: 'BookmarkFolderEditRoute',
      factory: $BookmarkFolderEditRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'createEntry',
      name: 'BookmarkEntryAddRoute',
      factory: $BookmarkEntryAddRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'editEntry',
      name: 'BookmarkEntryEditRoute',
      factory: $BookmarkEntryEditRoute._fromState,
    ),
  ],
);

mixin $BookmarksRoute on GoRouteData {
  static BookmarksRoute _fromState(GoRouterState state) => BookmarksRoute();

  @override
  String get location => GoRouteData.$location('/bookmarks');

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

mixin $BookmarkListRoute on GoRouteData {
  static BookmarkListRoute _fromState(GoRouterState state) =>
      BookmarkListRoute(entryGuid: state.pathParameters['entryGuid']!);

  BookmarkListRoute get _self => this as BookmarkListRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/list/${Uri.encodeComponent(_self.entryGuid)}',
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

mixin $BookmarkFolderAddRoute on GoRouteData {
  static BookmarkFolderAddRoute _fromState(GoRouterState state) =>
      BookmarkFolderAddRoute(
        parentGuid: state.uri.queryParameters['parent-guid'],
      );

  BookmarkFolderAddRoute get _self => this as BookmarkFolderAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/createFolder',
    queryParams: {
      if (_self.parentGuid != null) 'parent-guid': _self.parentGuid,
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

mixin $BookmarkFolderEditRoute on GoRouteData {
  static BookmarkFolderEditRoute _fromState(GoRouterState state) =>
      BookmarkFolderEditRoute(folder: state.uri.queryParameters['folder']!);

  BookmarkFolderEditRoute get _self => this as BookmarkFolderEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/editFolder',
    queryParams: {'folder': _self.folder},
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

mixin $BookmarkEntryAddRoute on GoRouteData {
  static BookmarkEntryAddRoute _fromState(GoRouterState state) =>
      BookmarkEntryAddRoute(
        bookmarkInfo: state.uri.queryParameters['bookmark-info']!,
      );

  BookmarkEntryAddRoute get _self => this as BookmarkEntryAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/createEntry',
    queryParams: {'bookmark-info': _self.bookmarkInfo},
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

mixin $BookmarkEntryEditRoute on GoRouteData {
  static BookmarkEntryEditRoute _fromState(GoRouterState state) =>
      BookmarkEntryEditRoute(
        bookmarkEntry: state.uri.queryParameters['bookmark-entry']!,
      );

  BookmarkEntryEditRoute get _self => this as BookmarkEntryEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/bookmarks/editEntry',
    queryParams: {'bookmark-entry': _self.bookmarkEntry},
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
  path: '/browser',
  name: 'BrowserRoute',
  factory: $BrowserRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search/:tabType/:searchText',
      name: 'SearchRoute',
      factory: $SearchRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tab_view',
      name: 'TabViewRoute',
      factory: $TabViewRoute._fromState,
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
          path: 'create/:containerData',
          name: 'ContainerCreateRoute',
          factory: $ContainerCreateRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'edit/:containerData',
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
    GoRouteData.$route(
      path: 'profile',
      name: 'SelectProfileRoute',
      factory: $SelectProfileRoute._fromState,
    ),
  ],
);

mixin $BrowserRoute on GoRouteData {
  static BrowserRoute _fromState(GoRouterState state) => const BrowserRoute();

  @override
  String get location => GoRouteData.$location('/browser');

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
    tabId: state.uri.queryParameters['tab-id'],
  );

  SearchRoute get _self => this as SearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/search/${Uri.encodeComponent(_$TabTypeEnumMap[_self.tabType]!)}/${Uri.encodeComponent(_self.searchText)}',
    queryParams: {
      if (_self.launchedFromIntent != false)
        'launched-from-intent': _self.launchedFromIntent.toString(),
      if (_self.tabId != null) 'tab-id': _self.tabId,
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

mixin $TabViewRoute on GoRouteData {
  static TabViewRoute _fromState(GoRouterState state) => const TabViewRoute();

  @override
  String get location => GoRouteData.$location('/browser/tab_view');

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
      ContextMenuRoute(hitResult: state.uri.queryParameters['hit-result']!);

  ContextMenuRoute get _self => this as ContextMenuRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/context_menu',
    queryParams: {'hit-result': _self.hitResult},
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

mixin $ContainerDraftRoute on GoRouteData {
  static ContainerDraftRoute _fromState(GoRouterState state) =>
      const ContainerDraftRoute();

  @override
  String get location => GoRouteData.$location('/browser/container_draft');

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
      const ContainerListRoute();

  @override
  String get location => GoRouteData.$location('/browser/containers');

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
      ContainerCreateRoute(
        containerData: state.pathParameters['containerData']!,
      );

  ContainerCreateRoute get _self => this as ContainerCreateRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/containers/create/${Uri.encodeComponent(_self.containerData)}',
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

mixin $ContainerEditRoute on GoRouteData {
  static ContainerEditRoute _fromState(GoRouterState state) =>
      ContainerEditRoute(containerData: state.pathParameters['containerData']!);

  ContainerEditRoute get _self => this as ContainerEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/browser/containers/edit/${Uri.encodeComponent(_self.containerData)}',
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

mixin $ContainerSelectionRoute on GoRouteData {
  static ContainerSelectionRoute _fromState(GoRouterState state) =>
      const ContainerSelectionRoute();

  @override
  String get location => GoRouteData.$location('/browser/select_container');

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
    '/browser/tab_tree/${Uri.encodeComponent(_self.rootTabId)}',
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
    '/browser/open_content',
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

mixin $SelectProfileRoute on GoRouteData {
  static SelectProfileRoute _fromState(GoRouterState state) =>
      const SelectProfileRoute();

  @override
  String get location => GoRouteData.$location('/browser/profile');

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
      FeedAddRoute(uri: state.uri.queryParameters['uri']);

  FeedAddRoute get _self => this as FeedAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/feeds/add',
    queryParams: {if (_self.uri != null) 'uri': _self.uri},
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

RouteBase get $historyRoute => GoRouteData.$route(
  path: '/history',
  name: 'HistoryRoute',
  factory: $HistoryRoute._fromState,
);

mixin $HistoryRoute on GoRouteData {
  static HistoryRoute _fromState(GoRouterState state) => const HistoryRoute();

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

RouteBase get $profileListRoute => GoRouteData.$route(
  path: '/profiles',
  name: 'ProfileListRoute',
  factory: $ProfileListRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'edit',
      name: 'ProfileEditRoute',
      factory: $EditProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'backup_list',
      name: 'ProfileBackupListRoute',
      factory: $ProfileBackupListRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'restore',
      name: 'RestoreProfileRoute',
      factory: $RestoreProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'backup',
      name: 'BackupProfileRoute',
      factory: $BackupProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'create',
      name: 'CreateProfileRoute',
      factory: $CreateProfileRoute._fromState,
    ),
  ],
);

mixin $ProfileListRoute on GoRouteData {
  static ProfileListRoute _fromState(GoRouterState state) => ProfileListRoute();

  @override
  String get location => GoRouteData.$location('/profiles');

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

mixin $EditProfileRoute on GoRouteData {
  static EditProfileRoute _fromState(GoRouterState state) =>
      EditProfileRoute(profile: state.uri.queryParameters['profile']!);

  EditProfileRoute get _self => this as EditProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/profiles/edit',
    queryParams: {'profile': _self.profile},
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

mixin $ProfileBackupListRoute on GoRouteData {
  static ProfileBackupListRoute _fromState(GoRouterState state) =>
      ProfileBackupListRoute();

  @override
  String get location => GoRouteData.$location('/profiles/backup_list');

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

mixin $RestoreProfileRoute on GoRouteData {
  static RestoreProfileRoute _fromState(GoRouterState state) =>
      RestoreProfileRoute(
        backupFilePath: state.uri.queryParameters['backup-file-path']!,
      );

  RestoreProfileRoute get _self => this as RestoreProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/profiles/restore',
    queryParams: {'backup-file-path': _self.backupFilePath},
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

mixin $BackupProfileRoute on GoRouteData {
  static BackupProfileRoute _fromState(GoRouterState state) =>
      BackupProfileRoute(profile: state.uri.queryParameters['profile']!);

  BackupProfileRoute get _self => this as BackupProfileRoute;

  @override
  String get location => GoRouteData.$location(
    '/profiles/backup',
    queryParams: {'profile': _self.profile},
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

mixin $CreateProfileRoute on GoRouteData {
  static CreateProfileRoute _fromState(GoRouterState state) =>
      CreateProfileRoute();

  @override
  String get location => GoRouteData.$location('/profiles/create');

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
      path: 'appearance_display',
      name: 'AppearanceDisplaySettingsRoute',
      factory: $AppearanceDisplaySettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'privacy_security',
      name: 'PrivacySecuritySettingsRoute',
      factory: $PrivacySecuritySettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'search_content',
      name: 'SearchContentSettingsRoute',
      factory: $SearchContentSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tabs_behavior',
      name: 'TabsBehaviorSettingsRoute',
      factory: $TabsBehaviorSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'fingerprinting',
      name: 'FingerprintingSettingsRoute',
      factory: $FingerprintingSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'advanced',
      name: 'AdvancedSettingsRoute',
      factory: $AdvancedSettingsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'bang',
      name: 'BangSettingsRoute',
      factory: $BangSettingsRoute._fromState,
    ),
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
    GoRouteData.$route(
      path: 'addon_collection',
      name: 'AddonCollectionRoute',
      factory: $AddonCollectionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'tracking_protection_exceptions',
      name: 'TrackingProtectionExceptionsRoute',
      factory: $TrackingProtectionExceptionsRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'custom_tracking_protection',
      name: 'CustomTrackingProtectionRoute',
      factory: $CustomTrackingProtectionRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'error_logs',
      name: 'ErrorLogsRoute',
      factory: $ErrorLogsRoute._fromState,
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

mixin $AppearanceDisplaySettingsRoute on GoRouteData {
  static AppearanceDisplaySettingsRoute _fromState(GoRouterState state) =>
      AppearanceDisplaySettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/appearance_display');

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

mixin $PrivacySecuritySettingsRoute on GoRouteData {
  static PrivacySecuritySettingsRoute _fromState(GoRouterState state) =>
      PrivacySecuritySettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/privacy_security');

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

mixin $SearchContentSettingsRoute on GoRouteData {
  static SearchContentSettingsRoute _fromState(GoRouterState state) =>
      SearchContentSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/search_content');

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

mixin $TabsBehaviorSettingsRoute on GoRouteData {
  static TabsBehaviorSettingsRoute _fromState(GoRouterState state) =>
      TabsBehaviorSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/tabs_behavior');

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

mixin $FingerprintingSettingsRoute on GoRouteData {
  static FingerprintingSettingsRoute _fromState(GoRouterState state) =>
      FingerprintingSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/fingerprinting');

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

mixin $AdvancedSettingsRoute on GoRouteData {
  static AdvancedSettingsRoute _fromState(GoRouterState state) =>
      AdvancedSettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings/advanced');

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

mixin $WebEngineHardeningRoute on GoRouteData {
  static WebEngineHardeningRoute _fromState(GoRouterState state) =>
      WebEngineHardeningRoute();

  @override
  String get location => GoRouteData.$location('/settings/hardening');

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
    '/settings/hardening/group/${Uri.encodeComponent(_self.group)}',
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
  String get location => GoRouteData.$location('/settings/doh');

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
  String get location => GoRouteData.$location('/settings/fingerprint');

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
  String get location => GoRouteData.$location('/settings/locales');

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
  String get location => GoRouteData.$location('/settings/addon_collection');

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

mixin $TrackingProtectionExceptionsRoute on GoRouteData {
  static TrackingProtectionExceptionsRoute _fromState(GoRouterState state) =>
      TrackingProtectionExceptionsRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/tracking_protection_exceptions');

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

mixin $CustomTrackingProtectionRoute on GoRouteData {
  static CustomTrackingProtectionRoute _fromState(GoRouterState state) =>
      CustomTrackingProtectionRoute();

  @override
  String get location =>
      GoRouteData.$location('/settings/custom_tracking_protection');

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

mixin $ErrorLogsRoute on GoRouteData {
  static ErrorLogsRoute _fromState(GoRouterState state) => ErrorLogsRoute();

  @override
  String get location => GoRouteData.$location('/settings/error_logs');

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

RouteBase get $torProxyRoute => GoRouteData.$route(
  path: '/tor',
  name: 'TorProxyRoute',
  factory: $TorProxyRoute._fromState,
);

mixin $TorProxyRoute on GoRouteData {
  static TorProxyRoute _fromState(GoRouterState state) => const TorProxyRoute();

  @override
  String get location => GoRouteData.$location('/tor');

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
