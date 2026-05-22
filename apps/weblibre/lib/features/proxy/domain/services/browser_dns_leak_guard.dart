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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

part 'browser_dns_leak_guard.g.dart';

/// Watches the proxy runtime and **disables** GeckoView's TRR (sets
/// [DohSettingsMode.off]) while at least one profile is running.
///
/// Why "off" and not "max": TRR resolves URL hostnames over DoH directly via
/// the system network, *before* any SOCKS connection is established — so a
/// DoH lookup leaks the destination outside the proxy even when the data
/// itself goes through it. `max` (TRR-only) keeps that leak. `off` disables
/// TRR so GeckoView uses its native resolver, which — combined with
/// `proxyDNS: true` on our SOCKS proxy settings — sends hostnames through the
/// SOCKS inbound so sing-box can resolve them instead of GeckoView doing a
/// direct DoH lookup first.
///
/// The previous TRR mode is captured on engage and restored when all
/// profiles stop.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.
@Riverpod(keepAlive: true)
class BrowserDnsLeakGuard extends _$BrowserDnsLeakGuard {
  DohSettingsMode? _savedMode;

  @override
  Future<void> build() async {
    final runtime = ref.watch(singboxProxyRuntimeRepositoryProvider);

    // Skip while a start/stop is in flight. `startProfiles` resets the runtime
    // state to `AsyncLoading` for the entire restart — `asData` is briefly
    // null, which would otherwise look like "no profiles running" and trigger
    // a premature DoH restore in the middle of e.g. starting a second profile
    // while one is already active, opening a leak window during the transition.
    if (runtime.isLoading) return;

    final anyRunning = runtime.asData?.value.endpoints.isNotEmpty ?? false;
    if (anyRunning) {
      await _enforceOffMode();
    } else if (_savedMode != null) {
      await _restoreSavedMode();
    }
  }

  Future<void> _enforceOffMode() async {
    final engine = ref.read(engineSettingsRepositoryProvider.notifier);
    try {
      final current = await engine.fetchSettings();
      if (current.dohSettingsMode == DohSettingsMode.off) {
        // Already off — don't capture it as the "saved" value, otherwise we
        // would restore it back to off on disengage instead of the user's
        // real previous choice.
        return;
      }
      _savedMode = current.dohSettingsMode;
      await engine.updateSettings(
        (current) => current.copyWith.dohSettingsMode(DohSettingsMode.off),
      );
    } catch (error, stack) {
      logger.e(
        'browser DNS leak guard failed to disable TRR',
        error: error,
        stackTrace: stack,
      );
    }
  }

  Future<void> _restoreSavedMode() async {
    final saved = _savedMode;
    _savedMode = null;
    if (saved == null) return;
    try {
      await ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings((current) => current.copyWith.dohSettingsMode(saved));
    } catch (error, stack) {
      logger.e(
        'browser DNS leak guard failed to restore DoH mode',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
