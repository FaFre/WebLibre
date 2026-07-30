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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_html_utils.dart';

@GenerateMocks([GeckoBookmarksService])
import 'bookmark_html_utils_test.mocks.dart';

/// Nodes the parser routed to [root], or an empty list if it produced no such
/// section.
List<ImportBookmarkNode> section(ImportBookmarkTree tree, BookmarkRoot root) =>
    tree.sections[root.id] ?? const [];

/// Mirrors what the native side reports back: bookmark items only, recursively.
int countItems(List<BookmarkImportNode> nodes) => nodes.fold(
  0,
  (total, node) =>
      total +
      (node.type == BookmarkNodeType.item ? 1 : 0) +
      countItems(node.children),
);

void main() {
  late MockGeckoBookmarksService mockService;
  late BookmarkHTMLUtils utils;

  setUp(() {
    mockService = MockGeckoBookmarksService();
    utils = BookmarkHTMLUtils(mockService);

    when(mockService.eraseEverything(any)).thenAnswer((_) async {});
    when(mockService.insertTree(any, any)).thenAnswer(
      (invocation) async => BookmarkInsertTreeResult(
        insertedItemCount: countItems(
          invocation.positionalArguments[1] as List<BookmarkImportNode>,
        ),
        failedNodeCount: 0,
      ),
    );
  });

  group('parseBookmarkHtml', () {
    test('should route everything under menu without root markers', () {
      const simpleHtml = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com">Example</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(simpleHtml, preserveRootFolders: false);

      expect(tree.sections.keys, equals([BookmarkRoot.menu.id]));
      expect(
        section(tree, BookmarkRoot.menu).single,
        isA<ImportBookmarkItem>()
            .having((i) => i.url, 'url', Uri.parse('https://example.com'))
            .having((i) => i.title, 'title', 'Example'),
      );
      expect(tree.stats.bookmarkCount, equals(1));
    });

    test('should decode HTML entities in titles', () {
      const htmlWithSpecialChars = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com">&lt;unescaped="test"&gt;</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(
        htmlWithSpecialChars,
        preserveRootFolders: false,
      );

      final item = section(tree, BookmarkRoot.menu).single;
      expect((item as ImportBookmarkItem).title, equals('<unescaped="test">'));
    });

    test('should preserve item timestamps as seconds since epoch', () {
      const htmlWithDates = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com" ADD_DATE="1177375336" LAST_MODIFIED="1177375423">Test</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(htmlWithDates, preserveRootFolders: false);

      final item =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkItem;
      expect(
        item.dateAdded,
        equals(DateTime.fromMillisecondsSinceEpoch(1177375336 * 1000)),
      );
      expect(
        item.lastModified,
        equals(DateTime.fromMillisecondsSinceEpoch(1177375423 * 1000)),
      );
    });

    test('should fall back to LAST_MODIFIED when ADD_DATE is absent', () {
      const html = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com" LAST_MODIFIED="1177375423">Test</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(html, preserveRootFolders: false);

      final item =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkItem;
      expect(item.dateAdded, equals(item.lastModified));
    });

    test('should preserve folder timestamps', () {
      const html = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3 ADD_DATE="1177375336" LAST_MODIFIED="1177375423">Dated</H3>
          <DL><p>
            <DT><A HREF="https://example.com">Child</A>
          </DL><p>
        </DL>
      ''';

      final tree = parseBookmarkHtml(html, preserveRootFolders: false);

      final folder =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkFolder;
      expect(
        folder.dateAdded,
        equals(DateTime.fromMillisecondsSinceEpoch(1177375336 * 1000)),
      );
      expect(
        folder.lastModified,
        equals(DateTime.fromMillisecondsSinceEpoch(1177375423 * 1000)),
      );
    });

    test('should nest folders and keep child order', () {
      const htmlWithFolders = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3>Parent Folder</H3>
          <DL><p>
            <DT><A HREF="https://example.com/1">Child 1</A>
            <DT><H3>Nested Folder</H3>
            <DL><p>
              <DT><A HREF="https://example.com/2">Grandchild</A>
            </DL><p>
          </DL><p>
        </DL>
      ''';

      final tree = parseBookmarkHtml(
        htmlWithFolders,
        preserveRootFolders: false,
      );

      final parent =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkFolder;
      expect(parent.title, equals('Parent Folder'));
      expect(parent.children, hasLength(2));

      expect(
        (parent.children[0] as ImportBookmarkItem).title,
        equals('Child 1'),
      );

      final nested = parent.children[1] as ImportBookmarkFolder;
      expect(nested.title, equals('Nested Folder'));
      expect(
        (nested.children.single as ImportBookmarkItem).title,
        equals('Grandchild'),
      );

      expect(tree.stats.bookmarkCount, equals(2));
      expect(tree.stats.folderCount, equals(2));
    });

    test('should keep empty folders', () {
      const html = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3>Empty</H3>
          <DL><p>
          </DL><p>
          <DT><A HREF="https://example.com">After</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(html, preserveRootFolders: false);
      final nodes = section(tree, BookmarkRoot.menu);

      expect(nodes, hasLength(2));
      expect(
        nodes[0],
        isA<ImportBookmarkFolder>()
            .having((f) => f.title, 'title', 'Empty')
            .having((f) => f.children, 'children', isEmpty),
      );
      expect(nodes[1], isA<ImportBookmarkItem>());
    });

    test('should route root-marked folders when preserving roots', () {
      const htmlWithRoots = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
          <DL><p>
            <DT><A HREF="https://example.com/toolbar">Toolbar Bookmark</A>
          </DL><p>
          <DT><H3 UNFILED_BOOKMARKS_FOLDER="true">Unsorted Bookmarks</H3>
          <DL><p>
            <DT><A HREF="https://example.com/unfiled">Unfiled Bookmark</A>
          </DL><p>
          <DT><A HREF="https://example.com/loose">Loose</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(htmlWithRoots, preserveRootFolders: true);

      expect(
        (section(tree, BookmarkRoot.toolbar).single as ImportBookmarkItem)
            .title,
        equals('Toolbar Bookmark'),
      );
      expect(
        (section(tree, BookmarkRoot.unfiled).single as ImportBookmarkItem)
            .title,
        equals('Unfiled Bookmark'),
      );
      // The marked folders themselves are not recreated, only their contents.
      expect(
        (section(tree, BookmarkRoot.menu).single as ImportBookmarkItem).title,
        equals('Loose'),
      );
    });

    test('should treat root markers as plain folders when not preserving', () {
      const htmlWithToolbar = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
          <DL><p>
            <DT><A HREF="https://example.com">Toolbar Bookmark</A>
          </DL><p>
        </DL>
      ''';

      final tree = parseBookmarkHtml(
        htmlWithToolbar,
        preserveRootFolders: false,
      );

      expect(tree.sections.keys, equals([BookmarkRoot.menu.id]));
      expect(
        (section(tree, BookmarkRoot.menu).single as ImportBookmarkFolder).title,
        equals('Bookmarks Toolbar'),
      );
    });

    test('should keep separators between bookmarks', () {
      const htmlWithSeparator = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com/1">Bookmark 1</A>
          <HR>
          <DT><A HREF="https://example.com/2">Bookmark 2</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(
        htmlWithSeparator,
        preserveRootFolders: false,
      );
      final nodes = section(tree, BookmarkRoot.menu);

      expect(nodes, hasLength(3));
      expect(nodes[1], isA<ImportBookmarkSeparator>());
      expect(tree.stats.bookmarkCount, equals(2));
      expect(tree.stats.separatorCount, equals(1));
    });

    test('should skip bookmarks without URLs', () {
      const htmlWithoutUrl = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A>No URL</A>
          <DT><A HREF="https://example.com">Valid</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(
        htmlWithoutUrl,
        preserveRootFolders: false,
      );

      expect(section(tree, BookmarkRoot.menu), hasLength(1));
      expect(tree.stats.skippedUrlCount, equals(1));
    });

    test('should skip bookmarks with schemeless URLs', () {
      const htmlWithInvalidUrl = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="not a url">Invalid</A>
          <DT><A HREF="https://example.com">Valid</A>
        </DL>
      ''';

      final tree = parseBookmarkHtml(
        htmlWithInvalidUrl,
        preserveRootFolders: false,
      );

      expect(section(tree, BookmarkRoot.menu), hasLength(1));
      expect(tree.stats.skippedUrlCount, equals(1));
    });

    test('should produce no sections for an empty document', () {
      const emptyHtml = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
        </DL>
      ''';

      final tree = parseBookmarkHtml(emptyHtml, preserveRootFolders: true);

      expect(tree.isEmpty, isTrue);
      expect(tree.stats.bookmarkCount, equals(0));
    });

    test('should keep headings that never open a list', () {
      // Firefox writes empty folders without a `<DL>`; the folder must still be
      // emitted, and the heading after it must not inherit its metadata.
      const html = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3>First</H3>
          <DT><H3 ADD_DATE="1177375336">Second</H3>
          <DL><p>
            <DT><A HREF="https://example.com">Child</A>
          </DL><p>
        </DL>
      ''';

      final tree = parseBookmarkHtml(html, preserveRootFolders: false);
      final nodes = section(tree, BookmarkRoot.menu);

      expect(nodes, hasLength(2));
      expect((nodes[0] as ImportBookmarkFolder).title, equals('First'));
      expect((nodes[0] as ImportBookmarkFolder).dateAdded, isNull);

      final second = nodes[1] as ImportBookmarkFolder;
      expect(second.title, equals('Second'));
      expect(
        second.dateAdded,
        equals(DateTime.fromMillisecondsSinceEpoch(1177375336 * 1000)),
      );
      expect(second.children, hasLength(1));
    });

    test('should handle deeply nested folders', () {
      const depth = 60;
      final buffer = StringBuffer(
        '<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<DL><p>',
      );
      for (var i = 0; i < depth; i++) {
        buffer.write('<DT><H3>Level $i</H3>\n<DL><p>');
      }
      buffer.write('<DT><A HREF="https://example.com">Deep</A>');
      for (var i = 0; i < depth; i++) {
        buffer.write('</DL><p>');
      }
      buffer.write('</DL>');

      final tree = parseBookmarkHtml(
        buffer.toString(),
        preserveRootFolders: false,
      );

      var node = section(tree, BookmarkRoot.menu).single;
      for (var i = 0; i < depth; i++) {
        node = (node as ImportBookmarkFolder).children.single;
      }
      expect(node, isA<ImportBookmarkItem>());
      expect(tree.stats.folderCount, equals(depth));
    });

    test('should parse the corrupt fixture without throwing', () async {
      final htmlString = await File(
        'test/utils/bookmarks/fixtures/bookmarks.corrupt.html',
      ).readAsString();

      final tree = parseBookmarkHtml(htmlString, preserveRootFolders: true);

      expect(tree.stats.bookmarkCount, greaterThan(0));
    });

    test('should parse the pre-places fixture', () async {
      final htmlString = await File(
        'test/utils/bookmarks/fixtures/bookmarks.preplaces.html',
      ).readAsString();

      final tree = parseBookmarkHtml(htmlString, preserveRootFolders: true);

      expect(tree.stats.bookmarkCount, greaterThan(0));
    });

    test('should parse the single frame fixture', () async {
      final htmlString = await File(
        'test/utils/bookmarks/fixtures/bookmarks_html_singleframe.html',
      ).readAsString();

      final tree = parseBookmarkHtml(htmlString, preserveRootFolders: false);

      expect(tree.stats.bookmarkCount, greaterThan(0));
    });
  });

  group('BookmarkHTMLUtils - Import', () {
    test('should insert each section with a single bulk call', () async {
      const htmlWithFolders = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3>Parent Folder</H3>
          <DL><p>
            <DT><A HREF="https://example.com/1">Child 1</A>
            <DT><H3>Nested Folder</H3>
            <DL><p>
              <DT><A HREF="https://example.com/2">Grandchild</A>
            </DL><p>
          </DL><p>
        </DL>
      ''';

      final count = await utils.importFromHTML(htmlWithFolders);

      expect(count, equals(2));
      verify(mockService.insertTree(BookmarkRoot.menu.id, any)).called(1);
      verifyNever(mockService.addItem(any, any, any, any));
      verifyNever(mockService.addFolder(any, any, any));
    });

    test(
      'should erase every root except the tree root when replacing',
      () async {
        final htmlString = await File(
          'test/utils/bookmarks/fixtures/bookmarks.preplaces.html',
        ).readAsString();

        final count = await utils.importFromHTML(htmlString, replace: true);

        expect(count, greaterThan(0));
        for (final root in BookmarkRoot.values) {
          if (root == BookmarkRoot.root) {
            verifyNever(mockService.eraseEverything(root));
          } else {
            verify(mockService.eraseEverything(root)).called(1);
          }
        }
      },
    );

    test('should not erase when replace is false', () async {
      const simpleHtml = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com">Example</A>
        </DL>
      ''';

      await utils.importFromHTML(simpleHtml);

      verifyNever(mockService.eraseEverything(any));
    });

    test('should route root-marked sections to their Places roots', () async {
      const htmlWithToolbar = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
          <DL><p>
            <DT><A HREF="https://example.com">Toolbar Bookmark</A>
          </DL><p>
        </DL>
      ''';

      await utils.importFromHTML(htmlWithToolbar, replace: true);

      verify(mockService.insertTree(BookmarkRoot.toolbar.id, any)).called(1);
    });

    test('should insert nothing for an empty document', () async {
      const emptyHtml = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <H1>Bookmarks</H1>
        <DL><p>
        </DL>
      ''';

      final count = await utils.importFromHTML(emptyHtml, replace: true);

      expect(count, equals(0));
      verifyNever(mockService.insertTree(any, any));
      // Nothing parsed means nothing to replace, so existing bookmarks survive.
      verifyNever(mockService.eraseEverything(any));
    });
  });

  group('BookmarkHTMLUtils - Export', () {
    test('should export bookmark tree to HTML', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'Test Bookmark',
            url: 'https://example.com',
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      expect(html, contains('<!DOCTYPE NETSCAPE-Bookmark-file-1>'));
      expect(html, contains('<H1>Bookmarks Menu</H1>'));
      expect(html, contains('https://example.com'));
      expect(html, contains('Test Bookmark'));
    });

    test('should escape HTML entities in export', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: '<unescaped="test">',
            url: 'https://example.com',
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      // Should escape special characters
      expect(html, contains('&lt;unescaped=&quot;test&quot;&gt;'));
      expect(html, isNot(contains('<unescaped="test">')));
    });

    test('should include date attributes in export', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'Test',
            url: 'https://example.com',
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      expect(html, contains('ADD_DATE='));
      expect(html, contains('LAST_MODIFIED='));
    });

    test('should export toolbar with title as H1 when root', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.toolbar.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks Toolbar',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.toolbar);

      // When toolbar is the root, it becomes H1 without special attributes
      expect(html, contains('<H1>Bookmarks Toolbar</H1>'));
      expect(html, isNot(contains('PERSONAL_TOOLBAR_FOLDER')));
    });

    test('should export unfiled with title as H1 when root', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.unfiled.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Unsorted Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.unfiled);

      // When unfiled is the root, it becomes H1 without special attributes
      expect(html, contains('<H1>Unsorted Bookmarks</H1>'));
      expect(html, isNot(contains('UNFILED_BOOKMARKS_FOLDER')));
    });

    test('should export separators', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'First',
            url: 'https://example.com/1',
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.item,
          ),
          BookmarkNode(
            guid: 'separator___',
            parentGuid: BookmarkRoot.menu.id,
            position: 1,
            title: null,
            url: null,
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.separator,
          ),
          BookmarkNode(
            guid: 'bookmark2___',
            parentGuid: BookmarkRoot.menu.id,
            position: 2,
            title: 'Second',
            url: 'https://example.com/2',
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      expect(html, contains('<HR>'));
    });

    test('should skip bookmarks with invalid URLs during export', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'invalid1____',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'Invalid',
            url: '', // Empty URL
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.item,
          ),
          BookmarkNode(
            guid: 'valid1______',
            parentGuid: BookmarkRoot.menu.id,
            position: 1,
            title: 'Valid',
            url: 'https://example.com',
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      // Should only contain the valid bookmark
      expect(html, contains('https://example.com'));
      expect(html, contains('Valid'));
      expect(html, isNot(contains('Invalid')));
    });

    test('should export nested folders', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'folder1_____',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'Parent Folder',
            url: null,
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.folder,
            children: [
              BookmarkNode(
                guid: 'bookmark1___',
                parentGuid: 'folder1_____',
                position: 0,
                title: 'Nested Bookmark',
                url: 'https://example.com',
                dateAdded: 0,
                lastModified: 0,
                type: BookmarkNodeType.item,
              ),
            ],
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      expect(html, contains('Parent Folder'));
      expect(html, contains('Nested Bookmark'));
      expect(html, contains('<H3'));
      expect(html, contains('</H3>'));
    });

    test('should throw when tree cannot be fetched', () {
      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => null);

      expect(
        () => utils.exportToHTML(root: BookmarkRoot.menu),
        throwsA(isA<Exception>()),
      );
    });

    test('should include proper HTML header', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      expect(html, contains('<!DOCTYPE NETSCAPE-Bookmark-file-1>'));
      expect(html, contains('<META HTTP-EQUIV="Content-Type"'));
      expect(html, contains('<TITLE>Bookmarks</TITLE>'));
      expect(html, contains('Content-Security-Policy'));
    });

    test('should properly indent HTML structure', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks',
        url: null,
        dateAdded: 0,
        lastModified: 0,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'Test',
            url: 'https://example.com',
            dateAdded: 0,
            lastModified: 0,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final html = await utils.exportToHTML(root: BookmarkRoot.menu);

      // Should contain indentation
      expect(html, contains('    <DT>'));
      expect(html, contains('<DL><p>'));
      expect(html, contains('</DL>'));
    });
  });

  group('BookmarkHTMLUtils - Import/Export Round-Trip', () {
    test('should preserve data through export and re-import', () async {
      final mockNode = BookmarkNode(
        guid: BookmarkRoot.menu.id,
        parentGuid: BookmarkRoot.root.id,
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'folder1_____',
            parentGuid: BookmarkRoot.menu.id,
            position: 0,
            title: 'Test Folder',
            url: null,
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.folder,
            children: [
              BookmarkNode(
                guid: 'bookmark1___',
                parentGuid: 'folder1_____',
                position: 0,
                title: 'Test Bookmark',
                url: 'https://example.com',
                dateAdded: 1361551979350273,
                lastModified: 1361551979376699,
                type: BookmarkNodeType.item,
              ),
            ],
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      // Export
      final html = await utils.exportToHTML(root: BookmarkRoot.menu);
      expect(html, isNotEmpty);

      // Re-import
      final count = await utils.importFromHTML(html, replace: true);

      expect(count, equals(1)); // One bookmark imported
      verify(mockService.eraseEverything(BookmarkRoot.menu)).called(1);

      final inserted =
          verify(
                mockService.insertTree(BookmarkRoot.menu.id, captureAny),
              ).captured.single
              as List<BookmarkImportNode>;

      final folder = inserted.single;
      expect(folder.type, equals(BookmarkNodeType.folder));
      expect(folder.title, equals('Test Folder'));

      final bookmark = folder.children.single;
      expect(bookmark.title, equals('Test Bookmark'));
      expect(bookmark.url, equals('https://example.com'));
    });
  });
}
