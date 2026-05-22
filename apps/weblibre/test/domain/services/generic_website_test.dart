import 'dart:ui';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/domain/services/favicon_resolver.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/icon_cache_marker.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserDatabase db;
  late ProviderContainer container;
  late FakeFaviconResolver resolver;
  late FakeGeckoIconService geckoIcons;
  late GenericWebsiteService service;
  late CacheRepository cacheRepository;

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );
    resolver = FakeFaviconResolver();
    geckoIcons = FakeGeckoIconService();
    container = ProviderContainer(
      overrides: [
        userDatabaseProvider.overrideWith((ref) => db),
        faviconResolverProvider.overrideWithValue(resolver),
        geckoIconServiceProvider.overrideWithValue(geckoIcons),
      ],
    );
    service = container.read(genericWebsiteServiceProvider.notifier);
    cacheRepository = container.read(cacheRepositoryProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('returns cached icons without hitting the resolver', () async {
    final url = Uri.parse('https://cached.example/article');
    await cacheRepository.cacheIcon(url, _cachedSvgBytes);

    final icon = await service.getUrlIcon([url]);

    expect(icon, isNotNull);
    expect(icon!.source, IconSource.disk);
    expect(resolver.callCount, 0);
    expect(geckoIcons.callCount, 0);
  });

  test('caches DDG misses and skips retries until the miss expires', () async {
    final url = Uri.parse('https://missing.example/');
    resolver.enqueue(const FaviconResolveResult.missing());
    geckoIcons
      ..enqueue(_generatorResult)
      ..enqueue(_generatorResult);

    final first = await service.getUrlIcon([url]);
    final second = await service.getUrlIcon([url]);

    expect(first?.source, IconSource.generator);
    expect(second?.source, IconSource.generator);
    expect(resolver.callCount, 1);
    expect(geckoIcons.callCount, 2);
    expect(
      isMissingIconMarker(await cacheRepository.getCachedIconRaw(url.origin)),
      isTrue,
    );
  });

  test(
    'resolver errors fall back to generation without negative caching',
    () async {
      final url = Uri.parse('https://flaky.example/');
      resolver.enqueue(const FaviconResolveResult.error());
      resolver.enqueue(const FaviconResolveResult.error());
      geckoIcons
        ..enqueue(_generatorResult)
        ..enqueue(_generatorResult);

      final first = await service.getUrlIcon([url]);
      final second = await service.getUrlIcon([url]);

      expect(first?.source, IconSource.generator);
      expect(second?.source, IconSource.generator);
      expect(resolver.callCount, 2);
      expect(geckoIcons.callCount, 2);
      expect(await cacheRepository.getCachedIconRaw(url.origin), isNull);
    },
  );

  test(
    'resolver recovery replaces generated fallback with a real icon',
    () async {
      final url = Uri.parse('https://recovery.example/');
      resolver
        ..enqueue(const FaviconResolveResult.error())
        ..enqueue(FaviconResolveResult.hit(_updatedSvgBytes));
      geckoIcons.enqueue(_generatorResult);

      final first = await service.getUrlIcon([url]);
      final second = await service.getUrlIcon([url]);

      expect(first?.source, IconSource.generator);
      expect(second?.source, IconSource.download);
      expect(resolver.callCount, 2);
      expect(geckoIcons.callCount, 1);
      expect(
        listEquals(
          await cacheRepository.getCachedIcon(url.origin),
          _updatedSvgBytes,
        ),
        isTrue,
      );
    },
  );

  test('skips DDG resolution for localhost, onion, and IP hosts', () async {
    final urls = [
      Uri.parse('http://localhost:8080/'),
      Uri.parse('https://hiddenservice.onion/'),
      Uri.parse('https://127.0.0.1/'),
      Uri.parse('https://192.168.0.10/'),
    ];
    for (var i = 0; i < urls.length; i++) {
      geckoIcons.enqueue(_generatorResult);
    }

    for (final url in urls) {
      final icon = await service.getUrlIcon([url]);
      expect(icon?.source, IconSource.generator);
    }

    expect(resolver.callCount, 0);
    expect(geckoIcons.callCount, urls.length);
  });

  test('refreshIconIfStale updates stale cached icons from DDG', () async {
    final url = Uri.parse('https://stale.example/');
    await cacheRepository.cacheIcon(url, _cachedSvgBytes);
    await db.customUpdate(
      'UPDATE icon_cache SET fetch_date = ? WHERE origin = ?',
      variables: [
        Variable(DateTime.now().subtract(const Duration(days: 31))),
        Variable(url.origin),
      ],
    );
    resolver.enqueue(FaviconResolveResult.hit(_updatedSvgBytes));

    await service.refreshIconIfStale(url);

    final updatedBytes = await cacheRepository.getCachedIcon(url.origin);
    expect(updatedBytes, isNotNull);
    expect(listEquals(updatedBytes, _updatedSvgBytes), isTrue);
    expect(resolver.callCount, 1);
  });
}

final class FakeFaviconResolver implements FaviconResolver {
  int callCount = 0;
  final List<FaviconResolveResult> _results = [];

  void enqueue(FaviconResolveResult result) {
    _results.add(result);
  }

  @override
  Future<FaviconResolveResult> resolve(Uri url, {int? proxyPort}) async {
    callCount += 1;
    if (_results.isEmpty) {
      return const FaviconResolveResult.error();
    }
    return _results.removeAt(0);
  }
}

final class FakeGeckoIconService extends GeckoIconService {
  int callCount = 0;
  final List<IconResult> _results = [];

  void enqueue(IconResult result) {
    _results.add(result);
  }

  @override
  Future<IconResult> loadIcon({
    required Uri url,
    List<Resource> resources = const [],
    IconSize size = IconSize.defaultSize,
    bool isPrivate = false,
    bool waitOnNetworkLoad = true,
  }) async {
    callCount += 1;
    if (_results.isEmpty) {
      return _generatorResult;
    }
    return _results.removeAt(0);
  }
}

final _generatorResult = IconResult(
  image: _generatedSvgBytes,
  color: const Color(0xFF5B8DEF).toARGB32(),
  source: IconSource.generator,
  maskable: false,
);

final _cachedSvgBytes = Uint8List.fromList(
  '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
<rect width="16" height="16" fill="#ff0000"/>
</svg>'''
      .codeUnits,
);

final _updatedSvgBytes = Uint8List.fromList(
  '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
<circle cx="8" cy="8" r="8" fill="#0000ff"/>
</svg>'''
      .codeUnits,
);

final _generatedSvgBytes = Uint8List.fromList(
  '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
<rect width="16" height="16" rx="3" fill="#5B8DEF"/>
<text x="8" y="11" text-anchor="middle" font-size="8" fill="#fff">W</text>
</svg>'''
      .codeUnits,
);
