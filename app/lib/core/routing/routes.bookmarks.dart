/*
 * Copyright (c) 2024-2026 Fabian Freund.
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

@TypedGoRoute<BookmarkListRoute>(
  name: 'BookmarkListRoute',
  path: '/bookmarks/:entryGuid',
)
class BookmarkListRoute extends GoRouteData with $BookmarkListRoute {
  final String entryGuid;

  const BookmarkListRoute({required this.entryGuid});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookmarkListScreen(entryGuid: entryGuid);
  }
}

@TypedGoRoute<BookmarkFolderAddRoute>(
  name: 'BookmarkFolderAddRoute',
  path: '/bookmarks/createFolder',
)
class BookmarkFolderAddRoute extends GoRouteData with $BookmarkFolderAddRoute {
  final String? parentGuid;

  const BookmarkFolderAddRoute({required this.parentGuid});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookmarkFolderEditScreen(parentGuid: parentGuid, folder: null);
  }
}

@TypedGoRoute<BookmarkFolderEditRoute>(
  name: 'BookmarkFolderEditRoute',
  path: '/bookmarks/editFolder',
)
class BookmarkFolderEditRoute extends GoRouteData
    with $BookmarkFolderEditRoute {
  final String folder;

  const BookmarkFolderEditRoute({required this.folder});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookmarkFolderEditScreen(
      folder: BookmarkFolder.fromJson(
        jsonDecode(folder) as Map<String, dynamic>,
      ),
    );
  }
}

@TypedGoRoute<BookmarkEntryAddRoute>(
  name: 'BookmarkEntryAddRoute',
  path: '/bookmarks/createEntry',
)
class BookmarkEntryAddRoute extends GoRouteData with $BookmarkEntryAddRoute {
  final String bookmarkInfo;

  const BookmarkEntryAddRoute({required this.bookmarkInfo});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookmarkEntryEditScreen(
      initialInfo: BookmarkInfo.decode(jsonDecode(bookmarkInfo) as Object),
      exisitingEntry: null,
    );
  }
}

@TypedGoRoute<BookmarkEntryEditRoute>(
  name: 'BookmarkEntryEditRoute',
  path: '/bookmarks/editEntry',
)
class BookmarkEntryEditRoute extends GoRouteData with $BookmarkEntryEditRoute {
  final String bookmarkEntry;

  const BookmarkEntryEditRoute({required this.bookmarkEntry});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookmarkEntryEditScreen(
      initialInfo: null,
      exisitingEntry: BookmarkEntry.fromJson(
        jsonDecode(bookmarkEntry) as Map<String, dynamic>,
      ),
    );
  }
}
