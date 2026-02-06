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
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// A widget that displays a tree view of bookmark folders and allows the user
/// to select a parent folder.
///
/// When editing a folder, pass [excludeFolderGuid] to prevent selecting the
/// folder itself or its descendants as the parent (which would create a circular reference).
class FolderTreePicker extends HookConsumerWidget {
  /// The currently selected folder GUID
  final ValueNotifier<String> selectedFolderGuid;

  /// Optional folder GUID to exclude from the tree (along with its descendants).
  /// Used when editing a folder to prevent circular parent relationships.
  final String? excludeFolderGuid;

  final String entryGuid;

  const FolderTreePicker({
    required this.selectedFolderGuid,
    required this.entryGuid,
    this.excludeFolderGuid,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeKey = useMemoized(() => GlobalKey<TreeViewState>());

    final folderList = ref.watch(bookmarksProvider<BookmarkFolder>(entryGuid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Folder', style: Theme.of(context).textTheme.labelMedium),
        folderList.when(
          skipLoadingOnReload: true,
          data: (list) {
            TreeNode<BookmarkFolder> addChildren(
              TreeNode<BookmarkFolder>? parent,
              BookmarkFolder item,
            ) {
              final node = TreeNode(key: item.guid, data: item, parent: parent);
              final targetNode = (parent?..add(node)) ?? node;

              if (item.children != null) {
                for (final child in item.children!) {
                  // Skip the excluded folder and its descendants
                  if (child is BookmarkFolder &&
                      child.guid != excludeFolderGuid) {
                    addChildren(node, child);
                  }
                }
              }

              return targetNode;
            }

            final root = (list != null)
                ? addChildren(null, list)
                : TreeNode<BookmarkFolder>.root();

            return TreeView.simple(
              key: treeKey,
              tree: root,
              shrinkWrap: true,
              showRootNode: entryGuid != BookmarkRoot.root.id,
              onTreeReady: (controller) {
                controller.expandAllChildren(root, recursive: true);
              },
              expansionIndicatorBuilder: (context, tree) =>
                  ChevronIndicator.upDown(
                    tree: tree,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 12.0,
                    ),
                  ),
              builder: (context, item) {
                final isSelected = item.data?.guid == selectedFolderGuid.value;

                // BookmarkRoot.root cannot be selected as a parent
                final isRootFolder = item.data?.guid == BookmarkRoot.root.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 42.0),
                  child: switch (item.data) {
                    final BookmarkFolder folder => ListTile(
                      key: ValueKey(folder.guid),
                      contentPadding: EdgeInsets.zero,
                      selected: isSelected,
                      enabled: !isRootFolder,
                      leading: (item.isExpanded)
                          ? const Icon(MdiIcons.folderOpen)
                          : const Icon(MdiIcons.folder),
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
                    null => const SizedBox.shrink(),
                  },
                );
              },
            );
          },
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: 'Failed to load Bookmark Folders',
              exception: error,
              onRetry: () {
                ref.invalidate(bookmarksProvider<BookmarkFolder>(entryGuid));
              },
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
