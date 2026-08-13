import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/services/connection_usage.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';

const _tor = TorProxyConnectionId();
const _profile = SingboxProxyConnectionId('profile-1');

void main() {
  test('a connection nothing routes through is unused', () {
    expect(_usage(_tor).isUnused, isTrue);
  });

  test('the global route counts only in "all" mode', () {
    expect(
      _usage(
        _tor,
        settings: ProxyRoutingSettings.withDefaults(
          regularTabsMode: ProxyRegularTabRoutingMode.all,
          regularTabsProxyConnectionId: _tor,
        ),
      ).routesRegularTabs,
      isTrue,
    );

    // Per-container mode leaves the connection named but unused.
    expect(
      _usage(
        _tor,
        settings: ProxyRoutingSettings.withDefaults(
          regularTabsProxyConnectionId: _tor,
        ),
      ).isUnused,
      isTrue,
    );
  });

  test('the private-tab route counts', () {
    expect(
      _usage(
        _tor,
        settings: ProxyRoutingSettings.withDefaults(
          privateTabsProxyConnectionId: _tor,
        ),
      ).routesPrivateTabs,
      isTrue,
    );
  });

  test('containers are counted', () {
    expect(
      _usage(
        _tor,
        containers: [_container('a', _tor), _container('b', _tor)],
      ).containerCount,
      2,
    );
  });

  test('isolation routes are counted', () {
    // Missing these hides the connection from the menu entirely, since usage
    // also decides whether a profile is listed.
    expect(
      _usage(
        _tor,
        settings: ProxyRoutingSettings.withDefaults(
          isolationContextRoutes: const {'iso1_a': _tor, 'iso1_b': _tor},
        ),
      ).isolatedGroupCount,
      2,
    );
  });

  test('an explicitly direct isolation route counts against no connection', () {
    expect(
      _usage(
        _tor,
        settings: ProxyRoutingSettings.withDefaults(
          isolationContextRoutes: const {'iso1_a': null},
        ),
      ).isUnused,
      isTrue,
    );
  });

  test('every kind of route is reported together', () {
    final usage = _usage(
      _tor,
      settings: ProxyRoutingSettings.withDefaults(
        regularTabsMode: ProxyRegularTabRoutingMode.all,
        regularTabsProxyConnectionId: _tor,
        privateTabsProxyConnectionId: _tor,
        isolationContextRoutes: const {'iso1_a': _tor},
      ),
      containers: [_container('a', _tor)],
    );

    expect(usage.routesRegularTabs, isTrue);
    expect(usage.routesPrivateTabs, isTrue);
    expect(usage.containerCount, 1);
    expect(usage.isolatedGroupCount, 1);
  });

  test('routes naming another connection are not counted', () {
    expect(
      _usage(
        _tor,
        settings: ProxyRoutingSettings.withDefaults(
          regularTabsMode: ProxyRegularTabRoutingMode.all,
          regularTabsProxyConnectionId: _profile,
          isolationContextRoutes: const {'iso1_a': _profile},
        ),
        containers: [_container('a', _profile)],
      ).isUnused,
      isTrue,
    );
  });
}

ProxyConnectionUsage _usage(
  ProxyConnectionId id, {
  ProxyRoutingSettings? settings,
  List<ContainerDataWithCount> containers = const [],
}) {
  return proxyConnectionUsage(
    id: id,
    routingSettings: settings ?? ProxyRoutingSettings.withDefaults(),
    containers: containers,
  );
}

ContainerDataWithCount _container(String id, ProxyConnectionId? connectionId) {
  return ContainerDataWithCount(
    id: id,
    name: 'Container $id',
    color: const Color(0xFF336699),
    orderKey: 'a',
    metadata: ContainerMetadata.withDefaults(
      contextualIdentity: 'context-$id',
      proxyConnectionId: connectionId,
    ),
    tabCount: 0,
  );
}
