import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';

void main() {
  test('an unresolved snapshot blocks rather than going direct', () {
    expect(
      resolveAppRoutingPolicyForContext(null, generalContextId),
      isA<BlockedAppRouting>(),
    );
  });

  test('no general relation means direct', () {
    expect(
      resolveAppRoutingPolicyForContext(_snapshot(), generalContextId),
      isA<DirectAppRouting>(),
    );
  });

  test('an explicitly direct general relation means direct', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(relations: {generalContextId: const []}),
      generalContextId,
    );

    expect(policy, isA<DirectAppRouting>());
  });

  test('a general proxy relation routes through its endpoint', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
        },
        proxies: [_proxy(id: 'proxy-1', port: 9050)],
      ),
      generalContextId,
    );

    expect(
      policy,
      isA<ProxiedAppRouting>()
          .having((p) => p.host, 'host', '127.0.0.1')
          .having((p) => p.port, 'port', 9050)
          .having((p) => p.username, 'username', 'user'),
    );
  });

  test('a relation whose endpoint is missing blocks', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
        },
      ),
      generalContextId,
    );

    expect(policy, isA<BlockedAppRouting>());
  });

  test('a non-socks endpoint blocks rather than falling back', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
        },
        proxies: [_proxy(id: 'proxy-1', port: 8080, type: 'http')],
      ),
      generalContextId,
    );

    expect(policy, isA<BlockedAppRouting>());
  });

  test('a container relation wins over the general one', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
          'context-a': const ['proxy-2'],
        },
        proxies: [
          _proxy(id: 'proxy-1', port: 9050),
          _proxy(id: 'proxy-2', port: 12080),
        ],
      ),
      'context-a',
    );

    expect(
      policy,
      isA<ProxiedAppRouting>().having((p) => p.port, 'port', 12080),
    );
  });

  test('a container inherits the general relation', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
        },
        proxies: [_proxy(id: 'proxy-1', port: 9050)],
      ),
      'context-a',
    );

    expect(
      policy,
      isA<ProxiedAppRouting>().having((p) => p.port, 'port', 9050),
    );
  });

  test('private never inherits the general relation', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
        },
        proxies: [_proxy(id: 'proxy-1', port: 9050)],
      ),
      privateContextId,
    );

    expect(policy, isA<DirectAppRouting>());
  });

  test('an explicitly direct container ignores the general proxy', () {
    final policy = resolveAppRoutingPolicyForContext(
      _snapshot(
        relations: {
          generalContextId: const ['proxy-1'],
          'context-a': const [],
        },
        proxies: [_proxy(id: 'proxy-1', port: 9050)],
      ),
      'context-a',
    );

    expect(policy, isA<DirectAppRouting>());
  });
}

ContainerRoutingSnapshot _snapshot({
  Map<String, List<String>> relations = const {},
  List<GeckoProxySettings> proxies = const [],
}) {
  return ContainerRoutingSnapshot(
    proxies: proxies,
    relations: relations,
    directScopes: const {},
    siteAssignments: const {},
    strictContexts: const {},
  );
}

GeckoProxySettings _proxy({
  required String id,
  required int port,
  String type = 'socks',
}) {
  return GeckoProxySettings(
    id: id,
    title: id,
    type: type,
    host: '127.0.0.1',
    port: port,
    username: 'user',
    password: 'pass',
    proxyDNS: true,
    doNotProxyLocal: true,
  );
}
