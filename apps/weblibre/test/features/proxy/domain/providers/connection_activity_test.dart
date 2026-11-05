/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show ProviderListenable;
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/connection_activity.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

/// Tor's status, settings and routes, with nothing running and nothing
/// configured unless a test says so.
ProviderContainer _container({
  TorStatus? status,
  TorSettings? settings,
  ProxyRoutingSettings? routing,
  List<ContainerDataWithCount> containers = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      generalSettingsWithDefaultsProvider.overrideWithValue(
        GeneralSettings.withDefaults(),
      ),
      runningSingboxProfileIdsProvider.overrideWith(
        () => _FakeRunningProfileIds(const {}),
      ),
      singboxProxyStartingConnectionsProvider.overrideWith(
        () => _FakeStartingConnections(const {}),
      ),
      torProxyServiceProvider.overrideWith(() => _FakeTorProxyService(status)),
      torSettingsWithDefaultsProvider.overrideWithValue(
        settings ?? TorSettings.withDefaults(),
      ),
      proxyRoutingSettingsWithDefaultsProvider.overrideWithValue(
        routing ?? ProxyRoutingSettings.withDefaults(),
      ),
      watchContainersWithCountProvider.overrideWith(
        (ref) => Stream.value(containers),
      ),
      // For [connectionsInUse]: no sing-box profile, nothing running, so only
      // Tor can keep the Proxy category.
      singboxProxyProfilesRepositoryProvider.overrideWith(
        _NoProfilesRepository.new,
      ),
      anyConnectionActiveProvider.overrideWithValue(false),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<bool> _read(
  ProviderContainer container,
  ProviderListenable<bool> provider,
) async {
  // Riverpod pauses a provider nothing listens to, so a bare `.future` read
  // of one would never resolve.
  container.listen(provider, (_, _) {});
  container
    ..listen(torProxyServiceProvider, (_, _) {})
    ..listen(watchContainersWithCountProvider, (_, _) {})
    ..listen(singboxProxyProfilesRepositoryProvider, (_, _) {});
  await container.read(torProxyServiceProvider.future);
  await container.read(watchContainersWithCountProvider.future);
  await container.read(singboxProxyProfilesRepositoryProvider.future);
  final value = container.read(provider);
  return value;
}

ContainerDataWithCount _containerRoutedThrough(ProxyConnectionId id) =>
    ContainerDataWithCount(
      id: 'c1',
      name: 'Container',
      color: const Color(0xFF336699),
      orderKey: 'a',
      metadata: ContainerMetadata.withDefaults(
        contextualIdentity: 'ctx-1',
        proxyConnectionId: id,
      ),
      tabCount: 0,
    );

void main() {
  const tor = TorProxyConnectionId();

  test('an unused, stopped Tor with default settings is not in use', () async {
    final container = _container();
    expect(await _read(container, torInUseProvider), isFalse);
    expect(await _read(container, connectionsInUseProvider), isFalse);
  });

  // The review's case: autostart failed, so Tor is stopped, and there is
  // nothing else to keep the Proxy category.
  test('autostart keeps Tor and the Proxy category while stopped', () async {
    final container = _container(
      settings: TorSettings.withDefaults(autostart: true),
    );
    expect(await _read(container, torInUseProvider), isTrue);
    expect(await _read(container, connectionsInUseProvider), isTrue);
  });

  test('settings changed from the defaults keep Tor while stopped', () async {
    final container = _container(
      settings: TorSettings.withDefaults(config: TorConnectionConfig.obfs4),
    );
    expect(await _read(container, torInUseProvider), isTrue);
  });

  test('a container route through Tor keeps it while stopped', () async {
    final container = _container(containers: [_containerRoutedThrough(tor)]);
    expect(await _read(container, torInUseProvider), isTrue);
    expect(await _read(container, connectionsInUseProvider), isTrue);
  });

  test('an isolated-group route through Tor keeps it while stopped', () async {
    final container = _container(
      routing: ProxyRoutingSettings.withDefaults(
        isolationContextRoutes: {'group-1': tor},
      ),
    );
    expect(await _read(container, torInUseProvider), isTrue);
    expect(await _read(container, connectionsInUseProvider), isTrue);
  });

  test('a route through another connection does not keep Tor', () async {
    final container = _container(
      containers: [
        _containerRoutedThrough(const SingboxProxyConnectionId('p')),
      ],
    );
    expect(await _read(container, torInUseProvider), isFalse);
  });

  test('a running Tor is in use', () async {
    final container = _container(
      status: TorStatus(isRunning: true, bootstrapProgress: 100),
    );
    expect(await _read(container, torInUseProvider), isTrue);
  });
}

class _FakeTorProxyService extends TorProxyService {
  _FakeTorProxyService(this._status);

  final TorStatus? _status;

  @override
  Stream<TorStatus> build() async* {
    yield _status ?? TorStatus(isRunning: false, bootstrapProgress: 0);
  }
}

class _NoProfilesRepository extends SingboxProxyProfilesRepository {
  @override
  Stream<List<ProxyProfile>> build() => Stream.value(const []);
}

class _FakeRunningProfileIds extends RunningSingboxProfileIds {
  _FakeRunningProfileIds(this._ids);

  final Set<String> _ids;

  @override
  Set<String> build() => _ids;
}

class _FakeStartingConnections extends SingboxProxyStartingConnections {
  _FakeStartingConnections(this._ids);

  final Set<String> _ids;

  @override
  Set<String> build() => _ids;
}
