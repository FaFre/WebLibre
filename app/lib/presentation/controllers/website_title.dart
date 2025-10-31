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
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/extensions/ref_cache.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

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

    // ref.listen(
    //   fireImmediately: true,
    //   pageInfoProvider(cached.url, isImageRequest: false),
    //   (previous, next) {
    //     if (next.hasValue) {
    //       final current = stateOrNull?.value ?? cached;

    //       state = AsyncData(
    //         current.copyWith(
    //           //Cached is preferred as this comes from gecko and is more likely to be correct compared to manual request
    //           favicon: current.favicon ?? next.value!.favicon,
    //           feeds: current.feeds ?? next.value!.feeds,
    //           title: current.title.whenNotEmpty ?? next.value!.title,
    //         ),
    //       );
    //     } else {
    //       state = next;
    //     }
    //   },
    //   onError: (error, stackTrace) {
    //     logger.e(
    //       'Error listening to pageInfoProvider',
    //       error: error,
    //       stackTrace: stackTrace,
    //     );
    //   },
    // );

    ref.listen(
      fireImmediately: true,
      tabStateProvider(cached.id).select((value) => value?.title),
      (previous, next) {
        if (next != null) {
          final current = stateOrNull?.value ?? cached;
          state = AsyncData(current.copyWith.title(next));
        }
      },
    );

    ref.listen(
      fireImmediately: true,
      tabStateProvider(cached.id).select((value) => value?.favicon),
      (previous, next) {
        if (next != null) {
          final current = stateOrNull?.value ?? cached;
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

  final tabState = ref.read(selectedTabStateProvider);

  int? proxyPort;
  if (tabState?.id != null) {
    final containerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getContainerTabId(tabState!.id);

    final containerData = await containerId.mapNotNull(
      (containerId) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(containerId),
    );

    final torSettings = ref.read(torSettingsWithDefaultsProvider);

    if (containerData?.metadata.useProxy == true ||
        (tabState.isPrivate == false &&
            torSettings.proxyRegularTabsMode == TorRegularTabProxyMode.all) ||
        (tabState.isPrivate == true && torSettings.proxyPrivateTabsTor)) {
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
