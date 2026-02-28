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

/// Recursively sorts a bookmark tree by the given sort type.
/// Root-level built-in folders are kept in their canonical order.
BookmarkItem sortBookmarkTree(
  BookmarkItem item,
  BookmarkSortType sortType, {
  bool isRoot = false,
}) {
  if (sortType == BookmarkSortType.manual) return item;

  if (item is BookmarkFolder && item.children != null) {
    final sortedChildren = item.children!.map((child) {
      return sortBookmarkTree(child, sortType);
    }).toList();

    // At root level, keep built-in root folders pinned in original order
    if (isRoot) {
      final rootFolders = <BookmarkItem>[];
      final nonRootItems = <BookmarkItem>[];
      for (final child in sortedChildren) {
        if (bookmarkRootIds.contains(child.guid)) {
          rootFolders.add(child);
        } else {
          nonRootItems.add(child);
        }
      }
      nonRootItems.sort((a, b) => compareBookmarkItems(a, b, sortType));
      return BookmarkFolder(
        guid: item.guid,
        parentGuid: item.parentGuid,
        title: item.title,
        position: item.position,
        dateAdded: item.dateAdded,
        children: [...rootFolders, ...nonRootItems],
      );
    }

    sortedChildren.sort((a, b) => compareBookmarkItems(a, b, sortType));
    return BookmarkFolder(
      guid: item.guid,
      parentGuid: item.parentGuid,
      title: item.title,
      position: item.position,
      dateAdded: item.dateAdded,
      children: sortedChildren,
    );
  }

  return item;
}

/// Collects all descendant folder GUIDs from a folder (not including the folder itself).
Set<String> collectDescendantFolderGuids(BookmarkFolder folder) {
  final result = <String>{};
  if (folder.children != null) {
    for (final child in folder.children!) {
      if (child is BookmarkFolder) {
        result.add(child.guid);
        result.addAll(collectDescendantFolderGuids(child));
      }
    }
  }
  return result;
}

/// Resolves BookmarkItems from a tree by their GUIDs.
List<BookmarkItem> resolveSelectedItems(BookmarkItem root, Set<String> guids) {
  final result = <BookmarkItem>[];
  _collectByGuids(root, guids, result);
  return result;
}

void _collectByGuids(
  BookmarkItem item,
  Set<String> guids,
  List<BookmarkItem> result,
) {
  if (guids.contains(item.guid)) {
    result.add(item);
  }
  if (item is BookmarkFolder && item.children != null) {
    for (final child in item.children!) {
      _collectByGuids(child, guids, result);
    }
  }
}

/// Whether a folder can be flattened (non-root, has a parent, has children).
bool canFlattenFolder(BookmarkFolder folder) {
  return folder.parentGuid != null &&
      !bookmarkRootIds.contains(folder.guid) &&
      folder.children != null &&
      folder.children!.isNotEmpty;
}

/// Normalizes a selection set: removes items that are descendants of selected folders.
/// This prevents double-applying moves when both a folder and its children are selected.
Set<String> normalizeSelection(BookmarkItem root, Set<String> selectedGuids) {
  final items = resolveSelectedItems(root, selectedGuids);
  final folderGuidsToRemove = <String>{};

  for (final item in items) {
    if (item is BookmarkFolder) {
      _collectAllDescendantGuids(item, folderGuidsToRemove);
    }
  }

  return selectedGuids.difference(folderGuidsToRemove);
}

void _collectAllDescendantGuids(BookmarkFolder folder, Set<String> result) {
  if (folder.children != null) {
    for (final child in folder.children!) {
      result.add(child.guid);
      if (child is BookmarkFolder) {
        _collectAllDescendantGuids(child, result);
      }
    }
  }
}
