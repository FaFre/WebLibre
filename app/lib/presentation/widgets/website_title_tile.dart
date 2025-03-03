import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/presentation/controllers/website_title.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WebsiteTitleTile extends HookConsumerWidget {
  final Uri url;
  final WebPageInfo? precachedInfo;

  const WebsiteTitleTile(this.url, {this.precachedInfo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfoAsync =
        (precachedInfo?.isPageInfoComplete ?? false)
            ? AsyncValue.data(precachedInfo!)
            : ref.watch(pageInfoProvider(url, isImageRequest: false));

    return Skeletonizer(
      enabled: pageInfoAsync.isLoading && precachedInfo == null,
      child: pageInfoAsync.when(
        skipLoadingOnReload: true,
        data: (info) {
          return ListTile(
            leading: RawImage(
              image: info.favicon?.image.value,
              height: 24,
              width: 24,
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(info.title ?? 'Unknown Title'),
            subtitle: Text(url.authority),
          );
        },
        error: (error, stackTrace) {
          return FailureWidget(
            title: error.toString(),
            onRetry:
                () => ref.refresh(pageInfoProvider(url, isImageRequest: false)),
          );
        },
        loading:
            () =>
                (precachedInfo != null)
                    ? ListTile(
                      leading: RawImage(
                        image: precachedInfo!.favicon?.image.value,
                        height: 24,
                        width: 24,
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(precachedInfo!.title ?? 'Unknown Title'),
                      subtitle: Text(url.authority),
                    )
                    : const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Bone.text(),
                      subtitle: Bone.text(),
                    ),
      ),
    );
  }
}
