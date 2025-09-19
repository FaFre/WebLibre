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
import 'dart:async';
import 'dart:ui';

import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/io_client.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socks5_proxy/socks_client.dart';
import 'package:universal_io/io.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/extensions/http_encoding.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/web_feed/utils/feed_finder.dart';
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'generic_website.g.dart';

const _typeMap = {
  "manifest": IconType.manifestIcon,
  "icon": IconType.favicon,
  "shortcut icon": IconType.favicon,
  "fluid-icon": IconType.fluidIcon,
  "apple-touch-icon": IconType.appleTouchIcon,
  "image_src": IconType.imageSrc,
  "apple-touch-icon image_src": IconType.appleTouchIcon,
  "apple-touch-icon-precomposed": IconType.appleTouchIcon,
  "og:image": IconType.openGraph,
  "og:image:url": IconType.openGraph,
  "og:image:secure_url": IconType.openGraph,
  "twitter:image": IconType.twitter,
  "msapplication-TileImage": IconType.microsoftTile,
};

Iterable<ResourceSize> sizesToList(String? sizes) sync* {
  if (sizes != null) {
    final splitted = sizes
        .split(' ')
        .where((size) => size.contains('x'))
        .toList();

    for (final size in splitted) {
      final dimensions = size.split('x');
      if (dimensions.length == 2) {
        final height = int.tryParse(dimensions[0]);
        final width = int.tryParse(dimensions[1]);

        if (width != null && height != null) {
          yield ResourceSize(height: height, width: width);
        }
      }
    }
  }
}

@Riverpod(keepAlive: true)
class GenericWebsiteService extends _$GenericWebsiteService {
  final GeckoIconService _iconsService;

  //Global icon cache
  late CacheRepository _cacheRepository;
  //Local decoded icon cache
  final LRUCache<String, BrowserIcon> _browserIconCache;

  GenericWebsiteService()
    : _iconsService = GeckoIconService(),
      _browserIconCache = LRUCache(50);

  @override
  void build() {
    _cacheRepository = ref.watch(cacheRepositoryProvider.notifier);
  }

  static Map<String, dynamic> _serializeResource(Resource resource) {
    return {
      'url': resource.url,
      'type': resource.type,
      'sizes': resource.sizes.nonNulls.map((s) => [s.height, s.width]).toList(),
      'mimeType': resource.mimeType,
      'maskable': resource.maskable,
    };
  }

  static Resource _deserializeResource(Map<String, dynamic> resource) {
    return Resource(
      url: resource['url'] as String,
      type: resource['type'] as IconType,
      mimeType: resource['mimeType'] as String?,
      sizes: (resource['sizes'] as List<List<int>>)
          .map((s) => ResourceSize(height: s[0], width: s[1]))
          .toList(),
      maskable: resource['maskable'] as bool,
    );
  }

  static Uri _resolveRelativeUri(Uri baseUri, Uri uri) {
    if (!uri.isAbsolute) {
      return baseUri.resolveUri(uri);
    }
    return uri;
  }

  static List<Resource> _extractIcons(Uri baseUrl, Document document) {
    final List<Resource> icons = [];

    void collectLinkIcons(String rel) {
      final links = document.querySelectorAll('link[rel="$rel"]');
      for (final link in links) {
        final href = link.attributes['href'];
        final type = _typeMap[rel];
        final mimeType = link.attributes['type'];
        if (href != null && type != null) {
          if (Uri.tryParse(href) case final Uri url) {
            icons.add(
              Resource(
                url: _resolveRelativeUri(baseUrl, url).toString(),
                type: type,
                sizes: sizesToList(link.attributes['sizes']).toList(),
                mimeType: mimeType.isNotEmpty ? mimeType : null,
                maskable: false,
              ),
            );
          }
        }
      }
    }

    void collectMetaPropertyIcons(String property) {
      final metas = document.querySelectorAll('meta[property="$property"]');
      for (final meta in metas) {
        final content = meta.attributes['content'];
        final type = _typeMap[property];
        if (content != null && type != null) {
          if (Uri.tryParse(content) case final Uri url) {
            icons.add(
              Resource(
                type: type,
                url: _resolveRelativeUri(baseUrl, url).toString(),
                sizes: [],
                maskable: false,
              ),
            );
          }
        }
      }
    }

    void collectMetaNameIcons(String name) {
      final metas = document.querySelectorAll('meta[name="$name"]');
      for (final meta in metas) {
        final content = meta.attributes['content'];
        final type = _typeMap[name];
        if (content != null && type != null) {
          if (Uri.tryParse(content) case final Uri url) {
            icons.add(
              Resource(
                type: type,
                url: _resolveRelativeUri(baseUrl, url).toString(),
                sizes: [],
                maskable: false,
              ),
            );
          }
        }
      }
    }

    collectLinkIcons("icon");
    collectLinkIcons("shortcut icon");
    collectLinkIcons("fluid-icon");
    collectLinkIcons("apple-touch-icon");
    collectLinkIcons("image_src");
    collectLinkIcons("apple-touch-icon image_src");
    collectLinkIcons("apple-touch-icon-precomposed");

    collectMetaPropertyIcons("og:image");
    collectMetaPropertyIcons("og:image:url");
    collectMetaPropertyIcons("og:image:secure_url");

    collectMetaNameIcons("twitter:image");
    collectMetaNameIcons("msapplication-TileImage");

    return icons;
  }

  Future<Result<WebPageInfo>> fetchPageInfo({
    required Uri url,
    required bool isImageRequest,
    required int? proxyPort,
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
          final resources = _extractIcons(baseUri, document);
          final feeds = await FeedFinder(
            url: baseUri,
            document: document,
          ).parse();

          return {
            'title': title,
            'resources': resources.map(_serializeResource).toList(),
            'feeds': feeds.map((uri) => uri.toString()).toList(),
          };
        } finally {
          client.close();
        }
      }, <dynamic>[url.toString(), isImageRequest, proxyPort]);

      if (result['imageBytes'] case final Uint8List imageBytes) {
        return WebPageInfo(
          url: url,
          favicon: await BrowserIcon.fromBytes(
            imageBytes,
            dominantColor: null,
            source: IconSource.download,
          ),
        );
      }

      final resources = (result['resources']! as List<Map<String, dynamic>>)
          .map(_deserializeResource)
          .toList();

      final favicon =
          await getCachedIcon(url) ??
          await loadIcon(url: url, resources: resources);

      return WebPageInfo(
        url: url,
        title: (result['title'] as String?)?.trim(),
        favicon: favicon,
        feeds: Set.from(
          (result['feeds']! as List<String>).map((url) => Uri.tryParse(url)),
        ),
      );
    }, exceptionHandler: handleHttpError);
  }

  Future<BrowserIcon?> getCachedIcon(Uri url) async {
    if (url.scheme.startsWith('http')) {
      final cachedBrowserIcon = _browserIconCache.get(url.origin);
      if (cachedBrowserIcon != null) {
        return cachedBrowserIcon;
      }

      final cachedIcon = await _cacheRepository.getCachedIcon(url.origin);
      if (cachedIcon != null) {
        return _browserIconCache.set(
          url.origin,
          await BrowserIcon.fromBytes(
            cachedIcon,
            dominantColor: null,
            source: IconSource.disk,
          ),
        );
      }
    }

    return null;
  }

  Future<BrowserIcon> loadIcon({
    required Uri url,
    required List<Resource> resources,
    bool isPrivate = false,
    bool waitOnNetworkLoad = true,
  }) async {
    final result = await _iconsService.loadIcon(
      url: url,
      resources: resources,
      isPrivate: isPrivate,
      waitOnNetworkLoad: waitOnNetworkLoad,
    );

    // unawaited(_cacheRepository.cacheIcon(url, result.image));

    return _browserIconCache.set(
      url.origin,
      await BrowserIcon.fromBytes(
        result.image,
        dominantColor: result.color.mapNotNull((color) => Color(color)),
        source: result.source,
      ),
    );
  }

  Future<BrowserIcon?> getUrlIcon(List<Uri> urlList) async {
    for (final url in urlList) {
      final cachedIcon = await getCachedIcon(url);

      if (cachedIcon != null) {
        return cachedIcon;
      }

      // ignore: only_use_keep_alive_inside_keep_alive
      final result = await ref.read(
        pageInfoProvider(url, isImageRequest: true).future,
      );

      if (result.favicon case final BrowserIcon favicon) {
        //If it was a `isImageRequest` hit, we need to cache it at this point
        if (!_browserIconCache.contains(url.origin)) {
          _browserIconCache.set(url.origin, favicon);
        }

        return favicon;
      }
    }

    return null;
  }

  // Future<Uri?> tryUpgradeToHttps(Uri httpUri) async {
  //   if (httpUri.isScheme('https')) {
  //     return httpUri;
  //   } else if (httpUri.isScheme('http')) {
  //     final cached = _httpsCache[httpUri.host];
  //     if (cached != null) {
  //       return cached ? httpUri.replace(scheme: 'https') : null;
  //     }

  //     var sslAvailable = false;

  //     try {
  //       final context = SecurityContext.defaultContext;

  //       final socket = await SecureSocket.connect(
  //         httpUri.host,
  //         443,
  //         context: context,
  //         timeout: const Duration(seconds: 3),
  //       );

  //       await socket.close();

  //       sslAvailable = true;
  //     } catch (_) {
  //       sslAvailable = false;
  //     }

  //     _httpsCache[httpUri.host] = sslAvailable;

  //     if (sslAvailable) {
  //       return httpUri.replace(scheme: 'https');
  //     }
  //   }

  //   return null;
  // }
}
