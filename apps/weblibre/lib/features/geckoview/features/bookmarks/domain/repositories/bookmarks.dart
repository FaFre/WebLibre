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
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_html_utils.dart';
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
    ref.invalidateSelf();
  }

  Future<void> addFolder({
    required String parentGuid,
    required String title,
    int? position,
  }) async {
    await _service.addFolder(parentGuid, title, position);
    ref.invalidateSelf();
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
    ref.invalidateSelf();
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
    ref.invalidateSelf();
  }

  Future<void> delete(String guid) async {
    await _service.deleteNode(guid);
    ref.invalidateSelf();
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
    ref.invalidateSelf();
  }

  Future<void> deleteMany(Iterable<String> guids) async {
    for (final guid in guids) {
      if (bookmarkRootIds.contains(guid)) {
        logger.w('Skipping delete of root folder: $guid');
        continue;
      }
      await _service.deleteNode(guid);
    }
    ref.invalidateSelf();
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
    ref.invalidateSelf();
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
    ref.invalidateSelf();
  }

  Future<int> importFromJSON(String jsonString, {bool replace = false}) async {
    final count = await _jsonUtils.importFromJSON(jsonString, replace: replace);
    ref.invalidateSelf();
    return count;
  }

  Future<int> importFromHTML(String htmlString, {bool replace = false}) async {
    final count = await _htmlUtils.importFromHTML(htmlString, replace: replace);
    ref.invalidateSelf();
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

  @override
  Future<BookmarkItem?> build() async {
    final node = await _service.getTree(BookmarkRoot.root.id, recursive: true);
    return node.mapNotNull(BookmarkItem.parseRecursive);
  }
}
