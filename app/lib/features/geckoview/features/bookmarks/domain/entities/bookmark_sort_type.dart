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
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';

enum BookmarkSortType {
  manual('Default'),
  titleAsc('Title A-Z'),
  titleDesc('Title Z-A'),
  urlAsc('URL A-Z'),
  dateAddedDesc('Newest First');

  final String label;

  const BookmarkSortType(this.label);
}

int compareBookmarkItems(
  BookmarkItem a,
  BookmarkItem b,
  BookmarkSortType sort,
) {
  return switch (sort) {
    BookmarkSortType.manual => 0,
    BookmarkSortType.titleAsc => a.title.toLowerCase().compareTo(
      b.title.toLowerCase(),
    ),
    BookmarkSortType.titleDesc => b.title.toLowerCase().compareTo(
      a.title.toLowerCase(),
    ),
    BookmarkSortType.urlAsc => _compareByUrl(a, b),
    BookmarkSortType.dateAddedDesc => b.dateAdded.compareTo(a.dateAdded),
  };
}

int _compareByUrl(BookmarkItem a, BookmarkItem b) {
  final aUrl = a is BookmarkEntry ? a.url.toString() : a.title.toLowerCase();
  final bUrl = b is BookmarkEntry ? b.url.toString() : b.title.toLowerCase();
  return aUrl.compareTo(bUrl);
}
