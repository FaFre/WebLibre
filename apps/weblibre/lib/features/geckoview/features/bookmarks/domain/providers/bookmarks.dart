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
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';

part 'bookmarks.g.dart';

/// Whether a root folder holds anything worth showing.
///
/// Roots always contain each other, so a root that only contains other roots
/// counts as empty.
bool _hasVisibleContent(BookmarkFolder? folder) {
  final children = folder?.children;
  if (children == null) return false;
  return children.any((child) => !bookmarkRootIds.contains(child.guid));
}

@Riverpod()
class BookmarkSearchResults extends _$BookmarkSearchResults {
  final _service = GeckoBookmarksService();

  /// Identifies the most recent request.
  ///
  /// Typing starts a search per keystroke and storage does not answer them in
  /// order, so a slow early query could otherwise land after a fast later one
  /// and leave the list showing results for text the user has moved on from.
  int _latestRequest = 0;

  Future<void> search(String query, {int limit = 10}) async {
    final request = ++_latestRequest;

    if (query.isEmpty) {
      state = [];
      return;
    }

    try {
      final results = await _service.searchBookmarks(query, limit: limit);
      if (!ref.mounted || request != _latestRequest) return;
      state = results
          .map(BookmarkItem.parseRecursive)
          .whereType<BookmarkEntry>()
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'OperationInterrupted') return;
      rethrow;
    }
  }

  @override
  List<BookmarkEntry> build() {
    return [];
  }
}

/// A single folder with its direct children.
///
/// The load is scoped to one folder, so its cost tracks the folder being shown
/// rather than the size of the library. Rebuilds whenever the repository
/// reports a change.
@Riverpod()
Future<BookmarkFolder?> bookmarkFolder(Ref ref, String guid) {
  ref.watch(bookmarksRepositoryProvider);
  return ref.read(bookmarksRepositoryProvider.notifier).getFolder(guid);
}

/// The folder shown by the bookmark list, with the roots the user asked to
/// hide already removed.
///
/// Emptiness can only be judged by looking inside each root, but the root level
/// has a fixed handful of children, so the extra loads are bounded and shallow.
@Riverpod()
Future<BookmarkFolder?> bookmarkListFolder(
  Ref ref,
  String entryGuid, {
  bool hideEmptyRoots = false,
}) async {
  final folder = await ref.watch(bookmarkFolderProvider(entryGuid).future);

  if (folder == null ||
      !hideEmptyRoots ||
      entryGuid != BookmarkRoot.root.id ||
      folder.children == null) {
    return folder;
  }

  final visible = <BookmarkItem>[];
  for (final child in folder.children!) {
    if (child is! BookmarkFolder || child.guid == BookmarkRoot.mobile.id) {
      visible.add(child);
      continue;
    }

    final loaded = await ref.watch(bookmarkFolderProvider(child.guid).future);
    if (_hasVisibleContent(loaded)) {
      visible.add(child);
    }
  }

  return folder.copyWith.children(visible);
}

/// Guids of the bookmarks pointing at [url], or an empty list when there are
/// none.
///
/// Backed by a storage lookup, so "is this page bookmarked?" costs the same
/// whether the user has ten bookmarks or fifty thousand.
@Riverpod()
Future<List<String>> bookmarkGuidsForUrl(Ref ref, Uri? url) async {
  if (url == null) return const [];

  ref.watch(bookmarksRepositoryProvider);
  return ref
      .read(bookmarksRepositoryProvider.notifier)
      .bookmarkGuidsForUrl(url);
}

/// Number of bookmarks inside the trees rooted at [guids].
///
/// Used to tell the user how much a destructive action will affect.
@Riverpod()
Future<int> bookmarkCountInTrees(Ref ref, List<String> guids) {
  ref.watch(bookmarksRepositoryProvider);
  return ref
      .read(bookmarksRepositoryProvider.notifier)
      .countBookmarksInTrees(guids);
}
