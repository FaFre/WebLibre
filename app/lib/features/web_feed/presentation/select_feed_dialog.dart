import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class SelectFeedDialog extends HookConsumerWidget {
  final Set<Uri> feedUris;

  const SelectFeedDialog({required this.feedUris});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleDialog(
      title: const Text('Add Feed'),
      children: feedUris
          .map(
            (uri) => HookConsumer(
              builder: (context, ref, child) {
                final feedAsync = ref.watch(fetchWebFeedProvider(uri));

                return feedAsync.when(
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
          )
          .toList(),
    );
  }
}
