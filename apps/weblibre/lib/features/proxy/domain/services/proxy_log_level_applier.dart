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
import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

part 'proxy_log_level_applier.g.dart';

/// Restarts the sing-box runtime when the diagnostic log level changes.
///
/// sing-box takes `log.level` from the config document it is started with, so
/// there is nothing to toggle on a live runtime — the level a user picks while
/// a proxy is up would otherwise apply only after they stopped and started it
/// by hand, which is exactly the moment they are least likely to think of.
///
/// Only a *change* restarts. The first value this sees is whatever was already
/// persisted, and the runtime — if it is even up yet — was started from that
/// same value, so acting on it would be a restart that changes nothing.
@Riverpod(keepAlive: true)
class ProxyLogLevelApplier extends _$ProxyLogLevelApplier {
  /// The level the running runtime was last started with, or null when that is
  /// not known — before the first value arrives, and after a restart that
  /// failed. Null is what lets the *same* level be picked again and retried.
  ProxyLogLevel? _applied;

  /// Whether the first value has been seen. Kept apart from [_applied] so a
  /// failed restart can forget what is applied without being mistaken for the
  /// startup seed, which deliberately restarts nothing.
  bool _seeded = false;

  @override
  void build() {
    ref.listen(
      proxyDiagnosticsSettingsRepositoryProvider.select(
        (value) => value.value?.logLevel,
      ),
      (previous, next) {
        if (next == null) return;

        if (!_seeded) {
          // The value already in force when this started: the runtime, if it is
          // even up, was started from it.
          _seeded = true;
          _applied = next;
          return;
        }
        if (_applied == next) return;

        _applied = next;
        unawaited(_reload(next));
      },
      fireImmediately: true,
    );
  }

  Future<void> _reload(ProxyLogLevel level) async {
    try {
      await ref
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .reloadActiveProfiles();
    } catch (error, stackTrace) {
      // The runtime kept the level it had, so what is applied is no longer
      // known — unless the setting has moved on since, in which case that
      // change has a restart of its own in flight and owns the field.
      if (_applied == level) {
        _applied = null;
      }

      // The setting is stored either way; a failed restart only means the
      // running runtime keeps the old level until it is next started.
      logger.e(
        'Failed to restart the proxy runtime for log level ${level.name}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
