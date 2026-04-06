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

// ignore_for_file: avoid_redundant_argument_values

import 'dart:io';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_html_utils.dart';

@GenerateMocks([GeckoBookmarksService])
import 'bookmark_html_utils_test.mocks.dart';

void main() {
  late MockGeckoBookmarksService mockService;
  late BookmarkHTMLUtils utils;

  setUp(() {
    mockService = MockGeckoBookmarksService();
    utils = BookmarkHTMLUtils(mockService);
  });

  group('BookmarkHTMLUtils - Import', () {
    test('should handle corrupt HTML file with malformed URIs', () async {
      // Load the corrupt fixture
      final fixtureFile = File(
        'test/utils/bookmarks/fixtures/bookmarks.corrupt.html',
      );
      final htmlString = await fixtureFile.readAsString();

      // Mock the service calls
      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'generated_guid');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'generated_guid');

      final count = await utils.importFromHTML(htmlString, replace: true);

      // Should import valid bookmarks and skip the corrupt one
      expect(count, greaterThan(0));
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });

    test('should import from valid HTML file', () async {
      final fixtureFile = File(
        'test/utils/bookmarks/fixtures/bookmarks.preplaces.html',
      );
      final htmlString = await fixtureFile.readAsString();

      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder_guid');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark_guid');

      final count = await utils.importFromHTML(htmlString, replace: true);

      expect(count, greaterThan(0));
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
      // Verify some bookmarks were added
      verify(mockService.addItem(any, any, any, any)).called(greaterThan(0));
    });

    test('should handle empty HTML', () async {
      const emptyHtml = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
        </DL>
      ''';

      when(mockService.eraseEverything(any)).thenAnswer((_) async {});

      final count = await utils.importFromHTML(emptyHtml, replace: true);

      expect(count, equals(0));
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });

    test('should not erase when replace is false', () async {
      const simpleHtml = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com">Example</A>
        </DL>
      ''';

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      await utils.importFromHTML(simpleHtml);

      verifyNever(mockService.eraseEverything(any));
    });

    test('should handle bookmarks with special characters in title', () async {
      const htmlWithSpecialChars = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com">&lt;unescaped="test"&gt;</A>
        </DL>
      ''';

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      final count = await utils.importFromHTML(htmlWithSpecialChars);

      expect(count, equals(1));
      final captured = verify(
        mockService.addItem(any, any, captureAny, any),
      ).captured;
      // Should properly decode HTML entities
      expect(captured[0], equals('<unescaped="test">'));
    });

    test('should import bookmarks with timestamps', () async {
      const htmlWithDates = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="https://example.com" ADD_DATE="1177375336" LAST_MODIFIED="1177375423">Test</A>
        </DL>
      ''';

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      final count = await utils.importFromHTML(htmlWithDates);

      expect(count, equals(1));
    });

    test('should handle folder hierarchy', () async {
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

      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder_guid');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark_guid');

      final count = await utils.importFromHTML(htmlWithFolders);

      expect(count, equals(2)); // 2 bookmarks
      verify(mockService.addFolder(any, any, any)).called(2); // 2 folders
    });

    test('should recognize toolbar folder', () async {
      const htmlWithToolbar = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
          <DL><p>
            <DT><A HREF="https://example.com">Toolbar Bookmark</A>
          </DL><p>
        </DL>
      ''';

      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      await utils.importFromHTML(htmlWithToolbar, replace: true);

      // When replace is true, should add to toolbar
      final captured = verify(
        mockService.addItem(captureAny, any, any, any),
      ).captured;
      expect(captured[0], equals(BookmarkRoot.toolbar.id));
    });

    test('should recognize unfiled folder', () async {
      const htmlWithUnfiled = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><H3 UNFILED_BOOKMARKS_FOLDER="true">Unsorted Bookmarks</H3>
          <DL><p>
            <DT><A HREF="https://example.com">Unfiled Bookmark</A>
          </DL><p>
        </DL>
      ''';

      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      await utils.importFromHTML(htmlWithUnfiled, replace: true);

      final captured = verify(
        mockService.addItem(captureAny, any, any, any),
      ).captured;
      expect(captured[0], equals(BookmarkRoot.unfiled.id));
    });

    test('should handle separators', () async {
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

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      final count = await utils.importFromHTML(htmlWithSeparator);

      // Should import 2 bookmarks (separator is not supported by Android API)
      expect(count, equals(2));
    });

    test('should skip bookmarks without URLs', () async {
      const htmlWithoutUrl = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A>No URL</A>
          <DT><A HREF="https://example.com">Valid</A>
        </DL>
      ''';

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      final count = await utils.importFromHTML(htmlWithoutUrl);

      expect(count, equals(1)); // Only the valid one
    });

    test('should skip bookmarks with invalid URLs', () async {
      const htmlWithInvalidUrl = '''
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
          <DT><A HREF="not a url">Invalid</A>
          <DT><A HREF="https://example.com">Valid</A>
        </DL>
      ''';

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'guid');

      final count = await utils.importFromHTML(htmlWithInvalidUrl);

      expect(count, equals(1));
    });

    test('should handle single frame HTML', () async {
      final fixtureFile = File(
        'test/utils/bookmarks/fixtures/bookmarks_html_singleframe.html',
      );
      final htmlString = await fixtureFile.readAsString();

      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder_guid');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark_guid');

      final count = await utils.importFromHTML(htmlString);

      expect(count, greaterThan(0));
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
      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder1_____');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark1___');

      final count = await utils.importFromHTML(html, replace: true);

      expect(count, equals(1)); // One bookmark imported
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });
  });
}
