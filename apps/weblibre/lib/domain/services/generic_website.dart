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
import 'dart:io';
import 'dart:ui';

import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/io_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socks5_proxy/socks_client.dart';

import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/services/favicon_resolver.dart';
import 'package:weblibre/extensions/http_encoding.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/web_feed/utils/feed_finder.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'generic_website.g.dart';

@Riverpod(keepAlive: true)
FaviconResolver faviconResolver(Ref ref) => DdgFaviconResolver();

@Riverpod(keepAlive: true)
GeckoIconService geckoIconService(Ref ref) => GeckoIconService();

@Riverpod(keepAlive: true)
class GenericWebsiteService extends _$GenericWebsiteService {
  late CacheRepository _cacheRepository;
  late FaviconResolver _faviconResolver;
  late GeckoIconService _iconsService;
  late final LRUCache<String, BrowserIcon> _browserIconCache;
  final _inFlightIconFetches = <String, Future<BrowserIcon?>>{};

  GenericWebsiteService() : _browserIconCache = LRUCache(50);

  @override
  void build() {
    _cacheRepository = ref.watch(cacheRepositoryProvider.notifier);
    _faviconResolver = ref.watch(faviconResolverProvider);
    _iconsService = ref.watch(geckoIconServiceProvider);
  }

  static bool _isHttpUrl(Uri url) => url.isHttpOrHttps;

  static bool _isResolverEligible(Uri url) {
    if (!_isHttpUrl(url) || url.host.isEmpty || url.isLocalhost) {
      return false;
    }

    final host = url.host.toLowerCase();
    if (host.endsWith('.onion')) {
      return false;
    }

    return InternetAddress.tryParse(host) == null;
  }

  Future<Result<WebPageInfo>> fetchPageInfo({
    required Uri url,
    required bool isImageRequest,
    required int? proxyPort,
    bool forceRefresh = false,
  }) {
    return Result.fromAsync(() async {
      final result = await compute((args) async {
        final [String urlString, bool isImageRequest, int? proxyPort] = args;

        final httpClient = HttpClient();
        if (proxyPort != null) {
          SocksTCPClient.assignToHttpClient(httpClient, [
            ProxySettings(InternetAddress.loopbackIPv4, proxyPort),
          ]);
        }

        final client = IOClient(httpClient);
        try {
          final baseUri = Uri.parse(urlString);
          final response = await client
              .get(baseUri)
              .timeout(const Duration(seconds: 15));

          //When this is a request for an icon and we hit an image, directly return it
          if (isImageRequest) {
            final contentType = response.headers['content-type'];
            if (contentType?.contains('image/') == true) {
              return {
                'imageBytes': [response.bodyBytes],
              };
            }
          }

          final document = html_parser.parse(response.bodyUnicodeFallback);

          final title = document.querySelector('title')?.text;
          final feeds = await FeedFinder(
            url: baseUri,
            document: document,
          ).parse();

          return {
            'title': title,
            'feeds': feeds.map((uri) => uri.toString()).toList(),
          };
        } finally {
          client.close();
        }
      }, <dynamic>[url.toString(), isImageRequest, proxyPort]);

      if (result['imageBytes'] case final Uint8List imageBytes) {
        final favicon = await BrowserIcon.fromBytes(
          imageBytes,
          dominantColor: null,
          source: IconSource.download,
        );
        if (favicon != null) {
          await _cacheRepository.cacheIcon(url, imageBytes);
          _browserIconCache.set(url.origin, favicon);
        }
        return WebPageInfo(url: url, favicon: favicon);
      }

      return WebPageInfo(
        url: url,
        title: (result['title'] as String?)?.trim(),
        feeds: Set.from(
          (result['feeds']! as List<String>).map((url) => Uri.tryParse(url)),
        ),
      );
    }, exceptionHandler: handleHttpError);
  }

  Future<BrowserIcon?> getCachedIcon(Uri url) async {
    if (_isHttpUrl(url)) {
      final cachedBrowserIcon = _browserIconCache.get(url.origin);
      if (cachedBrowserIcon?.source == IconSource.generator) {
        _browserIconCache.remove(url.origin);
      } else if (cachedBrowserIcon?.image.value != null) {
        return cachedBrowserIcon;
      } else if (cachedBrowserIcon != null) {
        _browserIconCache.remove(url.origin);
      }

      final cachedIcon = await _cacheRepository.getCachedIcon(url.origin);
      if (cachedIcon != null) {
        final decoded = await BrowserIcon.fromBytes(
          cachedIcon,
          dominantColor: null,
          source: IconSource.disk,
        );
        if (decoded != null) {
          return _browserIconCache.set(url.origin, decoded);
        }
      }
    }

    return null;
  }

  Future<BrowserIcon?> _resolveIconWithDdg(
    Uri url, {
    required bool cacheMissing,
  }) {
    final origin = url.origin;
    final existing = _inFlightIconFetches[origin];
    if (existing != null) {
      return existing;
    }

    late final Future<BrowserIcon?> inFlight;
    inFlight = _fetchAndCacheDdgIcon(url, cacheMissing: cacheMissing)
        .whenComplete(() {
          if (identical(_inFlightIconFetches[origin], inFlight)) {
            _inFlightIconFetches.remove(origin)?.ignore();
          }
        });

    _inFlightIconFetches[origin] = inFlight;
    return inFlight;
  }

  Future<void> primeCachedIcon(Uri url, Uint8List bytes) async {
    await _cacheRepository.cacheIconIfAbsent(url, bytes);
  }

  static const _iconStaleTtl = Duration(days: 30);
  static const _missingIconStaleTtl = Duration(days: 7);

  Future<void> refreshIconIfStale(Uri url) async {
    if (!_isHttpUrl(url)) return;
    if (_inFlightIconFetches.containsKey(url.origin)) return;

    final rawIcon = await _cacheRepository.getCachedIconRaw(url.origin);
    if (rawIcon == null) return;

    final fetchedAt = await _cacheRepository.getCachedIconFetchDate(url.origin);
    if (fetchedAt == null) return;

    final ttl = _cacheRepository.isMissingIconBytes(rawIcon)
        ? _missingIconStaleTtl
        : _iconStaleTtl;
    if (DateTime.now().difference(fetchedAt) < ttl) return;
    if (!_isResolverEligible(url)) return;

    if (!ref.mounted) return;
    await _resolveIconWithDdg(
      url,
      cacheMissing: _cacheRepository.isMissingIconBytes(rawIcon),
    );
  }

  Future<BrowserIcon?> getUrlIcon(
    List<Uri> urlList, {
    bool cacheOnly = false,
  }) async {
    final eligibleUrls = urlList.where(_isHttpUrl).toList();
    if (eligibleUrls.isEmpty) {
      return null;
    }

    for (final url in eligibleUrls) {
      final cachedIcon = await getCachedIcon(url);
      if (cachedIcon != null) {
        return cachedIcon;
      }
    }

    if (cacheOnly) {
      return _loadIconWithoutNetwork(eligibleUrls.first);
    }

    for (final url in eligibleUrls) {
      if (!_isResolverEligible(url)) {
        continue;
      }

      if (await _hasFreshMissingIcon(url)) {
        continue;
      }

      if (ref.mounted) {
        final resolved = await _resolveIconWithDdg(url, cacheMissing: true);
        if (resolved != null) {
          return resolved;
        }
      }
    }

    BrowserIcon? generatedFallback;
    for (final url in eligibleUrls) {
      final icon = await _loadIconWithoutNetwork(url);
      if (icon == null) {
        continue;
      }
      if (icon.source != IconSource.generator) {
        return icon;
      }
      generatedFallback ??= icon;
    }

    return generatedFallback;
  }

  Future<BrowserIcon?> _fetchAndCacheDdgIcon(
    Uri url, {
    required bool cacheMissing,
  }) async {
    final result = await _faviconResolver.resolve(url);
    switch (result.status) {
      case FaviconResolveStatus.hit:
        final bytes = result.bytes!;
        final decoded = await BrowserIcon.fromBytes(
          bytes,
          dominantColor: null,
          source: IconSource.download,
        );
        if (decoded == null) {
          return null;
        }

        await _cacheRepository.cacheIcon(url, bytes);
        return _browserIconCache.set(url.origin, decoded);
      case FaviconResolveStatus.missing:
        if (cacheMissing) {
          await _cacheRepository.cacheMissingIcon(url);
        }
        return null;
      case FaviconResolveStatus.error:
        return null;
    }
  }

  Future<bool> _hasFreshMissingIcon(Uri url) async {
    final rawIcon = await _cacheRepository.getCachedIconRaw(url.origin);
    if (!_cacheRepository.isMissingIconBytes(rawIcon)) {
      return false;
    }

    final fetchedAt = await _cacheRepository.getCachedIconFetchDate(url.origin);
    if (fetchedAt == null) {
      return false;
    }

    return DateTime.now().difference(fetchedAt) < _missingIconStaleTtl;
  }

  Future<BrowserIcon?> _loadIconWithoutNetwork(Uri url) async {
    final result = await _iconsService.loadIcon(
      url: url,
      waitOnNetworkLoad: false,
    );

    final decoded = await BrowserIcon.fromBytes(
      result.image,
      dominantColor: result.color == null ? null : Color(result.color!),
      source: result.source,
    );
    if (decoded == null) {
      return null;
    }

    if (result.source == IconSource.generator) {
      _browserIconCache.remove(url.origin);
      return decoded;
    }

    if (result.source != IconSource.generator &&
        result.source != IconSource.memory) {
      await _cacheRepository.cacheIcon(url, result.image);
    }

    return _browserIconCache.set(url.origin, decoded);
  }
}
