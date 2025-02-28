import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/domain/entities/equatable_iterable.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_filter.dart';
import 'package:lensai/features/web_feed/domain/providers.dart';
import 'package:lensai/features/web_feed/domain/providers/article_filter.dart';
import 'package:lensai/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:lensai/features/web_feed/presentation/widgets/feed_article_card.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class FeedArticleListScreen extends HookConsumerWidget {
  final Uri? feedId;

  const FeedArticleListScreen({required this.feedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(
      // ignore: provider_parameters
      feedArticleListProvider(FeedFilter(feedId: feedId)),
    );

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            Consumer(
              builder: (context, ref, child) {
                final tags = ref.watch(articleFilterProvider);

                return SliverAppBar(floating: true, title: Text('Articles'));
              },
            ),
          ];
        },
        body: articlesAsync.when(
          data: (articles) {
            return RefreshIndicator(
              onRefresh: () async {
                if (feedId != null) {
                  await ref
                      .read(fetchArticlesControllerProvider.notifier)
                      .fetchFeedArticles(feedId!);
                } else {
                  await ref
                      .read(fetchArticlesControllerProvider.notifier)
                      .fetchAllArticles();
                }
              },
              child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, i) {
                  final article = articles[i];

                  return Consumer(
                    key: ValueKey(article.id),
                    builder: (context, ref, child) {
                      final tags = ref.watch(
                        articleFilterProvider.select(
                          (value) => EquatableCollection(
                            value.tags ?? const {},
                            immutable: false,
                          ),
                        ),
                      );

                      return FeedArticleCard(
                        selectedTags: tags.collection,
                        onTagSelected: (tagId, value) {
                          if (value) {
                            ref
                                .read(articleFilterProvider.notifier)
                                .addTag(tagId);
                          } else {
                            ref
                                .read(articleFilterProvider.notifier)
                                .removeTag(tagId);
                          }
                        },
                        article: article,
                      );
                    },
                  );
                },
              ),
            );
          },
          error:
              (error, stackTrace) => Center(
                child: FailureWidget(
                  title: 'Failed to load Articles',
                  exception: error,
                ),
              ),
          loading: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
