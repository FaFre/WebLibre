import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/extensions/uri.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/domain/providers.dart';
import 'package:lensai/features/web_feed/presentation/widgets/authors_horizontal_list.dart';
import 'package:lensai/features/web_feed/presentation/widgets/tags_horizontal_list.dart';
import 'package:lensai/presentation/widgets/rounded_text.dart';
import 'package:lensai/presentation/widgets/url_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedCard extends HookConsumerWidget {
  final FeedData feed;

  const FeedCard({super.key, required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.push(FeedArticleListRoute(feedId: feed.url).location);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrlIcon(feed.url.base, iconSize: 34.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.title ?? feed.url.host,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (feed.description != null)
                          Text(
                            feed.description!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (feed.authors.isNotEmpty || feed.tags.isNotEmpty) ...[
                if (feed.authors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),

                    child: AuthorsHorizontalList(authors: feed.authors!),
                  ),
                if (feed.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),

                    child: TagsHorizontalList(tags: feed.tags!),
                  ),
                const Divider(),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last fetched: ${(feed.lastFetched != null) ? timeago.format(feed.lastFetched!) : 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final countAsync = ref.watch(
                        unreadFeedArticleCountProvider(feed.url),
                      );

                      return countAsync.when(
                        data: (count) {
                          if (count == null) {
                            return const SizedBox();
                          }

                          return RoundedBackground(
                            child: Row(
                              children: [
                                Icon(
                                  MdiIcons.newspaperVariantMultipleOutline,
                                  size: 18,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  count.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        error: (error, stackTrace) => const Text('N/A'),
                        loading: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
