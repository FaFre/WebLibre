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
import 'dart:io';
import 'dart:isolate';

import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_html_utils.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_json_utils.dart';

/// The bookmark file formats WebLibre can read.
enum BookmarkImportFormat { html, json }

/// Reads and parses the bookmark file at [path] in a background isolate.
///
/// Both the file read and the parse happen off the UI isolate, so a large
/// export — the reported problem case is around 25k bookmarks — does not block
/// frames. Only the resulting [ImportBookmarkTree] crosses back, which is far
/// smaller than the HTML DOM or decoded JSON it was built from.
///
/// The file is read inside the isolate rather than handed over as a string, so
/// the UI isolate never holds the raw document in memory.
Future<ImportBookmarkTree> parseBookmarkFile({
  required String path,
  required BookmarkImportFormat format,
  required bool preserveRootFolders,
}) {
  return Isolate.run(
    () => _parseBookmarkFile(path, format, preserveRootFolders),
    debugName: 'bookmark-import-parse',
  );
}

/// Runs inside the spawned isolate; must stay free of platform channels and of
/// anything tied to the UI isolate's state.
ImportBookmarkTree _parseBookmarkFile(
  String path,
  BookmarkImportFormat format,
  bool preserveRootFolders,
) {
  final content = File(path).readAsStringSync();

  return switch (format) {
    BookmarkImportFormat.html => parseBookmarkHtml(
      content,
      preserveRootFolders: preserveRootFolders,
    ),
    BookmarkImportFormat.json => parseBookmarkJson(content),
  };
}
