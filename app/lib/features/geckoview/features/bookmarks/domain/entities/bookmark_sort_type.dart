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
import 'package:weblibre/core/sort_field.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';

enum BookmarkSortType {
  manual('Default', null),
  titleAsc('Title A-Z', SortField.titleAsc),
  titleDesc('Title Z-A', SortField.titleDesc),
  urlAsc('URL A-Z', SortField.urlAsc),
  urlDesc('URL Z-A', SortField.urlDesc),
  dateAddedDesc('Newest First', SortField.dateDesc),
  dateAddedAsc('Oldest First', SortField.dateAsc);

  final String label;
  final SortField? sortField;

  const BookmarkSortType(this.label, this.sortField);
}

int compareBookmarkItems(
  BookmarkItem a,
  BookmarkItem b,
  BookmarkSortType sort,
) {
  final sortField = sort.sortField;
  if (sortField == null) {
    return 0;
  }

  return switch (sortField) {
    SortField.titleAsc => a.title.toLowerCase().compareTo(
      b.title.toLowerCase(),
    ),
    SortField.titleDesc => b.title.toLowerCase().compareTo(
      a.title.toLowerCase(),
    ),
    SortField.urlAsc => _urlKey(a).compareTo(_urlKey(b)),
    SortField.urlDesc => _urlKey(b).compareTo(_urlKey(a)),
    SortField.dateAsc => a.dateAdded.compareTo(b.dateAdded),
    SortField.dateDesc => b.dateAdded.compareTo(a.dateAdded),
  };
}

String _urlKey(BookmarkItem item) =>
    item is BookmarkEntry ? item.url.toString() : item.title.toLowerCase();
