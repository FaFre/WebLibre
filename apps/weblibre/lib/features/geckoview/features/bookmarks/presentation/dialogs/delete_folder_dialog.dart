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
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(Icons.warning),
        title: const Text('Delete Folder'),
        content: Text(switch (bookmarkCount) {
          null =>
            'Are you sure you want to delete this Folder including '
                'all bookmarks?',
          0 => 'Are you sure you want to delete this Folder?',
          1 =>
            'Are you sure you want to delete this Folder and the '
                '1 bookmark inside it?',
          final count =>
            'Are you sure you want to delete this Folder and the '
                '$count bookmarks inside it?',
        }),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
