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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/dialogs/delete_bookmark_dialog.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/presentation/widgets/folder_tree_picker.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class BookmarkEntryEditScreen extends HookConsumerWidget {
  final BookmarkInfo? initialInfo;
  final BookmarkEntry? exisitingEntry;

  const BookmarkEntryEditScreen({
    super.key,
    required this.exisitingEntry,
    required this.initialInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final nameTextController = useTextEditingController(
      text: initialInfo?.title ?? exisitingEntry?.title,
    );
    final urlTextController = useTextEditingController(
      text: initialInfo?.url ?? exisitingEntry?.url.toString(),
    );

    final parentGuid = useState(
      initialInfo?.parentGuid ??
          exisitingEntry?.parentGuid ??
          BookmarkRoot.mobile.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: (exisitingEntry != null)
            ? const Text('Edit Bookmark')
            : const Text('Create Bookmark'),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final newUrl = uri_parser.tryParseUrl(
                  urlTextController.text,
                  eagerParsing: true,
                )!;

                if (exisitingEntry != null) {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .editBookmark(
                        guid: exisitingEntry!.guid,
                        title:
                            (nameTextController.text != exisitingEntry!.title)
                            ? nameTextController.text
                            : null,
                        parentGuid:
                            (parentGuid.value != exisitingEntry!.parentGuid)
                            ? parentGuid.value
                            : null,
                        url: (newUrl != exisitingEntry!.url) ? newUrl : null,
                      );

                  if (context.mounted) {
                    context.pop();
                  }
                } else {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .addBookmark(
                        parentGuid: parentGuid.value,
                        title: nameTextController.text,
                        url: newUrl,
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
      body: SafeArea(
        child: Form(
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
                  minLines: 1,
                  maxLines: 3,
                  validator: validateRequired,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: urlTextController,
                  keyboardType: TextInputType.url,
                  minLines: 1,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    label: Text('URL'),
                    hintText: 'https://example.com/',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    return validateUrl(
                      value,
                      onlyHttpProtocol: true,
                      eagerParsing: true,
                    );
                  },
                ),
                const SizedBox(height: 16),
                FolderTreePicker(
                  selectedFolderGuid: parentGuid,
                  entryGuid: BookmarkRoot.root.id,
                ),
                const SizedBox(height: 16),
                if (exisitingEntry != null)
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
                      icon: const Icon(MdiIcons.bookmarkRemove),
                      onPressed: () async {
                        final result = await showDeleteBookmarkDialog(context);

                        if (result == true) {
                          await ref
                              .read(bookmarksRepositoryProvider.notifier)
                              .delete(exisitingEntry!.guid);

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
      ),
    );
  }
}
