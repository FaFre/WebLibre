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
import 'package:flutter_tor/flutter_tor.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/tor/data/models/moat.dart';
import 'package:weblibre/features/tor/data/services/moat_service.dart';
import 'package:weblibre/features/tor/domain/repositories/builtin_bridges.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'tor_proxy.g.dart';

@Riverpod(keepAlive: true)
class TorProxyService extends _$TorProxyService {
  final _tor = FlutterTor();
  late StreamController<TorStatus> _statusSyncController;

  Future<TorStatus> startOrReconfigure({
    required bool reconfigureIfRunning,
  }) async {
    final currentStatus = await _tor.getStatus();

    if (!currentStatus.isRunning ||
        currentStatus.socksPort == null ||
        reconfigureIfRunning) {
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
              // ignore: only_use_keep_alive_inside_keep_alive
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
                (setting) => setting.bridge.type == MoatTransportType.obfs4,
              ) ??
              config.firstWhereOrNull(
                (setting) => setting.bridge.type == MoatTransportType.snowflake,
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

          if (config == null &&
              (torSettings.requireBridge || !torSettings.fetchRemoteBridges)) {
            config = MoatService.convertBuiltinToSettings(
              // ignore: only_use_keep_alive_inside_keep_alive
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
                    TorConnectionConfig.auto => throw UnimplementedError(
                      'TorConnectionConfig.auto bridge type not supported',
                    ),
                    TorConnectionConfig.direct => throw UnimplementedError(
                      'TorConnectionConfig.direct does not use bridges',
                    ),
                    TorConnectionConfig.obfs4 => MoatTransportType.obfs4,
                    TorConnectionConfig.snowflake =>
                      MoatTransportType.snowflake,
                  },
            ),
          );
        } catch (e, s) {
          logger.e('Failed auto configure bridges', error: e, stackTrace: s);
        } finally {
          await moat.dispose();
        }
      }

      final config = TorConfiguration(
        transport: switch (setting?.bridge.type) {
          MoatTransportType.obfs4 => TransportType.obfs4,
          MoatTransportType.snowflake => TransportType.snowflake,
          MoatTransportType.meek => TransportType.meek,
          MoatTransportType.meekAzure => TransportType.meekAzure,
          MoatTransportType.webtunnel => TransportType.webtunnel,
          null => TransportType.none,
        },
        bridgeLines: setting?.bridge.bridges ?? [],
        entryNodeCountries: torSettings.entryNodeCountry?.toLowerCase(),
        exitNodeCountries: torSettings.exitNodeCountry?.toLowerCase(),
      );

      await _tor.start(config);
      return _tor.getStatus();
    }

    return currentStatus;
  }

  Future<TorStatus> requestSync() async {
    final status = await _tor.getStatus();
    _statusSyncController.add(status);
    return status;
  }

  Future<void> disconnect() async {
    await _tor.stop();
  }

  Future<void> requestNewIdentity() async {
    await _tor.requestNewIdentity();
  }

  @override
  Stream<TorStatus> build() {
    _statusSyncController = StreamController();

    ref.onDispose(() async {
      await _statusSyncController.close();
      await _tor.stop();
    });

    return MergeStream([_tor.statusStream, _statusSyncController.stream]);
  }
}
