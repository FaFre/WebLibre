import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/extensions/uri.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/models/feed_article_query_result.dart';
import 'package:lensai/features/web_feed/domain/providers/article_filter.dart';
import 'package:lensai/features/web_feed/domain/repositories/feed_repository.dart';
import 'package:lensai/features/web_feed/extensions/feed_article.dart';
import 'package:lensai/features/web_feed/presentation/widgets/authors_horizontal_list.dart';
import 'package:lensai/features/web_feed/presentation/widgets/tags_horizontal_list.dart';
import 'package:lensai/presentation/widgets/url_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedArticleCard extends HookConsumerWidget {
  final FeedArticle article;

  const FeedArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final tags = ref.watch(articleFilterProvider);

    final titleHighlight = switch (article) {
      final FeedArticleQueryResult result => result.titleHighlight.whenNotEmpty,
      _ => null,
    };

    final searchSnippet = switch (article) {
      final FeedArticleQueryResult result =>
        result.summarySnippet.whenNotEmpty ??
            result.contentSnippet.whenNotEmpty,
      _ => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await FeedArticleRoute(articleId: article.id).push(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrlIcon([
                    article.icon ?? article.feedId.base,
                  ], iconSize: 34.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleHighlight.isNotEmpty)
                          MarkdownBody(
                            data: titleHighlight!,
                            styleSheet: MarkdownStyleSheet(
                              p: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        if (titleHighlight.isEmpty)
                          Text(
                            article.displayTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                        if (searchSnippet.isNotEmpty)
                          MarkdownBody(
                            data: searchSnippet!,
                            styleSheet: MarkdownStyleSheet(
                              p: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                              a: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        if (searchSnippet.isEmpty &&
                            article.summaryPlain != null)
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
                  AuthorsHorizontalList(
                    authors: article.authors!,
                    selectedTags: tags,
                    onTagSelected: (tagId, value) {
                      if (value) {
                        ref.read(articleFilterProvider.notifier).addTag(tagId);
                      } else {
                        ref
                            .read(articleFilterProvider.notifier)
                            .removeTag(tagId);
                      }
                    },
                  ),
                if (article.tags.isNotEmpty)
                  TagsHorizontalList(
                    tags: article.tags!,
                    selectedTags: tags,
                    onTagSelected: (tagId, value) {
                      if (value) {
                        ref.read(articleFilterProvider.notifier).addTag(tagId);
                      } else {
                        ref
                            .read(articleFilterProvider.notifier)
                            .removeTag(tagId);
                      }
                    },
                  ),
              ],
              const Divider(),
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
