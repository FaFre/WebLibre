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
