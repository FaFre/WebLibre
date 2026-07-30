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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_import_isolate.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bookmark-import-test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<File> writeFixture(String name, String contents) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsString(contents);
    return file;
  }

  group('parseBookmarkFile', () {
    test('should return an HTML tree across the isolate boundary', () async {
      final file = await writeFixture('bookmarks.html', '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3>Folder</H3>
          <DL><p>
            <DT><A HREF="https://example.com" ADD_DATE="1177375336">Example</A>
            <HR>
          </DL><p>
        </DL>
      ''');

      final tree = await parseBookmarkFile(
        path: file.path,
        format: BookmarkImportFormat.html,
        preserveRootFolders: false,
      );

      final folder =
          tree.sections[BookmarkRoot.menu.id]!.single as ImportBookmarkFolder;
      expect(folder.title, equals('Folder'));

      final item = folder.children[0] as ImportBookmarkItem;
      expect(item.url, equals(Uri.parse('https://example.com')));
      expect(
        item.dateAdded,
        equals(DateTime.fromMillisecondsSinceEpoch(1177375336 * 1000)),
      );
      expect(folder.children[1], isA<ImportBookmarkSeparator>());

      expect(tree.stats.bookmarkCount, equals(1));
      expect(tree.stats.separatorCount, equals(1));
    });

    test('should return a JSON tree across the isolate boundary', () async {
      final file = await writeFixture('bookmarks.json', '''
        {
          "children": [
            {
              "guid": "menu________",
              "type": "text/x-moz-place-container",
              "children": [
                {
                  "guid": "bookmark1___",
                  "title": "Example",
                  "type": "text/x-moz-place",
                  "uri": "https://example.com"
                }
              ]
            }
          ]
        }
      ''');

      final tree = await parseBookmarkFile(
        path: file.path,
        format: BookmarkImportFormat.json,
        preserveRootFolders: false,
      );

      final item =
          tree.sections[BookmarkRoot.menu.id]!.single as ImportBookmarkItem;
      expect(item.title, equals('Example'));
      expect(item.url, equals(Uri.parse('https://example.com')));
    });

    test('should propagate a missing file as an error', () {
      expect(
        parseBookmarkFile(
          path: '${tempDir.path}/does-not-exist.html',
          format: BookmarkImportFormat.html,
          preserveRootFolders: false,
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('should propagate a malformed JSON document as an error', () async {
      final file = await writeFixture('broken.json', '{not json');

      expect(
        parseBookmarkFile(
          path: file.path,
          format: BookmarkImportFormat.json,
          preserveRootFolders: false,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
