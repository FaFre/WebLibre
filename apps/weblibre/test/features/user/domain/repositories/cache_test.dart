import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/icon_cache_marker.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';

/// The favicon cache announces changes so readers can drop their decoded icons.
/// A write that leaves a reader rendering the same thing must stay silent —
/// Gecko re-dispatches a page's favicon on essentially every navigation, and
/// announcing those would evict the decoded icon for the site being browsed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserDatabase db;
  late ProviderContainer container;
  late CacheRepository repository;
  late List<String?> announced;

  final url = Uri.parse('https://example.com/page');

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );
    container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWith((ref) => db)],
    );
    repository = container.read(cacheRepositoryProvider.notifier);

    announced = [];
    final sub = repository.iconInvalidations.listen(
      (event) => announced.add(event.origin),
    );
    addTearDown(sub.cancel);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Lets the broadcast controller deliver before the assertion reads the log.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a first icon is announced', () async {
    await repository.cacheIcon(url, _redIcon);
    await settle();

    expect(announced, [url.origin]);
  });

  test('re-writing the same bytes is not announced', () async {
    await repository.cacheIcon(url, _redIcon);
    await repository.cacheIcon(url, Uint8List.fromList(_redIcon));
    await repository.cacheIcon(url, Uint8List.fromList(_redIcon));
    await settle();

    expect(announced, [url.origin]);
  });

  test('replacing an icon with different bytes is announced', () async {
    await repository.cacheIcon(url, _redIcon);
    await repository.cacheIcon(url, _blueIcon);
    await settle();

    expect(announced, [url.origin, url.origin]);
  });

  test('an identical re-write still refreshes the fetch date', () async {
    await repository.cacheIcon(url, _redIcon);
    await db.customUpdate(
      'UPDATE icon_cache SET fetch_date = ? WHERE origin = ?',
      variables: [
        Variable(DateTime.now().subtract(const Duration(days: 40))),
        Variable(url.origin),
      ],
    );

    await repository.cacheIcon(url, Uint8List.fromList(_redIcon));

    final fetchedAt = await repository.getCachedIconFetchDate(url.origin);
    expect(
      DateTime.now().difference(fetchedAt!),
      lessThan(const Duration(minutes: 1)),
    );
  });

  test(
    'a missing marker over an origin with no icon is not announced',
    () async {
      await repository.cacheMissingIcon(url);
      await settle();

      expect(announced, isEmpty);
      expect(
        isMissingIconMarker(await repository.getCachedIconRaw(url.origin)),
        isTrue,
      );
    },
  );

  test('a missing marker replacing a real icon is announced', () async {
    await repository.cacheIcon(url, _redIcon);
    await repository.cacheMissingIcon(url);
    await settle();

    expect(announced, [url.origin, url.origin]);
    expect(await repository.getCachedIcon(url.origin), isNull);
  });

  test('cacheIconIfAbsent over an existing icon is not announced', () async {
    await repository.cacheIcon(url, _redIcon);
    await repository.cacheIconIfAbsent(url, _blueIcon);
    await settle();

    expect(announced, [url.origin]);
    expect(await repository.getCachedIcon(url.origin), _redIcon);
  });

  test('cacheIconIfAbsent over a missing marker is announced', () async {
    await repository.cacheMissingIcon(url);
    await repository.cacheIconIfAbsent(url, _blueIcon);
    await settle();

    expect(announced, [url.origin]);
    expect(await repository.getCachedIcon(url.origin), _blueIcon);
  });

  test('clearing the cache announces every origin at once', () async {
    await repository.cacheIcon(url, _redIcon);
    await repository.clearCache();
    await settle();

    expect(announced, [url.origin, null]);
  });

  test(
    'revisions never repeat, so a restarted reader cannot miss one',
    () async {
      final revisions = <int>[];
      final sub = repository.iconInvalidations.listen(
        (event) => revisions.add(event.revision),
      );
      addTearDown(sub.cancel);

      await repository.cacheIcon(url, _redIcon);
      await repository.cacheIcon(url, _blueIcon);
      await repository.clearCache();
      await settle();

      expect(revisions, hasLength(3));
      expect(revisions, orderedEquals([...revisions]..sort()));
      expect(revisions.toSet(), hasLength(3));
    },
  );
}

final _redIcon = Uint8List.fromList(
  utf8.encode(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">'
    ' <rect width="16" height="16" fill="#ff0000"/></svg>',
  ),
);

final _blueIcon = Uint8List.fromList(
  utf8.encode(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">'
    ' <circle cx="8" cy="8" r="8" fill="#0000ff"/></svg>',
  ),
);
