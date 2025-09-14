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
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:nullability/nullability.dart';
import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/lifecycle.dart';
import 'package:weblibre/features/tor/domain/repositories/builtin_bridges.dart';
import 'package:weblibre/features/tor/utils/tor_entrypoint.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'tor_proxy.g.dart';

class _TorService {
  final service = FlutterBackgroundService();

  final _portSubject = BehaviorSubject<int?>.seeded(null);

  ValueStream<int?> get portStream => _portSubject.stream;

  Future<void> startOrReconfigure({
    ProxyType? proxyType,
    String? bridgeLines,
  }) async {
    await service.startService();
    service.invoke('startOrReconfigure', {
      if (proxyType != null) 'proxyType': proxyType.name,
      if (bridgeLines != null) 'bridgeLines': bridgeLines,
    });
  }

  Future<void> reconfigure({ProxyType? proxyType, String? bridgeLines}) async {
    service.invoke('reconfigure', {
      if (proxyType != null) 'proxyType': proxyType.name,
      if (bridgeLines != null) 'bridgeLines': bridgeLines,
    });
  }

  Future<void> requestSync() async {
    service.invoke("sync");
  }

  Future<void> sendHeartbeat() async {
    service.invoke("heartbeat");
  }

  Future<void> stop() async {
    service.invoke("stop");
  }

  Future<void> initializeService() async {
    await service.configure(
      iosConfiguration: IosConfiguration(autoStart: false),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
        initialNotificationTitle: 'Tor Service',
        initialNotificationContent: 'Running in background',
      ),
    );

    service.on('portUpdate').listen((data) {
      final port = data!['port'] as int;
      _portSubject.add((port > -1) ? port : null);
    });
  }

  Future<void> dispose() async {
    await stop();
    await _portSubject.close();
  }
}

@Riverpod(keepAlive: true)
class TorProxyService extends _$TorProxyService {
  final _tor = _TorService();

  Timer? _heartbeatUpdate;
  //This is managed by widget state changes to resume a timer
  bool _timerPaused = false;

  void _enableHeartbeatTimer() {
    _heartbeatUpdate?.cancel();
    _timerPaused = false;
    _heartbeatUpdate = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      await _tor.sendHeartbeat();
    });
  }

  Future<void> startOrReconfigure({bool forceReconnect = false}) async {
    final currentPort = await requestSync();

    if (currentPort == null || forceReconnect) {
      state = const AsyncLoading();

      final torSettings = await ref
          .read(torSettingsRepositoryProvider.notifier)
          .fetchSettings();

      Setting? setting;
      if (torSettings.config == TorConnectionConfig.auto) {
        List<Setting>? config;

        final moat = MoatService();
        try {
          await moat.initialize();
          config = await moat.autoConf(
            cannotConnectWithoutPt: torSettings.requireBridge,
          );

          if (config == null && torSettings.requireBridge) {
            config = MoatService.convertBuiltinToSettings(
              await ref
                  .read(builtinBridgesRepositoryProvider(moat).notifier)
                  .getBridges(),
            );
          }
        } catch (e, s) {
          logger.e('Failed auto configure bridges', error: e, stackTrace: s);
        } finally {
          await moat.dispose();
        }

        setting = config.mapNotNull(
          (config) =>
              config.firstWhereOrNull(
                (setting) => setting.bridge.type == TransportType.obfs4,
              ) ??
              config.firstWhereOrNull(
                (setting) => setting.bridge.type == TransportType.snowflake,
              ),
        );
      } else if (torSettings.config != TorConnectionConfig.direct) {
        List<Setting>? config;

        final moat = MoatService();
        try {
          await moat.initialize();
          if (torSettings.fetchRemoteBridges) {
            config = await moat.getDefaultBridges();
          }

          if (config == null && torSettings.requireBridge) {
            config = MoatService.convertBuiltinToSettings(
              await ref
                  .read(builtinBridgesRepositoryProvider(moat).notifier)
                  .getBridges(tryUpdate: torSettings.fetchRemoteBridges),
            );
          }

          setting = config.mapNotNull(
            (config) => config.firstWhereOrNull(
              (setting) =>
                  setting.bridge.type ==
                  switch (torSettings.config) {
                    TorConnectionConfig.auto => throw UnimplementedError(),
                    TorConnectionConfig.direct => throw UnimplementedError(),
                    TorConnectionConfig.obfs4 => TransportType.obfs4,
                    TorConnectionConfig.snowflake => TransportType.snowflake,
                  },
            ),
          );
        } catch (e, s) {
          logger.e('Failed auto configure bridges', error: e, stackTrace: s);
        } finally {
          await moat.dispose();
        }
      }

      if (setting != null) {
        switch (setting.bridge.type) {
          case TransportType.obfs4:
            await _tor.startOrReconfigure(
              proxyType: ProxyType.obfs4,
              bridgeLines: setting.bridge.bridges?.join('\n'),
            );
          case TransportType.snowflake:
            await _tor.startOrReconfigure(
              proxyType: ProxyType.snowflake,
              bridgeLines: setting.bridge.bridges?.join('\n'),
            );
          case TransportType.meek:
          case TransportType.meekAzure:
          case TransportType.webtunnel:
            throw UnimplementedError();
        }
      } else {
        await _tor.startOrReconfigure();
      }

      _enableHeartbeatTimer();
    }
  }

  Future<int?> requestSync() async {
    final nextPortUpdate = _tor.portStream.first;

    await _tor.requestSync();
    return nextPortUpdate;
  }

  Future<void> disconnect() async {
    state = const AsyncLoading();

    _heartbeatUpdate?.cancel();
    _heartbeatUpdate = null;
    _timerPaused = false;

    await _tor.stop();
  }

  @override
  Future<int?> build() async {
    final portSub = _tor.portStream.distinct().listen((port) {
      state = AsyncData(port);
    });

    await _tor.initializeService();

    ref.listen(
      fireImmediately: true,
      browserViewLifecycleProvider,
      (previous, next) {
        switch (next) {
          case AppLifecycleState.resumed:
            if (_timerPaused) {
              _enableHeartbeatTimer();
            }
          case AppLifecycleState.detached:
          case AppLifecycleState.inactive:
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
          case null:
            if (_heartbeatUpdate?.isActive == true) {
              _heartbeatUpdate?.cancel();
              _timerPaused = true;
            }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to browserViewLifecycleProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      _heartbeatUpdate?.cancel();
      _heartbeatUpdate = null;
      _timerPaused = false;

      await portSub.cancel();
      await _tor.dispose();
    });

    return _tor.portStream.valueOrNull;
  }
}
