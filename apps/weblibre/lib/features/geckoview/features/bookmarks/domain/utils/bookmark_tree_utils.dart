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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';

/// Sorts one folder's direct children by the given sort type.
///
/// Only the level being displayed is sorted; descendants are not loaded, so
/// there is nothing deeper to order. Root-level built-in folders are kept
/// pinned in their canonical order ahead of everything else.
List<BookmarkItem> sortBookmarkChildren(
  List<BookmarkItem> children,
  BookmarkSortType sortType, {
  bool isRoot = false,
}) {
  if (sortType == BookmarkSortType.manual) return children;

  if (!isRoot) {
    return [...children]..sort((a, b) => compareBookmarkItems(a, b, sortType));
  }

  final rootFolders = <BookmarkItem>[];
  final rest = <BookmarkItem>[];
  for (final child in children) {
    if (bookmarkRootIds.contains(child.guid)) {
      rootFolders.add(child);
    } else {
      rest.add(child);
    }
  }
  rest.sort((a, b) => compareBookmarkItems(a, b, sortType));

  return [...rootFolders, ...rest];
}

/// One rendered line of the bookmark list: an item and how deep it sits.
///
/// The list flattens the expanded folders into rows rather than nesting
/// widgets, so it can stay a `ListView.builder` and only build what is on
/// screen — a folder with thousands of entries costs the same to expand as a
/// small one.
class BookmarkRow {
  final BookmarkItem item;
  final int depth;

  /// True when this row only stands in for [item]'s children while they load.
  ///
  /// A placeholder repeats the folder it belongs to, so it must never be
  /// treated as a second occurrence of that folder — acting on it would apply
  /// the same operation twice.
  final bool isPlaceholder;

  const BookmarkRow(this.item, this.depth, {this.isPlaceholder = false});
}

/// Resolves the items of [children] whose GUIDs are in [guids].
///
/// The caller passes whatever is currently displayed, which may be one folder's
/// children, several expanded levels, or search hits from all over the library.
List<BookmarkItem> resolveSelectedItems(
  List<BookmarkItem> children,
  Set<String> guids,
) {
  return children.where((child) => guids.contains(child.guid)).toList();
}

/// Drops selections that sit inside another selected folder.
///
/// Expanding a folder makes its children selectable alongside it, and acting on
/// both would move a child out of the very folder that just moved, or delete it
/// twice. A folder's descendants are exactly the rows that follow it until the
/// depth returns to its own, so one pass over [rows] is enough.
Set<String> normalizeSelection(List<BookmarkRow> rows, Set<String> selected) {
  final result = <String>{};
  var skipBelowDepth = -1;

  for (final row in rows) {
    if (skipBelowDepth >= 0) {
      if (row.depth > skipBelowDepth) continue;
      skipBelowDepth = -1;
    }

    if (row.isPlaceholder) continue;

    if (selected.contains(row.item.guid)) {
      result.add(row.item.guid);
      if (row.item is BookmarkFolder) {
        skipBelowDepth = row.depth;
      }
    }
  }

  return result;
}

/// Whether a folder can be flattened (non-root and has a parent).
///
/// Whether it actually holds anything is left to the repository, which reads
/// the folder's children at the moment of the operation rather than relying on
/// what the list happens to have loaded.
bool canFlattenFolder(BookmarkFolder folder) {
  return folder.parentGuid != null && !bookmarkRootIds.contains(folder.guid);
}
