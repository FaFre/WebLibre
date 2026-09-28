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
import 'package:flutter/widgets.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for [BookmarkSortType].
extension BookmarkSortTypeL10n on BookmarkSortType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BookmarkSortType.manual => l10n.bookmarks_sortDefault,
      BookmarkSortType.titleAsc => l10n.bookmarks_sortTitleAsc,
      BookmarkSortType.titleDesc => l10n.bookmarks_sortTitleDesc,
      BookmarkSortType.urlAsc => l10n.bookmarks_sortUrlAsc,
      BookmarkSortType.urlDesc => l10n.bookmarks_sortUrlDesc,
      BookmarkSortType.dateAddedDesc => l10n.bookmarks_sortDateAddedDesc,
      BookmarkSortType.dateAddedAsc => l10n.bookmarks_sortDateAddedAsc,
    };
  }
}
