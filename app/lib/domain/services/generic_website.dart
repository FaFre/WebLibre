import 'dart:async';
import 'dart:ui';

import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:lensai/core/http_error_handler.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/entities/browser_icon.dart';
import 'package:lensai/features/user/domain/repositories/cache.dart';
import 'package:lensai/utils/lru_cache.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final splitted =
        sizes.split(' ').where((size) => size.contains('x')).toList();

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

  late http.Client _client;

  //Global icon cache
  late CacheRepository _cacheRepository;
  //Local decoded icon cache
  final LRUCache<String, BrowserIcon> _browserIconCache;

  GenericWebsiteService()
    : _iconsService = GeckoIconService(),
      _browserIconCache = LRUCache(50);

  @override
  void build() {
    _client = http.Client();
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
      sizes:
          (resource['sizes'] as List<List<int>>)
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
                mimeType: (mimeType?.isNotEmpty ?? true) ? null : mimeType,
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

  Future<Result<WebPageInfo>> fetchPageInfo(Uri url) async {
    return Result.fromAsync(() async {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 10));

      final result = await compute((args) async {
        final document = html_parser.parse(args[0]);
        final baseUri = Uri.parse(args[1]);

        final title = document.querySelector('title')?.text;
        final resources = _extractIcons(baseUri, document);

        return {
          'title': title,
          'resources': resources.map(_serializeResource).toList(),
        };
      }, [response.body, url.toString()],);

      final resources =
          (result['resources']! as List<Map<String, dynamic>>)
              .map(_deserializeResource)
              .toList();

      final favicon =
          await getCachedIcon(url) ??
          await loadIcon(url: url, resources: resources);

      return WebPageInfo(
        url: url,
        title: result['title'] as String?,
        favicon: favicon,
      );
    }, exceptionHandler: handleHttpError,);
  }

  Future<BrowserIcon?> getCachedIcon(Uri url) async {
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

  Future<BrowserIcon> getUrlIcon(Uri url) async {
    final cachedIcon = await getCachedIcon(url);

    if (cachedIcon != null) {
      return cachedIcon;
    }

    return fetchPageInfo(
      url,
    ).then((result) => result.flatMap((pageInfo) => pageInfo.favicon!).value);
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
