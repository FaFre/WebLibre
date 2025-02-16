import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lensai/core/routing/dialog_page.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/features/about/presentation/screens/about.dart';
import 'package:lensai/features/bangs/presentation/screens/categories.dart';
import 'package:lensai/features/bangs/presentation/screens/list.dart';
import 'package:lensai/features/bangs/presentation/screens/search.dart';
import 'package:lensai/features/chat_archive/presentation/screens/detail.dart';
import 'package:lensai/features/chat_archive/presentation/screens/list.dart';
import 'package:lensai/features/chat_archive/presentation/screens/search.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/dialogs/web_page_dialog.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/screens/browser.dart';
import 'package:lensai/features/geckoview/features/search/presentation/screens/search.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/screens/container_edit.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/screens/container_list.dart';
import 'package:lensai/features/settings/presentation/screens/bang_settings.dart';
import 'package:lensai/features/settings/presentation/screens/general_settings.dart';
import 'package:lensai/features/settings/presentation/screens/settings.dart';
import 'package:lensai/features/settings/presentation/screens/web_engine_hardening.dart';
import 'package:lensai/features/settings/presentation/screens/web_engine_hardening_group.dart';
import 'package:lensai/features/settings/presentation/screens/web_engine_settings.dart';
import 'package:lensai/features/tor/presentation/screens/tor_proxy.dart';
import 'package:lensai/features/user/presentation/screens/auth.dart';

part 'routes.g.dart';

@TypedGoRoute<BrowserRoute>(
  name: 'BrowserRoute',
  path: '/',
  routes: [
    TypedGoRoute<WebPageRoute>(
      name: 'WebPageRoute',
      path: 'page/:url',
    ),
    TypedGoRoute<AboutRoute>(
      name: 'AboutRoute',
      path: 'about',
    ),
    TypedGoRoute<UserAuthRoute>(
      name: 'UserAuthRoute',
      path: 'userAuth',
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
      routes: [
        TypedGoRoute<ContainerCreateRoute>(
          name: 'ContainerCreateRoute',
          path: 'create',
        ),
        TypedGoRoute<ContainerEditRoute>(
          name: 'ContainerEditRoute',
          path: 'edit',
        ),
      ],
    ),
  ],
)
class BrowserRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BrowserScreen();
  }
}

class WebPageRoute extends GoRouteData {
  final String url;

  const WebPageRoute({required this.url});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      builder: (_) => WebPageDialog(
        url: Uri.parse(url),
        precachedInfo: state.extra as WebPageInfo?,
      ),
    );
  }
}

class AboutRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const AboutDialogScreen());
  }
}

class UserAuthRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const UserAuthScreen());
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

class ContainerEditRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.edit(
      initialContainer: state.extra! as ContainerData,
    );
  }
}

class ContainerCreateRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContainerEditScreen.create(
      initialContainer: state.extra! as ContainerData,
    );
  }
}

@TypedGoRoute<SettingsRoute>(
  name: 'SettingsRoute',
  path: '/settings',
  routes: [
    TypedGoRoute<GeneralSettingsRoute>(
      name: 'GeneralSettingsRoute',
      path: 'general',
    ),
    TypedGoRoute<BangSettingsRoute>(
      name: 'BangSettingsRoute',
      path: 'bang',
    ),
    TypedGoRoute<WebEngineSettingsRoute>(
      name: 'WebEngineSettingsRoute',
      path: 'web_engine',
      routes: [
        TypedGoRoute<WebEngineHardeningRoute>(
          name: 'WebEngineHardeningRoute',
          path: 'hardening',
          routes: [
            TypedGoRoute<WebEngineHardeningGroupRoute>(
              name: 'WebEngineHardeningGroupRoute',
              path: 'group/:group',
            ),
          ],
        ),
      ],
    ),
  ],
)
class SettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class GeneralSettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GeneralSettingsScreen();
  }
}

class BangSettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangSettingsScreen();
  }
}

class WebEngineSettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineSettingsScreen();
  }
}

class WebEngineHardeningRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineHardeningScreen();
  }
}

class WebEngineHardeningGroupRoute extends GoRouteData {
  final String group;

  const WebEngineHardeningGroupRoute({required this.group});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WebEngineHardeningGroupScreen(groupName: group);
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

@TypedGoRoute<TorProxyRoute>(
  name: 'TorProxyRoute',
  path: '/tor_proxy',
)
class TorProxyRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TorProxyScreen();
  }
}
