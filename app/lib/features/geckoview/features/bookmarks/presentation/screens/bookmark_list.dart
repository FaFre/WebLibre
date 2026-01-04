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
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/import_bookmarks_dialog.dart';
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
    final treeKey = useMemoized(() => GlobalKey<TreeViewState>());
    final bookmarkList = ref.watch(seamlessBookmarksProvider(entryGuid));

    final textFilterEnabled = useState(false);
    final textFilterController = useTextEditingController();

    useOnListenableChange(textFilterController, () {
      if (ref.exists(seamlessBookmarksProvider(entryGuid))) {
        ref
            .read(seamlessBookmarksProvider(entryGuid).notifier)
            .search(textFilterController.text);
      }
    });

    return Scaffold(
      appBar: AppBar(
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
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.expandAll),
                child: const Text('Expand All Folders'),
                onPressed: () {
                  treeKey.currentState?.controller.mapNotNull((controller) {
                    controller.expandAllChildren(
                      controller.tree,
                      recursive: true,
                    );
                  });
                },
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: bookmarkList.when(
            skipLoadingOnReload: true,
            data: (list) {
              TreeNode<BookmarkItem> addChildren(
                TreeNode<BookmarkItem>? parent,
                BookmarkItem item,
              ) {
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

              final root = (list != null)
                  ? addChildren(null, list)
                  : TreeNode<BookmarkItem>.root();

              return TreeView.simple(
                key: treeKey,
                tree: root,
                showRootNode: entryGuid != BookmarkRoot.root.id,
                onTreeReady: (controller) {
                  if (textFilterEnabled.value) {
                    controller.expandAllChildren(root, recursive: true);
                  } else {
                    controller.expandNode(root);
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
                  return switch (item.data) {
                    final BookmarkEntry bookmark => ListTile(
                      key: ValueKey(bookmark.guid),
                      contentPadding: EdgeInsets.zero,
                      leading: UrlIcon([bookmark.url], iconSize: 34.0),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await BookmarkEntryEditRoute(
                            bookmarkEntry: jsonEncode(bookmark.toJson()),
                          ).push(context);
                        },
                      ),
                      title: Text(
                        bookmark.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    ),
                    final BookmarkFolder folder => Padding(
                      key: ValueKey(folder.guid),
                      padding: (item.isLeaf)
                          ? const EdgeInsets.only(right: 4.0)
                          : const EdgeInsets.only(right: 42.0),
                      child: HookBuilder(
                        builder: (context) {
                          final controller = useMenuController();

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: (item.isExpanded)
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
                                if (!bookmarkRootIds.contains(folder.guid))
                                  MenuItemButton(
                                    leadingIcon: const Icon(
                                      MdiIcons.folderEdit,
                                    ),
                                    child: const Text('Edit'),
                                    onPressed: () async {
                                      await BookmarkFolderEditRoute(
                                        folder: jsonEncode(folder.toJson()),
                                      ).push(context);
                                    },
                                  ),
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
                                  leadingIcon: const Icon(
                                    MdiIcons.bookmarkPlus,
                                  ),
                                  child: const Text('Add Bookmark'),
                                  onPressed: () async {
                                    await BookmarkEntryAddRoute(
                                      bookmarkInfo: jsonEncode(
                                        BookmarkInfo(
                                          parentGuid: folder.guid,
                                        ).encode(),
                                      ),
                                    ).push(context);
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (folder.guid != entryGuid) {
                                await BookmarkListRoute(
                                  entryGuid: folder.guid,
                                ).push(context);
                              }
                            },
                          );
                        },
                      ),
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
            loading: () => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

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
    } catch (e) {
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
    } catch (e) {
      if (context.mounted) {
        showErrorMessage(context, 'Export failed: $e');
      }
    }
  }
}
