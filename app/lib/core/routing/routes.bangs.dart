/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
part of 'routes.dart';

@TypedGoRoute<BangMenuRoute>(
  name: 'BangRoute',
  path: '/bangs',
  routes: [
    TypedGoRoute<UserBangsRoute>(
      name: 'UserBangsRoute',
      path: 'user',
      routes: [
        TypedGoRoute<NewUserBangRoute>(name: 'NewUserBangRoute', path: 'new'),
        TypedGoRoute<EditUserBangRoute>(
          name: 'EditUserBangRoute',
          path: 'edit',
        ),
      ],
    ),
    TypedGoRoute<BangSearchRoute>(
      name: 'BangSearchRoute',
      path: 'search/:searchText',
    ),
    TypedGoRoute<BangCategoriesRoute>(
      name: 'BangCategoriesRoute',
      path: 'categories',
      routes: [
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
    ),
  ],
)
class BangMenuRoute extends GoRouteData with $BangMenuRoute {
  const BangMenuRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangMenuScreen();
  }
}

class BangCategoriesRoute extends GoRouteData with $BangCategoriesRoute {
  const BangCategoriesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangCategoriesScreen();
  }
}

class BangCategoryRoute extends GoRouteData with $BangCategoryRoute {
  final String category;

  const BangCategoryRoute({required this.category});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangCategoryScreen(category: category);
  }
}

class BangSubCategoryRoute extends GoRouteData with $BangSubCategoryRoute {
  final String category;
  final String subCategory;

  const BangSubCategoryRoute({
    required this.category,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangCategoryScreen(category: category, subCategory: subCategory);
  }
}

class BangSearchRoute extends GoRouteData with $BangSearchRoute {
  static const String emptySearchText = ' ';

  //This should be nullable but isnt allowed by go_router
  final String searchText;

  const BangSearchRoute({this.searchText = BangSearchRoute.emptySearchText});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BangSearchScreen(
      initialSearchText: (searchText.isEmpty || searchText == emptySearchText)
          ? null
          : searchText,
    );
  }
}

class UserBangsRoute extends GoRouteData with $UserBangsRoute {
  const UserBangsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UserBangs();
  }
}

class NewUserBangRoute extends GoRouteData with $NewUserBangRoute {
  const NewUserBangRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const EditBangScreen(initialBang: null);
  }
}

class EditUserBangRoute extends GoRouteData with $EditUserBangRoute {
  final String initialBang;

  const EditUserBangRoute({required this.initialBang});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EditBangScreen(
      initialBang: Bang.fromJson(
        jsonDecode(initialBang) as Map<String, dynamic>,
      ),
    );
  }
}
