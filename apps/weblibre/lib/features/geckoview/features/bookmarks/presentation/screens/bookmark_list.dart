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
import 'dart:async';
import 'dart:convert';

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
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_list_ui_state.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_sort_type.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/import_bookmark_node.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmark_list_ui_state.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/utils/bookmark_tree_utils.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/delete_bookmark_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/delete_folder_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/import_bookmarks_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/import_progress_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/select_bookmark_folder_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/utils/bookmark_import_isolate.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// How many hits an in-list search asks storage for.
///
/// Generous enough to be useful on a large library while staying a bounded,
/// lazily rendered list.
const _searchResultLimit = 200;

/// Indentation applied per level of folder nesting.
const _indentPerDepth = 20.0;

class BookmarkListScreen extends HookConsumerWidget {
  final String entryGuid;

  const BookmarkListScreen({super.key, required this.entryGuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideEmptyRoots = useState(true);
    final uiState = ref.watch(bookmarkListUiStateProvider);
    final uiStateNotifier = ref.read(bookmarkListUiStateProvider.notifier);

    // Only the folder being shown is loaded. Descendants stay in storage until
    // the user navigates into them, which is what keeps this screen openable on
    // a large library.
    final folderAsync = ref.watch(
      bookmarkListFolderProvider(
        entryGuid,
        hideEmptyRoots: hideEmptyRoots.value,
      ),
    );

    final textFilterEnabled = useState(false);
    final textFilterController = useTextEditingController();
    final searchQuery = useState('');

    useOnListenableChange(textFilterController, () {
      searchQuery.value = textFilterController.text;
      // Searching goes through storage rather than filtering a loaded tree, so
      // it reaches bookmarks this screen never loaded.
      unawaited(
        ref
            .read(bookmarkSearchResultsProvider.notifier)
            .search(textFilterController.text, limit: _searchResultLimit),
      );
    });

    final isSearching = searchQuery.value.isNotEmpty;
    final searchResults = ref.watch(bookmarkSearchResultsProvider);

    // Folders the user has opened. Keyed by guid so expansion survives sort and
    // filter changes.
    final expandedGuids = useState(<String>{});

    // Storage can only match bookmarks, never folders, so "Folders Only" and a
    // search query have no overlap to show.
    final searchSuppressedByFilter = isSearching && uiState.foldersOnly;

    // Everything currently on screen, flattened. Selection is resolved against
    // exactly these rows — search hits come from anywhere in the library, and
    // expanded folders contribute items from below the entry folder.
    final rows = isSearching
        ? [
            if (!searchSuppressedByFilter)
              for (final result in searchResults) BookmarkRow(result, 0),
          ]
        : _buildRows(
            ref,
            folderAsync.value,
            uiState,
            expandedGuids.value,
            depth: 0,
          );

    return PopScope(
      canPop: !uiState.selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && uiState.selectionMode) {
          uiStateNotifier.exitSelectionMode();
        }
      },
      child: Scaffold(
        appBar: uiState.selectionMode
            ? _buildSelectionAppBar(
                context,
                ref,
                uiState,
                uiStateNotifier,
                rows,
              )
            : _buildNormalAppBar(
                context,
                ref,
                hideEmptyRoots,
                expandedGuids,
                textFilterEnabled,
                textFilterController,
                uiStateNotifier,
                uiState,
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: isSearching
                ? _buildRowList(
                    context,
                    ref,
                    rows,
                    uiState,
                    uiStateNotifier,
                    expandedGuids,
                    emptyLabel: searchSuppressedByFilter
                        ? 'Search matches bookmarks, which "Folders Only" is '
                              'hiding'
                        : 'No bookmarks match "${searchQuery.value}"',
                  )
                : folderAsync.when(
                    skipLoadingOnReload: true,
                    data: (_) => _buildRowList(
                      context,
                      ref,
                      rows,
                      uiState,
                      uiStateNotifier,
                      expandedGuids,
                      emptyLabel: 'Empty',
                    ),
                    error: (error, stackTrace) => Center(
                      child: FailureWidget(
                        title: 'Failed to load Bookmarks',
                        exception: error,
                        onRetry: () {
                          ref.invalidate(bookmarkFolderProvider(entryGuid));
                        },
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),
      ),
    );
  }

  /// Flattens the entry folder and every expanded folder beneath it into rows.
  ///
  /// A folder's children are only requested once it is expanded, so a collapsed
  /// subtree costs nothing — this is what keeps the screen openable after a
  /// large import or sync. Watching the child providers here means expanding
  /// starts the load and the row list rebuilds when it lands.
  List<BookmarkRow> _buildRows(
    WidgetRef ref,
    BookmarkFolder? folder,
    BookmarkListUiState uiState,
    Set<String> expandedGuids, {
    required int depth,
  }) {
    final rows = <BookmarkRow>[];

    for (final item in _visibleChildren(folder, uiState, depth: depth)) {
      rows.add(BookmarkRow(item, depth));

      if (item is! BookmarkFolder || !expandedGuids.contains(item.guid)) {
        continue;
      }

      final child = ref.watch(bookmarkFolderProvider(item.guid));
      if (child.value == null) {
        rows.add(BookmarkRow(item, depth + 1, isPlaceholder: true));
        continue;
      }

      rows.addAll(
        _buildRows(ref, child.value, uiState, expandedGuids, depth: depth + 1),
      );
    }

    return rows;
  }

  /// The children of [folder] in display order, with the folders-only filter
  /// applied.
  List<BookmarkItem> _visibleChildren(
    BookmarkFolder? folder,
    BookmarkListUiState uiState, {
    required int depth,
  }) {
    var children = folder?.children ?? const <BookmarkItem>[];

    if (uiState.foldersOnly) {
      children = children.whereType<BookmarkFolder>().toList();
    }

    return sortBookmarkChildren(
      children,
      uiState.sortType,
      // Only the entry level can be the tree root, and only there do the
      // built-in folders need pinning.
      isRoot: depth == 0 && entryGuid == BookmarkRoot.root.id,
    );
  }

  /// Renders the flattened rows lazily.
  ///
  /// [ListView.builder] only builds the tiles actually on screen, so expanding
  /// a folder with thousands of entries stays as cheap as a small one.
  Widget _buildRowList(
    BuildContext context,
    WidgetRef ref,
    List<BookmarkRow> rows,
    BookmarkListUiState uiState,
    BookmarkListUiStateNotifier uiStateNotifier,
    ValueNotifier<Set<String>> expandedGuids, {
    required String emptyLabel,
  }) {
    if (rows.isEmpty) {
      return Center(child: Text(emptyLabel));
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        final item = row.item;
        final isSelected = uiState.selectedGuids.contains(item.guid);

        return Padding(
          padding: EdgeInsets.only(left: row.depth * _indentPerDepth),
          child: row.isPlaceholder
              ? const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: SizedBox(
                      height: 16.0,
                      width: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                )
              : switch (item) {
                  final BookmarkEntry bookmark => _buildEntryTile(
                    context,
                    ref,
                    bookmark,
                    uiState,
                    uiStateNotifier,
                    isSelected,
                  ),
                  final BookmarkFolder folder => _buildFolderTile(
                    context,
                    ref,
                    folder,
                    uiState: uiState,
                    uiStateNotifier: uiStateNotifier,
                    isSelected: isSelected,
                    isExpanded: expandedGuids.value.contains(folder.guid),
                    onToggleExpanded: () {
                      final next = {...expandedGuids.value};
                      if (!next.remove(folder.guid)) next.add(folder.guid);
                      expandedGuids.value = next;
                    },
                  ),
                },
        );
      },
    );
  }

  // -- App Bars --

  PreferredSizeWidget _buildSelectionAppBar(
    BuildContext context,
    WidgetRef ref,
    BookmarkListUiState uiState,
    BookmarkListUiStateNotifier uiStateNotifier,
    List<BookmarkRow> rows,
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
              ? () => _bulkOpenInBackground(context, ref, uiState, rows)
              : null,
        ),
        IconButton(
          icon: const Icon(MdiIcons.folderMove),
          tooltip: 'Move selected',
          onPressed: count > 0
              ? () => _bulkMove(context, ref, uiState, rows)
              : null,
        ),
        IconButton(
          icon: const Icon(MdiIcons.delete),
          tooltip: 'Delete selected',
          onPressed: count > 0
              ? () => _bulkDelete(context, ref, uiState, uiStateNotifier, rows)
              : null,
        ),
      ],
    );
  }

  AppBar _buildNormalAppBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> hideEmptyRoots,
    ValueNotifier<Set<String>> expandedGuids,
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
            // Adding is otherwise only reachable from a child folder's row
            // menu, which leaves an empty folder with no way to fill it.
            // BookmarkRoot.root holds only the built-in folders, so it takes
            // no children of its own.
            if (entryGuid != BookmarkRoot.root.id) ...[
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.bookmarkPlus),
                child: const Text('Add Bookmark Here'),
                onPressed: () async {
                  await BookmarkEntryAddRoute(
                    bookmarkInfo: jsonEncode(
                      BookmarkInfo(parentGuid: entryGuid).encode(),
                    ),
                  ).push(context);
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.folderPlus),
                child: const Text('Add Subfolder Here'),
                onPressed: () async {
                  await BookmarkFolderAddRoute(
                    parentGuid: entryGuid,
                  ).push(context);
                },
              ),
            ],
            SubmenuButton(
              leadingIcon: const Icon(MdiIcons.eye),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.collapseAll),
                  onPressed: expandedGuids.value.isEmpty
                      ? null
                      : () => expandedGuids.value = <String>{},
                  child: const Text('Collapse All'),
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
                  onPressed: uiStateNotifier.toggleFoldersOnly,
                  child: Text(
                    uiState.foldersOnly ? 'Show Bookmarks' : 'Folders Only',
                  ),
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
                    onPressed: () => uiStateNotifier.setSortType(sortType),
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
                  onPressed: () =>
                      _handleImport(context, ref, BookmarkImportFormat.json),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.xml),
                  child: const Text('HTML'),
                  onPressed: () =>
                      _handleImport(context, ref, BookmarkImportFormat.html),
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
      trailing: _buildEntryMenu(context, ref, bookmark),
      title: Text(bookmark.title, maxLines: 3, overflow: TextOverflow.ellipsis),
      subtitle: UriBreadcrumb(uri: bookmark.url),
      onTap: () => _openBookmark(context, ref, bookmark.url),
      onLongPress: () {
        uiStateNotifier.enterSelectionMode(initialGuid: bookmark.guid);
      },
    );
  }

  Widget _buildEntryMenu(
    BuildContext context,
    WidgetRef ref,
    BookmarkEntry bookmark,
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
    required BookmarkListUiState uiState,
    required BookmarkListUiStateNotifier uiStateNotifier,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onToggleExpanded,
  }) {
    final isRoot = bookmarkRootIds.contains(folder.guid);

    if (uiState.selectionMode) {
      return Padding(
        key: ValueKey(folder.guid),
        padding: const EdgeInsets.only(right: 4.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(isExpanded ? MdiIcons.folderOpen : MdiIcons.folder),
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
      padding: const EdgeInsets.only(right: 4.0),
      child: HookBuilder(
        builder: (context) {
          final controller = useMenuController();

          return ListTile(
            contentPadding: EdgeInsets.zero,
            // Whether a folder has children is unknown until it is opened, so
            // every folder offers the toggle. Tapping the row still navigates
            // into it, as it did before.
            leading: IconButton(
              icon: Icon(isExpanded ? MdiIcons.folderOpen : MdiIcons.folder),
              tooltip: isExpanded ? 'Collapse' : 'Expand',
              onPressed: onToggleExpanded,
            ),
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
    List<BookmarkRow> rows,
  ) async {
    // Not normalised: opening is additive, so a bookmark selected inside an
    // also-selected folder should still open rather than be dropped.
    final entries = resolveSelectedItems([
      for (final row in rows)
        if (!row.isPlaceholder) row.item,
    ], uiState.selectedGuids).whereType<BookmarkEntry>().toList();

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
    List<BookmarkRow> rows,
  ) async {
    final items = _selectedItems(rows, uiState.selectedGuids);
    if (items.isEmpty) return;

    // A folder cannot be moved inside itself, so exclude each selected folder
    // and its descendants. Fetched from storage rather than read off the list,
    // which only knows the level currently on screen.
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

    await repo.moveMany(items: items, targetParentGuid: targetGuid);

    ref.read(bookmarkListUiStateProvider.notifier).exitSelectionMode();

    if (context.mounted) {
      showInfoMessage(context, 'Moved ${items.length} items');
    }
  }

  Future<void> _bulkDelete(
    BuildContext context,
    WidgetRef ref,
    BookmarkListUiState uiState,
    BookmarkListUiStateNotifier uiStateNotifier,
    List<BookmarkRow> rows,
  ) async {
    final items = _selectedItems(rows, uiState.selectedGuids);
    if (items.isEmpty) return;

    final folderGuids = items
        .whereType<BookmarkFolder>()
        .map((folder) => folder.guid)
        .toList();

    // Deleting a folder takes everything under it, which the user cannot see
    // from here — so say how much before asking.
    final nestedCount = folderGuids.isEmpty
        ? 0
        : await ref
              .read(bookmarksRepositoryProvider.notifier)
              .countBookmarksInTrees(folderGuids);

    if (!context.mounted) return;
    final result = await (folderGuids.isNotEmpty
        ? showDeleteFolderDialog(context, bookmarkCount: nestedCount)
        : showDeleteBookmarkDialog(context));
    if (result != true) return;

    final guids = items.map((item) => item.guid).toSet();
    await ref.read(bookmarksRepositoryProvider.notifier).deleteMany(guids);

    uiStateNotifier.exitSelectionMode();

    if (context.mounted) {
      showInfoMessage(context, 'Deleted ${guids.length} items');
    }
  }

  /// The selected items, with anything nested inside another selected folder
  /// dropped.
  ///
  /// Expanding a folder puts its children on screen next to it, so a user can
  /// select both — acting on each in turn would move a child out of the folder
  /// that just moved, or delete it a second time.
  List<BookmarkItem> _selectedItems(
    List<BookmarkRow> rows,
    Set<String> selectedGuids,
  ) {
    final guids = normalizeSelection(rows, selectedGuids);

    return resolveSelectedItems([
      for (final row in rows)
        if (!row.isPlaceholder) row.item,
    ], guids);
  }

  // -- Tab Opening Helper --

  /// Opens a tapped bookmark according to [BookmarkOpenSetting]. `ask` shows
  /// the "open in..." sheet (the historical, default behavior); the other
  /// values open the bookmark directly with no intermediate prompt.
  Future<void> _openBookmark(
    BuildContext context,
    WidgetRef ref,
    Uri url,
  ) async {
    final settings = ref.read(generalSettingsWithDefaultsProvider);

    switch (settings.effectiveBookmarkOpenSetting) {
      case BookmarkOpenSetting.ask:
        final result = await OpenSharedContentRoute(
          sharedUrl: url.toString(),
        ).push<bool>(context);

        if (result == true && context.mounted) {
          const BrowserRoute().go(context);
        }
      case BookmarkOpenSetting.regular:
      case BookmarkOpenSetting.private:
      case BookmarkOpenSetting.isolated:
        final effective = settings.effectiveBookmarkOpenSetting;
        final tabMode = switch (effective) {
          BookmarkOpenSetting.private => TabMode.private,
          BookmarkOpenSetting.isolated => TabMode.newIsolated(),
          _ => TabMode.regular,
        };

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: url,
              tabMode: tabMode,
              selectTab: true,
              containerSelection: effective == BookmarkOpenSetting.isolated
                  ? const TabContainerSelection.unassigned()
                  : const TabContainerSelection.useSelected(),
            );

        if (context.mounted) {
          const BrowserRoute().go(context);
        }
      case BookmarkOpenSetting.customTab:
        final containerRepo = ref.read(containerRepositoryProvider.notifier);

        ContainerData? container;
        if (url.hasAuthority && url.isHttpOrHttps) {
          final siteAssignedId = await containerRepo.siteAssignedContainerId(
            url,
          );
          if (siteAssignedId != null) {
            container = await containerRepo.getContainerData(siteAssignedId);
          }
        }
        container ??= await ref
            .read(selectedContainerProvider.notifier)
            .fetchData();

        await GeckoBrowserService().openInCustomTab(
          url: url,
          private: false,
          contextId: container?.metadata.contextualIdentity,
        );
    }
  }

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
    BookmarkImportFormat format,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: format == BookmarkImportFormat.json
            ? ['json']
            : ['html', 'htm'],
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

      if (!context.mounted) return;

      // Writing tens of thousands of bookmarks takes long enough that the app
      // would look frozen without something to watch.
      final progress = ValueNotifier<BookmarkImportProgress>(
        const BookmarkImportProgress(phase: BookmarkImportPhase.parsing),
      );

      final progressDialog = showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ImportProgressDialog(progress: progress),
      );

      final int count;
      try {
        // Reading and parsing happen in a background isolate, so a large file
        // does not freeze the UI while it is being processed.
        count = await ref
            .read(bookmarksRepositoryProvider.notifier)
            .importFromFile(
              path: file.path!,
              format: format,
              replace: shouldReplace,
              onProgress: (value) => progress.value = value,
            );
      } finally {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          await progressDialog;
        }
        progress.dispose();
      }

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

      final outputPath = await FilePicker.saveFile(
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
