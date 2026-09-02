import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/domain/services/favicon_resolver.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cached-icon lookup falls through to a later url in the list', () async {
    final firstUrl = Uri.parse('https://first.example/result');
    final secondUrl = Uri.parse('https://second.example/result');
    final db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );
    addTearDown(db.close);

    // Only the *second* origin has a cached icon, so a resolver that stopped at
    // the head of the list would fall through to the generated placeholder.
    await db.cacheDao.cacheIcon(secondUrl.origin, _secondSvgBytes);

    final container = ProviderContainer(
      overrides: [
        userDatabaseProvider.overrideWith((ref) => db),
        faviconResolverProvider.overrideWithValue(_NeverCalledResolver()),
        geckoIconServiceProvider.overrideWithValue(_FakeGeckoIconService()),
      ],
    );
    addTearDown(container.dispose);

    final icon = await container
        .read(genericWebsiteServiceProvider.notifier)
        .getUrlIcon([firstUrl, secondUrl], cacheOnly: true);

    expect(icon, isNotNull);
    expect(icon!.source, IconSource.disk);
  });

  testWidgets('distinct cached icons do not collapse to one image', (
    tester,
  ) async {
    final firstUrl = Uri.parse('https://first.example/result');
    final secondUrl = Uri.parse('https://second.example/result');
    final db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );

    addTearDown(() async {
      await db.close();
    });

    await db.cacheDao.cacheIcon(firstUrl.origin, _firstSvgBytes);
    await db.cacheDao.cacheIcon(secondUrl.origin, _secondSvgBytes);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWith((ref) => db),
          faviconResolverProvider.overrideWithValue(_NeverCalledResolver()),
          geckoIconServiceProvider.overrideWithValue(_FakeGeckoIconService()),
        ],
        child: MaterialApp(
          home: Row(
            children: [
              UrlIcon([firstUrl], iconSize: 24, cacheOnly: true),
              UrlIcon([secondUrl], iconSize: 24, cacheOnly: true),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final rawImages = tester
        .widgetList<RawImage>(find.byType(RawImage))
        .toList();
    expect(rawImages, hasLength(2));
    expect(identical(rawImages[0].image, rawImages[1].image), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('cacheOnly falls back to a generated icon on cache miss', (
    tester,
  ) async {
    final db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );

    addTearDown(() async {
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userDatabaseProvider.overrideWith((ref) => db),
          faviconResolverProvider.overrideWithValue(_NeverCalledResolver()),
          geckoIconServiceProvider.overrideWithValue(_FakeGeckoIconService()),
        ],
        child: MaterialApp(
          home: UrlIcon(
            [Uri.parse('https://generated.example')],
            iconSize: 24,
            cacheOnly: true,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(RawImage), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

final class _NeverCalledResolver implements FaviconResolver {
  @override
  Future<FaviconResolveResult> resolve(
    Uri url, {
    required AppRoutingPolicy policy,
  }) {
    throw UnimplementedError('cacheOnly should not hit the resolver');
  }
}

final class _FakeGeckoIconService extends GeckoIconService {
  @override
  Future<IconResult> loadIcon({
    required Uri url,
    List<Resource> resources = const [],
    IconSize size = IconSize.defaultSize,
    bool isPrivate = false,
    bool waitOnNetworkLoad = true,
  }) async {
    return IconResult(
      image: _firstSvgBytes,
      color: null,
      source: IconSource.generator,
      maskable: false,
    );
  }
}

final _firstSvgBytes = Uint8List.fromList(
  utf8.encode('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <rect width="16" height="16" fill="#ff0000"/>
</svg>
'''),
);

final _secondSvgBytes = Uint8List.fromList(
  utf8.encode('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <circle cx="8" cy="8" r="8" fill="#0000ff"/>
</svg>
'''),
);
