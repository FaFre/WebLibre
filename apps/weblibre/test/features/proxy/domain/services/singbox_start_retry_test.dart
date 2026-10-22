// The notifier subclasses below are test doubles: recording what a collaborator
// was asked to do is their whole purpose, and mutable public fields are how the
// tests read it back.
// ignore_for_file: riverpod_lint/avoid_public_notifier_properties

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/singbox_start_retry.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('retries a failed start until it comes up', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 2);
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    final retries = container.read(singboxStartRetriesProvider.notifier);

    retries.failed(['profile-1']);
    expect(
      container.read(singboxStartRetriesProvider)['profile-1']?.attempts,
      1,
    );

    await pumpEventQueue();

    expect(runtime.startCalls, [
      ['profile-1'],
      ['profile-1'],
      ['profile-1'],
    ]);
    // Up on the third attempt, so there is nothing left to report.
    expect(container.read(singboxStartRetriesProvider), isEmpty);
  });

  test('stops after the last attempt and says so', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 100);
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    container.read(singboxStartRetriesProvider.notifier).failed(['profile-1']);
    await pumpEventQueue();

    // One attempt per configured delay, and no more.
    expect(runtime.startCalls, hasLength(_delays.length));
    final retry = container.read(singboxStartRetriesProvider)['profile-1'];
    expect(retry, isNotNull);
    expect(retry!.exhausted, isTrue);
  });

  test('drops a profile that came up some other way', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 100);
    final container = _container(
      runtime: runtime,
      delays: const [Duration(hours: 1)],
    );
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    container.read(singboxStartRetriesProvider.notifier).failed(['profile-1']);
    expect(container.read(singboxStartRetriesProvider), contains('profile-1'));

    // The user started it by hand.
    runtime.emitRunning(['profile-1']);
    await pumpEventQueue();

    expect(container.read(singboxStartRetriesProvider), isEmpty);
    expect(runtime.startCalls, isEmpty);
  });

  test('a profile the user stopped is not started by itself', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 0);
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    final retries = container.read(singboxStartRetriesProvider.notifier);

    retries
      ..failed(['profile-1', 'profile-2'])
      ..cancel(['profile-1']);
    expect(container.read(singboxStartRetriesProvider).keys, ['profile-2']);

    retries.cancelAll();
    await pumpEventQueue();

    expect(runtime.startCalls, isEmpty);
    expect(container.read(singboxStartRetriesProvider), isEmpty);
  });

  test(
    'a profile stopped while its retry waited for the runtime stays down',
    () async {
      final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 0);
      final container = _container(runtime: runtime);
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final retries = container.read(singboxStartRetriesProvider.notifier);

      // "Stop all" lands while the attempt is queued behind another start.
      runtime.whileWaitingForLock = retries.cancelAll;
      retries.failed(['profile-1']);
      await pumpEventQueue();

      expect(runtime.probeCalls, ['profile-1']);
      expect(runtime.startCalls, isEmpty);
      expect(container.read(singboxStartRetriesProvider), isEmpty);
    },
  );

  test('a failed probe costs an attempt but no start', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 0)
      ..probeFailures = 1;
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    container.read(singboxStartRetriesProvider.notifier).failed(['profile-1']);
    await pumpEventQueue();

    expect(runtime.probeCalls, ['profile-1', 'profile-1']);
    expect(runtime.startCalls, [
      ['profile-1'],
    ]);
    expect(container.read(singboxStartRetriesProvider), isEmpty);
  });

  test('drops a profile that was deleted in the meantime', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 100);
    final container = _container(runtime: runtime, profiles: const []);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    container.read(singboxStartRetriesProvider.notifier).failed(['profile-1']);
    await pumpEventQueue();

    expect(runtime.startCalls, isEmpty);
    expect(container.read(singboxStartRetriesProvider), isEmpty);
  });

  test('a config sing-box refuses is not retried', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 100);
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    container.read(singboxStartRetriesProvider.notifier).failed([
      'profile-1',
    ], permanent: true);
    await pumpEventQueue();

    expect(runtime.startCalls, isEmpty);
    expect(
      container.read(singboxStartRetriesProvider)['profile-1']?.exhausted,
      isTrue,
    );
  });

  test('a retry that sing-box refuses stops retrying', () async {
    final runtime = _FakeRuntimeRepository(
      failuresBeforeSuccess: 100,
      rejectFrom: 1,
    );
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    container.read(singboxStartRetriesProvider.notifier).failed(['profile-1']);
    await pumpEventQueue();

    expect(runtime.startCalls, hasLength(1));
    expect(
      container.read(singboxStartRetriesProvider)['profile-1']?.exhausted,
      isTrue,
    );
  });

  test('a profile the runtime put back is not retried', () async {
    final runtime = _FakeRuntimeRepository(failuresBeforeSuccess: 100)
      ..emitRunning(['profile-1']);
    final container = _container(runtime: runtime);
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    // A failed batch that also named a profile which was running before it:
    // the runtime restored that one, so only the new one needs another go.
    container.read(singboxStartRetriesProvider.notifier).failed([
      'profile-1',
      'profile-2',
    ]);

    expect(container.read(singboxStartRetriesProvider).keys, ['profile-2']);
  });
}

const _delays = [Duration.zero, Duration.zero, Duration.zero];

ProviderContainer _container({
  required _FakeRuntimeRepository runtime,
  List<Duration> delays = _delays,
  List<String> profiles = const ['profile-1', 'profile-2'],
}) {
  return ProviderContainer(
    overrides: [
      singboxProxyRuntimeRepositoryProvider.overrideWith(() => runtime),
      singboxProxyProfilesRepositoryProvider.overrideWith(
        () => _FakeProfilesRepository(profiles.map(_profile).toList()),
      ),
      singboxStartRetryDelaysProvider.overrideWithValue(delays),
    ],
  );
}

ProxyProfile _profile(String id) {
  final createdAt = DateTime(2026);
  return ProxyProfile(
    id: id,
    name: id,
    type: SingboxProxyProfileType.customOutbound,
    configJson: '{"type":"socks"}',
    autostart: true,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  _FakeRuntimeRepository({
    required this.failuresBeforeSuccess,
    this.rejectFrom,
  });

  final int failuresBeforeSuccess;

  /// From this attempt on (1-based), a start fails as sing-box refusing it.
  final int? rejectFrom;
  final startCalls = <List<String>>[];

  /// Retries whose probe fails before one passes.
  int probeFailures = 0;
  final probeCalls = <String>[];

  /// Runs where the real [retryProfile] waits for the runtime lock.
  void Function()? whileWaitingForLock;
  var _built = false;
  SingboxProxyRuntimeState _initial = SingboxProxyRuntimeState(
    status: SingboxProxyRuntimeStatus.stopped,
    endpoints: const [],
  );

  void emitRunning(List<String> profileIds) {
    final running = SingboxProxyRuntimeState(
      status: SingboxProxyRuntimeStatus.running,
      endpoints: [
        for (final (index, profileId) in profileIds.indexed)
          SingboxProxyRuntimeEndpoint(
            profileId: SingboxProxyConnectionId(profileId).encode(),
            host: '127.0.0.1',
            port: 12080 + index,
            username: 'user',
            password: 'pass',
          ),
      ],
    );
    _initial = running;
    // Before the build, [build] picks [_initial] up instead.
    if (_built) state = AsyncData(running);
  }

  @override
  Future<SingboxProxyRuntimeState> ensureProfilesStarted(
    List<String> profileIds, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    startCalls.add(profileIds);
    final rejectFrom = this.rejectFrom;
    if (rejectFrom != null && startCalls.length >= rejectFrom) {
      throw SingboxProfilesRejected({
        for (final id in profileIds) id: (name: id, message: 'invalid key'),
      });
    }
    if (startCalls.length <= failuresBeforeSuccess) {
      throw StateError('start failed');
    }
    emitRunning(profileIds);
    return _initial;
  }

  @override
  Future<SingboxProxyRuntimeState?> retryProfile(
    String profileId, {
    required bool Function() stillWanted,
  }) async {
    probeCalls.add(profileId);
    if (probeCalls.length <= probeFailures) {
      throw const SingboxProbeFailed('peer does not resolve');
    }
    whileWaitingForLock?.call();
    if (!stillWanted()) return null;
    return await ensureProfilesStarted([profileId]);
  }

  @override
  Future<SingboxProxyRuntimeState> build() async {
    _built = true;
    return _initial;
  }
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  _FakeProfilesRepository(this.profiles);

  final List<ProxyProfile> profiles;

  @override
  Future<ProxyProfile?> findProfile(String id) async {
    return profiles.where((profile) => profile.id == id).firstOrNull;
  }

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}
