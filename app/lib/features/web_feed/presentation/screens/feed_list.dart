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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:weblibre/features/web_feed/presentation/widgets/feed_card.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class FeedListScreen extends HookConsumerWidget {
  const FeedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(feedListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeds'),
        actions: [
          HookBuilder(
            builder: (context) {
              final future = useState<Future<void>?>(null);
              final state = useFuture(future.value);

              if (state.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                );
              }

              return IconButton(
                onPressed: () {
                  future.value = ref
                      .read(fetchArticlesControllerProvider.notifier)
                      .fetchAllArticles();
                },
                icon: const Icon(MdiIcons.cloudSync),
              );
            },
          ),
        ],
      ),
      body: feeds.when(
        skipLoadingOnReload: true,
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
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed to load Feeds',
            exception: error,
            onRetry: () {
              // ignore: unused_result
              ref.refresh(feedListProvider);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Feed'),
        icon: const Icon(Icons.add),
        onPressed: () async {
          await const FeedAddRoute(uri: null).push(context);
        },
      ),
    );
  }
}
