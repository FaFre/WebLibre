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
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/uri_input_parser.dart';

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
    final l10n = AppLocalizations.of(context);
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

    final addToTop = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: (exisitingEntry != null)
            ? Text(l10n.bookmarks_editBookmarkTitle)
            : Text(l10n.bookmarks_createBookmarkTitle),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                var newUrl = parseValidatedUrl(
                  urlTextController.text,
                  eagerParsing: true,
                  onlyHttpProtocol: true,
                );

                if (newUrl == null) {
                  return;
                }

                newUrl = redactUriCredentials(newUrl);

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
                        position: addToTop.value ? 0 : null,
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
                  decoration: InputDecoration(
                    label: Text(l10n.bookmarks_fieldNameLabel),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  minLines: 1,
                  maxLines: 3,
                  validator: (value) => validateRequired(value, l10n: l10n),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: urlTextController,
                  keyboardType: TextInputType.url,
                  minLines: 1,
                  maxLines: 10,
                  decoration: InputDecoration(
                    label: Text(l10n.bookmarks_fieldUrlLabel),
                    hintText: 'https://example.com/',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    return validateUrl(
                      value,
                      onlyHttpProtocol: true,
                      eagerParsing: true,
                      l10n: l10n,
                    );
                  },
                ),
                const SizedBox(height: 16),
                FolderTreePicker(
                  selectedFolderGuid: parentGuid,
                  entryGuid: BookmarkRoot.root.id,
                ),
                if (exisitingEntry == null) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.bookmarks_addToTop),
                    value: addToTop.value,
                    onChanged: (value) => addToTop.value = value,
                  ),
                ],
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
                      label: Text(l10n.common_delete),
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
