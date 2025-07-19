import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/extensions/ref_cache.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'website_title.g.dart';

const _supportedFetchSchemes = {'http', 'https'};

@Riverpod()
class CompletePageInfo extends _$CompletePageInfo {
  @override
  AsyncValue<WebPageInfo> build(Uri url, WebPageInfo? cached) {
    ref.cacheFor(const Duration(minutes: 2));

    if (cached?.isPageInfoComplete == true ||
        !_supportedFetchSchemes.contains(url.scheme)) {
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
  final tabId = ref.read(selectedTabProvider);

  int? proxyPort;
  if (tabId != null) {
    final containerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .containerTabId(tabId);

    final containerData = await containerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    if (containerData?.metadata.useProxy == true) {
      proxyPort = await ref.read(torProxyServiceProvider.future);

      if (proxyPort == null) {
        throw Exception('Could not proxy request');
      }
    }
  }

  final result = await ref
      .watch(genericWebsiteServiceProvider.notifier)
      .fetchPageInfo(
        url: url,
        isImageRequest: isImageRequest,
        proxyPort: proxyPort,
      );

  if (result.isSuccess) {
    ref.cacheFor(const Duration(minutes: 2));
  }

  return result.value;
}
