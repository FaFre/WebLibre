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

// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_json_utils.dart';

@GenerateMocks([GeckoBookmarksService])
import 'bookmark_json_utils_test.mocks.dart';

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
  late BookmarkJSONUtils utils;

  setUp(() {
    mockService = MockGeckoBookmarksService();
    utils = BookmarkJSONUtils(mockService);

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

  group('parseBookmarkJson', () {
    test('should reject a document that is not an object', () {
      expect(() => parseBookmarkJson('[]'), throwsA(isA<FormatException>()));
    });

    test('should produce nothing for empty or missing children', () {
      expect(parseBookmarkJson('{"children": []}').isEmpty, isTrue);
      expect(parseBookmarkJson('{"guid": "root________"}').isEmpty, isTrue);
    });

    test('should filter out the tags folder', () {
      final jsonData = {
        'children': [
          {
            'guid': 'tags________',
            'root': 'tagsFolder',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'tag1________',
                'title': 'Tagged',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com/tagged',
              },
            ],
          },
          {
            'guid': 'menu________',
            'root': 'bookmarksMenuFolder',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'Kept',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      expect(tree.sections.keys, equals([BookmarkRoot.menu.id]));
      expect(tree.stats.bookmarkCount, equals(1));
    });

    test('should ignore top-level nodes that are not Places roots', () {
      final jsonData = {
        'children': [
          {
            'guid': 'notaroot____',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'Orphan',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
              },
            ],
          },
        ],
      };

      expect(parseBookmarkJson(jsonEncode(jsonData)).isEmpty, isTrue);
    });

    test('should accept both the uri and url fields', () {
      for (final field in ['uri', 'url']) {
        final jsonData = {
          'children': [
            {
              'guid': 'menu________',
              'type': 'text/x-moz-place-container',
              'children': [
                {
                  'guid': 'bookmark1___',
                  'title': 'Test Bookmark',
                  'type': 'text/x-moz-place',
                  field: 'https://example.com',
                },
              ],
            },
          ],
        };

        final tree = parseBookmarkJson(jsonEncode(jsonData));

        expect(
          section(tree, BookmarkRoot.menu).single,
          isA<ImportBookmarkItem>()
              .having((i) => i.url, 'url', Uri.parse('https://example.com'))
              .having((i) => i.title, 'title', 'Test Bookmark'),
          reason: 'field "$field" should be read as the bookmark URL',
        );
      }
    });

    test('should skip bookmarks with invalid URLs', () {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'invalid1____',
                'title': 'Invalid URL',
                'type': 'text/x-moz-place',
                'uri': 'not a valid url',
              },
              {
                'guid': 'valid1______',
                'title': 'Valid URL',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      expect(section(tree, BookmarkRoot.menu), hasLength(1));
      expect(tree.stats.skippedUrlCount, equals(1));
    });

    test('should nest folders recursively', () {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'folder1_____',
                'title': 'Folder 1',
                'type': 'text/x-moz-place-container',
                'children': [
                  {
                    'guid': 'bookmark1___',
                    'title': 'Nested Bookmark',
                    'type': 'text/x-moz-place',
                    'uri': 'https://example.com',
                  },
                ],
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      final folder =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkFolder;
      expect(folder.title, equals('Folder 1'));
      expect(
        (folder.children.single as ImportBookmarkItem).title,
        equals('Nested Bookmark'),
      );
      expect(tree.stats.bookmarkCount, equals(1));
      expect(tree.stats.folderCount, equals(1));
    });

    test('should keep separators', () {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'First Bookmark',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com/1',
              },
              {'guid': 'separator___', 'type': 'text/x-moz-place-separator'},
              {
                'guid': 'bookmark2___',
                'title': 'Second Bookmark',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com/2',
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));
      final nodes = section(tree, BookmarkRoot.menu);

      expect(nodes, hasLength(3));
      expect(nodes[1], isA<ImportBookmarkSeparator>());
      expect(tree.stats.bookmarkCount, equals(2));
      expect(tree.stats.separatorCount, equals(1));
    });

    test('should read microsecond timestamps from Firefox backups', () {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'Dated',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
                'dateAdded': 1361551979350273,
                'lastModified': 1361551979376699,
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      final item =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkItem;
      expect(
        item.dateAdded,
        equals(DateTime.fromMillisecondsSinceEpoch(1361551979350)),
      );
      expect(
        item.lastModified,
        equals(DateTime.fromMillisecondsSinceEpoch(1361551979376)),
      );
    });

    test('should read millisecond timestamps from WebLibre exports', () {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'Dated',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
                'dateAdded': 1361551979350,
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      final item =
          section(tree, BookmarkRoot.menu).single as ImportBookmarkItem;
      expect(
        item.dateAdded,
        equals(DateTime.fromMillisecondsSinceEpoch(1361551979350)),
      );
      expect(item.lastModified, isNull);
    });

    test('should fixup place: queries with folder shortcuts', () {
      final jsonData = {
        'children': [
          {
            'guid': 'unfiled_____',
            'type': 'text/x-moz-place-container',
            'id': '5',
            'children': [
              {
                'guid': 'folder1_____',
                'title': 'Test Folder',
                'type': 'text/x-moz-place-container',
                'id': '6',
                'children': [],
              },
              {
                'guid': 'shortcut1___',
                'title': 'Folder Shortcut',
                'type': 'text/x-moz-place',
                'uri': 'place:folder=6',
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      final shortcut =
          section(tree, BookmarkRoot.unfiled)[1] as ImportBookmarkItem;
      expect(shortcut.url.toString(), contains('parent=folder1_____'));
    });

    test('should handle invalid folder references in place: queries', () {
      final jsonData = {
        'children': [
          {
            'guid': 'unfiled_____',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'shortcut1___',
                'title': 'Invalid Folder Shortcut',
                'type': 'text/x-moz-place',
                'uri': 'place:folder=999999',
              },
            ],
          },
        ],
      };

      final tree = parseBookmarkJson(jsonEncode(jsonData));

      final url =
          (section(tree, BookmarkRoot.unfiled).single as ImportBookmarkItem).url
              .toString();
      expect(url, contains('invalidOldParentId=999999'));
      expect(url, contains('excludeItems=1'));
    });

    test('should parse the bookmarks fixture', () async {
      final jsonString = await File(
        'test/utils/bookmarks/fixtures/bookmarks.json',
      ).readAsString();

      final tree = parseBookmarkJson(jsonString);

      expect(tree.stats.bookmarkCount, greaterThan(0));
    });
  });

  group('BookmarkJSONUtils - Import', () {
    test('should reject invalid JSON format', () {
      expect(() => utils.importFromJSON('[]'), throwsA(isA<Exception>()));
    });

    test('should return 0 without touching storage for empty input', () async {
      expect(await utils.importFromJSON('{"children": []}'), equals(0));
      expect(await utils.importFromJSON('{"guid": "root________"}'), equals(0));

      verifyNever(mockService.insertTree(any, any));
      verifyNever(mockService.eraseEverything(any));
    });

    test('should insert each root section with a single bulk call', () async {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'folder1_____',
                'title': 'Folder 1',
                'type': 'text/x-moz-place-container',
                'children': [
                  {
                    'guid': 'bookmark1___',
                    'title': 'Nested Bookmark',
                    'type': 'text/x-moz-place',
                    'uri': 'https://example.com',
                  },
                ],
              },
            ],
          },
          {
            'guid': 'unfiled_____',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark2___',
                'title': 'Unfiled Bookmark',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com/2',
              },
            ],
          },
        ],
      };

      final count = await utils.importFromJSON(jsonEncode(jsonData));

      expect(count, equals(2));
      verify(mockService.insertTree(BookmarkRoot.menu.id, any)).called(1);
      verify(mockService.insertTree(BookmarkRoot.unfiled.id, any)).called(1);
      verifyNever(mockService.addItem(any, any, any, any));
      verifyNever(mockService.addFolder(any, any, any));
    });

    test(
      'should erase every root except the tree root when replacing',
      () async {
        final jsonString = await File(
          'test/utils/bookmarks/fixtures/bookmarks.json',
        ).readAsString();

        final count = await utils.importFromJSON(jsonString, replace: true);

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
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'Test Bookmark',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
              },
            ],
          },
        ],
      };

      await utils.importFromJSON(jsonEncode(jsonData));

      verifyNever(mockService.eraseEverything(any));
    });

    test('should rethrow storage failures', () {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [
              {
                'guid': 'bookmark1___',
                'title': 'Test Bookmark',
                'type': 'text/x-moz-place',
                'uri': 'https://example.com',
              },
            ],
          },
        ],
      };

      when(
        mockService.insertTree(any, any),
      ).thenThrow(Exception('Database error'));

      expect(
        () => utils.importFromJSON(jsonEncode(jsonData)),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('BookmarkJSONUtils - Export', () {
    test('should export bookmark tree to JSON', () async {
      final mockNode = BookmarkNode(
        guid: 'menu________',
        parentGuid: 'root________',
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: 'menu________',
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

      final result = await utils.exportToJson(root: BookmarkRoot.menu);

      expect(result, isNotNull);
      expect(result!['guid'], equals('menu________'));
      expect(result['title'], equals('Bookmarks Menu'));
      expect(result['type'], equals('text/x-moz-place-container'));
      expect(result['root'], equals('bookmarksMenuFolder'));
      expect(result['children'], isA<List>());
      expect((result['children'] as List).length, equals(1));

      final child = (result['children'] as List)[0] as Map<String, dynamic>;
      expect(child['guid'], equals('bookmark1___'));
      expect(child['title'], equals('Test Bookmark'));
      expect(child['url'], equals('https://example.com'));
      expect(child['type'], equals('text/x-moz-place'));
    });

    test('should skip bookmarks with invalid URLs during export', () async {
      final mockNode = BookmarkNode(
        guid: 'menu________',
        parentGuid: 'root________',
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'invalid1____',
            parentGuid: 'menu________',
            position: 0,
            title: 'Invalid Bookmark',
            url: '', // Empty URL
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.item,
          ),
          BookmarkNode(
            guid: 'valid1______',
            parentGuid: 'menu________',
            position: 1,
            title: 'Valid Bookmark',
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

      final result = await utils.exportToJson(root: BookmarkRoot.menu);

      expect(result, isNotNull);
      final children = result!['children'] as List;
      // Only the valid bookmark should be exported
      expect(children.length, equals(1));
      expect(children[0]['guid'], equals('valid1______'));
    });

    test('should handle separators in export', () async {
      final mockNode = BookmarkNode(
        guid: 'menu________',
        parentGuid: 'root________',
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'separator___',
            parentGuid: 'menu________',
            position: 0,
            title: 'should be ignored',
            url: null,
            dateAdded: 1361551979380988,
            lastModified: 1361551979380988,
            type: BookmarkNodeType.separator,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final result = await utils.exportToJson(root: BookmarkRoot.menu);

      expect(result, isNotNull);
      final children = result!['children'] as List;
      expect(children.length, equals(1));

      final separator = children[0];
      expect(separator['type'], equals('text/x-moz-place-separator'));
      expect(separator['title'], equals('')); // Title should be empty
    });

    test('should assign correct root names', () async {
      final testCases = [
        (BookmarkRoot.menu, 'bookmarksMenuFolder'),
        (BookmarkRoot.toolbar, 'toolbarFolder'),
        (BookmarkRoot.unfiled, 'unfiledBookmarksFolder'),
        (BookmarkRoot.mobile, 'mobileFolder'),
      ];

      for (final testCase in testCases) {
        final mockNode = BookmarkNode(
          guid: testCase.$1.id,
          parentGuid: 'root________',
          position: 0,
          title: 'Test Root',
          url: null,
          dateAdded: 1361551978957783,
          lastModified: 1361551979382837,
          type: BookmarkNodeType.folder,
          children: [],
        );

        when(
          mockService.getTree(testCase.$1.id, recursive: true),
        ).thenAnswer((_) async => mockNode);

        final result = await utils.exportToJson(root: testCase.$1);

        expect(result, isNotNull);
        expect(result!['root'], equals(testCase.$2));
      }
    });

    test('should preserve correct index values for children', () async {
      final mockNode = BookmarkNode(
        guid: 'menu________',
        parentGuid: 'root________',
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: 'menu________',
            position: 0,
            title: 'First',
            url: 'https://example.com/1',
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.item,
          ),
          BookmarkNode(
            guid: 'bookmark2___',
            parentGuid: 'menu________',
            position: 1,
            title: 'Second',
            url: 'https://example.com/2',
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.item,
          ),
          BookmarkNode(
            guid: 'bookmark3___',
            parentGuid: 'menu________',
            position: 2,
            title: 'Third',
            url: 'https://example.com/3',
            dateAdded: 1361551979350273,
            lastModified: 1361551979376699,
            type: BookmarkNodeType.item,
          ),
        ],
      );

      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => mockNode);

      final result = await utils.exportToJson(root: BookmarkRoot.menu);

      expect(result, isNotNull);
      final children = result!['children'] as List;
      expect(children.length, equals(3));
      expect(children[0]['index'], equals(0));
      expect(children[1]['index'], equals(1));
      expect(children[2]['index'], equals(2));
    });

    test('should throw when tree cannot be fetched', () {
      when(
        mockService.getTree(any, recursive: true),
      ).thenAnswer((_) async => null);

      expect(
        () => utils.exportToJson(root: BookmarkRoot.menu),
        throwsA(isA<Exception>()),
      );
    });

    test('should include typeCode in export', () async {
      final mockNode = BookmarkNode(
        guid: 'menu________',
        parentGuid: 'root________',
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'bookmark1___',
            parentGuid: 'menu________',
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

      final result = await utils.exportToJson(root: BookmarkRoot.menu);

      expect(result, isNotNull);
      expect(result!['typeCode'], equals(BookmarkNodeType.folder.index + 1));

      final child = (result['children'] as List)[0] as Map<String, dynamic>;
      expect(child['typeCode'], equals(BookmarkNodeType.item.index + 1));
    });
  });

  group('BookmarkJSONUtils - Import/Export Round-Trip', () {
    test('should preserve data through export and re-import', () async {
      // Setup initial data
      final mockNode = BookmarkNode(
        guid: 'menu________',
        parentGuid: 'root________',
        position: 0,
        title: 'Bookmarks Menu',
        url: null,
        dateAdded: 1361551978957783,
        lastModified: 1361551979382837,
        type: BookmarkNodeType.folder,
        children: [
          BookmarkNode(
            guid: 'folder1_____',
            parentGuid: 'menu________',
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
      final exported = await utils.exportToJson(root: BookmarkRoot.menu);
      expect(exported, isNotNull);

      // Re-import
      final jsonString = jsonEncode({
        'children': [exported],
      });
      final count = await utils.importFromJSON(jsonString, replace: true);

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
