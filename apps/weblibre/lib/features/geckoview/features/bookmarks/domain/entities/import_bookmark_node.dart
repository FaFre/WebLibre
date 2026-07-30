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

/// Parser output for bookmark imports.
///
/// This is the hand-off between parsing (which is pure, and runs in a
/// background isolate) and insertion (which talks to Places). Nodes carry no
/// guids and no explicit positions: the tree is described purely by nesting and
/// child order, and storage assigns both while inserting.
///
/// Netscape/Firefox metadata that Places cannot represent — `TAGS`,
/// `SHORTCUTURL`/keyword, `POST_DATA` and `LAST_CHARSET` — is intentionally
/// dropped during parsing rather than modelled here.
library;

/// A single node of a parsed bookmark tree.
sealed class ImportBookmarkNode {
  /// Creation time recorded in the imported file, or null if it had none.
  final DateTime? dateAdded;

  /// Modification time recorded in the imported file, or null if it had none.
  final DateTime? lastModified;

  const ImportBookmarkNode({this.dateAdded, this.lastModified});
}

/// A folder and everything nested underneath it.
final class ImportBookmarkFolder extends ImportBookmarkNode {
  final String title;

  /// Children in the order they should appear under this folder.
  final List<ImportBookmarkNode> children;

  const ImportBookmarkFolder({
    required this.title,
    required this.children,
    super.dateAdded,
    super.lastModified,
  });
}

/// A bookmark pointing at [url].
final class ImportBookmarkItem extends ImportBookmarkNode {
  final Uri url;
  final String title;

  const ImportBookmarkItem({
    required this.url,
    required this.title,
    super.dateAdded,
    super.lastModified,
  });
}

/// A visual divider between sibling nodes.
final class ImportBookmarkSeparator extends ImportBookmarkNode {
  const ImportBookmarkSeparator({super.dateAdded, super.lastModified});
}

/// What a parser found in a bookmark file, and where it belongs.
///
/// [sections] maps the guid of a Places root onto the nodes that should be
/// appended underneath it. Files without root markers produce a single section;
/// Firefox exports that identify their menu/toolbar/unfiled roots produce one
/// section per recognised root.
class ImportBookmarkTree {
  final Map<String, List<ImportBookmarkNode>> sections;

  /// Counters describing what the parser saw, including what it discarded.
  final ImportBookmarkStats stats;

  const ImportBookmarkTree({required this.sections, required this.stats});

  static const empty = ImportBookmarkTree(
    sections: {},
    stats: ImportBookmarkStats(),
  );

  bool get isEmpty => sections.values.every((nodes) => nodes.isEmpty);
}

/// Summary of a parse, useful for reporting and for regression tests that care
/// about what was skipped rather than only about what survived.
class ImportBookmarkStats {
  /// Bookmark items that parsed successfully.
  final int bookmarkCount;

  /// Folders that parsed successfully.
  final int folderCount;

  /// Separators that parsed successfully.
  final int separatorCount;

  /// Entries dropped because they had no URL, or one that could not be parsed
  /// or carried no scheme.
  final int skippedUrlCount;

  const ImportBookmarkStats({
    this.bookmarkCount = 0,
    this.folderCount = 0,
    this.separatorCount = 0,
    this.skippedUrlCount = 0,
  });

  ImportBookmarkStats copyWith({
    int? bookmarkCount,
    int? folderCount,
    int? separatorCount,
    int? skippedUrlCount,
  }) {
    return ImportBookmarkStats(
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      folderCount: folderCount ?? this.folderCount,
      separatorCount: separatorCount ?? this.separatorCount,
      skippedUrlCount: skippedUrlCount ?? this.skippedUrlCount,
    );
  }
}
