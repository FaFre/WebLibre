import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

/// Enumeration of the ids of the roots of the bookmarks tree.
///
/// There are 5 "roots" in the bookmark tree. The actual root
/// (which has no parent), and it's 4 children (which have the
/// actual root as their parent).
///
/// You cannot delete or move any of these items.
enum BookmarkRoot {
  root("root________", "Default"),
  menu("menu________", "Menu"),
  toolbar("toolbar_____", "Toolbar"),
  unfiled("unfiled_____", "Unified"),
  mobile("mobile______", "WebLibre");

  final String id;
  final String displayName;

  const BookmarkRoot(this.id, this.displayName);
}

final bookmarkRootIds = BookmarkRoot.values.map((e) => e.id).toSet();
final bookmarkRootDisplayNames = Map.fromEntries(
  BookmarkRoot.values.map((e) => MapEntry(e.id, e.displayName)),
);

final _api = GeckoBookmarksApi();

class GeckoBookmarksService {
  /// Produces a bookmarks tree for the given guid string.
  ///
  /// @param guid The bookmark guid to obtain.
  /// @param recursive Whether to recurse and obtain all levels of children.
  /// @return The populated root starting from the guid.
  Future<BookmarkNode?> getTree(String guid, {bool recursive = false}) {
    return _api.getTree(guid, recursive);
  }

  /// Obtains the details of a bookmark without children, if one exists with that guid. Otherwise, null.
  ///
  /// @param guid The bookmark guid to obtain.
  /// @return The bookmark node or null if it does not exist.
  Future<BookmarkNode?> getBookmark(String guid) {
    return _api.getBookmark(guid);
  }

  /// Produces a list of all bookmarks with the given URL.
  ///
  /// @param url The URL string.
  /// @return The list of bookmarks that match the URL
  Future<List<BookmarkNode>> getBookmarksWithUrl(Uri url) {
    return _api.getBookmarksWithUrl(url.toString());
  }

  /// Produces a list of the most recently added bookmarks.
  ///
  /// @param limit The maximum number of entries to return.
  /// @param maxAge Optional parameter used to filter out entries older than this number of milliseconds.
  /// @param currentTime Optional parameter for current time. Defaults toSystem.currentTimeMillis()
  /// @return The list of bookmarks that have been recently added up to the limit number of items.
  Future<List<BookmarkNode>> getRecentBookmarks(
    int limit, {
    Duration maxAge = Duration.zero,
    DateTime? currentTime,
  }) {
    return _api.getRecentBookmarks(
      limit,
      maxAge.inMilliseconds,
      (currentTime ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  /// Searches bookmarks with a query string.
  ///
  /// @param query The query string to search.
  /// @param limit The maximum number of entries to return.
  /// @return The list of matching bookmark nodes up to the limit number of items.
  Future<List<BookmarkNode>> searchBookmarks(String query, {int limit = 10}) {
    return _api.searchBookmarks(query, limit);
  }

  /// Adds a new bookmark item to a given node.
  ///
  /// Sync behavior: will add new bookmark item to remote devices.
  ///
  /// @param parentGuid The parent guid of the new node.
  /// @param url The URL of the bookmark item to add.
  /// @param title The title of the bookmark item to add.
  /// @param position The optional position to add the new node or null to append.
  /// @return The guid of the newly inserted bookmark item.
  Future<String> addItem(
    String parentGuid,
    Uri url,
    String title,
    int? position,
  ) {
    return _api.addItem(parentGuid, url.toString(), title, position);
  }

  /// Adds a new bookmark folder to a given node.
  ///
  /// Sync behavior: will add new separator to remote devices.
  ///
  /// @param parentGuid The parent guid of the new node.
  /// @param title The title of the bookmark folder to add.
  /// @param position The optional position to add the new node or null to append.
  /// @return The guid of the newly inserted bookmark item.
  Future<String> addFolder(String parentGuid, String title, int? position) {
    return _api.addFolder(parentGuid, title, position);
  }

  /// Edits the properties of an existing bookmark item and/or moves an existing one underneath a new parent guid.
  ///
  /// Sync behavior: will alter bookmark item on remote devices.
  ///
  /// @param guid The guid of the item to update.
  /// @param info The info to change in the bookmark.
  Future<void> updateNode(String guid, BookmarkInfo info) {
    return _api.updateNode(guid, info);
  }

  /// Deletes a bookmark node and all of its children, if any.
  ///
  /// Sync behavior: will remove bookmark from remote devices.
  ///
  /// @return Whether the bookmark existed or not.
  Future<bool> deleteNode(String guid) {
    return _api.deleteNode(guid);
  }
}
