/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/widgets/folder_tree_picker.dart';

/// Dialog to select a bookmark folder.
/// Returns the selected folder GUID or null if cancelled.
Future<String?> showSelectFolderDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _SelectFolderDialog(),
  );
}

class _SelectFolderDialog extends HookConsumerWidget {
  const _SelectFolderDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFolderGuid = useState(BookmarkRoot.mobile.id);

    return AlertDialog(
      title: const Text('Select folder'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: FolderTreePicker(
            selectedFolderGuid: selectedFolderGuid,
            entryGuid: BookmarkRoot.root.id,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selectedFolderGuid.value),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
