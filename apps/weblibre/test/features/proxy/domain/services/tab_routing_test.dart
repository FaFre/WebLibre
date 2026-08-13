import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';

void main() {
  group('context id', () {
    test('a private tab is its own context', () {
      expect(
        tabRoutingContextId(contextId: 'context-a', isPrivate: true),
        privateContextId,
      );
    });

    test('a tab without a container falls back to general', () {
      expect(
        tabRoutingContextId(contextId: null, isPrivate: false),
        generalContextId,
      );
      expect(
        tabRoutingContextId(contextId: '', isPrivate: false),
        generalContextId,
      );
    });
  });

  group('status', () {
    test('no snapshot is pending, not direct', () {
      final routing = _resolve(snapshot: null);

      expect(routing.status, TabRoutingStatus.pending);
    });

    test('an uninstalled snapshot is pending', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            generalContextId: const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        routingInstalled: false,
      );

      expect(routing.status, TabRoutingStatus.pending);
    });

    test('a relation whose proxy is running is active', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            'context-a': const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: 'context-a',
      );

      expect(routing.status, TabRoutingStatus.active);
      expect(routing.proxyConnectionId, const TorProxyConnectionId());
      expect(routing.proxyTitle, 'Tor');
    });

    test('a relation whose proxy is not running is blocked, not direct', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            'context-a': const ['tor'],
          },
        ),
        contextId: 'context-a',
      );

      expect(routing.status, TabRoutingStatus.blocked);
      // Which proxy is down is the whole point of the blocked state.
      expect(routing.proxyConnectionId, const TorProxyConnectionId());
    });

    test('no relation at all is direct', () {
      final routing = _resolve(snapshot: _snapshot());

      expect(routing.status, TabRoutingStatus.direct);
    });

    test('an unreported tab context is unknown, not direct', () {
      // "The engine has not said which cookie store this tab carries" and "this
      // tab connects directly" are answers to different questions.
      final routing = _resolve(snapshot: _snapshot(), contextId: null);

      expect(routing.status, TabRoutingStatus.unknown);
      expect(routing.contextId, isNull);
    });

    test('a missing snapshot outranks an unreported context', () {
      final routing = _resolve(snapshot: null, contextId: null);

      expect(routing.status, TabRoutingStatus.pending);
    });
  });

  group('container context mismatch', () {
    test("a tab outside its container's context says so", () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            'context-a': const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: generalContextId,
        containerContextId: 'context-a',
        containerName: 'Work',
      );

      // The tab really is direct — the container's proxy does not reach it.
      expect(routing.status, TabRoutingStatus.direct);
      expect(routing.isContextMismatch, isTrue);
      expect(routing.containerName, 'Work');
    });

    test('a mismatch is reported even when something else routes the tab', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            generalContextId: const ['tor'],
            'context-a': const [],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: generalContextId,
        containerContextId: 'context-a',
      );

      expect(routing.status, TabRoutingStatus.active);
      expect(routing.isContextMismatch, isTrue);
    });

    test("a tab in its container's context is not a mismatch", () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            'context-a': const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: 'context-a',
        containerContextId: 'context-a',
      );

      expect(routing.isContextMismatch, isFalse);
    });

    test('a container without a context of its own never mismatches', () {
      // Such a container shares the general context by design.
      final routing = _resolve(snapshot: _snapshot());

      expect(routing.isContextMismatch, isFalse);
    });

    test('an unresolved context is never reported as a mismatch', () {
      // Nothing is known about the tab yet, so nothing about it disagrees.
      final routing = _resolve(
        snapshot: _snapshot(),
        contextId: null,
        containerContextId: 'context-a',
      );

      expect(routing.status, TabRoutingStatus.unknown);
      expect(routing.isContextMismatch, isFalse);
    });
  });

  group('relation resolution', () {
    // The proxy the browser offers to start after a failed load is read off
    // the snapshot the same way (see `_proxyConnectionIdForLoadError`), so
    // these also pin down which connection that prompt names.
    test('an isolation route is resolved for its own context', () {
      // Regression: this used to be re-derived from the group's containers,
      // which knew nothing about a route set on the group itself — so an
      // isolated tab whose own proxy was down got no prompt at all.
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            'context-a': const ['tor'],
            'iso1_a': const ['singbox:profile-1'],
          },
        ),
        contextId: 'iso1_a',
      );

      expect(routing.status, TabRoutingStatus.blocked);
      expect(
        routing.proxyConnectionId,
        const SingboxProxyConnectionId('profile-1'),
      );
    });

    test('an isolation group with no relation of its own inherits', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            generalContextId: const ['tor'],
          },
        ),
        contextId: 'iso1_a',
      );

      expect(routing.proxyConnectionId, const TorProxyConnectionId());
    });

    test('a context without its own relation inherits the general one', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            generalContextId: const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: 'context-a',
      );

      expect(routing.status, TabRoutingStatus.active);
      expect(routing.proxyConnectionId, const TorProxyConnectionId());
    });

    test('an explicitly empty relation is direct, not inherited', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            generalContextId: const ['tor'],
            'context-a': const [],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: 'context-a',
      );

      expect(routing.status, TabRoutingStatus.direct);
      expect(routing.proxyConnectionId, isNull);
    });

    test('private never inherits the general relation', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            generalContextId: const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: privateContextId,
      );

      expect(routing.status, TabRoutingStatus.direct);
    });

    test('private uses its own relation', () {
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            privateContextId: const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: privateContextId,
      );

      expect(routing.status, TabRoutingStatus.active);
      expect(routing.proxyConnectionId, const TorProxyConnectionId());
    });

    test('an isolation context is resolved like any other', () {
      // Whether the relation came from the group's own route or from its
      // container's alias, the tab is carried by it either way.
      final routing = _resolve(
        snapshot: _snapshot(
          relations: {
            'iso1_a': const ['tor'],
          },
          proxies: [_proxy('tor')],
        ),
        contextId: 'iso1_a',
      );

      expect(routing.status, TabRoutingStatus.active);
      expect(routing.proxyConnectionId, const TorProxyConnectionId());
    });
  });
}

TabRouting _resolve({
  required ContainerRoutingSnapshot? snapshot,
  bool routingInstalled = true,
  String? contextId = generalContextId,
  String? containerContextId,
  String? containerName,
}) {
  return resolveTabRouting(
    snapshot: snapshot,
    routingInstalled: routingInstalled,
    contextId: contextId,
    containerContextId: containerContextId,
    containerName: containerName,
    proxyTitle: (id) => switch (id) {
      TorProxyConnectionId() => 'Tor',
      SingboxProxyConnectionId(:final profileId) => profileId,
    },
  );
}

ContainerRoutingSnapshot _snapshot({
  Map<String, List<String>> relations = const {},
  List<GeckoProxySettings> proxies = const [],
  Map<String, String> siteAssignments = const {},
}) {
  return ContainerRoutingSnapshot(
    proxies: proxies,
    relations: relations,
    directScopes: const {},
    siteAssignments: siteAssignments,
    strictContexts: const {},
  );
}

GeckoProxySettings _proxy(String id) {
  return GeckoProxySettings(
    id: id,
    title: id,
    type: 'socks',
    host: '127.0.0.1',
    port: 9050,
    username: 'user',
    password: 'pass',
    proxyDNS: true,
    doNotProxyLocal: true,
  );
}
