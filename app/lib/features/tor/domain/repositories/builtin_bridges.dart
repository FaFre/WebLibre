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
import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/tor/data/services/builtin_bridges.dart';

part 'builtin_bridges.g.dart';

@Riverpod(keepAlive: true)
class BuiltinBridgesRepository extends _$BuiltinBridgesRepository {
  Future<void> updateIfNecessary() async {
    final lastUpdate = await ref
        .read(builtinBridgesServiceProvider.notifier)
        .lastUpdate();

    if (lastUpdate == null ||
        DateTime.now().difference(lastUpdate) > const Duration(days: 2)) {
      BuiltInBridges? remoteBridges;
      try {
        remoteBridges = await service.getBuiltinBridges();
      } catch (e, s) {
        logger.e('Failed fetching builtin bridges', error: e, stackTrace: s);
      }

      if (remoteBridges != null) {
        await ref
            .read(builtinBridgesServiceProvider.notifier)
            .updateStoredBuiltinBridges(remoteBridges);
      }
    }
  }

  Future<BuiltInBridges> getBridges({bool tryUpdate = true}) async {
    if (tryUpdate) {
      await updateIfNecessary();
    }

    final storedBridges = await ref
        .read(builtinBridgesServiceProvider.notifier)
        .getStoredBuiltinBridges();

    return storedBridges ??
        await ref
            .read(builtinBridgesServiceProvider.notifier)
            .getBundledBuiltinBridges();
  }

  @override
  void build(MoatService service) {}
}
