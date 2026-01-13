/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/features/web_feed/domain/providers/article_filter.dart';
import 'package:weblibre/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/feed_article_card.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';

class FeedArticleListScreen extends HookConsumerWidget {
  final Uri? feedId;

  const FeedArticleListScreen({required this.feedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(articleFilterProvider);
    final articlesAsync = ref.watch(
      // ignore: provider_parameters
      filteredArticleListProvider(feedId),
    );

    final feedTitle = ref.watch(
      feedDataProvider(
        feedId,
      ).select((value) => value.value?.title.whenNotEmpty),
    );

    final focusNode = useFocusNode();
    final searchTextController = useTextEditingController();

    final hasText = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    useOnListenableChange(searchTextController, () {
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

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              title: Text(feedTitle ?? 'Articles'),
              bottom: PreferredSize(
                preferredSize: Size(double.infinity, bottomHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        focusNode: focusNode,
                        controller: searchTextController,
                        decoration: InputDecoration(
                          label: const Text('Search'),
                          suffixIcon: hasText
                              ? IconButton(
                                  onPressed: () {
                                    searchTextController.clear();
                                    focusNode.requestFocus();
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : SpeechToTextButton(
                                  onTextReceived: (data) {
                                    searchTextController.text = data;
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
                                children: tags
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
            ),
          ];
        },
        body: articlesAsync.when(
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
          error: (error, stackTrace) => Center(
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
