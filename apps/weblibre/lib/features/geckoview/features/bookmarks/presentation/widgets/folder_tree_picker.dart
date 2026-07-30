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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// Indentation applied per level of folder nesting.
const _indentPerDepth = 20.0;

/// A widget that displays a tree view of bookmark folders and allows the user
/// to select a parent folder.
///
/// Folders are loaded one level at a time as the user expands them, so opening
/// the picker never pulls in the whole bookmark tree.
///
/// When editing a folder, pass [excludeFolderGuids] to prevent selecting the
/// folders or their descendants as the parent (which would create a circular
/// reference). Descendants are excluded implicitly: an excluded folder is never
/// rendered, so nothing underneath it can be reached or expanded.
class FolderTreePicker extends HookConsumerWidget {
  /// The currently selected folder GUID
  final ValueNotifier<String> selectedFolderGuid;

  /// Optional folder GUIDs to exclude from the tree (along with their descendants).
  /// Used when editing/moving folders to prevent circular parent relationships.
  final Set<String> excludeFolderGuids;

  final String entryGuid;

  const FolderTreePicker({
    required this.selectedFolderGuid,
    required this.entryGuid,
    this.excludeFolderGuids = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Folders start collapsed apart from the entry point, so the picker opens
    // after a single shallow load.
    final expandedGuids = useState(<String>{entryGuid});

    final rootFolder = ref.watch(bookmarkFolderProvider(entryGuid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Folder', style: Theme.of(context).textTheme.labelMedium),
        rootFolder.when(
          skipLoadingOnReload: true,
          data: (folder) {
            if (folder == null) return const SizedBox.shrink();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entryGuid != BookmarkRoot.root.id)
                  _FolderRow(
                    folder: folder,
                    depth: 0,
                    expandedGuids: expandedGuids,
                    selectedFolderGuid: selectedFolderGuid,
                  ),
                _FolderChildren(
                  parentGuid: folder.guid,
                  depth: entryGuid != BookmarkRoot.root.id ? 1 : 0,
                  expandedGuids: expandedGuids,
                  selectedFolderGuid: selectedFolderGuid,
                  excludeFolderGuids: excludeFolderGuids,
                ),
              ],
            );
          },
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: 'Failed to load Bookmark Folders',
              exception: error,
              onRetry: () {
                ref.invalidate(bookmarkFolderProvider(entryGuid));
              },
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

/// The direct subfolders of [parentGuid], rendered only while its parent is
/// expanded.
///
/// Mounting this widget is what triggers the load, so a collapsed folder costs
/// nothing.
class _FolderChildren extends HookConsumerWidget {
  final String parentGuid;
  final int depth;
  final ValueNotifier<Set<String>> expandedGuids;
  final ValueNotifier<String> selectedFolderGuid;
  final Set<String> excludeFolderGuids;

  const _FolderChildren({
    required this.parentGuid,
    required this.depth,
    required this.expandedGuids,
    required this.selectedFolderGuid,
    required this.excludeFolderGuids,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(bookmarkFolderProvider(parentGuid));

    final subfolders = (folder.value?.children ?? const <BookmarkItem>[])
        .whereType<BookmarkFolder>()
        .where((child) => !excludeFolderGuids.contains(child.guid))
        .toList();

    if (folder.isLoading && folder.value == null) {
      return Padding(
        padding: EdgeInsets.only(left: depth * _indentPerDepth, top: 8.0),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 16.0,
            width: 16.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final subfolder in subfolders) ...[
          _FolderRow(
            folder: subfolder,
            depth: depth,
            expandedGuids: expandedGuids,
            selectedFolderGuid: selectedFolderGuid,
          ),
          if (expandedGuids.value.contains(subfolder.guid))
            _FolderChildren(
              parentGuid: subfolder.guid,
              depth: depth + 1,
              expandedGuids: expandedGuids,
              selectedFolderGuid: selectedFolderGuid,
              excludeFolderGuids: excludeFolderGuids,
            ),
        ],
      ],
    );
  }
}

class _FolderRow extends HookConsumerWidget {
  final BookmarkFolder folder;
  final int depth;
  final ValueNotifier<Set<String>> expandedGuids;
  final ValueNotifier<String> selectedFolderGuid;

  const _FolderRow({
    required this.folder,
    required this.depth,
    required this.expandedGuids,
    required this.selectedFolderGuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = expandedGuids.value.contains(folder.guid);
    final isSelected = folder.guid == selectedFolderGuid.value;

    // BookmarkRoot.root cannot be selected as a parent
    final isRootFolder = folder.guid == BookmarkRoot.root.id;

    return Padding(
      padding: EdgeInsets.only(left: depth * _indentPerDepth, right: 42.0),
      child: ListTile(
        key: ValueKey(folder.guid),
        contentPadding: EdgeInsets.zero,
        selected: isSelected,
        enabled: !isRootFolder,
        // Whether a folder has subfolders is unknown until it is opened, so
        // every folder offers the toggle.
        leading: IconButton(
          icon: Icon(isExpanded ? MdiIcons.folderOpen : MdiIcons.folder),
          onPressed: () {
            expandedGuids.value = isExpanded
                ? ({...expandedGuids.value}..remove(folder.guid))
                : ({...expandedGuids.value}..add(folder.guid));
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) const Icon(Icons.check),
            IconButton(
              onPressed: () async {
                await BookmarkFolderAddRoute(
                  parentGuid: folder.guid,
                ).push(context);
              },
              icon: const Icon(MdiIcons.folderPlus),
            ),
          ],
        ),
        title: Text(folder.title),
        onTap: !isRootFolder
            ? () {
                selectedFolderGuid.value = folder.guid;
              }
            : null,
      ),
    );
  }
}
