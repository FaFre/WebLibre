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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/widgets/folder_tree_picker.dart';

/// Shows a bottom sheet for selecting a bookmark folder destination (for move operations).
///
/// Returns the selected folder GUID, or null if cancelled.
Future<String?> showSelectBookmarkFolderDialog(
  BuildContext context, {
  Set<String> excludeFolderGuids = const {},
  String? initialFolderGuid,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SelectBookmarkFolderSheet(
      excludeFolderGuids: excludeFolderGuids,
      initialFolderGuid: initialFolderGuid,
    ),
  );
}

class _SelectBookmarkFolderSheet extends HookConsumerWidget {
  final Set<String> excludeFolderGuids;
  final String? initialFolderGuid;

  const _SelectBookmarkFolderSheet({
    required this.excludeFolderGuids,
    this.initialFolderGuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGuid = useState(initialFolderGuid ?? BookmarkRoot.mobile.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Move to Folder',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: FolderTreePicker(
                  selectedFolderGuid: selectedGuid,
                  excludeFolderGuids: excludeFolderGuids,
                  entryGuid: BookmarkRoot.root.id,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => context.pop(selectedGuid.value),
                  child: const Text('Move'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
