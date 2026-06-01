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
import 'dart:async';
import 'dart:typed_data';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/widgets/safe_raw_image.dart';

/// Origins served by a bundled asset instead of a network-fetched favicon.
/// Lets first-party properties (e.g. the WebLibre search bang) show their
/// brand mark rather than a generic globe or a remotely fetched icon.
const _bundledIconByOrigin = {
  'https://weblibre.eu': 'assets/icon/bang_icon.png',
};

Uint8List? selectFirstCachedIconBytes(Iterable<Uint8List?> cachedBytesByUrl) {
  for (final cachedBytes in cachedBytesByUrl) {
    if (cachedBytes != null) {
      return cachedBytes;
    }
  }

  return null;
}

class UrlIcon extends HookConsumerWidget {
  final double iconSize;
  final List<Uri> urlList;
  final bool cacheOnly;

  const UrlIcon(
    this.urlList, {
    required this.iconSize,
    this.cacheOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligibleUrls = urlList
        .where((u) => u.isScheme('http') || u.isScheme('https'))
        .toList();

    for (final url in eligibleUrls) {
      final asset = _bundledIconByOrigin[url.origin];
      if (asset != null) {
        return RepaintBoundary(
          child: Image.asset(
            asset,
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    final cachedBytesByUrl = [
      for (final url in eligibleUrls)
        ref.watch(watchCachedIconBytesProvider(url.origin)).value,
    ];

    final cacheHashes = [
      for (final bytes in cachedBytesByUrl)
        bytes == null ? null : identityHashCode(bytes),
    ];

    final icon = useCachedFuture(
      () => _resolveIcon(ref, eligibleUrls, cachedBytesByUrl),
      [EquatableValue(urlList), ...cacheHashes, cacheOnly],
    );

    return Skeletonizer(
      // Only show the skeleton on the *initial* resolve (no data yet).
      // When a fresh favicon arrives later, `useMemoized` produces a new
      // future and `useFuture` flips connectionState back to waiting while
      // preserving the previous data — without this guard, the existing
      // icon would get a skeleton overlay for the brief async gap before
      // BrowserIcon.fromBytes resolves, which reads as a flicker.
      enabled:
          icon.connectionState != ConnectionState.done && icon.data == null,
      child: SizedBox.square(
        dimension: iconSize,
        child: (icon.data != null)
            ? RepaintBoundary(
                child: SafeRawImage(
                  image: icon.data?.image,
                  height: iconSize,
                  width: iconSize,
                  fit: BoxFit.fill,
                  fallback: Icon(MdiIcons.web, size: iconSize),
                ),
              )
            : Icon(MdiIcons.web, size: iconSize),
      ),
    );
  }

  Future<BrowserIcon?> _resolveIcon(
    WidgetRef ref,
    List<Uri> eligibleUrls,
    List<Uint8List?> cachedBytesByUrl,
  ) async {
    if (eligibleUrls.isEmpty) {
      return null;
    }

    final cachedBytes = selectFirstCachedIconBytes(cachedBytesByUrl);
    if (cachedBytes != null) {
      final decoded = await BrowserIcon.fromBytes(
        cachedBytes,
        dominantColor: null,
        source: IconSource.disk,
      );
      if (decoded != null) {
        if (!cacheOnly) {
          _scheduleStaleRefresh(ref, eligibleUrls);
        }
        return decoded;
      }
    }

    if (cacheOnly) {
      return ref
          .read(genericWebsiteServiceProvider.notifier)
          .getUrlIcon(urlList, cacheOnly: true);
    }

    return ref.read(genericWebsiteServiceProvider.notifier).getUrlIcon(urlList);
  }

  void _scheduleStaleRefresh(WidgetRef ref, List<Uri> eligibleUrls) {
    if (eligibleUrls.isEmpty) return;
    final service = ref.read(genericWebsiteServiceProvider.notifier);
    for (final url in eligibleUrls) {
      unawaited(service.refreshIconIfStale(url));
    }
  }
}
