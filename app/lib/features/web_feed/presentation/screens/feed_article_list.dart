import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/domain/providers.dart';
import 'package:lensai/features/web_feed/domain/providers/article_filter.dart';
import 'package:lensai/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:lensai/features/web_feed/presentation/widgets/feed_article_card.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:lensai/presentation/widgets/speech_to_text_button.dart';

class FeedArticleListScreen extends HookConsumerWidget {
  final Uri? feedId;

  const FeedArticleListScreen({required this.feedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            HookConsumer(
              builder: (context, ref, child) {
                final tags = ref.watch(articleFilterProvider);
                final feedTitle = ref.watch(
                  feedDataProvider(
                    feedId,
                  ).select((value) => value.valueOrNull?.title.whenNotEmpty),
                );

                final searchTextController = useTextEditingController();

                final hasText = useListenableSelector(
                  searchTextController,
                  () => searchTextController.text.isNotEmpty,
                );

                useListenableCallback(searchTextController, () {
                  ref
                      .read(filteredArticleListProvider(feedId).notifier)
                      .search(searchTextController.text);
                });

                final bottomHeight = useMemoized(() {
                  var height = 56.0 + 4.0;

                  if (tags.isNotEmpty) {
                    height += 48;
                  }

                  return height;
                }, [tags.isNotEmpty]);

                return SliverAppBar(
                  floating: true,
                  title: Text(feedTitle ?? 'Articles'),
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, bottomHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: searchTextController,
                            decoration: InputDecoration(
                              label: const Text('Search'),
                              suffixIcon:
                                  hasText
                                      ? IconButton(
                                        onPressed: () {
                                          searchTextController.clear();
                                        },
                                        icon: const Icon(Icons.clear),
                                      )
                                      : SpeechToTextButton(
                                        onTextReceived: (data) {
                                          searchTextController.text =
                                              data.toString();
                                        },
                                      ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (tags.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FadingScroll(
                                fadingSize: 15,
                                builder: (context, controller) {
                                  return ListView(
                                    controller: controller,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        tags
                                            .map(
                                              (tag) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: FilterChip(
                                                  label: Text(tag),
                                                  showCheckmark: false,
                                                  selected: true,
                                                  onSelected: (value) {},
                                                  onDeleted: () {
                                                    ref
                                                        .read(
                                                          articleFilterProvider
                                                              .notifier,
                                                        )
                                                        .removeTag(tag);
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ];
        },
        body: Consumer(
          builder: (context, ref, child) {
            final articlesAsync = ref.watch(
              // ignore: provider_parameters
              filteredArticleListProvider(feedId),
            );

            return articlesAsync.when(
              skipLoadingOnReload: true,
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
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: articles.length,
                      itemBuilder: (context, i) {
                        final article = articles[i];
                        return FeedArticleCard(
                          key: ValueKey(article.id),
                          article: article,
                        );
                      },
                    ),
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
            );
          },
        ),
      ),
    );
  }
}
