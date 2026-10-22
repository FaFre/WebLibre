// The notifier subclasses below are test doubles: driving a collaborator's
// state from the test is their whole purpose.
// ignore_for_file: riverpod_lint/avoid_public_notifier_properties

import 'package:clock/clock.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_health.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/domain/services/singbox_start_retry.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profile = SingboxProxyConnectionId('profile-1');
  final encoded = profile.encode();

  group('traffic evidence', () {
    test('one failing site is not enough', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.health.recordFailedLoad(encoded, host: 'mistyped.example');

      // Through sing-box a site that does not exist fails exactly like a
      // dead tunnel, so a single typo must not condemn a working proxy.
      expect(harness.evidence(encoded)?.notResponding, isFalse);
    });

    test('the same site failing twice is still one site', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'a.example');

      expect(harness.evidence(encoded)?.notResponding, isFalse);
    });

    test('two different sites failing is not responding', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example');

      expect(harness.evidence(encoded)?.notResponding, isTrue);
    });

    test('failures age out of the window', () {
      final harness = _Harness();
      addTearDown(harness.dispose);
      var now = DateTime(2026, 10, 21, 12);

      withClock(Clock(() => now), () {
        harness.health.recordFailedLoad(encoded, host: 'a.example');
        now = now.add(proxyFailedLoadWindow + const Duration(seconds: 1));
        harness.health.recordFailedLoad(encoded, host: 'b.example');
      });

      expect(harness.evidence(encoded)?.failedLoads, hasLength(1));
      expect(harness.evidence(encoded)?.notResponding, isFalse);
    });

    test('a restart of the proxy drops its evidence', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example');
      harness.starting.announce([encoded]);

      expect(harness.evidence(encoded), isNull);
    });

    test('a failure reported just after a restart ended is its echo', () {
      final harness = _Harness();
      addTearDown(harness.dispose);
      var now = DateTime(2026, 10, 21, 12);

      withClock(Clock(() => now), () {
        harness.starting
          ..announce([encoded])
          ..announce(const []);
        harness.health
          ..recordFailedLoad(encoded, host: 'a.example')
          ..recordFailedLoad(encoded, host: 'b.example');
        expect(harness.evidence(encoded), isNull);

        now = now.add(proxyRestartGracePeriod);
        harness.health.recordFailedLoad(encoded, host: 'a.example');
        expect(harness.evidence(encoded)?.failedLoads, hasLength(1));
      });
    });

    test('a load failing while its proxy starts is not counted', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.starting.announce([encoded]);
      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example');

      expect(harness.evidence(encoded), isNull);
    });

    test('a load that got through outweighs every failure before it', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example')
        ..recordSuccessfulLoad(encoded);

      expect(harness.evidence(encoded), isNull);
    });

    test('a failed connection test is not responding on its own', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.latency.put(
        profile,
        AsyncError(Exception('timed out'), StackTrace.current),
      );

      expect(harness.evidence(encoded)?.notResponding, isTrue);
    });

    test('a test a restart cut short says nothing about the tunnel', () {
      final harness = _Harness();
      addTearDown(harness.dispose);
      var now = DateTime(2026, 10, 21, 12);

      withClock(Clock(() => now), () {
        // Starting another profile reloads the instance this one runs in,
        // and the test's socket goes with it.
        harness.latency.put(profile, const AsyncLoading());
        harness.starting.announce([encoded]);
        now = now.add(const Duration(seconds: 2));
        harness.starting.announce(const []);

        // Long after the grace period: the test had been waiting on a
        // socket the reload had already closed.
        now = now.add(proxyRestartGracePeriod * 3);
        harness.latency.put(
          profile,
          AsyncError(Exception('connection reset'), StackTrace.current),
        );
      });

      expect(harness.evidence(encoded), isNull);
    });

    test('a test that started after a restart still counts', () {
      final harness = _Harness();
      addTearDown(harness.dispose);
      var now = DateTime(2026, 10, 21, 12);

      withClock(Clock(() => now), () {
        harness.starting
          ..announce([encoded])
          ..announce(const []);
        // Within the grace period a failed page load gets: the test's socket
        // is the new instance's all the same, as for a freshly enabled proxy
        // whose upstream refuses straight away.
        now = now.add(const Duration(seconds: 1));
        harness.latency.put(profile, const AsyncLoading());
        now = now.add(const Duration(seconds: 1));
        harness.latency.put(
          profile,
          AsyncError(Exception('timed out'), StackTrace.current),
        );
      });

      expect(harness.evidence(encoded)?.notResponding, isTrue);
    });

    test('a test that could not run says nothing about the tunnel', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.latency.put(
        profile,
        AsyncError(const ProxyNotRunningError(), StackTrace.current),
      );

      expect(harness.evidence(encoded), isNull);
    });

    test('a successful test outweighs every failure before it', () {
      final harness = _Harness();
      addTearDown(harness.dispose);

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example');
      harness.latency.put(
        profile,
        AsyncData(
          ProxyLatencyData(
            latency: const Duration(milliseconds: 80),
            statusCode: 200,
          ),
        ),
      );

      expect(harness.evidence(encoded), isNull);
    });
  });

  group('condition', () {
    test('a running proxy with failing traffic is not responding', () async {
      final harness = _Harness(running: [encoded]);
      addTearDown(harness.dispose);
      await harness.settle();

      expect(harness.condition(profile), isNull);

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example');

      expect(
        harness.condition(profile),
        ProxyConnectionCondition.notResponding,
      );
    });

    test('evidence about a proxy that is down is not shown', () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      await harness.settle();

      harness.health
        ..recordFailedLoad(encoded, host: 'a.example')
        ..recordFailedLoad(encoded, host: 'b.example');

      expect(harness.condition(profile), isNull);
    });

    test(
      'a profile a failed start took down reads as retrying, not as up',
      () async {
        final harness = _Harness(
          running: [encoded],
          retries: {
            'profile-1': SingboxStartRetry(
              attempts: 1,
              nextAttemptAt: DateTime(2026, 10, 21),
            ),
          },
        );
        addTearDown(harness.dispose);
        await harness.settle();
        expect(harness.condition(profile), isNull);

        // The error still carries the RUNNING data from before the start.
        harness.runtime.fail();

        expect(
          harness.condition(profile),
          ProxyConnectionCondition.startRetrying,
        );
      },
    );

    test('a proxy that could not start says whether it will retry', () async {
      final harness = _Harness(
        retries: {
          'profile-1': SingboxStartRetry(
            attempts: 1,
            nextAttemptAt: DateTime(2026, 10, 21),
          ),
          'profile-2': SingboxStartRetry(attempts: 6, nextAttemptAt: null),
        },
      );
      addTearDown(harness.dispose);
      await harness.settle();

      expect(
        harness.condition(profile),
        ProxyConnectionCondition.startRetrying,
      );
      expect(
        harness.condition(const SingboxProxyConnectionId('profile-2')),
        ProxyConnectionCondition.startFailed,
      );
    });
  });
}

class _Harness {
  _Harness({
    List<String> running = const [],
    Map<String, SingboxStartRetry> retries = const {},
  }) {
    container = ProviderContainer(
      overrides: [
        singboxProxyRuntimeRepositoryProvider.overrideWith(
          () => _FakeRuntimeRepository(running),
        ),
        singboxProxyStartingConnectionsProvider.overrideWith(
          _FakeStartingConnections.new,
        ),
        proxyLatencyResultsProvider.overrideWith(_FakeLatencyResults.new),
        torProxyServiceProvider.overrideWith(_FakeTorProxyService.new),
        singboxStartRetriesProvider.overrideWith(
          () => _FakeStartRetries(retries),
        ),
      ],
    );
    // Keep the evidence alive and listening, as the app does.
    container.listen(proxyTrafficHealthProvider, (_, _) {});
  }

  late final ProviderContainer container;

  _FakeRuntimeRepository get runtime =>
      container.read(singboxProxyRuntimeRepositoryProvider.notifier)
          as _FakeRuntimeRepository;

  ProxyTrafficHealth get health =>
      container.read(proxyTrafficHealthProvider.notifier);

  _FakeStartingConnections get starting =>
      container.read(singboxProxyStartingConnectionsProvider.notifier)
          as _FakeStartingConnections;

  _FakeLatencyResults get latency =>
      container.read(proxyLatencyResultsProvider.notifier)
          as _FakeLatencyResults;

  ProxyTrafficEvidence? evidence(String encodedProxyId) =>
      container.read(proxyTrafficHealthProvider)[encodedProxyId];

  ProxyConnectionCondition? condition(ProxyConnectionId id) =>
      container.read(proxyConnectionConditionProvider(id));

  Future<void> settle() async {
    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await pumpEventQueue();
  }

  void dispose() => container.dispose();
}

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  _FakeRuntimeRepository(this._running);

  final List<String> _running;

  /// A start failed, the way the repository reports one.
  void fail() =>
      state = AsyncError(StateError('start failed'), StackTrace.empty);

  @override
  Future<SingboxProxyRuntimeState> build() async {
    return SingboxProxyRuntimeState(
      status: _running.isEmpty
          ? SingboxProxyRuntimeStatus.stopped
          : SingboxProxyRuntimeStatus.running,
      endpoints: [
        for (final profileId in _running)
          SingboxProxyRuntimeEndpoint(
            profileId: profileId,
            host: '127.0.0.1',
            port: 12080,
            username: 'user',
            password: 'pass',
          ),
      ],
    );
  }
}

class _FakeStartingConnections extends SingboxProxyStartingConnections {
  void announce(Iterable<String> encodedIds) => state = {...encodedIds};

  @override
  Set<String> build() => const {};
}

class _FakeLatencyResults extends ProxyLatencyResults {
  void put(ProxyConnectionId id, AsyncValue<ProxyLatencyData> result) {
    state = {...state, id: result};
  }
}

class _FakeStartRetries extends SingboxStartRetries {
  _FakeStartRetries(this._retries);

  final Map<String, SingboxStartRetry> _retries;

  @override
  Map<String, SingboxStartRetry> build() => _retries;
}

class _FakeTorProxyService extends TorProxyService {
  @override
  Stream<TorStatus> build() async* {
    yield TorStatus(isRunning: false, bootstrapProgress: 0);
  }
}
