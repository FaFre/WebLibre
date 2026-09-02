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

import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/services/favicon_resolver.dart';
import 'package:weblibre/extensions/http_encoding.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';
import 'package:weblibre/features/proxy/domain/services/routed_http_client.dart';
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

  /// The earliest time each origin's on-disk entry may be age-checked again.
  ///
  /// [refreshIconIfStale] is called every time a row resolves an icon, and each
  /// call costs two database reads before it can conclude that a 7-to-30-day
  /// TTL has not elapsed. Scrolling a list re-asks for the same origins over
  /// and over, so the answer is remembered — but as a *deadline*, never as a
  /// "done" flag. A fresh entry is suppressed exactly until its TTL expires,
  /// and an attempt that wrote nothing (a resolver error, or a "missing" answer
  /// for an origin that still holds a real icon) is retried after
  /// [_staleRecheckBackoff]. Remembering "checked" instead would strand such an
  /// origin on its old icon until the process restarted.
  final _staleCheckNotBefore = <String, DateTime>{};

  @override
  void build() {
    _cacheRepository = ref.watch(cacheRepositoryProvider.notifier);
    _faviconResolver = ref.watch(faviconResolverProvider);
    _iconsService = ref.watch(geckoIconServiceProvider);

    // The decoded-icon cache is keyed by origin with no notion of the row it
    // came from, so it has to be dropped when that row is rewritten — otherwise
    // a newly fetched favicon would sit behind the old decode until the entry
    // happened to be evicted.
    //
    // The write paths below populate `_browserIconCache` *after* awaiting the
    // repository write, and that ordering is what keeps them from being undone
    // by their own invalidation: the announcement is delivered on a microtask
    // queued before the awaiting continuation resumes, so the eviction lands
    // first and the fresh decode survives it. Priming the cache before the
    // write would silently invert that.
    final sub = _cacheRepository.iconInvalidations.listen((event) {
      final origin = event.origin;
      if (origin == null) {
        _browserIconCache.clear();
        _staleCheckNotBefore.clear();
      } else {
        _browserIconCache.remove(origin);
        _staleCheckNotBefore.remove(origin);
      }
    });

    ref.onDispose(sub.cancel);
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
    required AppRoutingPolicy policy,
    bool forceRefresh = false,
  }) {
    return Result.fromAsync(() async {
      final result = await compute((args) async {
        final [String urlString, bool isImageRequest, AppRoutingPolicy policy] =
            args;

        final httpClient = HttpClient();
        // Throws for a blocked policy, which surfaces as a failed Result rather
        // than as an unproxied request to the page being inspected.
        applyRoutingPolicy(httpClient, policy);

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
      }, <dynamic>[url.toString(), isImageRequest, policy]);

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

  /// Deadlines held by [_staleCheckNotBefore] before it is pruned.
  static const _maxStaleCheckEntries = 512;

  /// How long to wait before re-checking an origin whose refresh attempt wrote
  /// nothing.
  static const _staleRecheckBackoff = Duration(minutes: 30);

  static const _iconStaleTtl = Duration(days: 30);
  static const _missingIconStaleTtl = Duration(days: 7);

  Future<void> refreshIconIfStale(Uri url) async {
    // Nothing this method does can help an origin the resolver will not serve,
    // and deciding that is pure — cheaper than the two reads it saves. It also
    // guarantees the `url.origin` reads below cannot throw, since eligibility
    // implies an http(s) url with a host.
    if (!_isResolverEligible(url)) return;

    final origin = url.origin;
    if (_inFlightIconFetches.containsKey(origin)) return;

    final now = DateTime.now();
    final notBefore = _staleCheckNotBefore[origin];
    if (notBefore != null && now.isBefore(notBefore)) return;

    final rawIcon = await _cacheRepository.getCachedIconRaw(origin);
    final fetchedAt = rawIcon == null
        ? null
        : await _cacheRepository.getCachedIconFetchDate(origin);

    if (rawIcon == null || fetchedAt == null) {
      // Nothing cached to age out. Whatever eventually caches an icon here
      // announces itself and clears this deadline, so a plain backoff is enough
      // to stop every scroll pass from re-asking in the meantime.
      _deferStaleCheck(origin, now.add(_staleRecheckBackoff));
      return;
    }

    final isMissing = _cacheRepository.isMissingIconBytes(rawIcon);
    final expiresAt = fetchedAt.add(
      isMissing ? _missingIconStaleTtl : _iconStaleTtl,
    );

    if (now.isBefore(expiresAt)) {
      // Known fresh: there is nothing worth asking again until the TTL runs
      // out, which is the whole point of remembering a deadline.
      _deferStaleCheck(origin, expiresAt);
      return;
    }

    // Bound the retry rate *before* the attempt. A resolver error, or a
    // "missing" answer for an origin that still holds a real icon, writes
    // nothing and therefore announces nothing — without this the next scroll
    // pass would ask again immediately. A refresh that succeeds does write,
    // which clears this deadline and lets the next check read the new fetch
    // date instead.
    _deferStaleCheck(origin, now.add(_staleRecheckBackoff));

    if (!ref.mounted) return;
    await _resolveIconWithDdg(url, cacheMissing: isMissing);
  }

  void _deferStaleCheck(String origin, DateTime notBefore) {
    if (_staleCheckNotBefore.length >= _maxStaleCheckEntries &&
        !_staleCheckNotBefore.containsKey(origin)) {
      // Bounded rather than precise: drop the deadlines that have already
      // passed, and start over if that frees nothing. Forgetting costs one more
      // round of checks, whereas growing without limit would not.
      final now = DateTime.now();
      _staleCheckNotBefore.removeWhere((_, at) => !now.isBefore(at));

      if (_staleCheckNotBefore.length >= _maxStaleCheckEntries) {
        _staleCheckNotBefore.clear();
      }
    }

    _staleCheckNotBefore[origin] = notBefore;
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
    // The lookup tells the resolver which host is being displayed, so it has to
    // travel the route of the tab that is displaying it. Falling back to the
    // general container would hand that host to a third party over a direct
    // connection while the user browses in a proxied one.
    //
    // This applies to every icon, including those requested by surfaces with no
    // tab behind them (bookmarks, settings, history). That is deliberate rather
    // than overreach: the icon cache is global and keyed by origin, so whichever
    // surface asks first decides the route for all of them, and a contextless
    // request routed direct would leak the host just as surely. The cost is
    // bounded — a blocked lookup resolves to an error, which yields a generated
    // placeholder and is not negatively cached, so it retries once the route
    // works again.
    final result = await _faviconResolver.resolve(
      url,
      policy: await ref.read(selectedTabRoutingPolicyProvider)(),
    );
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
