import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/web_feed/domain/providers.dart';
import 'package:lensai/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:lensai/features/web_feed/presentation/widgets/feed_card.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class FeedListScreen extends HookConsumerWidget {
  const FeedListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(feedListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feeds')),
      body: feeds.when(
        data: (feeds) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(fetchArticlesControllerProvider.notifier)
                  .fetchAllArticles();
            },
            child: ListView.builder(
              itemCount: feeds.length,
              itemBuilder: (context, i) {
                return FeedCard(feed: feeds[i]);
              },
            ),
          );
        },
        error:
            (error, stackTrace) => Center(
              child: FailureWidget(
                title: 'Failed to load Feeds',
                exception: error,
              ),
            ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
