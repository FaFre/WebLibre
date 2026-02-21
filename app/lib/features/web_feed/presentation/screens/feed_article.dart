/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/features/web_feed/extensions/atom.dart';
import 'package:weblibre/features/web_feed/extensions/feed_article.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/authors_horizontal_list.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/tags_horizontal_list.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/utils/markdown/image_extractor.dart';
import 'package:weblibre/utils/ui_helper.dart';

enum _Pages { summary, content }

class FeedArticleScreen extends HookConsumerWidget {
  final String articleId;

  const FeedArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(
      feedArticleProvider(articleId, updateReadDate: true),
    );

    return Scaffold(
      body: articleAsync.when(
        skipLoadingOnReload: true,
        data: (article) {
          if (article == null) {
            return const SizedBox.shrink();
          }

          return HookBuilder(
            builder: (context) {
              final hasArticleCreated = article.created != null;
              final hasArticleUpdated =
                  article.updated != null && article.updated != article.created;
              final hasAuthors = article.authors.isNotEmpty;
              final hasTags = article.tags.isNotEmpty;

              final tabs = useMemoized(
                () => [
                  if (article.summaryMarkdown.isNotEmpty) _Pages.summary,
                  if (article.contentMarkdown.isNotEmpty) _Pages.content,
                ],
                [article],
              );

              final tabController = useTabController(
                initialLength: tabs.length,
              );

              final articleLink = useMemoized(
                () =>
                    article.links?.getRelation(FeedLinkRelation.alternate) ??
                    article.links?.getRelation(null),
                [article],
              );

              final articleImages = useMemoized(
                () => (article.contentMarkdown ?? article.summaryMarkdown)
                    .mapNotNull(extractImagesFromMarkdown),
                [article],
              );

              final bottomHeight = useMemoized(() {
                var height = 0.0;

                if (hasArticleCreated) {
                  height += 20;
                }
                if (hasArticleUpdated) {
                  height += 20;
                }
                if (hasAuthors) {
                  height += 56;
                }
                if (hasTags) {
                  height += 56;
                }

                return height;
              }, [article]);

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar.large(
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: EdgeInsetsDirectional.only(
                        start: 72,
                        end: 72,
                        bottom: bottomHeight + 16,
                      ),
                      title: Text(
                        article.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      background: articleImages?.firstOrNull.mapNotNull(
                        (img) => Image.network(
                          img.toString(),
                          fit: BoxFit.cover,
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(200),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size(double.infinity, bottomHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            Text(
                              'Published: ${hasArticleCreated ? ref.read(formatProvider.notifier).fullDateTime(article.created!) : 'N/A'}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                            if (hasArticleUpdated)
                              Text(
                                'Updated: ${ref.read(formatProvider.notifier).fullDateTime(article.updated!)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            if (hasAuthors)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    const Text('Authors:'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AuthorsHorizontalList(
                                        authors: article.authors!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (hasTags)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    const Text('Tags:'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TagsHorizontalList(
                                        tags: article.tags!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      if (articleLink != null)
                        IconButton(
                          onPressed: () async {
                            final isPrivate =
                                ref
                                    .read(generalSettingsWithDefaultsProvider)
                                    .defaultCreateTabType ==
                                TabType.private;

                            await ref
                                .read(tabRepositoryProvider.notifier)
                                .addTab(
                                  url: articleLink.uri,
                                  private: isPrivate,
                                  container: const Value(null),
                                  selectTab: true,
                                );

                            if (context.mounted) {
                              const BrowserRoute().go(context);
                            }
                          },
                          icon: const Icon(Icons.open_in_browser),
                        ),
                    ],
                  ),
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: TabBar(
                  //       controller: tabController,
                  //       tabs: [
                  //         ...tabs.map(
                  //           (tab) => switch (tab) {
                  //             _Pages.summary => const Tab(text: 'Summary'),
                  //             _Pages.content => const Tab(text: 'Article'),
                  //           },
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
                body: TabBarView(
                  controller: tabController,
                  children: [
                    ...tabs.map(
                      (tab) => Markdown(
                        selectable: true,
                        onTapLink: (text, href, title) async {
                          if (href.mapNotNull(Uri.tryParse)
                              case final Uri url) {
                            final isPrivate =
                                ref
                                    .read(generalSettingsWithDefaultsProvider)
                                    .defaultCreateTabType ==
                                TabType.private;

                            await ref
                                .read(tabRepositoryProvider.notifier)
                                .addTab(
                                  url: url,
                                  private: isPrivate,
                                  selectTab: true,
                                );

                            if (context.mounted) {
                              showTabOpenedMessage(
                                context,
                                tabName: title.whenNotEmpty,
                                onShow: () {
                                  const BrowserRoute().go(context);
                                },
                              );
                            }
                          }
                        },
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              blockquoteDecoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                        data: switch (tab) {
                          _Pages.summary => article.summaryMarkdown!,
                          _Pages.content => article.contentMarkdown!,
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed reading article',
            exception: error,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
