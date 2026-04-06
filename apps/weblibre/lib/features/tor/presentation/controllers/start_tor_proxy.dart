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
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/widgets/tor_notification.dart';

part 'start_tor_proxy.g.dart';

@Riverpod(keepAlive: true)
class StartProxyController extends _$StartProxyController {
  Future<bool> shouldPromptProxyStart() async {
    final currentStatus = await ref
        .read(torProxyServiceProvider.notifier)
        .requestSync();

    return !currentStatus.isRunning;
  }

  Future<void> startProxy() async {
    if (state) return;

    state = true;

    try {
      final connection = ref
          .read(torProxyServiceProvider.notifier)
          .startOrReconfigure(reconfigureIfRunning: false);

      ref
          .read(overlayControllerProvider.notifier)
          .show(
            (context) =>
                const Positioned(top: 0, left: 0, child: TorNotification()),
          );

      await connection;
    } finally {
      state = false;
    }
  }

  @override
  bool build() {
    return false;
  }
}
