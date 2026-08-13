import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_pref_baseline.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'container assignments reach the snapshot as explicit relations',
    () async {
      const profileId = SingboxProxyConnectionId('profile-1');
      final assignedContainer = _container(
        id: 'container-1',
        contextId: 'context-a',
        proxyConnectionId: profileId,
      );
      final harness = await _harness(containers: [assignedContainer]);

      final snapshot = await harness.awaitSnapshot();

      expect(snapshot.relations['context-a'], [profileId.encode()]);
    },
  );

  test('bypassed containers get an explicit direct relation', () async {
    final bypassedContainer = _container(
      id: 'container-1',
      contextId: 'context-a',
      bypassGlobalProxy: true,
    );
    final harness = await _harness(
      containers: [bypassedContainer],
      routingSettings: ProxyRoutingSettings.withDefaults(
        regularTabsMode: ProxyRegularTabRoutingMode.all,
        regularTabsProxyConnectionId: const TorProxyConnectionId(),
      ),
    );

    final snapshot = await harness.awaitSnapshot();

    expect(snapshot.relations['context-a'], isEmpty);
    expect(snapshot.directScopes['context-a'], 'context-a');
    expect(snapshot.relations[generalContextId], [
      const TorProxyConnectionId().encode(),
    ]);
  });

  test(
    'mixed bypassed and inherited isolated containers do not bypass globally',
    () async {
      final bypassedContainer = _container(
        id: 'container-direct',
        contextId: 'context-direct',
        bypassGlobalProxy: true,
      );
      final inheritedContainer = _container(
        id: 'container-inherit',
        contextId: 'context-inherit',
      );
      final harness = await _harness(
        containers: [bypassedContainer, inheritedContainer],
        routingSettings: ProxyRoutingSettings.withDefaults(
          regularTabsMode: ProxyRegularTabRoutingMode.all,
          regularTabsProxyConnectionId: const TorProxyConnectionId(),
        ),
        isolationContexts: const {
          'isolation-a': {'container-direct', 'container-inherit'},
        },
        seedIsolatedTabs: true,
      );

      final snapshot = await harness.awaitSnapshot();

      expect(snapshot.relations['context-direct'], isEmpty);
      expect(snapshot.relations[generalContextId], [
        const TorProxyConnectionId().encode(),
      ]);
      // The isolation context inherits rather than aliasing to the bypass, so
      // the globally-proxied container in it keeps its proxy.
      expect(snapshot.relations.containsKey('isolation-a'), isFalse);
    },
  );

  test('a relation whose backend is not running has no endpoint', () async {
    const profileId = SingboxProxyConnectionId('profile-1');
    final harness = await _harness(
      containers: [
        _container(
          id: 'container-1',
          contextId: 'context-a',
          proxyConnectionId: profileId,
        ),
      ],
    );

    final snapshot = await harness.awaitSnapshot();

    // The relation stays, so the extension blocks the container instead of
    // letting it fall through to a direct connection.
    expect(snapshot.relations['context-a'], [profileId.encode()]);
    expect(snapshot.proxies, isEmpty);
  });

  test('a stopped sing-box endpoint drops out of the snapshot', () async {
    const profileId = SingboxProxyConnectionId('profile-1');
    final runtime = _FakeSingboxRuntimeRepository(
      SingboxProxyRuntimeState(
        status: SingboxProxyRuntimeStatus.running,
        endpoints: [
          SingboxProxyRuntimeEndpoint(
            profileId: profileId.encode(),
            host: '127.0.0.1',
            port: 12080,
            username: 'user',
            password: 'pass',
          ),
        ],
      ),
    );
    final harness = await _harness(
      containers: [
        _container(
          id: 'container-1',
          contextId: 'context-a',
          proxyConnectionId: profileId,
        ),
      ],
      runtimeRepository: runtime,
    );

    final running = await harness.awaitSnapshot();
    expect(running.proxies.map((proxy) => proxy.id), [profileId.encode()]);
    expect(running.proxies.single.port, 12080);

    runtime.emit(
      SingboxProxyRuntimeState(
        status: SingboxProxyRuntimeStatus.stopped,
        endpoints: const [],
      ),
    );
    await pumpEventQueue();

    final stopped = harness.readSnapshot();
    expect(stopped.proxies, isEmpty);
    expect(stopped.relations['context-a'], [profileId.encode()]);
  });

  test(
    'proxied routing arms the fail-closed prefs before installing',
    () async {
      final harness = await _harness(
        containers: [
          _container(
            id: 'container-1',
            contextId: 'context-a',
            proxyConnectionId: const SingboxProxyConnectionId('profile-1'),
          ),
        ],
      );
      await harness.awaitSnapshot();
      await pumpEventQueue();

      // The prefs must be in place before routing that relies on them, and must
      // never be disarmed while a proxy is in use.
      expect(harness.baseline.events, ['baseline:on', 'snapshot']);
    },
  );

  test(
    'fully direct routing disarms the prefs without waiting for the install',
    () async {
      final harness = await _harness(
        containers: [_container(id: 'container-1', contextId: 'context-a')],
      );
      await harness.awaitSnapshot();
      await pumpEventQueue();

      // Routing that uses no proxy leaves the prefs protecting nothing, so
      // disarming them deliberately does not wait for the push to land. Gating
      // it on an install that may never happen — an extension that fails to
      // load never acknowledges one — would stand the browser up on a dead
      // proxy pref on every launch, with no in-app way back.
      expect(harness.baseline.events, ['baseline:off', 'snapshot']);
    },
  );

  test('an isolation route reaches the snapshot as its own relation', () async {
    final harness = await _harness(
      containers: const [],
      routingSettings: ProxyRoutingSettings.withDefaults(
        isolationContextRoutes: const {'iso1_a': TorProxyConnectionId()},
      ),
    );

    final snapshot = await harness.awaitSnapshot();

    expect(snapshot.relations['iso1_a'], [
      const TorProxyConnectionId().encode(),
    ]);
  });

  test('an isolation route overrides the route of its container', () async {
    const profileId = SingboxProxyConnectionId('profile-1');
    final harness = await _harness(
      containers: [
        _container(
          id: 'container-1',
          contextId: 'context-a',
          proxyConnectionId: profileId,
        ),
      ],
      isolationContexts: const {
        'iso1_a': {'container-1'},
      },
      seedIsolatedTabs: true,
      routingSettings: ProxyRoutingSettings.withDefaults(
        isolationContextRoutes: const {'iso1_a': TorProxyConnectionId()},
      ),
    );

    final snapshot = await harness.awaitSnapshot();

    // The container keeps its own route; only the isolation group departs from
    // it.
    expect(snapshot.relations['context-a'], [profileId.encode()]);
    expect(snapshot.relations['iso1_a'], [
      const TorProxyConnectionId().encode(),
    ]);
  });

  test('an explicitly direct isolation route beats its container', () async {
    final harness = await _harness(
      containers: [
        _container(
          id: 'container-1',
          contextId: 'context-a',
          proxyConnectionId: const TorProxyConnectionId(),
        ),
      ],
      isolationContexts: const {
        'iso1_a': {'container-1'},
      },
      seedIsolatedTabs: true,
      routingSettings: ProxyRoutingSettings.withDefaults(
        isolationContextRoutes: const {'iso1_a': null},
      ),
    );

    final snapshot = await harness.awaitSnapshot();

    // Empty, not absent: absent would inherit the general relation instead of
    // connecting directly.
    expect(snapshot.relations['iso1_a'], isEmpty);
    expect(snapshot.directScopes['iso1_a'], 'iso1_a');
  });

  test('a group without a route still follows its container', () async {
    const profileId = SingboxProxyConnectionId('profile-1');
    final harness = await _harness(
      containers: [
        _container(
          id: 'container-1',
          contextId: 'context-a',
          proxyConnectionId: profileId,
        ),
      ],
      isolationContexts: const {
        'iso1_a': {'container-1'},
      },
      seedIsolatedTabs: true,
    );

    final snapshot = await harness.awaitSnapshot();

    expect(snapshot.relations['iso1_a'], [profileId.encode()]);
  });

  test(
    'no snapshot is produced while routing inputs are still loading',
    () async {
      final harness = await _harness(
        containers: [_container(id: 'container-1', contextId: 'context-a')],
        withholdSiteAssignments: true,
      );

      expect(harness.container.read(containerRoutingSnapshotProvider), isNull);
    },
  );
}

class _Harness {
  final ProviderContainer container;
  final _FakeProxyPrefBaseline baseline;
  final _FakeContainerProxyRepository containerProxy;

  _Harness(this.container, this.baseline, this.containerProxy);

  ContainerRoutingSnapshot readSnapshot() {
    final snapshot = container.read(containerRoutingSnapshotProvider);
    expect(snapshot, isNotNull, reason: 'expected a routing snapshot');
    return snapshot!;
  }

  Future<ContainerRoutingSnapshot> awaitSnapshot() async {
    await pumpEventQueue();
    return readSnapshot();
  }
}

Future<_Harness> _harness({
  required List<ContainerDataWithCount> containers,
  ProxyRoutingSettings? routingSettings,
  Map<String, Set<String>> isolationContexts = const {},
  bool seedIsolatedTabs = false,
  bool withholdSiteAssignments = false,
  _FakeSingboxRuntimeRepository? runtimeRepository,
}) async {
  final db = TabDatabase(
    NativeDatabase.memory(
      setup: (database) {
        registerLexorankFunctions(database);
        registerUrlFunctions(database);
      },
    ),
  );

  if (seedIsolatedTabs) {
    for (final container in containers) {
      await db.containerDao.addContainer(container);
      await db.tabDao.insertTab(
        'tab-${container.id}',
        source: TabSource.manual,
        parentId: const Value(null),
        containerId: Value(container.id),
        tabMode: Value(TabMode.isolated('isolation-a')),
      );
    }
  }

  final baseline = _FakeProxyPrefBaseline();
  final containerProxy = _FakeContainerProxyRepository()
    ..events = baseline.events;

  final providerContainer = ProviderContainer(
    overrides: [
      tabDatabaseProvider.overrideWith((ref) => db),
      containerProxyRepositoryProvider.overrideWith(() => containerProxy),
      containerRepositoryProvider.overrideWith(
        () => _FakeContainerRepository(containers),
      ),
      torProxyServiceProvider.overrideWith(_FakeTorProxyService.new),
      proxyPrefBaselineProvider.overrideWith(() => baseline),
      singboxProxyProfilesRepositoryProvider.overrideWith(
        _FakeProfilesRepository.new,
      ),
      singboxProxyRuntimeRepositoryProvider.overrideWith(
        () => runtimeRepository ?? _FakeSingboxRuntimeRepository(null),
      ),
      proxyRoutingSettingsRepositoryProvider.overrideWith(
        () => _FakeProxyRoutingSettingsRepository(
          routingSettings ?? ProxyRoutingSettings.withDefaults(),
        ),
      ),
      proxyRoutingSettingsWithDefaultsProvider.overrideWith(
        (ref) => routingSettings ?? ProxyRoutingSettings.withDefaults(),
      ),
      watchContainersWithCountProvider.overrideWith(
        (ref) => Stream.value(containers),
      ),
      watchAllAssignedSitesProvider.overrideWith(
        (ref) => withholdSiteAssignments
            ? const Stream<List<SiteAssignment>>.empty()
            : Stream.value(const <SiteAssignment>[]),
      ),
      watchIsolatedContextContainerMapProvider.overrideWith(
        (ref) => Stream.value(isolationContexts),
      ),
    ],
  );

  addTearDown(() async {
    providerContainer.dispose();
    await db.close();
  });

  final subscription = providerContainer.listen<void>(
    proxySettingsReplicationProvider,
    (previous, next) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);

  return _Harness(providerContainer, baseline, containerProxy);
}

ContainerDataWithCount _container({
  required String id,
  required String contextId,
  ProxyConnectionId? proxyConnectionId,
  bool bypassGlobalProxy = false,
}) {
  return ContainerDataWithCount(
    id: id,
    name: 'Container',
    color: const Color(0xFF336699),
    orderKey: 'a',
    metadata: ContainerMetadata.withDefaults(
      contextualIdentity: contextId,
      proxyConnectionId: proxyConnectionId,
      bypassGlobalProxy: bypassGlobalProxy,
    ),
    tabCount: 0,
  );
}

class _FakeContainerProxyRepository extends ContainerProxyRepository {
  final applied = <ContainerRoutingSnapshot>[];
  List<String>? events;

  @override
  Future<void> applySnapshot(ContainerRoutingSnapshot snapshot) async {
    applied.add(snapshot);
    events?.add('snapshot');
  }

  @override
  Future<bool> isRoutingReady() async => applied.isNotEmpty;

  @override
  void build() {}
}

class _FakeContainerRepository extends ContainerRepository {
  final List<ContainerDataWithCount> containers;

  _FakeContainerRepository(this.containers);

  @override
  Future<List<ContainerDataWithCount>> getAllContainersWithCount() async {
    return containers;
  }

  @override
  void build() {}
}

class _FakeTorProxyService extends TorProxyService {
  @override
  Stream<TorStatus> build() async* {
    // Mirror production: the real TorProxyService seeds the provider with the
    // current status so downstream `selectAsync` paths don't stay in
    // AsyncLoading forever. Tor is stopped in these tests.
    yield TorStatus(isRunning: false, bootstrapProgress: 0);
  }
}

class _FakeSingboxRuntimeRepository extends SingboxProxyRuntimeRepository {
  _FakeSingboxRuntimeRepository(this._initial);

  final SingboxProxyRuntimeState? _initial;

  void emit(SingboxProxyRuntimeState next) => state = AsyncData(next);

  @override
  Future<SingboxProxyRuntimeState> build() async {
    return _initial ??
        SingboxProxyRuntimeState(
          status: SingboxProxyRuntimeStatus.stopped,
          endpoints: const [],
        );
  }
}

class _FakeProxyPrefBaseline extends ProxyPrefBaseline {
  /// Every setRequired call, interleaved with snapshot installs via
  /// [_FakeContainerProxyRepository.events] so ordering can be asserted.
  final events = <String>[];

  @override
  Future<void> setRequired({required bool required}) async {
    events.add(required ? 'baseline:on' : 'baseline:off');
  }

  @override
  void build() {}
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  @override
  Stream<List<ProxyProfile>> build() => Stream.value(const []);
}

class _FakeProxyRoutingSettingsRepository
    extends ProxyRoutingSettingsRepository {
  _FakeProxyRoutingSettingsRepository(this._settings);

  final ProxyRoutingSettings _settings;

  @override
  Stream<ProxyRoutingSettings> build() => Stream.value(_settings);
}
