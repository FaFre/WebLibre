/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:tor/tor.dart';

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  Timer? timeout;
  final startedProxyType = <ProxyType>{};

  Tor.init();

  final portSub = Tor.instance.events.stream.listen((port) {
    service.invoke('portUpdate', {'port': port});
  });

  Future<void> stopProxies() async {
    for (final proxyType in startedProxyType) {
      await IPtProxyController().stop(proxyType);
    }
    startedProxyType.clear();
  }

  Future<void> stopService() async {
    timeout?.cancel();
    timeout = null;

    Tor.instance.stop();
    await stopProxies();

    service.invoke('portUpdate', {'port': -1});

    await portSub.cancel();

    await service.stopSelf();
  }

  void addHeartbeat() {
    timeout?.cancel();
    //Kill service after 1 hour of inactivity
    timeout = Timer(const Duration(hours: 1), () async {
      // logger.i('Terminating tor due to timeout');
      await stopService();
    });
  }

  Future<void> startService(ProxyType? proxyType, String? bridgeLines) async {
    if (proxyType != null) {
      final port = await IPtProxyController().start(proxyType, "");
      startedProxyType.add(proxyType);

      switch (proxyType) {
        case ProxyType.obfs4:
          await Tor.instance.start(obfs4Port: port, bridgeLines: bridgeLines);
        case ProxyType.meekLite:
          throw UnimplementedError();
        case ProxyType.webtunnel:
          throw UnimplementedError();
        case ProxyType.snowflake:
          await Tor.instance.start(
            snowflakePort: port,
            bridgeLines: bridgeLines,
          );
      }
    } else {
      await Tor.instance.start();
    }
  }

  Future<void> reconfigureService(
    ProxyType? proxyType,
    String? bridgeLines,
  ) async {
    if (Tor.instance.hasClient) {
      await stopProxies();

      if (proxyType != null) {
        final port = await IPtProxyController().start(proxyType, "");
        startedProxyType.add(proxyType);

        switch (proxyType) {
          case ProxyType.obfs4:
            await Tor.instance.reconfigure(
              obfs4Port: port,
              bridgeLines: bridgeLines,
            );
          case ProxyType.meekLite:
            throw UnimplementedError();
          case ProxyType.webtunnel:
            throw UnimplementedError();
          case ProxyType.snowflake:
            await Tor.instance.reconfigure(
              snowflakePort: port,
              bridgeLines: bridgeLines,
            );
        }
      } else {
        await Tor.instance.reconfigure();
      }
    }
  }

  service.on("startOrReconfigure").listen((event) async {
    final proxyType = ProxyType.values.firstWhereOrNull(
      (x) => x.name == event?['proxyType'],
    );

    await reconfigureService(proxyType, event?['bridgeLines'] as String?);

    if (!Tor.instance.hasClient) {
      await startService(proxyType, event?['bridgeLines'] as String?);
    }
  });

  service.on("reconfigure").listen((event) async {
    final proxyType = ProxyType.values.firstWhereOrNull(
      (x) => x.name == event?['proxyType'],
    );

    await reconfigureService(proxyType, event?['bridgeLines'] as String?);
  });

  service.on("heartbeat").listen((event) {
    // logger.d('Received tor heartbeat');
    addHeartbeat();
  });

  service.on("sync").listen((event) {
    service.invoke('portUpdate', {'port': Tor.instance.port});
  });

  service.on("stop").listen((event) async {
    await stopService();
  });
}
