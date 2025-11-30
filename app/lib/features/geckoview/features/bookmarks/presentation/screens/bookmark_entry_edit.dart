import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class BookmarkEntryEditScreen extends HookConsumerWidget {
  final BookmarkInfo? initialInfo;
  final BookmarkEntry? exisitingEntry;

  const BookmarkEntryEditScreen({
    required this.exisitingEntry,
    required this.initialInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final folderList = ref.watch(
      bookmarksProvider<BookmarkFolder>(BookmarkRoot.mobile.id),
    );

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
                Text('Folder', style: Theme.of(context).textTheme.labelMedium),
                folderList.when(
                  data: (list) {
                    TreeNode<BookmarkFolder> addChildren(
                      TreeNode<BookmarkFolder>? parent,
                      BookmarkFolder item,
                    ) {
                      final node = TreeNode(
                        key: item.guid,
                        data: item,
                        parent: parent,
                      );
                      final targetNode = (parent?..add(node)) ?? node;

                      if (item.children != null) {
                        for (final child in item.children!) {
                          addChildren(node, child as BookmarkFolder);
                        }
                      }

                      return targetNode;
                    }

                    final root = (list != null)
                        ? addChildren(null, list)
                        : TreeNode<BookmarkFolder>.root();

                    return TreeView.simple(
                      tree: root,
                      shrinkWrap: true,
                      onTreeReady: (controller) {
                        controller.expandAllChildren(root);
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
                        final isSelected = item.data?.guid == parentGuid.value;

                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: switch (item.data) {
                            final BookmarkFolder folder => ListTile(
                              selected: isSelected,
                              leading: (item.isExpanded)
                                  ? const Icon(MdiIcons.folderOpen)
                                  : const Icon(MdiIcons.folder),
                              trailing: isSelected
                                  ? const Icon(Icons.check)
                                  : null,
                              title: Text(folder.title),
                              onTap: () {
                                parentGuid.value = folder.guid;
                              },
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
                        // ignore: unused_result
                        ref.refresh(
                          bookmarksProvider<BookmarkFolder>(
                            BookmarkRoot.mobile.id,
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
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
                        final result = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              icon: const Icon(Icons.warning),
                              title: const Text('Delete Bookmark'),
                              content: const Text(
                                'Are you sure you want to delete this Bookmark?',
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
