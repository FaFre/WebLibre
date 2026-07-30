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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/utils/bookmark_tree_utils.dart';

BookmarkEntry entry(String guid, String title) => BookmarkEntry(
  guid: guid,
  parentGuid: BookmarkRoot.menu.id,
  url: Uri.parse('https://example.com/$guid'),
  title: title,
  previewImageUrl: Uri.parse('https://example.com/$guid'),
  position: 0,
  dateAdded: 0,
);

BookmarkFolder folder(String guid, String title, {List<BookmarkItem>? kids}) =>
    BookmarkFolder(
      guid: guid,
      parentGuid: BookmarkRoot.root.id,
      title: title,
      position: 0,
      dateAdded: 0,
      children: kids,
    );

void main() {
  group('sortBookmarkChildren', () {
    test('should leave order untouched for manual sorting', () {
      final children = [entry('b', 'Beta'), entry('a', 'Alpha')];

      final sorted = sortBookmarkChildren(children, BookmarkSortType.manual);

      expect(sorted.map((c) => c.guid), equals(['b', 'a']));
    });

    test('should sort a plain level by title', () {
      final children = [
        entry('c', 'Charlie'),
        entry('a', 'Alpha'),
        entry('b', 'Bravo'),
      ];

      final sorted = sortBookmarkChildren(children, BookmarkSortType.titleAsc);

      expect(sorted.map((c) => c.title), equals(['Alpha', 'Bravo', 'Charlie']));
    });

    test('should not mutate the list it was given', () {
      final children = [entry('c', 'Charlie'), entry('a', 'Alpha')];

      sortBookmarkChildren(children, BookmarkSortType.titleAsc);

      expect(children.map((c) => c.guid), equals(['c', 'a']));
    });

    test('should keep built-in roots pinned ahead of the rest at root', () {
      final children = <BookmarkItem>[
        entry('z', 'Zulu'),
        folder(BookmarkRoot.mobile.id, 'WebLibre'),
        entry('a', 'Alpha'),
        folder(BookmarkRoot.menu.id, 'Menu'),
      ];

      final sorted = sortBookmarkChildren(
        children,
        BookmarkSortType.titleAsc,
        isRoot: true,
      );

      expect(
        sorted.map((c) => c.guid),
        equals([BookmarkRoot.mobile.id, BookmarkRoot.menu.id, 'a', 'z']),
      );
    });
  });

  group('resolveSelectedItems', () {
    test('should return the children whose guids are selected', () {
      final children = [entry('a', 'Alpha'), entry('b', 'Bravo')];

      final selected = resolveSelectedItems(children, {'b'});

      expect(selected.single.guid, equals('b'));
    });

    test('should ignore guids that are not in the given list', () {
      final children = [entry('a', 'Alpha')];

      expect(resolveSelectedItems(children, {'somewhere-else'}), isEmpty);
    });

    test('should resolve items that live in other folders', () {
      // Search results come from anywhere in the library, so the list handed to
      // this function is not always one folder's children. Callers must pass
      // whatever is actually on screen — resolving against the current folder
      // instead would silently drop every result from a subfolder.
      final results = [
        entry('a', 'Alpha').copyWith(parentGuid: 'folder_one__'),
        entry('b', 'Bravo').copyWith(parentGuid: 'folder_two__'),
      ];

      final selected = resolveSelectedItems(results, {'a', 'b'});

      expect(selected.map((item) => item.guid), equals(['a', 'b']));
    });
  });

  group('normalizeSelection', () {
    test('should keep selections that are siblings', () {
      final rows = [
        BookmarkRow(entry('a', 'Alpha'), 0),
        BookmarkRow(entry('b', 'Bravo'), 0),
      ];

      expect(normalizeSelection(rows, {'a', 'b'}), equals({'a', 'b'}));
    });

    test('should drop children of a selected folder', () {
      final rows = [
        BookmarkRow(folder('f1__________', 'Folder'), 0),
        BookmarkRow(entry('child_______', 'Child'), 1),
        BookmarkRow(entry('after_______', 'After'), 0),
      ];

      final normalized = normalizeSelection(rows, {
        'f1__________',
        'child_______',
        'after_______',
      });

      expect(normalized, equals({'f1__________', 'after_______'}));
    });

    test('should drop the whole subtree under a selected folder', () {
      final rows = [
        BookmarkRow(folder('outer_______', 'Outer'), 0),
        BookmarkRow(folder('inner_______', 'Inner'), 1),
        BookmarkRow(entry('deep________', 'Deep'), 2),
        BookmarkRow(entry('sibling_____', 'Sibling'), 0),
      ];

      final normalized = normalizeSelection(rows, {
        'outer_______',
        'inner_______',
        'deep________',
        'sibling_____',
      });

      expect(normalized, equals({'outer_______', 'sibling_____'}));
    });

    test('should keep a nested selection when its parent is not selected', () {
      final rows = [
        BookmarkRow(folder('f1__________', 'Folder'), 0),
        BookmarkRow(entry('child_______', 'Child'), 1),
      ];

      expect(
        normalizeSelection(rows, {'child_______'}),
        equals({'child_______'}),
      );
    });

    test('should not count a loading placeholder as a second occurrence', () {
      // While an expanded folder loads, a placeholder row repeats it one level
      // down. Treating that as a real row would resolve the folder twice and
      // apply the same move or delete to it twice over.
      final selectedFolder = folder('f1__________', 'Folder');
      final rows = [
        BookmarkRow(selectedFolder, 0),
        BookmarkRow(selectedFolder, 1, isPlaceholder: true),
      ];

      final normalized = normalizeSelection(rows, {'f1__________'});

      expect(normalized, equals({'f1__________'}));
    });

    test('should resume after leaving a selected folder subtree', () {
      final rows = [
        BookmarkRow(folder('f1__________', 'One'), 0),
        BookmarkRow(entry('inside______', 'Inside'), 1),
        BookmarkRow(folder('f2__________', 'Two'), 0),
        BookmarkRow(entry('later_______', 'Later'), 1),
      ];

      final normalized = normalizeSelection(rows, {
        'f1__________',
        'inside______',
        'later_______',
      });

      expect(normalized, equals({'f1__________', 'later_______'}));
    });
  });

  group('canFlattenFolder', () {
    test('should reject built-in roots', () {
      expect(canFlattenFolder(folder(BookmarkRoot.menu.id, 'Menu')), isFalse);
    });

    test('should accept an ordinary folder even before its children load', () {
      // The list only loads one level, so a folder shown in it has no children
      // attached; emptiness is decided by the repository at operation time.
      expect(canFlattenFolder(folder('normal______', 'Normal')), isTrue);
    });

    test('should reject a folder without a parent', () {
      final orphan = BookmarkFolder(
        guid: 'orphan______',
        parentGuid: null,
        title: 'Orphan',
        position: 0,
        dateAdded: 0,
        children: null,
      );

      expect(canFlattenFolder(orphan), isFalse);
    });
  });
}
