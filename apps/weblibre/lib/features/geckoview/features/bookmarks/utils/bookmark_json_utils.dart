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
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_importer.dart';
import 'package:weblibre/utils/uri_input_parser.dart';

/// Parses a Firefox JSON bookmark backup into an [ImportBookmarkTree].
///
/// Pure and free of platform channels, so it is safe to run inside an isolate;
/// see `bookmark_import_isolate.dart`.
///
/// Only top-level nodes that identify themselves as a Places root are imported,
/// each into its matching root. `place:` query URLs have their folder ids
/// rewritten to guids, and the tags folder is ignored.
ImportBookmarkTree parseBookmarkJson(String jsonString) {
  final data = jsonDecode(jsonString);

  if (data is! Map<String, dynamic>) {
    throw const FormatException('Invalid JSON format');
  }

  return const _BookmarkJsonParser().parse(data);
}

class BookmarkJSONUtils {
  final GeckoBookmarksService _service;

  BookmarkJSONUtils(this._service);

  /// Import bookmarks from JSON string
  Future<int> importFromJSON(String jsonString, {bool replace = false}) async {
    try {
      final tree = parseBookmarkJson(jsonString);
      return await BookmarkTreeImporter(
        _service,
      ).import(tree, replace: replace);
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
}

/// Running totals collected while converting a JSON backup.
class _Counters {
  int bookmarks = 0;
  int folders = 0;
  int separators = 0;
  int skippedUrls = 0;
}

class _BookmarkJsonParser {
  const _BookmarkJsonParser();

  ImportBookmarkTree parse(Map<String, dynamic> data) {
    final nodes =
        (data['children'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .where(
              (node) =>
                  node['root'] != 'tagsFolder' &&
                  node['guid'] != 'tags________',
            )
            .toList() ??
        const [];

    // `place:` query URLs reference folders by numeric id, which is meaningless
    // once imported. Collect every id -> guid pair up front, including from
    // sections that are not themselves imported, so the rewrite below can
    // resolve references that point across roots.
    final folderIdToGuid = <String, String>{};
    for (final node in nodes) {
      if (_childrenOf(node).isEmpty) continue;
      _collectFolderGuids(node, folderIdToGuid);
    }

    final counters = _Counters();
    final sections = <String, List<ImportBookmarkNode>>{};

    for (final node in nodes) {
      final children = _childrenOf(node);
      if (children.isEmpty) continue;

      // Anything that does not name a Places root has nowhere to go: a backup
      // always describes its roots explicitly.
      final guid = node['guid'] as String?;
      if (guid == null || !bookmarkRootIds.contains(guid)) continue;

      final converted = <ImportBookmarkNode>[];
      for (final child in children) {
        final node = _convert(child, folderIdToGuid, counters);
        if (node != null) converted.add(node);
      }

      if (converted.isEmpty) continue;
      sections
          .putIfAbsent(guid, () => <ImportBookmarkNode>[])
          .addAll(converted);
    }

    return ImportBookmarkTree(
      sections: sections,
      stats: ImportBookmarkStats(
        bookmarkCount: counters.bookmarks,
        folderCount: counters.folders,
        separatorCount: counters.separators,
        skippedUrlCount: counters.skippedUrls,
      ),
    );
  }

  ImportBookmarkNode? _convert(
    Map<String, dynamic> node,
    Map<String, String> folderIdToGuid,
    _Counters counters,
  ) {
    final dateAdded = _parseTimestamp(node['dateAdded']);
    final lastModified = _parseTimestamp(node['lastModified']);

    switch (_getNodeType(node)) {
      case BookmarkNodeType.folder:
        final children = <ImportBookmarkNode>[];
        for (final child in _childrenOf(node)) {
          final converted = _convert(child, folderIdToGuid, counters);
          if (converted != null) children.add(converted);
        }
        counters.folders++;
        return ImportBookmarkFolder(
          title: node['title'] as String? ?? '',
          children: children,
          dateAdded: dateAdded,
          lastModified: lastModified,
        );

      case BookmarkNodeType.item:
        var url = _getNodeUrl(node);
        if (url == null || url.isEmpty) {
          counters.skippedUrls++;
          return null;
        }
        if (url.startsWith('place:')) {
          url = _fixupQuery(url, folderIdToGuid);
        }

        final uri = Uri.tryParse(url);
        if (uri == null || !uri.hasScheme) {
          counters.skippedUrls++;
          logger.w(
            'Skipping invalid URL: ${uri != null ? redactUriCredentials(uri) : url}',
          );
          return null;
        }

        counters.bookmarks++;
        return ImportBookmarkItem(
          url: uri,
          title: node['title'] as String? ?? '',
          dateAdded: dateAdded,
          lastModified: lastModified,
        );

      case BookmarkNodeType.separator:
        counters.separators++;
        return ImportBookmarkSeparator(
          dateAdded: dateAdded,
          lastModified: lastModified,
        );
    }
  }

  void _collectFolderGuids(
    Map<String, dynamic> node,
    Map<String, String> folderIdToGuid,
  ) {
    if (node['type'] == 'text/x-moz-place-container') {
      final id = node['id']?.toString();
      final guid = node['guid'] as String?;
      if (id != null && guid != null) {
        folderIdToGuid[id] = guid;
      }
    }

    for (final child in _childrenOf(node)) {
      _collectFolderGuids(child, folderIdToGuid);
    }
  }

  List<Map<String, dynamic>> _childrenOf(Map<String, dynamic> node) {
    return (node['children'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [];
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

  /// Get URL from node (accepts both 'url' and 'uri')
  String? _getNodeUrl(Map<String, dynamic> node) {
    return node['url'] as String? ?? node['uri'] as String?;
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

  /// Reads a backup timestamp, which may be in either unit.
  ///
  /// Firefox writes PRTime (microseconds), while WebLibre's own JSON export
  /// writes Places' native milliseconds. Any microsecond value for a date after
  /// ~1973 exceeds [_microsecondThreshold], whereas a millisecond value would
  /// have to be a date past the year 5138 to reach it.
  static const _microsecondThreshold = 100000000000000;

  DateTime? _parseTimestamp(Object? value) {
    final raw = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (raw == null || raw <= 0) return null;

    return DateTime.fromMillisecondsSinceEpoch(
      raw > _microsecondThreshold ? raw ~/ 1000 : raw,
    );
  }
}
