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

@TypedGoRoute<FeedListRoute>(
  name: 'FeedListRoute',
  path: '/feeds',
  routes: [
    TypedGoRoute<FeedAddRoute>(name: FeedAddRoute.name, path: 'add'),
    TypedGoRoute<FeedArticleListRoute>(
      name: 'FeedArticleListRoute',
      path: 'articles/:feedId',
    ),
    TypedGoRoute<FeedArticleRoute>(
      name: 'FeedArticleRoute',
      path: 'article/:articleId',
    ),
    TypedGoRoute<FeedCreateRoute>(
      name: 'FeedCreateRoute',
      path: 'create/:feedId',
    ),
    TypedGoRoute<SelectFeedDialogRoute>(
      name: 'SelectFeedDialogRoute',
      path: 'available/:feedsJson',
    ),
    TypedGoRoute<FeedEditRoute>(name: 'FeedEditRoute', path: 'edit/:feedId'),
  ],
)
class FeedListRoute extends GoRouteData with _$FeedListRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FeedListScreen();
  }
}

class FeedCreateRoute extends GoRouteData with _$FeedCreateRoute {
  final Uri feedId;

  FeedCreateRoute({required this.feedId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedEditScreen.create(feedId: feedId);
  }
}

class SelectFeedDialogRoute extends GoRouteData with _$SelectFeedDialogRoute {
  final String feedsJson;

  const SelectFeedDialogRoute({required this.feedsJson});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final feedUris = Set<Uri>.from(
      (jsonDecode(feedsJson) as List<dynamic>).map(
        (url) => Uri.parse(url as String),
      ),
    );

    return DialogPage(builder: (_) => SelectFeedDialog(feedUris: feedUris));
  }
}

class FeedEditRoute extends GoRouteData with _$FeedEditRoute {
  final Uri feedId;

  const FeedEditRoute({required this.feedId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedEditScreen.edit(feedId: feedId);
  }
}

class FeedAddRoute extends GoRouteData with _$FeedAddRoute {
  final Uri? $extra;

  static const name = 'FeedAddRoute';

  const FeedAddRoute({this.$extra});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => AddFeedDialog(initialUri: $extra));
  }
}

class FeedArticleListRoute extends GoRouteData with _$FeedArticleListRoute {
  final Uri feedId;

  FeedArticleListRoute({required this.feedId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedArticleListScreen(feedId: feedId);
  }
}

class FeedArticleRoute extends GoRouteData with _$FeedArticleRoute {
  final String articleId;

  FeedArticleRoute({required this.articleId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedArticleScreen(articleId: articleId);
  }
}
