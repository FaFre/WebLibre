import 'dart:async';
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'container assignments sync without starting stopped sing-box profiles',
    () async {
      const profileId = SingboxProxyConnectionId('profile-1');
      final assignedContainer = _container(
        id: 'container-1',
        contextId: 'context-a',
        proxyConnectionId: profileId,
      );
      final db = TabDatabase(
        NativeDatabase.memory(
          setup: (database) {
            registerLexorankFunctions(database);
            registerUrlFunctions(database);
          },
        ),
      );
      final containerProxyRepository = _FakeContainerProxyRepository();
      final containerRepository = _FakeContainerRepository([assignedContainer]);
      final container = ProviderContainer(
        overrides: [
          tabDatabaseProvider.overrideWith((ref) => db),
          containerProxyRepositoryProvider.overrideWith(
            () => containerProxyRepository,
          ),
          containerRepositoryProvider.overrideWith(() => containerRepository),
          torProxyServiceProvider.overrideWith(_FakeTorProxyService.new),
          proxyRoutingSettingsWithDefaultsProvider.overrideWith(
            (ref) => ProxyRoutingSettings.withDefaults(),
          ),
          watchContainersWithCountProvider.overrideWith(
            (ref) => Stream.value([assignedContainer]),
          ),
          watchAllAssignedSitesProvider.overrideWith(
            (ref) => Stream.value(const <SiteAssignment>[]),
          ),
          watchIsolatedContextContainerMapProvider.overrideWith(
            (ref) => Stream.value(const <String, Set<String>>{}),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final subscription = container.listen<void>(
        proxySettingsReplicationProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await pumpEventQueue();

      expect(containerProxyRepository.setContainerProxyCalls, [
        ('context-a', profileId.encode()),
      ]);
    },
  );
}

ContainerDataWithCount _container({
  required String id,
  required String contextId,
  required ProxyConnectionId proxyConnectionId,
}) {
  return ContainerDataWithCount(
    id: id,
    name: 'Container',
    color: const Color(0xFF336699),
    orderKey: 'a',
    metadata: ContainerMetadata.withDefaults(
      contextualIdentity: contextId,
      proxyConnectionId: proxyConnectionId,
    ),
    tabCount: 0,
  );
}

class _FakeContainerProxyRepository extends ContainerProxyRepository {
  final setContainerProxyCalls = <(String, String)>[];

  @override
  Future<void> setTorProxyPort(int? port) async {}

  @override
  Future<void> setSiteAssignments(List<SiteAssignment> assignements) async {}

  @override
  Future<void> setContainerProxy(String contextId, String proxyId) async {
    setContainerProxyCalls.add((contextId, proxyId));
  }

  @override
  Future<void> clearContainerProxy(String contextId) async {}

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
