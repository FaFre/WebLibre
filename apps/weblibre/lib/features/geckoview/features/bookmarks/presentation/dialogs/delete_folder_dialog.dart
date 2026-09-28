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
import 'package:flutter/material.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Confirms deleting a folder and everything inside it.
///
/// Pass [bookmarkCount] to name how many bookmarks go with it. The list only
/// shows one level at a time, so the contents of a folder are usually off
/// screen when this is asked.
Future<bool?> showDeleteFolderDialog(
  BuildContext context, {
  int? bookmarkCount,
}) {
  return showDialog<bool?>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (BuildContext context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        icon: const Icon(Icons.warning),
        title: Text(l10n.bookmarks_deleteFolderTitle),
        // `bookmarkCount == null` is not a plural form — it means the count
        // wasn't computed, distinct copy from "the count is zero".
        content: Text(
          bookmarkCount == null
              ? l10n.bookmarks_deleteFolderConfirmUnknown
              : l10n.bookmarks_deleteFolderConfirmCount(bookmarkCount),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(l10n.common_delete),
          ),
        ],
      );
    },
  );
}
