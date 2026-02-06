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
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/delete_folder_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/widgets/folder_tree_picker.dart';
import 'package:weblibre/utils/form_validators.dart';

class BookmarkFolderEditScreen extends HookConsumerWidget {
  final String? parentGuid;
  final BookmarkFolder? folder;

  const BookmarkFolderEditScreen({required this.folder, this.parentGuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameTextController = useTextEditingController(text: folder?.title);

    final currentParentGuid = useState(
      parentGuid ?? folder?.parentGuid ?? BookmarkRoot.mobile.id,
    );

    // Check if this is a bookmark root folder (these cannot be moved)
    final isBookmarkRoot =
        folder != null && bookmarkRootIds.contains(folder!.guid);

    return Scaffold(
      appBar: AppBar(
        title: (folder != null)
            ? const Text('Edit Folder')
            : const Text('Create Folder'),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (folder != null) {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .editFolder(
                        guid: folder!.guid,
                        title: (nameTextController.text != folder!.title)
                            ? nameTextController.text
                            : null,
                        parentGuid:
                            (!isBookmarkRoot &&
                                currentParentGuid.value != folder!.parentGuid)
                            ? currentParentGuid.value
                            : null,
                      );

                  if (context.mounted) {
                    context.pop();
                  }
                } else {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .addFolder(
                        parentGuid: currentParentGuid.value,
                        title: nameTextController.text,
                      );

                  if (context.mounted) {
                    context.pop();
                  }
                }
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ListView(
            children: [
              TextFormField(
                controller: nameTextController,
                decoration: const InputDecoration(
                  label: Text('Name'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: validateRequired,
              ),
              const SizedBox(height: 16),
              if (!isBookmarkRoot) ...[
                FolderTreePicker(
                  selectedFolderGuid: currentParentGuid,
                  excludeFolderGuid: folder?.guid,
                  entryGuid: BookmarkRoot.root.id,
                ),
                const SizedBox(height: 16),
              ],
              if (folder != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      iconColor: Theme.of(context).colorScheme.error,
                    ),
                    label: const Text('Delete'),
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final result = await showDeleteFolderDialog(context);

                      if (result == true) {
                        await ref
                            .read(bookmarksRepositoryProvider.notifier)
                            .delete(folder!.guid);

                        if (context.mounted) {
                          context.pop();
                        }
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
