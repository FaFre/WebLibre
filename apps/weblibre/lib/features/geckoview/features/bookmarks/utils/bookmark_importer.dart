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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';

/// Writes a parsed [ImportBookmarkTree] into Places.
///
/// Insertion is bulk: one native call per destination root, with each top-level
/// folder written as a single storage tree insertion. A 25k-bookmark file
/// therefore costs a handful of platform channel round trips rather than one
/// per node.
class BookmarkTreeImporter {
  final GeckoBookmarksService _service;

  const BookmarkTreeImporter(this._service);

  /// Inserts [tree] and returns the number of bookmark items written.
  ///
  /// When [replace] is set every root except [BookmarkRoot.root] is emptied
  /// first; the root itself is never deleted. A tree that parsed to nothing
  /// erases nothing either, so a malformed or empty file cannot wipe the
  /// user's bookmarks and leave them with an empty library.
  Future<int> import(
    ImportBookmarkTree tree, {
    required bool replace,
    void Function(BookmarkImportProgress)? onProgress,
  }) async {
    if (tree.isEmpty) return 0;

    final total = tree.stats.bookmarkCount;

    if (replace) {
      onProgress?.call(
        const BookmarkImportProgress(phase: BookmarkImportPhase.erasing),
      );

      for (final root in BookmarkRoot.values) {
        if (root != BookmarkRoot.root) {
          await _service.eraseEverything(root);
        }
      }
    }

    var importedCount = 0;

    // Native reports progress per insertion, counted from the start of that
    // call, so completed sections have to be added back on.
    void report(int insertedInSection) {
      onProgress?.call(
        BookmarkImportProgress(
          phase: BookmarkImportPhase.inserting,
          inserted: importedCount + insertedInSection,
          total: total,
        ),
      );
    }

    if (onProgress != null) {
      GeckoBookmarksEvents.setUp(_ImportProgressReceiver(report));
    }

    try {
      report(0);

      for (final section in tree.sections.entries) {
        if (section.value.isEmpty) continue;

        final result = await _service.insertTree(
          section.key,
          section.value.map(toPigeonImportNode).toList(),
        );

        importedCount += result.insertedItemCount;
        report(0);

        if (result.failedNodeCount > 0) {
          logger.e(
            'Failed to import ${result.failedNodeCount} top-level nodes into ${section.key}',
          );
        }
      }
    } finally {
      if (onProgress != null) {
        GeckoBookmarksEvents.setUp(null);
      }
    }

    return importedCount;
  }
}

class _ImportProgressReceiver extends GeckoBookmarksEvents {
  _ImportProgressReceiver(this._onProgress);

  final void Function(int insertedItemCount) _onProgress;

  @override
  void onImportProgress(int insertedItemCount) =>
      _onProgress(insertedItemCount);
}

/// Converts a parsed node into the Pigeon transport type.
///
/// Timestamps become milliseconds since epoch, with 0 standing in for "the file
/// did not say", which is what Places expects for an unknown timestamp.
BookmarkImportNode toPigeonImportNode(ImportBookmarkNode node) {
  return switch (node) {
    final ImportBookmarkFolder folder => BookmarkImportNode(
      type: BookmarkNodeType.folder,
      title: folder.title,
      url: null,
      dateAdded: _toMillis(folder.dateAdded),
      lastModified: _toMillis(folder.lastModified),
      children: folder.children.map(toPigeonImportNode).toList(),
    ),
    final ImportBookmarkItem item => BookmarkImportNode(
      type: BookmarkNodeType.item,
      title: item.title,
      url: item.url.toString(),
      dateAdded: _toMillis(item.dateAdded),
      lastModified: _toMillis(item.lastModified),
      children: const [],
    ),
    final ImportBookmarkSeparator separator => BookmarkImportNode(
      type: BookmarkNodeType.separator,
      title: null,
      url: null,
      dateAdded: _toMillis(separator.dateAdded),
      lastModified: _toMillis(separator.lastModified),
      children: const [],
    ),
  };
}

int _toMillis(DateTime? value) => value?.millisecondsSinceEpoch ?? 0;
