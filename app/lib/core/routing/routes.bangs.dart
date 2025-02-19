part of 'routes.dart';

@TypedGoRoute<BangCategoriesRoute>(
  name: 'BangRoute',
  path: 'bangs',
  routes: [
    TypedGoRoute<BangSearchRoute>(
      name: 'BangSearchRoute',
      path: 'search/:searchText',
    ),
    TypedGoRoute<BangCategoryRoute>(
      name: 'BangCategoryRoute',
      path: 'category/:category',
      routes: [
        TypedGoRoute<BangSubCategoryRoute>(
          name: 'BangSubCategoryRoute',
          path: ':subCategory',
        ),
      ],
    ),
  ],
)
class BangCategoriesRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangCategoriesScreen();
  }
}

class BangCategoryRoute extends GoRouteData {
  final String category;

  const BangCategoryRoute({required this.category});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangListScreen(category: category);
  }
}

class BangSubCategoryRoute extends GoRouteData {
  final String category;
  final String subCategory;

  const BangSubCategoryRoute({
    required this.category,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangListScreen(category: category, subCategory: subCategory);
  }
}

class BangSearchRoute extends GoRouteData {
  static const String emptySearchText = ' ';

  //This should be nullable but isnt allowed by go_router
  final String searchText;

  const BangSearchRoute({this.searchText = BangSearchRoute.emptySearchText});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangSearchScreen(
      initialSearchText:
          (searchText.isEmpty || searchText == emptySearchText)
              ? null
              : searchText,
    );
  }
}
