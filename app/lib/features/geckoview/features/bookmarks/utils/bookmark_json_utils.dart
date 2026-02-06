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

// ignore_for_file: unnecessary_raw_strings

import 'dart:convert';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/core/logger.dart';

class BookmarkJSONUtils {
  final GeckoBookmarksService _service;

  BookmarkJSONUtils(this._service);

  /// Import bookmarks from JSON string
  Future<int> importFromJSON(String jsonString, {bool replace = false}) async {
    try {
      final data = jsonDecode(jsonString);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid JSON format');
      }

      final children = data['children'] as List?;
      if (children == null || children.isEmpty) {
        return 0;
      }

      return await _import(data, replace: replace);
    } catch (ex) {
      logger.e('Failed to import bookmarks: $ex');
      rethrow;
    }
  }

  /// Export bookmarks to JSON
  Future<Map<String, dynamic>?> exportToJson({
    required BookmarkRoot root,
  }) async {
    final tree = await _service.getTree(root.id, recursive: true);
    if (tree == null) {
      throw Exception('Failed to get bookmarks tree');
    }

    return _nodeToJson(tree, isRoot: true);
  }

  /// Import implementation
  Future<int> _import(
    Map<String, dynamic> rootNode, {
    required bool replace,
  }) async {
    final nodes =
        (rootNode['children'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .where(
              (node) =>
                  node['root'] != 'tagsFolder' &&
                  node['guid'] != 'tags________',
            )
            .toList() ??
        [];

    if (nodes.isEmpty) {
      return 0;
    }

    // If replacing, erase existing bookmarks first
    if (replace) {
      // Delete bookmarks from each root folder (except root itself to avoid errors)
      for (final root in BookmarkRoot.values) {
        if (root != BookmarkRoot.root) {
          await _service.eraseEverything(root);
        }
      }
    }

    final folderIdToGuidMap = <String, String>{};

    // Translate tree types and build folder map
    for (final node in nodes) {
      if (node['children'] == null || (node['children'] as List).isEmpty) {
        continue;
      }

      final folders = _translateTreeTypes(node);
      folderIdToGuidMap.addAll(folders);
    }

    int bookmarkCount = 0;

    // Insert nodes
    for (final node in nodes) {
      if (node['children'] == null || (node['children'] as List).isEmpty) {
        continue;
      }

      final guid = node['guid'] as String?;
      if (guid == null || !bookmarkRootIds.contains(guid)) {
        continue;
      }

      _fixupSearchQueries(node, folderIdToGuidMap);

      // Insert the tree recursively
      bookmarkCount += await _insertTree(node, folderIdToGuidMap);
    }

    return bookmarkCount;
  }

  /// Recursively insert bookmark tree
  Future<int> _insertTree(
    Map<String, dynamic> node,
    Map<String, String> folderIdToGuidMap,
  ) async {
    int count = 0;
    final children = node['children'] as List?;

    if (children == null || children.isEmpty) {
      return 0;
    }

    final parentGuid = node['guid'] as String;

    for (int i = 0; i < children.length; i++) {
      final child = children[i] as Map<String, dynamic>;
      final type = _getNodeType(child);

      if (type == BookmarkNodeType.item) {
        final url = _getNodeUrl(child);
        final title = child['title'] as String? ?? '';

        if (url != null && url.isNotEmpty) {
          try {
            // Validate URL before inserting
            final uri = Uri.tryParse(url);
            if (uri != null && uri.hasScheme) {
              await _service.addItem(parentGuid, uri, title, i);
              count++;
            } else {
              logger.w('Skipping invalid URL: $url');
            }
          } catch (e) {
            logger.e('Failed to import bookmark "$title": $e');
          }
        }
      } else if (type == BookmarkNodeType.folder) {
        final title = child['title'] as String? ?? '';
        try {
          final newGuid = await _service.addFolder(parentGuid, title, i);
          child['guid'] = newGuid;

          // Recursively insert children
          count += await _insertTree(child, folderIdToGuidMap);
        } catch (e) {
          logger.e('Failed to import folder "$title": $e');
        }
      }
      // Note: Separators are not supported by the Android API
    }

    return count;
  }

  /// Translate tree types from JSON format to internal format
  Map<String, String> _translateTreeTypes(Map<String, dynamic> node) {
    final folderIdToGuidMap = <String, String>{};

    _normalizeNodeUrl(node);

    final type = node['type'];
    if (type == 'text/x-moz-place-container') {
      node['type'] = BookmarkNodeType.folder.index;

      final id = node['id']?.toString();
      final guid = node['guid'] as String?;
      if (id != null && guid != null) {
        folderIdToGuidMap[id] = guid;
      }
    } else if (type == 'text/x-moz-place') {
      node['type'] = BookmarkNodeType.item.index;
    } else if (type == 'text/x-moz-place-separator') {
      node['type'] = BookmarkNodeType.separator.index;
      node.remove('title');
    }

    final children = node['children'] as List?;
    if (children != null) {
      for (final child in children) {
        if (child is Map<String, dynamic>) {
          folderIdToGuidMap.addAll(_translateTreeTypes(child));
        }
      }
    }

    return folderIdToGuidMap;
  }

  /// Fix up search queries with folder mappings
  void _fixupSearchQueries(
    Map<String, dynamic> node,
    Map<String, String> folderIdToGuidMap,
  ) {
    final url = _getNodeUrl(node);
    if (url != null && url.startsWith('place:')) {
      node['url'] = _fixupQuery(url, folderIdToGuidMap);
    }

    final children = node['children'] as List?;
    if (children != null) {
      for (final child in children) {
        if (child is Map<String, dynamic>) {
          _fixupSearchQueries(child, folderIdToGuidMap);
        }
      }
    }
  }

  /// Replace folder IDs with GUIDs in place: URIs
  String _fixupQuery(String queryURL, Map<String, String> folderIdToGuidMap) {
    final regex = RegExp(r'folder=([A-Za-z0-9_]+)');
    bool invalid = false;

    final result = queryURL.replaceAllMapped(regex, (match) {
      final folderId = match.group(1)!;
      final guid = folderIdToGuidMap[folderId];

      if (guid == null) {
        invalid = true;
        return 'invalidOldParentId=$folderId';
      }

      return 'parent=$guid';
    });

    if (invalid) {
      return '$result&excludeItems=1';
    }

    return result;
  }

  /// Convert BookmarkNode to JSON (for export)
  Map<String, dynamic>? _nodeToJson(BookmarkNode node, {bool isRoot = false}) {
    // Skip invalid bookmarks
    if (node.type == BookmarkNodeType.item) {
      if (node.url == null || node.url!.isEmpty) {
        logger.w('Skipping bookmark with invalid URL: ${node.guid}');
        return null;
      }
      try {
        Uri.parse(node.url!);
      } catch (e) {
        logger.w('Skipping bookmark with malformed URL: ${node.url}');
        return null;
      }
    }

    final json = <String, dynamic>{
      'guid': node.guid,
      'title': node.type == BookmarkNodeType.separator
          ? ''
          : (node.title ?? ''),
      'index': 0, // Will be set by parent
      'dateAdded': node.dateAdded,
      'lastModified': node.lastModified,
      'typeCode': node.type.index + 1,
      'type': _getTypeString(node.type),
    };

    if (isRoot &&
        node.parentGuid != null &&
        node.guid != BookmarkRoot.root.id) {
      json['parentGuid'] = node.parentGuid;
    }

    final rootName = _getRootName(node.guid);
    if (rootName != null) {
      json['root'] = rootName;
    }

    if (node.type == BookmarkNodeType.item) {
      json['url'] = node.url;
    }

    if (node.type == BookmarkNodeType.folder && node.children != null) {
      final validChildren = <Map<String, dynamic>>[];
      for (var i = 0; i < node.children!.length; i++) {
        final childJson = _nodeToJson(node.children![i]);
        if (childJson != null) {
          childJson['index'] = validChildren.length;
          validChildren.add(childJson);
        }
      }
      if (validChildren.isNotEmpty) {
        json['children'] = validChildren;
      }
    }

    return json;
  }

  /// Convert BookmarkNodeType to Firefox type string
  String _getTypeString(BookmarkNodeType type) {
    switch (type) {
      case BookmarkNodeType.item:
        return 'text/x-moz-place';
      case BookmarkNodeType.folder:
        return 'text/x-moz-place-container';
      case BookmarkNodeType.separator:
        return 'text/x-moz-place-separator';
    }
  }

  /// Get root folder name for JSON
  String? _getRootName(String guid) {
    if (guid == BookmarkRoot.root.id) return 'placesRoot';
    if (guid == BookmarkRoot.menu.id) return 'bookmarksMenuFolder';
    if (guid == BookmarkRoot.toolbar.id) return 'toolbarFolder';
    if (guid == BookmarkRoot.unfiled.id) return 'unfiledBookmarksFolder';
    if (guid == BookmarkRoot.mobile.id) return 'mobileFolder';
    return null;
  }

  /// Get URL from node (accepts both 'url' and 'uri')
  String? _getNodeUrl(Map<String, dynamic> node) {
    return node['url'] as String? ?? node['uri'] as String?;
  }

  /// Normalize 'uri' to 'url' during import
  void _normalizeNodeUrl(Map<String, dynamic> node) {
    if (node.containsKey('uri')) {
      node['url'] = node['uri'];
      node.remove('uri');
    }
  }

  /// Get node type from JSON
  BookmarkNodeType _getNodeType(Map<String, dynamic> node) {
    final type = node['type'];
    if (type is int) {
      return BookmarkNodeType.values[type];
    }

    if (type == 'text/x-moz-place-container') {
      return BookmarkNodeType.folder;
    } else if (type == 'text/x-moz-place') {
      return BookmarkNodeType.item;
    } else {
      return BookmarkNodeType.separator;
    }
  }
}
