import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lensai/core/routing/dialog_page.dart';
import 'package:lensai/features/about/presentation/screens/about.dart';
import 'package:lensai/features/bangs/presentation/screens/categories.dart';
import 'package:lensai/features/bangs/presentation/screens/list.dart';
import 'package:lensai/features/bangs/presentation/screens/search.dart';
import 'package:lensai/features/chat_archive/presentation/screens/detail.dart';
import 'package:lensai/features/chat_archive/presentation/screens/list.dart';
import 'package:lensai/features/chat_archive/presentation/screens/search.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/screens/browser.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/screens/container_list.dart';
import 'package:lensai/features/search/presentation/screens/search.dart';
import 'package:lensai/features/settings/presentation/screens/settings.dart';

part 'routes.g.dart';

@TypedGoRoute<BrowserRoute>(
  name: 'BrowserRoute',
  path: '/',
  routes: [
    TypedGoRoute<AboutRoute>(
      name: 'AboutRoute',
      path: 'about',
    ),
    TypedGoRoute<SearchRoute>(
      name: 'SearchRoute',
      path: 'search/:searchText',
    ),
    TypedGoRoute<BangCategoriesRoute>(
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
    ),
    TypedGoRoute<ContainerListRoute>(
      name: 'ContainerListRoute',
      path: 'containers',
    ),
  ],
)
class BrowserRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowserScreen();
  }
}

class AboutRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const AboutDialogScreen());
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
      initialSearchText: (searchText.isEmpty || searchText == emptySearchText)
          ? null
          : searchText,
    );
  }
}

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
      initialSearchText: (searchText.isEmpty || searchText == emptySearchText)
          ? null
          : searchText,
    );
  }
}

class ContainerListRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContainerListScreen();
  }
}

@TypedGoRoute<SettingsRoute>(
  name: 'SettingsRoute',
  path: '/settings',
)
class SettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

@TypedGoRoute<ChatArchiveListRoute>(
  name: 'ChatArchiveListRoute',
  path: '/chat_archive',
  routes: [
    TypedGoRoute<ChatArchiveSearchRoute>(
      name: 'ChatArchiveSearchRoute',
      path: 'search',
    ),
    TypedGoRoute<ChatArchiveDetailRoute>(
      name: 'ChatArchiveDetailRoute',
      path: 'detail/:fileName',
    ),
  ],
)
class ChatArchiveListRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChatArchiveListScreen();
  }
}

class ChatArchiveSearchRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChatArchiveSearchScreen();
  }
}

class ChatArchiveDetailRoute extends GoRouteData {
  final String fileName;

  const ChatArchiveDetailRoute({required this.fileName});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatArchiveDetailScreen(fileName);
  }
}
