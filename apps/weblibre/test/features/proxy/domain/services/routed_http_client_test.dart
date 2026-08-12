import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/routed_http_client.dart';

void main() {
  /// A request issued before the routing inputs have loaded used to resolve to
  /// blocked and stay failed — nothing re-runs a favicon lookup or feed fetch
  /// once routing lands, so the first seconds after launch silently lost them.
  test('a routing read taken before routing resolves waits for it', () async {
    final controller = StreamController<ContainerRoutingSnapshot?>();
    addTearDown(controller.close);

    final source = StreamProvider<ContainerRoutingSnapshot?>(
      (ref) => controller.stream,
    );

    final container = ProviderContainer(
      overrides: [
        containerRoutingSnapshotProvider.overrideWith(
          (ref) => ref.watch(source).value,
        ),
      ],
    );
    addTearDown(container.dispose);

    // Providers are auto-dispose by default, and a bare `read` of `.future`
    // would tear the probe down — and with it the routing subscription it is
    // waiting on — before the answer arrives.
    addTearDown(container.listen(_probeProvider, (_, _) {}).close);

    // Taken while routing is still unresolved, as a request racing startup is.
    final policy = container.read(_probeProvider.future);

    controller.add(
      ContainerRoutingSnapshot(
        proxies: const [],
        relations: const {},
        directScopes: const {},
        siteAssignments: const {},
        strictContexts: const {},
      ),
    );

    expect(await policy, isA<DirectAppRouting>());
  });

  /// [RoutedHttpClient] resolves through a closure over its provider's ref, so
  /// this runs long after that provider was built — the path every routed HTTP
  /// request takes.
  test('a routing read taken outside a build waits just the same', () async {
    final controller = StreamController<ContainerRoutingSnapshot?>();
    addTearDown(controller.close);

    final source = StreamProvider<ContainerRoutingSnapshot?>(
      (ref) => controller.stream,
    );

    final container = ProviderContainer(
      overrides: [
        containerRoutingSnapshotProvider.overrideWith(
          (ref) => ref.watch(source).value,
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(container.listen(_refHolderProvider, (_, _) {}).close);

    final ref = container.read(_refHolderProvider);
    final policy = resolveAppRoutingPolicy(ref, generalContextId);

    controller.add(
      ContainerRoutingSnapshot(
        proxies: const [],
        relations: const {},
        directScopes: const {},
        siteAssignments: const {},
        strictContexts: const {},
      ),
    );

    expect(await policy, isA<DirectAppRouting>());
  });

  test('routing that is resolved already answers immediately', () async {
    final container = ProviderContainer(
      overrides: [
        containerRoutingSnapshotProvider.overrideWith(
          (ref) => ContainerRoutingSnapshot(
            proxies: const [],
            relations: const {
              generalContextId: ['proxy-1'],
            },
            directScopes: const {},
            siteAssignments: const {},
            strictContexts: const {},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Providers are auto-dispose by default, and a bare `read` of `.future`
    // would tear the probe down — and with it the routing subscription it is
    // waiting on — before the answer arrives.
    addTearDown(container.listen(_probeProvider, (_, _) {}).close);

    // A relation whose endpoint is not running is a block, not a wait: it is
    // known, and what is known to be unusable must fail the request.
    expect(
      await container.read(_probeProvider.future),
      isA<BlockedAppRouting>(),
    );
  });

  /// The leak this guards: suggestions, favicon lookups and link expansions
  /// used to resolve against [generalContextId] no matter which tab they were
  /// made for, so browsing in a proxied container while the general container
  /// was direct sent them out unproxied.
  test(
    'selected-tab routing follows the tab, not the general container',
    () async {
      final container = ProviderContainer(
        overrides: [
          selectedTabStateProvider.overrideWithValue(
            TabState.$default('tab-1').copyWith.tabMode(const PrivateTabMode()),
          ),
          containerRoutingSnapshotProvider.overrideWith(
            (ref) => ContainerRoutingSnapshot(
              proxies: [
                GeckoProxySettings(
                  id: 'proxy-1',
                  title: 'proxy-1',
                  type: 'socks',
                  host: '127.0.0.1',
                  port: 9050,
                  username: null,
                  password: null,
                  proxyDNS: true,
                  doNotProxyLocal: true,
                ),
              ],
              // The general container is deliberately direct: resolving against
              // it is exactly what used to leak.
              relations: const {
                privateContextId: ['proxy-1'],
              },
              directScopes: const {},
              siteAssignments: const {},
              strictContexts: const {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final policy = await container.read(selectedTabRoutingPolicyProvider)();

      expect(
        policy,
        isA<ProxiedAppRouting>().having((p) => p.port, 'port', 9050),
      );
    },
  );
}

/// Stands in for any provider that resolves routing for a request it is about
/// to make.
final _probeProvider = FutureProvider<AppRoutingPolicy>(
  (ref) => resolveAppRoutingPolicy(ref, generalContextId),
);

/// Hands out a long-lived ref, standing in for the one a client closure keeps.
final _refHolderProvider = Provider<Ref>((ref) => ref);
