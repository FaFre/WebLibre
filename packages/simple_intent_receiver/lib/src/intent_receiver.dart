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

import 'package:flutter/services.dart';
import 'package:simple_intent_receiver/src/pigeons/intent.g.dart';

class IntentReceiver extends IntentEvents {
  final _controller = StreamController<Intent>.broadcast();
  int? _lastAdded;

  /// Intent events, including the cold-start launch intent for each listener.
  ///
  /// New-intent callbacks still arrive through the broadcast controller below.
  /// The initial intent is replayed per listener so existing callers that only
  /// listen to [events] continue to receive terminated-app launches.
  Stream<Intent> get events {
    return Stream.multi((controller) {
      final subscription = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      unawaited(
        initialIntent.then(
          (intent) {
            if (intent != null && !controller.isClosed) {
              controller.add(intent);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        ),
      );

      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

  /// The launch intent recovered from the host, if any. Resolves to
  /// `Future<null>` for instances not constructed via [IntentReceiver.setUp]
  /// (e.g. test fakes / subclasses), so callers can always `await` without
  /// guarding for `LateInitializationError`.
  ///
  /// On cold start the Android plugin sees the launch intent from
  /// onAttachedToActivity before Dart has registered the Pigeon handler, so it
  /// caches the value for Dart to recover. The [events] stream already replays
  /// this value for compatibility; use this future directly only when the
  /// launch intent needs one-shot handling outside the event stream.
  ///
  /// Note on rotation: the Android plugin's `pendingInitialIntent` cache
  /// is intentionally overwritten on configuration change. If the user
  /// triggers a new deep link via the activity launcher before Dart
  /// drains the previous initial intent (rare — the future is read on
  /// IntentReceiver construction, which happens during app bootstrap),
  /// only the newest intent is delivered.
  Future<Intent?> initialIntent = Future.value(null);

  @override
  void onIntentReceived(int sequence, Intent intent) {
    if (_lastAdded == null || sequence > _lastAdded!) {
      _lastAdded = sequence;
      _controller.add(intent);
    }
  }

  IntentReceiver.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    IntentEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );

    final host = IntentHost(
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
    initialIntent = host.getInitialIntent();
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
