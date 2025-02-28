import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/presentation/controllers/website_title.dart';
import 'package:lensai/presentation/widgets/rounded_text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WebsiteFeedTile extends HookConsumerWidget {
  final Uri url;
  final WebPageInfo? precachedInfo;

  const WebsiteFeedTile(this.url, {this.precachedInfo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfoAsync =
        (precachedInfo?.feeds != null)
            ? AsyncValue.data(precachedInfo!)
            : ref.watch(pageInfoProvider(url));

    return Skeletonizer(
      enabled: pageInfoAsync.isLoading && precachedInfo?.feeds == null,
      child: pageInfoAsync.when(
        data: (info) {
          if (info.feeds.isEmpty) {
            return const SizedBox.shrink();
          }

          return ListTile(
            leading: const Icon(Icons.rss_feed),
            title: const Text('Available Web Feeds'),
            trailing: RoundedBackground(
              child: Text(
                info.feeds!.length.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return const SizedBox.shrink();

          //Will be dispalyed on title already

          // return FailureWidget(
          //   title: error.toString(),
          //   onRetry: () => ref.refresh(pageInfoProvider(url)),
          // );
        },
        loading:
            () => const ListTile(
              leading: Icon(Icons.rss_feed),
              contentPadding: EdgeInsets.zero,
              title: Text('Available Web Feeds'),
              trailing: Bone.icon(),
            ),
      ),
    );
  }
}
