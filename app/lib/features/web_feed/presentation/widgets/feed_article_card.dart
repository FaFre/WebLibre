import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/extensions/uri.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:lensai/features/web_feed/extensions/feed_article.dart';
import 'package:lensai/features/web_feed/presentation/widgets/authors_horizontal_list.dart';
import 'package:lensai/features/web_feed/presentation/widgets/tags_horizontal_list.dart';
import 'package:lensai/presentation/widgets/url_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedArticleCard extends HookConsumerWidget {
  final FeedArticle article;

  final Set<String> selectedTags;
  final void Function(String tagId, bool value)? onTagSelected;

  const FeedArticleCard({
    super.key,
    required this.article,
    this.onTagSelected,
    this.selectedTags = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await ref
              .read(feedRepositoryProvider.notifier)
              .touchArticleRead(article.id);

          if (context.mounted) {
            await context.push(
              FeedArticleRoute(articleId: article.id).location,
              extra: article,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrlIcon(article.feedId.base, iconSize: 34.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.displayTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (article.summaryPlain != null)
                          Text(
                            article.summaryPlain!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (article.lastRead != null)
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(feedRepositoryProvider.notifier)
                            .unsetArticleRead(article.id);
                      },
                      icon: const Icon(Icons.visibility),
                    ),
                ],
              ),
              if (article.authors.isNotEmpty || article.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                if (article.authors.isNotEmpty)
                  AuthorsHorizontalList(authors: article.authors!),
                if (article.tags.isNotEmpty)
                  TagsHorizontalList(
                    tags: article.tags!,
                    selectedTags: selectedTags,
                    onTagSelected: onTagSelected,
                  ),
                const Divider(),
              ],
              Row(
                children: [
                  Text(
                    'Published: ${(article.created != null) ? timeago.format(article.created!) : 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (article.updated != null &&
                      article.updated != article.created)
                    Text(
                      'Updated: ${timeago.format(article.updated!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
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
