import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/services/generic_website.dart';

part 'website_title.g.dart';

@Riverpod()
class CompletePageInfo extends _$CompletePageInfo {
  @override
  AsyncValue<WebPageInfo> build(Uri url, WebPageInfo? cached) {
    if (cached?.isPageInfoComplete == true) {
      return AsyncData(cached!);
    }

    ref.listen(
      fireImmediately: true,
      pageInfoProvider(url, isImageRequest: false),
      (previous, next) {
        if (cached != null && next.hasValue) {
          state = AsyncData(
            WebPageInfo(
              url: url,
              //Cached is preferred as this comes from gecko and is more likely to be correct compared to manual request
              favicon: cached.favicon ?? next.value!.favicon,
              feeds: cached.feeds ?? next.value!.feeds,
              title: cached.title ?? next.value!.title,
            ),
          );
        } else {
          state = next;
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to pageInfoProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    return (cached != null) ? AsyncData(cached) : const AsyncLoading();
  }
}

@Riverpod()
Future<WebPageInfo> pageInfo(
  Ref ref,
  Uri url, {
  required bool isImageRequest,
}) async {
  final websiteService = ref.watch(genericWebsiteServiceProvider.notifier);

  final result = await websiteService.fetchPageInfo(url, isImageRequest);

  if (result.isSuccess) {
    ref.keepAlive();
  }

  return result.value;
}
