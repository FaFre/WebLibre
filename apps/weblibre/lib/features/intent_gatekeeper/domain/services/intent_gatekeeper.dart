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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/pending_intent_decision.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'intent_gatekeeper.g.dart';

const _ownPackageName = 'eu.weblibre.gecko';

@Riverpod(keepAlive: true)
class IntentGatekeeper extends _$IntentGatekeeper {
  late StreamController<PendingIntentDecision> _decisionRequests;
  final _pending = <int, Completer<bool>>{};
  int _nextId = 0;

  @override
  Stream<PendingIntentDecision> build() {
    _decisionRequests = StreamController<PendingIntentDecision>.broadcast();

    ref.onDispose(() async {
      for (final completer in _pending.values) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }

      _pending.clear();

      await _decisionRequests.close();
    });

    return _decisionRequests.stream;
  }

  /// Resolves whether an intent coming from [fromPackageName] targeting [url]
  /// should be allowed through. If the user has to decide, this waits for
  /// [resolve] to be called with the matching decision id.
  Future<bool> shouldAllow({
    required String? fromPackageName,
    required String? url,
  }) async {
    final settings = ref.read(generalSettingsWithDefaultsProvider);

    if (!settings.blockExternalAppsEnabled) {
      return true;
    }

    // Internal / unknown callers: no package to gate on — let through.
    if (fromPackageName == null || fromPackageName == _ownPackageName) {
      return true;
    }

    final existing = settings.externalAppIntentPolicies[fromPackageName];
    if (existing == IntentSourcePolicy.allow) {
      return true;
    }
    if (existing == IntentSourcePolicy.block) {
      return false;
    }

    final id = _nextId++;
    final completer = Completer<bool>();
    _pending[id] = completer;

    _decisionRequests.add(
      PendingIntentDecision(id: id, packageName: fromPackageName, url: url),
    );

    return completer.future;
  }

  Future<void> resolve({
    required int id,
    required IntentSourcePolicy decision,
    bool persist = false,
    String? packageName,
  }) async {
    final completer = _pending.remove(id);
    completer?.complete(decision == IntentSourcePolicy.allow);

    if (persist && packageName != null) {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (current) => current.copyWith.externalAppIntentPolicies({
              ...current.externalAppIntentPolicies,
              packageName: decision,
            }),
          );
    }
  }
}
