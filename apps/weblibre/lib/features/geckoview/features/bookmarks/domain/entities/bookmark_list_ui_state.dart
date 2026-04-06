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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';

part 'bookmark_list_ui_state.g.dart';

@CopyWith()
class BookmarkListUiState with FastEquatable {
  final bool selectionMode;
  final Set<String> selectedGuids;
  final BookmarkSortType sortType;
  final bool foldersOnly;

  BookmarkListUiState({
    this.selectionMode = false,
    this.selectedGuids = const {},
    this.sortType = BookmarkSortType.manual,
    this.foldersOnly = false,
  });

  @override
  List<Object?> get hashParameters => [
    selectionMode,
    selectedGuids,
    sortType,
    foldersOnly,
  ];
}
