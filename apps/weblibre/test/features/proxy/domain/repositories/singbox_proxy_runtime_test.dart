import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/singbox_proxy_endpoint_sync.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ensureProxyConnectionAvailable starts an assigned stopped profile',
    () async {
      final profile = _profile(id: 'profile-1', name: 'First');
      final client = _FakeSingboxProxyClient(_state(const []));
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final repository = container.read(
        singboxProxyRuntimeRepositoryProvider.notifier,
      );

      await repository.ensureProxyConnectionAvailable(
        SingboxProxyConnectionId(profile.id),
      );
      await repository.ensureProxyConnectionAvailable(
        SingboxProxyConnectionId(profile.id),
      );

      expect(client.startCalls, hasLength(1));
      expect(
        client.startCalls.single.map((runtimeProfile) => runtimeProfile.id),
        [profile.proxyConnectionId],
      );
    },
  );

  test('startProfile preserves already-running profiles', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client = _FakeSingboxProxyClient(
      _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
    );
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .startProfile(profile2.id);

    expect(client.startCalls, hasLength(1));
    expect(
      client.startCalls.single.map((profile) => profile.id),
      unorderedEquals([profile1.proxyConnectionId, profile2.proxyConnectionId]),
    );
  });

  test(
    'concurrent startProfile calls preserve both requested profiles',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Second');
      final client = _FakeSingboxProxyClient(_state(const []));
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final repository = container.read(
        singboxProxyRuntimeRepositoryProvider.notifier,
      );

      await Future.wait([
        repository.startProfile(profile1.id),
        repository.startProfile(profile2.id),
      ]);

      expect(client.startCalls, hasLength(2));
      expect(
        client.startCalls.last.map((profile) => profile.id),
        unorderedEquals([
          profile1.proxyConnectionId,
          profile2.proxyConnectionId,
        ]),
      );
      expect(
        container
            .read(singboxProxyRuntimeRepositoryProvider)
            .requireValue
            .endpoints
            .map((endpoint) => endpoint.profileId),
        unorderedEquals([
          profile1.proxyConnectionId,
          profile2.proxyConnectionId,
        ]),
      );
    },
  );

  test('stopProfiles unregisters removed Gecko proxy endpoints', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client =
        _FakeSingboxProxyClient(
            _state([
              _endpoint(profile1.proxyConnectionId, port: 12080),
              _endpoint(profile2.proxyConnectionId, port: 12081),
            ]),
          )
          ..stateAfterStop = _state([
            _endpoint(profile1.proxyConnectionId, port: 12080),
          ]);
    final containerProxyRepository = _FakeContainerProxyRepository();
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      containerProxyRepository: containerProxyRepository,
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .stopProfiles([profile2.id]);
    await _drainSync();

    expect(client.stopCalls, [profile2.proxyConnectionId]);
    expect(containerProxyRepository.removedProxyIds, [
      profile2.proxyConnectionId,
    ]);
  });

  test(
    'deleteProfile stops runtime and preserves persisted references',
    () async {
      final profile = _profile(id: 'profile-1', name: 'First');
      final client = _FakeSingboxProxyClient(
        _state([_endpoint(profile.proxyConnectionId, port: 12080)]),
      )..stateAfterStop = _state(const []);
      final profilesRepository = _FakeProfilesRepository([profile]);
      final containerRepository = _FakeContainerRepository();
      final routingSettingsRepository = _FakeProxyRoutingSettingsRepository(
        ProxyRoutingSettings(
          regularTabsMode: ProxyRegularTabRoutingMode.all,
          regularTabsProxyConnectionId: profile.proxyConnection,
          privateTabsProxyConnectionId: profile.proxyConnection,
        ),
      );
      final container = _container(
        client: client,
        profilesRepository: profilesRepository,
        containerRepository: containerRepository,
        routingSettingsRepository: routingSettingsRepository,
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .deleteProfile(profile.id);

      expect(client.stopCalls, [profile.proxyConnectionId]);
      expect(containerRepository.clearedProxyConnectionIds, isEmpty);
      final routingSettings = routingSettingsRepository.peekSettings();

      expect(routingSettings, isNotNull);
      expect(routingSettings!.regularTabsMode, ProxyRegularTabRoutingMode.all);
      expect(
        routingSettings.regularTabsProxyConnectionId,
        profile.proxyConnection,
      );
      expect(
        routingSettings.privateTabsProxyConnectionId,
        profile.proxyConnection,
      );
      expect(profilesRepository.deletedProfileIds, [profile.id]);
    },
  );

  test('runtime stream sync removes stale Gecko proxy registrations', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client = _FakeSingboxProxyClient(
      _state([
        _endpoint(profile1.proxyConnectionId, port: 12080),
        _endpoint(profile2.proxyConnectionId, port: 12081),
      ]),
    );
    final containerProxyRepository = _FakeContainerProxyRepository();
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      containerProxyRepository: containerProxyRepository,
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    client.emit(_state([_endpoint(profile2.proxyConnectionId, port: 12081)]));
    await _drainSync();

    expect(containerProxyRepository.removedProxyIds, [
      profile1.proxyConnectionId,
    ]);
  });
}

ProviderContainer _container({
  required _FakeSingboxProxyClient client,
  required _FakeProfilesRepository profilesRepository,
  _FakeContainerProxyRepository? containerProxyRepository,
  _FakeContainerRepository? containerRepository,
  _FakeProxyRoutingSettingsRepository? routingSettingsRepository,
}) {
  final container = ProviderContainer(
    overrides: [
      singboxProxyClientProvider.overrideWithValue(client),
      singboxProxyProfilesRepositoryProvider.overrideWith(
        () => profilesRepository,
      ),
      singboxProxyCredentialsRepositoryProvider.overrideWith(
        _FakeCredentialsRepository.new,
      ),
      engineSettingsRepositoryProvider.overrideWith(
        _FakeEngineSettingsRepository.new,
      ),
      containerProxyRepositoryProvider.overrideWith(
        () => containerProxyRepository ?? _FakeContainerProxyRepository(),
      ),
      containerRepositoryProvider.overrideWith(
        () => containerRepository ?? _FakeContainerRepository(),
      ),
      proxyRoutingSettingsRepositoryProvider.overrideWith(
        () =>
            routingSettingsRepository ?? _FakeProxyRoutingSettingsRepository(),
      ),
    ],
  );

  // Activate the endpoint sync notifier so runtime state changes propagate
  // into the fake container proxy repository. Production wires this in
  // main.dart; tests have to ask for it explicitly.
  container.read(singboxProxyEndpointSyncProvider);

  return container;
}

/// Drains all currently-pending microtasks/futures so the endpoint-sync
/// `ref.listen` callback (chained off the runtime state stream listener)
/// has time to apply its registrations against the fake Gecko repo.
Future<void> _drainSync() => pumpEventQueue();

ProxyProfile _profile({required String id, required String name}) {
  final createdAt = DateTime(2026);

  return ProxyProfile(
    id: id,
    name: name,
    type: SingboxProxyProfileType.customOutbound,
    configJson: '{"type":"socks"}',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

SingboxProxyRuntimeState _state(List<SingboxProxyRuntimeEndpoint> endpoints) {
  return SingboxProxyRuntimeState(
    status: endpoints.isEmpty
        ? SingboxProxyRuntimeStatus.stopped
        : SingboxProxyRuntimeStatus.running,
    endpoints: endpoints,
  );
}

SingboxProxyRuntimeEndpoint _endpoint(String profileId, {required int port}) {
  return SingboxProxyRuntimeEndpoint(
    profileId: profileId,
    host: '127.0.0.1',
    port: port,
    username: 'user-$port',
    password: 'pass-$port',
  );
}

class _FakeSingboxProxyClient implements SingboxProxyClient {
  final _stateController =
      StreamController<SingboxProxyRuntimeState>.broadcast();
  final startCalls = <List<SingboxProxyProfile>>[];
  final stopCalls = <String>[];
  SingboxProxyRuntimeState _currentState;
  SingboxProxyRuntimeState? stateAfterStop;

  _FakeSingboxProxyClient(this._currentState);

  @override
  Stream<SingboxProxyRuntimeState> get stateStream => _stateController.stream;

  @override
  Stream<SingboxProxyLogMessage> get logStream => const Stream.empty();

  void emit(SingboxProxyRuntimeState state) {
    _currentState = state;
    _stateController.add(state);
  }

  @override
  Future<SingboxProxyRuntimeState> getState() async => _currentState;

  @override
  Future<SingboxProxyRuntimeState> start(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    startCalls.add(profiles);
    return _currentState = _state(
      profiles.indexed
          .map((item) => _endpoint(item.$2.id, port: 12080 + item.$1))
          .toList(),
    );
  }

  @override
  Future<void> stop(List<String> profileIds) async {
    stopCalls.addAll(profileIds);
    _currentState = stateAfterStop ?? _currentState;
  }

  @override
  Future<void> stopAll() async {
    _currentState = _state(const []);
  }

  @override
  Future<String?> validateProfile(SingboxProxyProfile profile) async => null;

  @override
  Future<SingboxProxyConfigResult> buildConfig(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    return SingboxProxyConfigResult(configJson: '{}', endpoints: const []);
  }

  @override
  Future<void> dispose() => _stateController.close();
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;
  final deletedProfileIds = <String>[];

  _FakeProfilesRepository(this.profiles);

  @override
  Future<List<ProxyProfile>> fetchProfiles() async => profiles;

  @override
  Future<void> deleteProfile(String profileId) async {
    deletedProfileIds.add(profileId);
  }

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}

class _FakeCredentialsRepository extends SingboxProxyCredentialsRepository {
  @override
  Future<String?> readSecretJson(String profileId) async => null;

  @override
  void build() {}
}

class _FakeEngineSettingsRepository extends EngineSettingsRepository {
  final settings = EngineSettings.withDefaults();

  @override
  Future<EngineSettings> fetchSettings() async => settings;

  @override
  Stream<EngineSettings> build() => Stream.value(settings);
}

class _FakeContainerProxyRepository extends ContainerProxyRepository {
  final upsertedProxies = <GeckoProxySettings>[];
  final removedProxyIds = <String>[];

  @override
  Future<void> upsertProxy(GeckoProxySettings proxy) async {
    upsertedProxies.add(proxy);
  }

  @override
  Future<void> removeProxy(String proxyId) async {
    removedProxyIds.add(proxyId);
  }

  @override
  void build() {}
}

class _FakeContainerRepository extends ContainerRepository {
  final clearedProxyConnectionIds = <ProxyConnectionId>[];

  @override
  Future<void> clearProxyConnectionAssignments(
    ProxyConnectionId proxyConnectionId,
  ) async {
    clearedProxyConnectionIds.add(proxyConnectionId);
  }

  @override
  void build() {}
}

class _FakeProxyRoutingSettingsRepository
    extends ProxyRoutingSettingsRepository {
  final ProxyRoutingSettings? _settings;

  _FakeProxyRoutingSettingsRepository([this._settings]);

  ProxyRoutingSettings? peekSettings() => _settings;

  @override
  Stream<ProxyRoutingSettings> build() {
    return Stream.value(_settings ?? ProxyRoutingSettings.withDefaults());
  }
}
