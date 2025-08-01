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
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/extensions/ref_cache.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'website_title.g.dart';

const _supportedFetchSchemes = {'http', 'https'};

@Riverpod()
class CompletePageInfo extends _$CompletePageInfo {
  @override
  AsyncValue<WebPageInfo> build(TabState cached) {
    ref.cacheFor(const Duration(minutes: 2));

    if (cached.isPageInfoComplete ||
        !_supportedFetchSchemes.contains(cached.url.scheme)) {
      return AsyncData(cached);
    }

    ref.listen(
      fireImmediately: true,
      pageInfoProvider(cached.url, isImageRequest: false),
      (previous, next) {
        if (next.hasValue) {
          final current = stateOrNull?.valueOrNull ?? cached;

          state = AsyncData(
            current.copyWith(
              //Cached is preferred as this comes from gecko and is more likely to be correct compared to manual request
              favicon: current.favicon ?? next.value!.favicon,
              feeds: current.feeds ?? next.value!.feeds,
              title: current.title.whenNotEmpty ?? next.value!.title,
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

    ref.listen(
      fireImmediately: true,
      tabStateProvider(cached.id).select((value) => value?.title.whenNotEmpty),
      (previous, next) {
        if (next != null) {
          final current = stateOrNull?.valueOrNull ?? cached;
          state = AsyncData(current.copyWith.title(next));
        }
      },
    );

    ref.listen(
      fireImmediately: true,
      tabStateProvider(cached.id).select((value) => value?.favicon),
      (previous, next) {
        if (next != null) {
          final current = stateOrNull?.valueOrNull ?? cached;
          state = AsyncData(current.copyWith.favicon(next));
        }
      },
    );

    return AsyncData(cached);
  }
}

@Riverpod()
Future<WebPageInfo> pageInfo(
  Ref ref,
  Uri url, {
  required bool isImageRequest,
}) async {
  final link = ref.cacheFor(const Duration(minutes: 2));

  final tabId = ref.read(selectedTabProvider);

  int? proxyPort;
  if (tabId != null) {
    final containerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getContainerTabId(tabId);

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

  if (!result.isSuccess) {
    link.close();
  }

  return result.value;
}
