import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/utils/form_validators.dart';

class BookmarkFolderEditScreen extends HookConsumerWidget {
  final String? parentGuid;
  final BookmarkFolder? folder;

  const BookmarkFolderEditScreen({required this.folder, this.parentGuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameTextController = useTextEditingController(text: folder?.title);

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
                        title: nameTextController.text,
                      );

                  if (context.mounted) {
                    context.pop();
                  }
                } else {
                  await ref
                      .read(bookmarksRepositoryProvider.notifier)
                      .addFolder(
                        parentGuid: parentGuid ?? BookmarkRoot.mobile.id,
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
                      final result = await showDialog<bool?>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            icon: const Icon(Icons.warning),
                            title: const Text('Delete Folder'),
                            content: const Text(
                              'Are you sure you want to delete this Folder including all bookmarks?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

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
