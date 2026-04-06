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
import 'dart:convert';
import 'dart:io';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:convert/convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_list_ui_state.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmark_list_ui_state.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/utils/bookmark_tree_utils.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/delete_bookmark_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/delete_folder_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/import_bookmarks_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/select_bookmark_folder_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart';

class BookmarkListScreen extends HookConsumerWidget {
  final String entryGuid;

  const BookmarkListScreen({super.key, required this.entryGuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeController =
        useState<TreeViewController<BookmarkItem, TreeNode<BookmarkItem>>?>(
          null,
        );
    // Tracks which folder GUIDs are expanded, so expansion state survives
    // tree rebuilds caused by sort type changes.
    final expandedGuids = useRef(<String>{});
    final hideEmptyRoots = useState(true);
    final uiState = ref.watch(bookmarkListUiStateProvider);
    final uiStateNotifier = ref.read(bookmarkListUiStateProvider.notifier);
    final bookmarkList = ref.watch(
      seamlessBookmarksProvider(
        entryGuid,
        hideEmptyRoots: hideEmptyRoots.value,
      ),
    );

    final textFilterEnabled = useState(false);
    final textFilterController = useTextEditingController();

    useOnListenableChange(textFilterController, () {
      if (ref.exists(
        seamlessBookmarksProvider(
          entryGuid,
          hideEmptyRoots: hideEmptyRoots.value,
        ),
      )) {
        ref
            .read(
              seamlessBookmarksProvider(
                entryGuid,
                hideEmptyRoots: hideEmptyRoots.value,
              ).notifier,
            )
            .search(textFilterController.text);
      }
    });

    return PopScope(
      canPop: !uiState.selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && uiState.selectionMode) {
          uiStateNotifier.exitSelectionMode();
        }
      },
      child: Scaffold(
        appBar: uiState.selectionMode
            ? _buildSelectionAppBar(context, ref, uiState, uiStateNotifier)
            : _buildNormalAppBar(
                context,
                ref,
                treeController,
                expandedGuids,
                hideEmptyRoots,
                textFilterEnabled,
                textFilterController,
                uiStateNotifier,
                uiState,
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: bookmarkList.when(
              skipLoadingOnReload: true,
              data: (list) {
                final sortedList = list != null
                    ? sortBookmarkTree(
                        list,
                        uiState.sortType,
                        isRoot: entryGuid == BookmarkRoot.root.id,
                      )
                    : null;

                TreeNode<BookmarkItem> addChildren(
                  TreeNode<BookmarkItem>? parent,
                  BookmarkItem item,
                ) {
                  if (uiState.foldersOnly && item is BookmarkEntry) {
                    return parent ?? TreeNode<BookmarkItem>.root();
                  }

                  final node = TreeNode(
                    key: item.guid,
                    data: item,
                    parent: parent,
                  );
                  final targetNode = (parent?..add(node)) ?? node;

                  if (item is BookmarkFolder && item.children != null) {
                    for (final child in item.children!) {
                      addChildren(node, child);
                    }
                  }

                  return targetNode;
                }

                final root = (sortedList != null)
                    ? addChildren(null, sortedList)
                    : TreeNode<BookmarkItem>.root();

                return TreeView.simple(
                  key: ValueKey((uiState.sortType, uiState.foldersOnly)),
                  tree: root,
                  showRootNode: entryGuid != BookmarkRoot.root.id,
                  onTreeReady: (controller) {
                    treeController.value = controller;
                    if (expandedGuids.value.isNotEmpty) {
                      _restoreExpansion(controller, root, expandedGuids.value);
                    } else {
                      controller.expandAllChildren(root, recursive: true);
                    }
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
                    final BookmarkItem? data = item.data;
                    final isSelected = uiState.selectedGuids.contains(
                      data?.guid,
                    );
                    final bool isLeaf = item.isLeaf;
                    final bool isExpanded = item.isExpanded;

                    return switch (data) {
                      final BookmarkEntry bookmark => _buildEntryTile(
                        context,
                        ref,
                        bookmark,
                        uiState,
                        uiStateNotifier,
                        isSelected,
                        sortedList,
                      ),
                      final BookmarkFolder folder => _buildFolderTile(
                        context,
                        ref,
                        folder,
                        isLeaf: isLeaf,
                        isExpanded: isExpanded,
                        uiState: uiState,
                        uiStateNotifier: uiStateNotifier,
                        isSelected: isSelected,
                        rootItem: sortedList,
                      ),
                      null => const Center(child: Text('Empty')),
                    };
                  },
                );
              },
              error: (error, stackTrace) => Center(
                child: FailureWidget(
                  title: 'Failed to load Bookmarks',
                  exception: error,
                  onRetry: () {
                    // ignore: unused_result
                    ref.refresh(bookmarksProvider<BookmarkItem>(entryGuid));
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  // -- App Bars --

  PreferredSizeWidget _buildSelectionAppBar(
    BuildContext context,
    WidgetRef ref,
    BookmarkListUiState uiState,
    BookmarkListUiStateNotifier uiStateNotifier,
  ) {
    final count = uiState.selectedGuids.length;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => uiStateNotifier.exitSelectionMode(),
      ),
      title: Text('$count selected'),
      actions: [
        IconButton(
          icon: const Icon(MdiIcons.tabPlus),
          tooltip: 'Open in background',
          onPressed: count > 0
              ? () => _bulkOpenInBackground(context, ref, uiState)
              : null,
        ),
        IconButton(
          icon: const Icon(MdiIcons.folderMove),
          tooltip: 'Move selected',
          onPressed: count > 0 ? () => _bulkMove(context, ref, uiState) : null,
        ),
        IconButton(
          icon: const Icon(MdiIcons.delete),
          tooltip: 'Delete selected',
          onPressed: count > 0
              ? () => _bulkDelete(context, ref, uiState, uiStateNotifier)
              : null,
        ),
      ],
    );
  }

  AppBar _buildNormalAppBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<TreeViewController<BookmarkItem, TreeNode<BookmarkItem>>?>
    treeController,
    ObjectRef<Set<String>> expandedGuids,
    ValueNotifier<bool> hideEmptyRoots,
    ValueNotifier<bool> textFilterEnabled,
    TextEditingController textFilterController,
    BookmarkListUiStateNotifier uiStateNotifier,
    BookmarkListUiState uiState,
  ) {
    return AppBar(
      title: textFilterEnabled.value
          ? TextField(
              controller: textFilterController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 12),
                border: InputBorder.none,
                hintText: 'Filter bookmarks...',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: IconButton(
                  onPressed: () {
                    if (textFilterController.text.isNotEmpty) {
                      textFilterController.clear();
                    } else {
                      textFilterEnabled.value = false;
                    }
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            )
          : const Text('Bookmarks'),
      actions: [
        if (!textFilterEnabled.value)
          IconButton(
            onPressed: () {
              textFilterEnabled.value = !textFilterEnabled.value;
            },
            icon: const Icon(Icons.search),
          ),
        MenuAnchor(
          menuChildren: [
            SubmenuButton(
              leadingIcon: const Icon(MdiIcons.eye),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.expandAll),
                  child: const Text('Expand All'),
                  onPressed: () {
                    final controller = treeController.value;
                    if (controller != null) {
                      controller.expandAllChildren(
                        controller.tree,
                        recursive: true,
                      );
                    }
                  },
                ),
                if (entryGuid == BookmarkRoot.root.id)
                  MenuItemButton(
                    leadingIcon: Icon(
                      hideEmptyRoots.value
                          ? MdiIcons.folderOff
                          : MdiIcons.folder,
                    ),
                    child: Text(
                      hideEmptyRoots.value
                          ? 'Show Empty Folders'
                          : 'Hide Empty Folders',
                    ),
                    onPressed: () {
                      hideEmptyRoots.value = !hideEmptyRoots.value;
                    },
                  ),
                MenuItemButton(
                  leadingIcon: Icon(
                    uiState.foldersOnly
                        ? MdiIcons.bookmarkMultiple
                        : MdiIcons.folderOutline,
                  ),
                  child: Text(
                    uiState.foldersOnly ? 'Show Bookmarks' : 'Folders Only',
                  ),
                  onPressed: () {
                    _snapshotExpansion(treeController.value, expandedGuids);
                    uiStateNotifier.toggleFoldersOnly();
                  },
                ),
              ],
              child: const Text('Visibility'),
            ),
            SubmenuButton(
              leadingIcon: const Icon(MdiIcons.sort),
              menuChildren: [
                for (final sortType in BookmarkSortType.values)
                  MenuItemButton(
                    leadingIcon: sortType == uiState.sortType
                        ? const Icon(Icons.check)
                        : const SizedBox(width: 24),
                    child: Text(sortType.label),
                    onPressed: () {
                      _snapshotExpansion(treeController.value, expandedGuids);
                      uiStateNotifier.setSortType(sortType);
                    },
                  ),
              ],
              child: const Text('Sort'),
            ),
            SubmenuButton(
              leadingIcon: const Icon(MdiIcons.import),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.codeJson),
                  child: const Text('JSON'),
                  onPressed: () => _handleImport(context, ref, 'json'),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.xml),
                  child: const Text('HTML'),
                  onPressed: () => _handleImport(context, ref, 'html'),
                ),
              ],
              child: const Text('Import'),
            ),
            SubmenuButton(
              leadingIcon: const Icon(MdiIcons.export),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.codeJson),
                  child: const Text('JSON'),
                  onPressed: () => _handleExport(context, ref, 'json'),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.xml),
                  child: const Text('HTML'),
                  onPressed: () => _handleExport(context, ref, 'html'),
                ),
              ],
              child: const Text('Export'),
            ),
          ],
          builder: (context, controller, child) => IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(MdiIcons.dotsVertical),
          ),
        ),
      ],
    );
  }

  // -- Entry Tile --

  Widget _buildEntryTile(
    BuildContext context,
    WidgetRef ref,
    BookmarkEntry bookmark,
    BookmarkListUiState uiState,
    BookmarkListUiStateNotifier uiStateNotifier,
    bool isSelected,
    BookmarkItem? rootItem,
  ) {
    if (uiState.selectionMode) {
      return ListTile(
        key: ValueKey(bookmark.guid),
        contentPadding: EdgeInsets.zero,
        leading: UrlIcon([bookmark.url], iconSize: 34.0),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => uiStateNotifier.toggleSelection(bookmark.guid),
        ),
        title: Text(
          bookmark.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: UriBreadcrumb(uri: bookmark.url),
        onTap: () => uiStateNotifier.toggleSelection(bookmark.guid),
      );
    }

    return ListTile(
      key: ValueKey(bookmark.guid),
      contentPadding: EdgeInsets.zero,
      leading: UrlIcon([bookmark.url], iconSize: 34.0),
      trailing: _buildEntryMenu(context, ref, bookmark, rootItem),
      title: Text(bookmark.title, maxLines: 3, overflow: TextOverflow.ellipsis),
      subtitle: UriBreadcrumb(uri: bookmark.url),
      onTap: () async {
        final result = await OpenSharedContentRoute(
          sharedUrl: bookmark.url.toString(),
        ).push<bool>(context);

        if (result == true) {
          if (context.mounted) {
            const BrowserRoute().go(context);
          }
        }
      },
      onLongPress: () {
        uiStateNotifier.enterSelectionMode(initialGuid: bookmark.guid);
      },
    );
  }

  Widget _buildEntryMenu(
    BuildContext context,
    WidgetRef ref,
    BookmarkEntry bookmark,
    BookmarkItem? rootItem,
  ) {
    return HookBuilder(
      builder: (context) {
        final controller = useMenuController();

        return MenuAnchor(
          controller: controller,
          builder: (context, controller, child) => InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
              child: Icon(MdiIcons.dotsVertical),
            ),
          ),
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.openInNew),
              child: const Text('Open'),
              onPressed: () async {
                final result = await OpenSharedContentRoute(
                  sharedUrl: bookmark.url.toString(),
                ).push<bool>(context);
                if (result == true && context.mounted) {
                  const BrowserRoute().go(context);
                }
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.tabPlus),
              child: const Text('Open in New Tab'),
              onPressed: () async {
                await _openInNewTab(
                  context,
                  ref,
                  bookmark.url,
                  selectTab: true,
                );
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.tab),
              child: const Text('Open in Background'),
              onPressed: () async {
                await _openInNewTab(
                  context,
                  ref,
                  bookmark.url,
                  selectTab: false,
                );
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.share),
              child: const Text('Share'),
              onPressed: () async {
                await SharePlus.instance.share(
                  ShareParams(text: bookmark.url.toString()),
                );
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.folderMove),
              child: const Text('Move'),
              onPressed: () async {
                final targetGuid = await showSelectBookmarkFolderDialog(
                  context,
                  initialFolderGuid: bookmark.parentGuid,
                );
                if (targetGuid != null) {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .editBookmark(
                        guid: bookmark.guid,
                        parentGuid: targetGuid,
                      );
                }
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.edit),
              child: const Text('Edit'),
              onPressed: () async {
                await BookmarkEntryEditRoute(
                  bookmarkEntry: jsonEncode(bookmark.toJson()),
                ).push(context);
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.bookmarkRemove),
              child: const Text('Delete'),
              onPressed: () async {
                final result = await showDeleteBookmarkDialog(context);
                if (result == true) {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .delete(bookmark.guid);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // -- Folder Tile --

  Widget _buildFolderTile(
    BuildContext context,
    WidgetRef ref,
    BookmarkFolder folder, {
    required bool isLeaf,
    required bool isExpanded,
    required BookmarkListUiState uiState,
    required BookmarkListUiStateNotifier uiStateNotifier,
    required bool isSelected,
    required BookmarkItem? rootItem,
  }) {
    final isRoot = bookmarkRootIds.contains(folder.guid);

    if (uiState.selectionMode) {
      return Padding(
        key: ValueKey(folder.guid),
        padding: isLeaf
            ? const EdgeInsets.only(right: 4.0)
            : const EdgeInsets.only(right: 42.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: isExpanded
              ? const Icon(MdiIcons.folderOpen)
              : const Icon(MdiIcons.folder),
          title: Text(folder.title),
          trailing: isRoot
              ? null
              : Checkbox(
                  value: isSelected,
                  onChanged: (_) =>
                      uiStateNotifier.toggleSelection(folder.guid),
                ),
          onTap: isRoot
              ? null
              : () => uiStateNotifier.toggleSelection(folder.guid),
        ),
      );
    }

    return Padding(
      key: ValueKey(folder.guid),
      padding: isLeaf
          ? const EdgeInsets.only(right: 4.0)
          : const EdgeInsets.only(right: 42.0),
      child: HookBuilder(
        builder: (context) {
          final controller = useMenuController();

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: isExpanded
                ? const Icon(MdiIcons.folderOpen)
                : const Icon(MdiIcons.folder),
            title: Text(folder.title),
            trailing: MenuAnchor(
              controller: controller,
              builder: (context, controller, child) => InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15.0,
                  ),
                  child: Icon(MdiIcons.dotsVertical),
                ),
              ),
              menuChildren: [
                if (!isRoot) ...[
                  MenuItemButton(
                    leadingIcon: const Icon(MdiIcons.folderMove),
                    child: const Text('Move'),
                    onPressed: () async {
                      final repo = ref.read(
                        bookmarksRepositoryProvider.notifier,
                      );
                      final descendantGuids = await repo
                          .getDescendantFolderGuids(folder.guid);
                      final excludeGuids = {folder.guid, ...descendantGuids};
                      if (!context.mounted) return;
                      final targetGuid = await showSelectBookmarkFolderDialog(
                        context,
                        excludeFolderGuids: excludeGuids,
                        initialFolderGuid: folder.parentGuid,
                      );
                      if (targetGuid != null) {
                        await repo.editFolder(
                          guid: folder.guid,
                          parentGuid: targetGuid,
                        );
                      }
                    },
                  ),
                  if (canFlattenFolder(folder))
                    MenuItemButton(
                      leadingIcon: const Icon(MdiIcons.folderRemove),
                      child: const Text('Flatten'),
                      onPressed: () async {
                        await ref
                            .read(bookmarksRepositoryProvider.notifier)
                            .flattenFolder(folder: folder);
                      },
                    ),
                  MenuItemButton(
                    leadingIcon: const Icon(MdiIcons.folderEdit),
                    child: const Text('Edit'),
                    onPressed: () async {
                      await BookmarkFolderEditRoute(
                        folder: jsonEncode(folder.toJson()),
                      ).push(context);
                    },
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete),
                    child: const Text('Delete'),
                    onPressed: () async {
                      final result = await showDeleteFolderDialog(context);
                      if (result == true) {
                        await ref
                            .read(bookmarksRepositoryProvider.notifier)
                            .delete(folder.guid);
                      }
                    },
                  ),
                ],
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.folderPlus),
                  child: const Text('Add Subfolder'),
                  onPressed: () async {
                    await BookmarkFolderAddRoute(
                      parentGuid: folder.guid,
                    ).push(context);
                  },
                ),
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.bookmarkPlus),
                  child: const Text('Add Bookmark'),
                  onPressed: () async {
                    await BookmarkEntryAddRoute(
                      bookmarkInfo: jsonEncode(
                        BookmarkInfo(parentGuid: folder.guid).encode(),
                      ),
                    ).push(context);
                  },
                ),
              ],
            ),
            onTap: () async {
              if (folder.guid != entryGuid) {
                await BookmarkListRoute(entryGuid: folder.guid).push(context);
              }
            },
            onLongPress: isRoot
                ? null
                : () {
                    ref
                        .read(bookmarkListUiStateProvider.notifier)
                        .enterSelectionMode(initialGuid: folder.guid);
                  },
          );
        },
      ),
    );
  }

  // -- Bulk Actions --

  Future<void> _bulkOpenInBackground(
    BuildContext context,
    WidgetRef ref,
    BookmarkListUiState uiState,
  ) async {
    final bookmarkData = ref.read(
      seamlessBookmarksProvider(entryGuid, hideEmptyRoots: true),
    );
    final root = bookmarkData.value;
    if (root == null) return;

    final items = resolveSelectedItems(root, uiState.selectedGuids);
    final entries = items.whereType<BookmarkEntry>().toList();

    if (entries.isEmpty) {
      if (context.mounted) {
        showInfoMessage(context, 'No bookmark entries selected');
      }
      return;
    }

    final currentTab = ref.read(selectedTabStateProvider);
    final tabMode =
        currentTab?.tabMode ??
        TabMode.fromTabType(
          ref
              .read(generalSettingsWithDefaultsProvider)
              .effectiveDefaultCreateTabType,
        );

    for (final entry in entries) {
      await ref
          .read(tabRepositoryProvider.notifier)
          .addTab(url: entry.url, selectTab: false, tabMode: tabMode);
    }

    ref.read(bookmarkListUiStateProvider.notifier).exitSelectionMode();

    if (context.mounted) {
      showInfoMessage(context, 'Opened ${entries.length} tabs in background');
    }
  }

  Future<void> _bulkMove(
    BuildContext context,
    WidgetRef ref,
    BookmarkListUiState uiState,
  ) async {
    final bookmarkData = ref.read(
      seamlessBookmarksProvider(entryGuid, hideEmptyRoots: true),
    );
    final root = bookmarkData.value;
    if (root == null) return;

    final items = resolveSelectedItems(root, uiState.selectedGuids);

    // Build exclusion set from selected folders and their full descendant
    // trees fetched from storage, so hidden folders (e.g. filtered by search)
    // are still properly excluded as move targets.
    final repo = ref.read(bookmarksRepositoryProvider.notifier);
    final excludeGuids = <String>{};
    for (final item in items) {
      if (item is BookmarkFolder) {
        excludeGuids.add(item.guid);
        excludeGuids.addAll(await repo.getDescendantFolderGuids(item.guid));
      }
    }

    if (!context.mounted) return;

    final targetGuid = await showSelectBookmarkFolderDialog(
      context,
      excludeFolderGuids: excludeGuids,
    );

    if (targetGuid == null) return;

    // Normalize selection to avoid double-moves
    final normalizedGuids = normalizeSelection(root, uiState.selectedGuids);
    final normalizedItems = resolveSelectedItems(root, normalizedGuids);

    await ref
        .read(bookmarksRepositoryProvider.notifier)
        .moveMany(items: normalizedItems, targetParentGuid: targetGuid);

    ref.read(bookmarkListUiStateProvider.notifier).exitSelectionMode();

    if (context.mounted) {
      showInfoMessage(context, 'Moved ${normalizedItems.length} items');
    }
  }

  Future<void> _bulkDelete(
    BuildContext context,
    WidgetRef ref,
    BookmarkListUiState uiState,
    BookmarkListUiStateNotifier uiStateNotifier,
  ) async {
    final bookmarkData = ref.read(
      seamlessBookmarksProvider(entryGuid, hideEmptyRoots: true),
    );
    final root = bookmarkData.value;
    if (root == null) return;

    final items = resolveSelectedItems(root, uiState.selectedGuids);
    final hasFolders = items.any((item) => item is BookmarkFolder);

    if (!context.mounted) return;
    final result = await (hasFolders
        ? showDeleteFolderDialog(context)
        : showDeleteBookmarkDialog(context));
    if (result != true) return;

    // Normalize to avoid deleting children whose parent folder is also being deleted
    final normalizedGuids = normalizeSelection(root, uiState.selectedGuids);

    await ref
        .read(bookmarksRepositoryProvider.notifier)
        .deleteMany(normalizedGuids);

    uiStateNotifier.exitSelectionMode();

    if (context.mounted) {
      showInfoMessage(context, 'Deleted ${normalizedGuids.length} items');
    }
  }

  // -- Tree Expansion State Helpers --

  /// Collects the GUIDs of all currently expanded nodes from the tree.
  void _snapshotExpansion(
    TreeViewController<BookmarkItem, TreeNode<BookmarkItem>>? controller,
    ObjectRef<Set<String>> expandedGuids,
  ) {
    if (controller == null) return;
    final guids = <String>{};
    _collectExpandedGuids(controller.tree, guids);
    expandedGuids.value = guids;
  }

  void _collectExpandedGuids(TreeNode<BookmarkItem> node, Set<String> guids) {
    if (node.isExpanded && node.key != INode.ROOT_KEY) {
      guids.add(node.key);
    }
    for (final child in node.childrenAsList) {
      _collectExpandedGuids(child as TreeNode<BookmarkItem>, guids);
    }
  }

  /// Restores expansion state by expanding nodes whose GUIDs are in the set.
  void _restoreExpansion(
    TreeViewController<BookmarkItem, TreeNode<BookmarkItem>> controller,
    TreeNode<BookmarkItem> root,
    Set<String> guids,
  ) {
    // Always expand root
    controller.expandNode(root);
    _expandMatchingNodes(controller, root, guids);
  }

  void _expandMatchingNodes(
    TreeViewController<BookmarkItem, TreeNode<BookmarkItem>> controller,
    TreeNode<BookmarkItem> node,
    Set<String> guids,
  ) {
    for (final child in node.childrenAsList) {
      final typedChild = child as TreeNode<BookmarkItem>;
      if (guids.contains(typedChild.key)) {
        controller.expandNode(typedChild);
      }
      _expandMatchingNodes(controller, typedChild, guids);
    }
  }

  // -- Tab Opening Helper --

  Future<void> _openInNewTab(
    BuildContext context,
    WidgetRef ref,
    Uri url, {
    required bool selectTab,
  }) async {
    final currentTab = ref.read(selectedTabStateProvider);
    final tabMode =
        currentTab?.tabMode ??
        TabMode.fromTabType(
          ref
              .read(generalSettingsWithDefaultsProvider)
              .effectiveDefaultCreateTabType,
        );

    final tabId = await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(
          url: url,
          parentId: currentTab?.id,
          selectTab: selectTab,
          tabMode: tabMode,
        );

    if (selectTab) {
      if (context.mounted) {
        const BrowserRoute().go(context);
      }
    } else {
      if (context.mounted) {
        final repo = ref.read(tabRepositoryProvider.notifier);
        showTabSwitchMessage(
          context,
          onSwitch: () async {
            await repo.selectTab(tabId);
          },
        );
      }
    }
  }

  // -- Import/Export (unchanged) --

  Future<void> _handleImport(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: format == 'json' ? ['json'] : ['html', 'htm'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) {
        if (context.mounted) {
          showErrorMessage(context, 'Failed to read file');
        }
        return;
      }

      if (!context.mounted) return;

      // Ask user if they want to erase existing bookmarks
      final shouldReplace = await showImportBookmarksDialog(context);
      if (shouldReplace == null) return; // User cancelled dialog

      final content = await File(file.path!).readAsString();
      final repository = ref.read(bookmarksRepositoryProvider.notifier);

      final count = format == 'json'
          ? await repository.importFromJSON(content, replace: shouldReplace)
          : await repository.importFromHTML(content, replace: shouldReplace);

      if (context.mounted) {
        showInfoMessage(context, 'Imported $count bookmarks successfully');
      }
    } catch (e, s) {
      logger.e('Bookmark import failed', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(context, 'Import failed: $e');
      }
    }
  }

  Future<void> _handleExport(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    try {
      // Create the backup content first
      final repository = ref.read(bookmarksRepositoryProvider.notifier);

      String content;
      if (format == 'json') {
        final data = await repository.exportToJson(root: BookmarkRoot.root);
        if (data == null) {
          throw Exception('Failed to export bookmarks');
        }
        content = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        content = await repository.exportToHTML(root: BookmarkRoot.root);
      }

      // Convert to bytes for the file picker
      final bytes = utf8.encode(content);

      // Now show the save dialog with the content ready
      final dateFormatter = FixedDateTimeFormatter('YYYY-MM-DD_hhmmss');
      final timestamp = dateFormatter.encode(DateTime.now());
      final defaultFileName =
          'bookmarks_$timestamp.${format == 'json' ? 'json' : 'html'}';

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Bookmarks',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: format == 'json' ? ['json'] : ['html', 'htm'],
        bytes: bytes,
      );

      if (outputPath == null) return;

      if (context.mounted) {
        showInfoMessage(context, 'Bookmarks exported successfully');
      }
    } catch (e, s) {
      logger.e('Bookmark export failed', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(context, 'Export failed: $e');
      }
    }
  }
}
