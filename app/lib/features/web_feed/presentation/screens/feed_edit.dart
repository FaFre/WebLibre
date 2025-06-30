import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/tag_field.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

enum _DialogMode { create, edit }

class FeedEditScreen extends HookConsumerWidget {
  final _DialogMode _mode;

  final Uri feedId;

  const FeedEditScreen._({required _DialogMode mode, required this.feedId})
    : _mode = mode;

  factory FeedEditScreen.create({required Uri feedId}) {
    return FeedEditScreen._(mode: _DialogMode.create, feedId: feedId);
  }

  factory FeedEditScreen.edit({required Uri feedId}) {
    return FeedEditScreen._(mode: _DialogMode.edit, feedId: feedId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialFeedAsync = switch (_mode) {
      _DialogMode.create => ref.watch(
        fetchWebFeedProvider(
          feedId,
        ).select((value) => value.whenData((result) => result.feedData)),
      ),
      _DialogMode.edit => ref.watch(feedDataProvider(feedId)),
    };

    return initialFeedAsync.when(
      skipLoadingOnReload: true,
      data: (initialFeed) {
        if (initialFeed == null) {
          return Scaffold(
            key: const ValueKey('data'),
            appBar: AppBar(),
            body: const Center(
              child: FailureWidget(title: 'Failed to load feed'),
            ),
          );
        }

        return _FeedEditContent(mode: _mode, initialFeed: initialFeed);
      },
      error: (error, stackTrace) => Scaffold(
        key: const ValueKey('error'),
        appBar: AppBar(),
        body: Center(
          child: FailureWidget(title: 'Failed to load feed', exception: error),
        ),
      ),
      loading: () => Scaffold(
        key: const ValueKey('loading'),
        appBar: AppBar(
          title: Text(switch (_mode) {
            _DialogMode.create => 'New Feed',
            _DialogMode.edit => 'Edit Feed',
          }),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Fetching feed...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedEditContent extends HookConsumerWidget {
  final _DialogMode _mode;

  final FeedData initialFeed;

  const _FeedEditContent({required _DialogMode mode, required this.initialFeed})
    : _mode = mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final initialTags = useMemoized(
      () => initialFeed.tags?.map((tag) => tag.id).toSet(),
      [EquatableValue(initialFeed.tags)],
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
    final iconUrlTextController = useTextEditingController(
      text: initialFeed.icon?.toString(),
    );
    final siteLinkTextController = useTextEditingController(
      text: initialFeed.siteLink?.toString(),
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
                  url: uri_parser.tryParseUrl(
                    urlTextController.text,
                    eagerParsing: true,
                  )!,
                  authors: initialFeed.authors,
                  description: descriptionTextController.text.whenNotEmpty,
                  icon: uri_parser.tryParseUrl(
                    iconUrlTextController.text,
                    eagerParsing: true,
                  ),
                  siteLink: uri_parser.tryParseUrl(
                    siteLinkTextController.text,
                    eagerParsing: true,
                  ),
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
                            child: UrlIcon([
                              initialFeed.icon ??
                                  initialFeed.siteLink ??
                                  initialFeed.url.base,
                            ], iconSize: 24.0),
                          ),
                          label: const Text('Title'),
                        ),
                        controller: titleTextController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Description'),
                          prefixIcon: Icon(Icons.short_text),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        controller: descriptionTextController,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Icon URL'),
                          prefixIcon: Icon(Icons.image),
                        ),
                        keyboardType: TextInputType.url,
                        controller: iconUrlTextController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return validateUrl(
                            value,
                            onlyHttpProtocol: true,
                            required: false,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Site Link'),
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        controller: siteLinkTextController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return validateUrl(
                            value,
                            onlyHttpProtocol: true,
                            required: false,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      TagField(
                        initialTags: tags.value,
                        onTagsUpdate: (newTags) {
                          tags.value = newTags;
                        },
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Feed URL'),
                          prefixIcon: Icon(MdiIcons.rss),
                        ),
                        keyboardType: TextInputType.url,
                        controller: urlTextController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return validateUrl(value, onlyHttpProtocol: true);
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
