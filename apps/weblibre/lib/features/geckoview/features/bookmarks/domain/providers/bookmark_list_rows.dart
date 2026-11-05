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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmark_list_ui_state.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/utils/bookmark_tree_utils.dart';

part 'bookmark_list_rows.g.dart';

/// The bookmark list of [entryGuid] flattened into rows: the entry folder and
/// every folder of [expandedGuids] beneath it, in display order.
///
/// A folder's children are only requested once it is expanded, so a collapsed
/// subtree costs nothing — this is what keeps the list openable after a large
/// import or sync. Expanding starts the load, and the rows follow when it
/// lands; until then the folder has a placeholder row.
///
/// While [enabled] is false (the list shows search hits instead) nothing is
/// loaded or watched, so expanded folders are released until the tree comes
/// back.
@Riverpod()
List<BookmarkRow> bookmarkListRows(
  Ref ref,
  String entryGuid, {
  required bool hideEmptyRoots,
  required EquatableValue<Set<String>> expandedGuids,
  required bool enabled,
}) {
  if (!enabled) return const [];

  final folder = ref.watch(
    bookmarkListFolderProvider(
      entryGuid,
      hideEmptyRoots: hideEmptyRoots,
    ).select((value) => value.value),
  );
  final foldersOnly = ref.watch(
    bookmarkListUiStateProvider.select((state) => state.foldersOnly),
  );
  final sortType = ref.watch(
    bookmarkListUiStateProvider.select((state) => state.sortType),
  );

  /// The children of [folder] in display order, with the folders-only
  /// filter applied.
  List<BookmarkItem> visibleChildren(
    BookmarkFolder? folder, {
    required int depth,
  }) {
    var children = folder?.children ?? const <BookmarkItem>[];

    if (foldersOnly) {
      children = children.whereType<BookmarkFolder>().toList();
    }

    return sortBookmarkChildren(
      children,
      sortType,
      // Only the entry level can be the tree root, and only there do the
      // built-in folders need pinning.
      isRoot: depth == 0 && entryGuid == BookmarkRoot.root.id,
    );
  }

  List<BookmarkRow> rows(BookmarkFolder? folder, {required int depth}) {
    final result = <BookmarkRow>[];

    for (final item in visibleChildren(folder, depth: depth)) {
      result.add(BookmarkRow(item, depth));

      if (item is! BookmarkFolder || !expandedGuids.value.contains(item.guid)) {
        continue;
      }

      final child = ref.watch(
        bookmarkFolderProvider(item.guid).select((value) => value.value),
      );
      if (child == null) {
        result.add(BookmarkRow(item, depth + 1, isPlaceholder: true));
        continue;
      }

      result.addAll(rows(child, depth: depth + 1));
    }

    return result;
  }

  return rows(folder, depth: 0);
}
