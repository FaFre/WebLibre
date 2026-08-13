import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

void main() {
  late UserDatabase db;
  late ProviderContainer container;

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
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  ProxyRoutingSettingsRepository repository() =>
      container.read(proxyRoutingSettingsRepositoryProvider.notifier);

  group('isolation context routes', () {
    // The map is stored as a JSON document in a TEXT column, which the
    // repository has to decode by hand. Miss that step and every write below
    // succeeds while every read returns the default — the failure mode this
    // group exists for.
    test('a proxy route survives the round trip', () async {
      await repository().setIsolationContextRoute(
        'iso1_a',
        const TorProxyConnectionId(),
      );

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes, {
        'iso1_a': const TorProxyConnectionId(),
      });
    });

    test('an explicit direct route is kept, not dropped as absent', () async {
      // "Direct" and "follows its container" are different routes; a null value
      // has to survive as a *present* key.
      await repository().setIsolationContextRoute('iso1_a', null);

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes.containsKey('iso1_a'), isTrue);
      expect(settings.isolationContextRoutes['iso1_a'], isNull);
    });

    test('routes for several groups coexist', () async {
      await repository().setIsolationContextRoute(
        'iso1_a',
        const TorProxyConnectionId(),
      );
      await repository().setIsolationContextRoute(
        'iso1_b',
        const SingboxProxyConnectionId('profile-1'),
      );

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes, {
        'iso1_a': const TorProxyConnectionId(),
        'iso1_b': const SingboxProxyConnectionId('profile-1'),
      });
    });

    test(
      'clearing drops the entry so the group follows its container',
      () async {
        await repository().setIsolationContextRoute(
          'iso1_a',
          const TorProxyConnectionId(),
        );
        await repository().clearIsolationContextRoute('iso1_a');

        final settings = await repository().fetchSettings();

        expect(settings.isolationContextRoutes, isEmpty);
      },
    );

    test('copying carries a route to a duplicated group', () async {
      await repository().setIsolationContextRoute('iso1_a', null);
      await repository().copyIsolationContextRoute('iso1_a', 'iso1_b');

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes.containsKey('iso1_b'), isTrue);
      expect(settings.isolationContextRoutes['iso1_b'], isNull);
    });

    test('copying a group without a route adds nothing', () async {
      await repository().copyIsolationContextRoute('iso1_a', 'iso1_b');

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes, isEmpty);
    });

    test('the other routing settings are untouched', () async {
      await repository().updateSettings(
        (current) => current.copyWith(
          privateTabsProxyConnectionId: const TorProxyConnectionId(),
        ),
      );
      await repository().setIsolationContextRoute(
        'iso1_a',
        const SingboxProxyConnectionId('profile-1'),
      );

      final settings = await repository().fetchSettings();

      expect(
        settings.privateTabsProxyConnectionId,
        const TorProxyConnectionId(),
      );
      expect(settings.isolationContextRoutes, {
        'iso1_a': const SingboxProxyConnectionId('profile-1'),
      });
    });
  });

  group('unreadable persisted values', () {
    // This row is free-form text; a truncated or hand-edited one must not throw
    // out of the settings stream, because that stream gates the routing
    // snapshot and an unresolved gate leaves the extension blocking everything.
    Future<void> writeRaw(String value) => db.settingDao.updateSetting(
      'isolationContextRoutes',
      'proxy_routing',
      value,
    );

    test('malformed JSON falls back to no routes', () async {
      await writeRaw('{"iso1_a": "tor"');

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes, isEmpty);
    });

    test('JSON that is not an object falls back to no routes', () async {
      await writeRaw('["iso1_a"]');

      final settings = await repository().fetchSettings();

      expect(settings.isolationContextRoutes, isEmpty);
    });

    test('the other settings still load', () async {
      await repository().updateSettings(
        (current) => current.copyWith(
          privateTabsProxyConnectionId: const TorProxyConnectionId(),
        ),
      );
      await writeRaw('not json at all');

      final settings = await repository().fetchSettings();

      expect(
        settings.privateTabsProxyConnectionId,
        const TorProxyConnectionId(),
      );
    });
  });

  group('parsing', () {
    test('non-isolation keys are dropped', () {
      // Only an isolation context can carry one of these; anything else is
      // corruption, and honouring it would route a container from the wrong
      // setting.
      final routes = parseIsolationContextRoutes({
        'context-a': 'tor',
        'iso1_a': 'tor',
      });

      expect(routes.keys, ['iso1_a']);
    });

    test(
      'an unresolvable proxy id drops the entry rather than going direct',
      () {
        // Decoding it to null would silently turn a proxied group into a direct
        // one; dropping it leaves the group following its container instead.
        final routes = parseIsolationContextRoutes({'iso1_a': 'not-a-proxy'});

        expect(routes, isEmpty);
      },
    );

    test('a null value is an explicit direct connection', () {
      final routes = parseIsolationContextRoutes({'iso1_a': null});

      expect(routes.containsKey('iso1_a'), isTrue);
      expect(routes['iso1_a'], isNull);
    });

    test('malformed values are dropped', () {
      final routes = parseIsolationContextRoutes({'iso1_a': 42});

      expect(routes, isEmpty);
    });
  });
}
