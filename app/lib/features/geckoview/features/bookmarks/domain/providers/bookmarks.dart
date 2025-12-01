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
import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';

part 'bookmarks.g.dart';

T? _selectChildRecursive<T extends BookmarkItem>(
  List<BookmarkItem> children,
  String guid,
) {
  for (final child in children) {
    if (child.guid == guid && child is T) {
      return child;
    }

    if (child case final BookmarkFolder folder) {
      if (folder.children != null) {
        final result = _selectChildRecursive<T>(folder.children!, guid);
        if (result != null) {
          return result;
        }
      }
    }
  }

  return null;
}

T _cloneAndFilterChildrenType<T extends BookmarkItem>(T node) {
  if (node is BookmarkFolder) {
    if (node.children != null) {
      return node.copyWith.children(
            node.children
                ?.whereType<T>()
                .map((e) => _cloneAndFilterChildrenType<T>(e))
                .toList(),
          )
          as T;
    }
  }

  return node.clone() as T;
}

BookmarkItem? _cloneAndFilterOnGuids(BookmarkItem node, Set<String> guids) {
  if (node is BookmarkFolder) {
    if (node.children != null) {
      final filtered = node.children
          ?.where((e) => e is BookmarkFolder || guids.contains(e.guid))
          .map((e) => _cloneAndFilterOnGuids(e, guids))
          .nonNulls
          .toList();

      if (filtered.isNotEmpty) {
        return node.copyWith.children(filtered);
      } else {
        return null;
      }
    }
  }

  if (guids.contains(node.guid)) {
    return node.clone();
  }

  return null;
}

@Riverpod()
class BookmarksSearch extends _$BookmarksSearch {
  final _service = GeckoBookmarksService();
  late StreamController<Set<String>> _streamController;

  Future<void> search(String query, {int limit = 10}) async {
    if (query.isNotEmpty) {
      await _service.searchBookmarks(query, limit: limit).then((value) {
        if (!_streamController.isClosed) {
          _streamController.add(value.map((e) => e.guid).toSet());
        }
      });
    }
  }

  @override
  Stream<Set<String>> build() {
    _streamController = StreamController();

    ref.onDispose(() async {
      await _streamController.close();
    });

    return _streamController.stream;
  }
}

@Riverpod()
AsyncValue<T?> bookmarks<T extends BookmarkItem>(Ref ref, String entryGuid) {
  final bookmarksAsync = ref.watch(bookmarksRepositoryProvider);

  return bookmarksAsync.whenData((bookmarkNode) {
    T? selectedNode;

    if (bookmarkNode != null && bookmarkNode is T) {
      if (bookmarkNode.guid == entryGuid) {
        selectedNode = bookmarkNode;
      } else if (bookmarkNode case final BookmarkFolder folder) {
        if (folder.children != null) {
          selectedNode = _selectChildRecursive<T>(folder.children!, entryGuid);
        }
      }
    }

    if (selectedNode != null) {
      return _cloneAndFilterChildrenType<T>(selectedNode);
    }

    return null;
  });
}

@Riverpod()
class SeamlessBookmarks extends _$SeamlessBookmarks {
  bool _hasSearch = false;

  void search(String input) {
    if (input.isNotEmpty) {
      if (!_hasSearch) {
        _hasSearch = true;
        ref.invalidateSelf();
      }

      //Don't block
      unawaited(ref.read(bookmarksSearchProvider.notifier).search(input));
    } else if (_hasSearch) {
      _hasSearch = false;
      ref.invalidateSelf();
    }
  }

  @override
  AsyncValue<BookmarkItem?> build(String entryGuid) {
    final bookmarks = ref.watch(bookmarksProvider<BookmarkItem>(entryGuid));

    if (_hasSearch) {
      final filterGuids = ref.watch(bookmarksSearchProvider);
      return bookmarks.map(
        data: (node) =>
            node.value.mapNotNull(
              (node) => filterGuids.whenData(
                (results) => _cloneAndFilterOnGuids(node, results),
              ),
            ) ??
            const AsyncValue.data(null),
        error: (e) => e,
        loading: (s) => s,
      );
    } else {
      return bookmarks;
    }
  }
}
