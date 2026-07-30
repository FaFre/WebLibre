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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_html_utils.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_import_isolate.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_importer.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_json_utils.dart';

part 'bookmarks.g.dart';

@Riverpod(keepAlive: true)
class BookmarksRepository extends _$BookmarksRepository {
  final _service = GeckoBookmarksService();
  late final _jsonUtils = BookmarkJSONUtils(_service);
  late final _htmlUtils = BookmarkHTMLUtils(_service);

  Future<void> addBookmark({
    required String parentGuid,
    required Uri url,
    required String title,
    int? position,
  }) async {
    await _service.addItem(parentGuid, url, title, position);
    _notifyChanged();
  }

  Future<void> addFolder({
    required String parentGuid,
    required String title,
    int? position,
  }) async {
    await _service.addFolder(parentGuid, title, position);
    _notifyChanged();
  }

  Future<void> editBookmark({
    required String guid,
    String? title,
    Uri? url,
    String? parentGuid,
    int? position,
  }) async {
    await _service.updateNode(
      guid,
      BookmarkInfo(
        title: title,
        url: url?.toString(),
        parentGuid: parentGuid,
        position: position,
      ),
    );
    _notifyChanged();
  }

  Future<void> editFolder({
    required String guid,
    String? title,
    String? parentGuid,
    int? position,
  }) async {
    await _service.updateNode(
      guid,
      BookmarkInfo(title: title, parentGuid: parentGuid, position: position),
    );
    _notifyChanged();
  }

  Future<void> delete(String guid) async {
    await _service.deleteNode(guid);
    _notifyChanged();
  }

  Future<void> moveMany({
    required Iterable<BookmarkItem> items,
    required String targetParentGuid,
  }) async {
    for (final item in items) {
      if (bookmarkRootIds.contains(item.guid)) {
        logger.w('Skipping move of root folder: ${item.guid}');
        continue;
      }
      if (item.parentGuid == targetParentGuid) continue;
      await _service.updateNode(
        item.guid,
        BookmarkInfo(parentGuid: targetParentGuid),
      );
    }
    _notifyChanged();
  }

  Future<void> deleteMany(Iterable<String> guids) async {
    for (final guid in guids) {
      if (bookmarkRootIds.contains(guid)) {
        logger.w('Skipping delete of root folder: $guid');
        continue;
      }
      await _service.deleteNode(guid);
    }
    _notifyChanged();
  }

  Future<void> flattenFolder({required BookmarkFolder folder}) async {
    if (folder.parentGuid == null || bookmarkRootIds.contains(folder.guid)) {
      logger.w('Cannot flatten root or parentless folder: ${folder.guid}');
      return;
    }
    // Fetch the full folder tree from storage to avoid operating on a
    // filtered subset (e.g. when search is active), which would silently
    // delete children that were not moved.
    final fullNode = await _service.getTree(folder.guid);
    final children = fullNode?.children;
    if (children != null) {
      for (final child in children) {
        await _service.updateNode(
          child.guid,
          BookmarkInfo(parentGuid: folder.parentGuid),
        );
      }
    }
    await _service.deleteNode(folder.guid);
    _notifyChanged();
  }

  /// Loads a single folder and its direct children.
  ///
  /// This is the load the bookmark UI is built on: the cost is proportional to
  /// the folder being shown, not to the size of the library. Reach for
  /// [getFolderTree] only when an operation genuinely needs descendants.
  Future<BookmarkFolder?> getFolder(String guid) async {
    final node = await _service.getTree(guid);
    if (node == null || node.type != BookmarkNodeType.folder) return null;
    return BookmarkItem.parseRecursive(node) as BookmarkFolder?;
  }

  /// Loads a folder with every descendant.
  ///
  /// Only for operations that need the whole subtree — export, flatten, "open
  /// all in folder". Never for rendering a list.
  Future<BookmarkFolder?> getFolderTree(String guid) async {
    final node = await _service.getTree(guid, recursive: true);
    if (node == null || node.type != BookmarkNodeType.folder) return null;
    return BookmarkItem.parseRecursive(node) as BookmarkFolder?;
  }

  /// Number of bookmark items inside the trees rooted at [guids].
  ///
  /// Counted in storage, so this stays cheap on a large library.
  Future<int> countBookmarksInTrees(Iterable<String> guids) {
    if (guids.isEmpty) return Future.value(0);
    return _service.countBookmarksInTrees(guids.toList());
  }

  /// Guids of every bookmark entry pointing at [url].
  ///
  /// Answers "is this page bookmarked?" through a storage lookup instead of
  /// scanning an in-memory tree.
  Future<List<String>> bookmarkGuidsForUrl(Uri url) async {
    final nodes = await _service.getBookmarksWithUrl(url);
    return nodes.map((node) => node.guid).toList();
  }

  /// Returns the GUIDs of all descendant folders of [guid] by fetching the
  /// full subtree from storage. This is safe to call even when the UI tree is
  /// filtered (e.g. during search), unlike the pure-utility
  /// [collectDescendantFolderGuids] which only walks the in-memory tree.
  Future<Set<String>> getDescendantFolderGuids(String guid) async {
    final node = await _service.getTree(guid, recursive: true);
    if (node == null) return const {};
    final result = <String>{};
    void collect(BookmarkNode n) {
      for (final child in n.children ?? const <BookmarkNode>[]) {
        if (child.type == BookmarkNodeType.folder) {
          result.add(child.guid);
          collect(child);
        }
      }
    }

    collect(node);
    return result;
  }

  Future<void> eraseEverything(BookmarkRoot root) async {
    await _service.eraseEverything(root);
    _notifyChanged();
  }

  Future<int> importFromJSON(String jsonString, {bool replace = false}) async {
    final count = await _jsonUtils.importFromJSON(jsonString, replace: replace);
    _notifyChanged();
    return count;
  }

  Future<int> importFromHTML(String htmlString, {bool replace = false}) async {
    final count = await _htmlUtils.importFromHTML(htmlString, replace: replace);
    _notifyChanged();
    return count;
  }

  /// Imports the bookmark file at [path], parsing it in a background isolate.
  ///
  /// Preferred over [importFromHTML]/[importFromJSON] for user-initiated
  /// imports: neither the raw file nor the intermediate parse tree ever touches
  /// the UI isolate.
  Future<int> importFromFile({
    required String path,
    required BookmarkImportFormat format,
    bool replace = false,
  }) async {
    final tree = await parseBookmarkFile(
      path: path,
      format: format,
      // Replacing the library is the only case where a file's own root folders
      // should take over the corresponding Places roots.
      preserveRootFolders: replace,
    );

    final count = await BookmarkTreeImporter(
      _service,
    ).import(tree, replace: replace);

    _notifyChanged();
    return count;
  }

  Future<Map<String, dynamic>?> exportToJson({
    required BookmarkRoot root,
  }) async {
    return await _jsonUtils.exportToJson(root: root);
  }

  Future<String> exportToHTML({required BookmarkRoot root}) async {
    return await _htmlUtils.exportToHTML(root: root);
  }

  /// A revision that advances whenever bookmarks change.
  ///
  /// The repository deliberately holds no bookmark data. It used to build the
  /// entire tree recursively from [BookmarkRoot.root], which meant every
  /// consumer paid for the whole library — the reason opening bookmarks after
  /// a large import or sync could bring the app down. Data now comes from the
  /// folder-scoped providers, which watch this value to know when to reload.
  @override
  int build() => 0;

  /// Signals that stored bookmarks changed, prompting dependents to reload.
  void _notifyChanged() => state++;
}
