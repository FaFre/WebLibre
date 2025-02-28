import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/extensions/uri.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_category.dart';
import 'package:lensai/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:lensai/features/web_feed/presentation/widgets/tag_field.dart';
import 'package:lensai/presentation/widgets/url_icon.dart';

enum _DialogMode { create, edit }

class FeedEditScreen extends HookConsumerWidget {
  final _DialogMode _mode;

  final FeedData initialFeed;

  const FeedEditScreen._({required _DialogMode mode, required this.initialFeed})
    : _mode = mode;

  factory FeedEditScreen.create({required FeedData initialFeed}) {
    return FeedEditScreen._(mode: _DialogMode.create, initialFeed: initialFeed);
  }

  factory FeedEditScreen.edit({required FeedData initialFeed}) {
    return FeedEditScreen._(mode: _DialogMode.edit, initialFeed: initialFeed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final initialTags = useMemoized(
      () => initialFeed.tags?.map((tag) => tag.id).toSet(),
    );
    final tags = useRef(initialTags ?? {});

    final titleTextController = useTextEditingController(
      text: initialFeed.title ?? initialFeed.url.host,
    );
    final descriptionTextController = useTextEditingController(
      text: initialFeed.description,
    );
    final urlTextController = useTextEditingController(
      text: initialFeed.url.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_mode) {
          _DialogMode.create => 'New Feed',
          _DialogMode.edit => 'Edit Feed',
        }),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final feedData = FeedData(
                  url: Uri.parse(urlTextController.text),
                  authors: initialFeed.authors,
                  description: descriptionTextController.text.whenNotEmpty,
                  tags: tags.value.map((tag) => FeedCategory(id: tag)).toList(),
                  title: titleTextController.text.whenNotEmpty,
                );

                await ref
                    .read(feedRepositoryProvider.notifier)
                    .upsertFeed(feedData);

                if (context.mounted) {
                  context.pop();
                }
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: UrlIcon(
                              initialFeed.url.base,
                              iconSize: 24.0,
                            ),
                          ),
                          label: const Text('Title'),
                        ),
                        controller: titleTextController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Description'),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        controller: descriptionTextController,
                      ),
                      const SizedBox(height: 16),
                      TagField(
                        initialTags: tags.value,
                        onTagsUpdate: (newTags) {
                          tags.value = newTags;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Address'),
                        ),
                        keyboardType: TextInputType.url,
                        controller: urlTextController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Address must be provided';
                          }

                          if (Uri.tryParse(value!) case final Uri url) {
                            if (url.isScheme('https') ||
                                url.isScheme('http') &&
                                    url.authority.isNotEmpty) {
                              return null;
                            }
                          }

                          return 'Inavlid URL';
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_mode == _DialogMode.edit)
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
                            title: const Text('Delete Feed'),
                            content: const Text(
                              'Are you sure you want to delete this feed and delete all related articles?',
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
                            .read(feedRepositoryProvider.notifier)
                            .deleteFeed(initialFeed.url);

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
