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

import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'native_gatekeeper_replicator.g.dart';

/// Mirrors the Flutter-side block list to the native side so the
/// `IntentReceiverActivity` can reject intents without launching Flutter.
/// Only blocked packages are replicated — allow/unknown still fall through to
/// the Flutter gatekeeper dialog.
///
/// Also consumes any "always allow" decisions made via notification actions
/// and merges them into Flutter's policy before the next gatekeeper check.
@Riverpod(keepAlive: true)
class NativeIntentGatekeeperReplicator
    extends _$NativeIntentGatekeeperReplicator {
  final _api = IntentGatekeeperHostApi();
  Future<void>? _pendingAllowSync;

  Future<void> _push(
    ({bool enabled, Map<String, IntentSourcePolicy> policies}) config,
  ) async {
    final blocked = config.policies.entries
        .where((entry) => entry.value == IntentSourcePolicy.block)
        .map((entry) => entry.key)
        .toList();

    try {
      await _api.setConfig(config.enabled, blocked);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to replicate intent gatekeeper config to native',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reads any packages the user approved via notification and persists them
  /// as `allow` policies in the Flutter settings.
  Future<void> _syncPendingAllowsInternal() async {
    try {
      final pending = await _api.getPendingAlwaysAllows();
      if (pending.isEmpty) return;

      await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings(
            (current) => current.copyWith.externalAppIntentPolicies({
              ...current.externalAppIntentPolicies,
              for (final pkg in pending) pkg: IntentSourcePolicy.allow,
            }),
          );
      await _api.ackPendingAlwaysAllows(pending);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to consume pending always-allows from native',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deduplicates native pending-allow synchronization across concurrent
  /// callers so startup intent handling and config replication observe the same
  /// persisted policy state.
  Future<void> syncPendingAllows() {
    final inFlight = _pendingAllowSync;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _syncPendingAllowsInternal();
    _pendingAllowSync = future.whenComplete(() {
      if (identical(_pendingAllowSync, future)) {
        _pendingAllowSync = null;
      }
    });
    return _pendingAllowSync!;
  }

  @override
  void build() {
    unawaited(syncPendingAllows());

    ref.listen(
      generalSettingsWithDefaultsProvider.select(
        (settings) => EquatableValue((
          enabled: settings.blockExternalAppsEnabled,
          policies: settings.externalAppIntentPolicies,
        )),
      ),
      fireImmediately: true,
      (p, n) {
        final previous = p?.value;
        final next = n.value;

        if (previous != null &&
            previous.enabled == next.enabled &&
            const DeepCollectionEquality.unordered().equals(
              previous.policies,
              next.policies,
            )) {
          return;
        }
        unawaited(() async {
          await syncPendingAllows();
          final settings = await ref
              .read(generalSettingsRepositoryProvider.notifier)
              .fetchSettings();
          await _push((
            enabled: settings.blockExternalAppsEnabled,
            policies: settings.externalAppIntentPolicies,
          ));
        }());
      },
    );
  }
}
