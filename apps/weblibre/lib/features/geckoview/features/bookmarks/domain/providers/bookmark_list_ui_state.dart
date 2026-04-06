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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_list_ui_state.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';

part 'bookmark_list_ui_state.g.dart';

@Riverpod()
class BookmarkListUiStateNotifier extends _$BookmarkListUiStateNotifier {
  @override
  BookmarkListUiState build() => BookmarkListUiState();

  void enterSelectionMode({String? initialGuid}) {
    state = state.copyWith(
      selectionMode: true,
      selectedGuids: initialGuid != null ? {initialGuid} : {},
    );
  }

  void exitSelectionMode() {
    state = state.copyWith(selectionMode: false, selectedGuids: {});
  }

  void toggleSelection(String guid) {
    final updated = Set<String>.from(state.selectedGuids);
    if (updated.contains(guid)) {
      updated.remove(guid);
    } else {
      updated.add(guid);
    }
    if (updated.isEmpty) {
      exitSelectionMode();
    } else {
      state = state.copyWith(selectedGuids: updated);
    }
  }

  void selectAll(Iterable<String> guids) {
    state = state.copyWith(
      selectionMode: true,
      selectedGuids: Set<String>.from(guids),
    );
  }

  void clearSelection() {
    exitSelectionMode();
  }

  void setSortType(BookmarkSortType sortType) {
    state = state.copyWith(sortType: sortType);
  }

  void toggleFoldersOnly() {
    state = state.copyWith(foldersOnly: !state.foldersOnly);
  }
}
