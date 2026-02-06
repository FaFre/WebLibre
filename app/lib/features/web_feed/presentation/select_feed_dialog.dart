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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// Bottom sheet widget to select a feed from discovered feeds.
class SelectFeedDialog extends HookConsumerWidget {
  final Set<Uri> feedUris;

  const SelectFeedDialog({required this.feedUris});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Feed', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...feedUris.map(
              (uri) => HookConsumer(
                builder: (context, ref, child) {
                  final feedAsync = ref.watch(fetchWebFeedProvider(uri));

                  return feedAsync.when(
                    skipLoadingOnReload: true,
                    data: (data) {
                      return ListTile(
                        title: Text(
                          data.feedData.title.whenNotEmpty ?? 'Unnamed Feed',
                        ),
                        subtitle: Text(uri.toString()),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          FeedCreateRoute(feedId: uri).pushReplacement(context);
                        },
                      );
                    },
                    error: (error, stackTrace) => FailureWidget(
                      title: 'Failed to fetch Feed',
                      exception: error,
                      onRetry: () {
                        // ignore: unused_result
                        ref.refresh(fetchWebFeedProvider(uri));
                      },
                    ),
                    loading: () => Skeletonizer(
                      child: ListTile(
                        title: Text(BoneMock.title),
                        subtitle: Skeleton.keep(child: Text(uri.toString())),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
