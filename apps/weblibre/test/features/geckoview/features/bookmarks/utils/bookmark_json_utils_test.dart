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

// ignore_for_file: avoid_redundant_argument_values, avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_json_utils.dart';

@GenerateMocks([GeckoBookmarksService])
import 'bookmark_json_utils_test.mocks.dart';

void main() {
  late MockGeckoBookmarksService mockService;
  late BookmarkJSONUtils utils;

  setUp(() {
    mockService = MockGeckoBookmarksService();
    utils = BookmarkJSONUtils(mockService);
  });

  group('BookmarkJSONUtils - Import', () {
    test('should reject invalid JSON format', () {
      const invalidJson = '[]';

      expect(
        () => utils.importFromJSON(invalidJson),
        throwsA(isA<Exception>()),
      );
    });

    test('should return 0 for empty children', () async {
      const emptyJson = '{"children": []}';

      final count = await utils.importFromJSON(emptyJson);

      expect(count, equals(0));
    });

    test('should return 0 when children is null', () async {
      const noChildrenJson = '{"guid": "root________"}';

      final count = await utils.importFromJSON(noChildrenJson);

      expect(count, equals(0));
    });

    test('should filter out tags folder during import', () async {
      final jsonData = {
        'children': [
          {
            'guid': 'tags________',
            'root': 'tagsFolder',
            'type': 'text/x-moz-place-container',
            'children': [],
          },
          {
            'guid': 'menu________',
            'root': 'bookmarksMenuFolder',
            'type': 'text/x-moz-place-container',
            'children': [],
          },
        ],
      };

      when(mockService.eraseEverything(any)).thenAnswer((_) async {});

      final count = await utils.importFromJSON(
        jsonEncode(jsonData),
        replace: true,
      );

      // Only the menu folder should be processed, tags should be filtered
      expect(count, equals(0)); // No bookmarks, just folders
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });

    test('should erase everything when replace is true', () async {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [],
          },
        ],
      };

      when(mockService.eraseEverything(any)).thenAnswer((_) async {});

      await utils.importFromJSON(jsonEncode(jsonData), replace: true);

      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });

    test('should not erase when replace is false', () async {
      final jsonData = {
        'children': [
          {
            'guid': 'menu________',
            'type': 'text/x-moz-place-container',
            'children': [],
          },
        ],
      };

      await utils.importFromJSON(jsonEncode(jsonData));

      verifyNever(mockService.eraseEverything(any));
    });

    test('should import bookmarks with URI field', () async {
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
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark1___');

      final count = await utils.importFromJSON(jsonEncode(jsonData));

      expect(count, equals(1));
      verify(
        mockService.addItem(
          'menu________',
          Uri.parse('https://example.com'),
          'Test Bookmark',
          0,
        ),
      ).called(1);
    });

    test('should import bookmarks with URL field', () async {
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
                'url': 'https://example.com',
              },
            ],
          },
        ],
      };

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark1___');

      final count = await utils.importFromJSON(jsonEncode(jsonData));

      expect(count, equals(1));
      verify(
        mockService.addItem(
          'menu________',
          Uri.parse('https://example.com'),
          'Test Bookmark',
          0,
        ),
      ).called(1);
    });

    test('should skip bookmarks with invalid URLs', () async {
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

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'valid1______');

      final count = await utils.importFromJSON(jsonEncode(jsonData));

      // Only one valid bookmark should be imported
      expect(count, equals(1));
      // Note: position is 1 because the invalid bookmark was skipped first
      verify(
        mockService.addItem(
          'menu________',
          Uri.parse('https://example.com'),
          'Valid URL',
          1,
        ),
      ).called(1);
    });

    test('should import nested folders recursively', () async {
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

      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder1_____');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark1___');

      final count = await utils.importFromJSON(jsonEncode(jsonData));

      expect(count, equals(1));
      verify(mockService.addFolder('menu________', 'Folder 1', 0)).called(1);
      verify(
        mockService.addItem(
          'folder1_____',
          Uri.parse('https://example.com'),
          'Nested Bookmark',
          0,
        ),
      ).called(1);
    });

    test('should handle separators gracefully (skip them)', () async {
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

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((invocation) async => 'generated_guid');

      final count = await utils.importFromJSON(jsonEncode(jsonData));

      // Two bookmarks, separator should be skipped
      expect(count, equals(2));
      verify(mockService.addItem(any, any, any, any)).called(2);
    });

    test('should fixup place: queries with folder shortcuts', () async {
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

      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder1_____');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'shortcut1___');

      await utils.importFromJSON(jsonEncode(jsonData));

      // Capture the URI argument to verify it was fixed up
      // Note: position is 1 because the folder was added first at position 0
      final captured = verify(
        mockService.addItem('unfiled_____', captureAny, 'Folder Shortcut', 1),
      ).captured;

      expect((captured[0] as Uri).toString(), contains('parent=folder1_____'));
    });

    test('should handle invalid folder references in place: queries', () async {
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

      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'shortcut1___');

      await utils.importFromJSON(jsonEncode(jsonData));

      final captured = verify(
        mockService.addItem(
          'unfiled_____',
          captureAny,
          'Invalid Folder Shortcut',
          0,
        ),
      ).captured;

      final url = (captured[0] as Uri).toString();
      expect(url, contains('invalidOldParentId=999999'));
      expect(url, contains('excludeItems=1'));
    });

    test('should count imported bookmarks correctly from fixture', () async {
      // Load the fixture
      final fixtureFile = File('test/utils/bookmarks/fixtures/bookmarks.json');
      final jsonString = await fixtureFile.readAsString();

      // Mock the service calls
      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((invocation) async => 'generated_guid');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((invocation) async => 'generated_guid');

      final count = await utils.importFromJSON(jsonString, replace: true);

      // The fixture has several bookmarks - we should count only valid ones
      expect(count, greaterThan(0));
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });

    test('should handle import errors gracefully', () async {
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
        mockService.addItem(any, any, any, any),
      ).thenThrow(Exception('Database error'));

      // Should not throw, but should log and continue
      final count = await utils.importFromJSON(jsonEncode(jsonData));

      expect(count, equals(0)); // Failed to add
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
      when(mockService.eraseEverything(any)).thenAnswer((_) async {});
      when(
        mockService.addFolder(any, any, any),
      ).thenAnswer((_) async => 'folder1_____');
      when(
        mockService.addItem(any, any, any, any),
      ).thenAnswer((_) async => 'bookmark1___');

      final jsonString = jsonEncode({
        'children': [exported],
      });
      final count = await utils.importFromJSON(jsonString, replace: true);

      expect(count, equals(1)); // One bookmark imported
      verify(mockService.eraseEverything(BookmarkRoot.root)).called(1);
    });
  });
}
