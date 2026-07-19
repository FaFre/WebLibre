/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

/// Service for UnifiedPush-backed web push.
///
/// Web push is delivered by a separate distributor app (ntfy, Sunup, …) that the
/// user selects. With no distributor selected nothing can be delivered, so the
/// distributor selection doubles as the on/off switch for web push.
///
/// Subscriptions are exposed read-only: Gecko owns the subscription state and
/// offers no app-facing channel to revoke one, so removal must go through the
/// site's notification permission.
class GeckoPushService extends GeckoPushEvents {
  final GeckoPushApi _api;
  final BinaryMessenger? _defaultBinaryMessenger;
  final String _defaultMessageChannelSuffix;

  final _statusSubject = PublishSubject<PushStatus>();
  BinaryMessenger? _eventBinaryMessenger;
  String _eventMessageChannelSuffix = '';
  int? _lastStatusSequence;
  bool _isSetUp = false;
  bool _disposed = false;
  Future<void>? _disposeFuture;

  /// Stream of status snapshots pushed from native, emitted when a distributor
  /// acknowledges registration, fails to register, or is uninstalled.
  ///
  /// Non-replaying: callers that need the current value must subscribe to this
  /// before calling [getPushStatus], or they will miss any transition that lands
  /// between the two.
  Stream<PushStatus> get statusChanges => _statusSubject.stream;

  GeckoPushService({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _defaultBinaryMessenger = binaryMessenger,
       _defaultMessageChannelSuffix = messageChannelSuffix,
       _api = GeckoPushApi(
         binaryMessenger: binaryMessenger,
         messageChannelSuffix: messageChannelSuffix,
       );

  /// Sets up the service to receive events from native.
  ///
  /// Must be called before events will be received.
  void setUp({BinaryMessenger? binaryMessenger, String? messageChannelSuffix}) {
    if (_isSetUp || _disposed) {
      return;
    }

    _eventBinaryMessenger = binaryMessenger ?? _defaultBinaryMessenger;
    _eventMessageChannelSuffix =
        messageChannelSuffix ?? _defaultMessageChannelSuffix;
    GeckoPushEvents.setUp(
      this,
      binaryMessenger: _eventBinaryMessenger,
      messageChannelSuffix: _eventMessageChannelSuffix,
    );
    _isSetUp = true;
  }

  Future<PushStatus> getPushStatus() => _api.getPushStatus();

  /// Selects [packageName], which must be one of [PushStatus.available].
  Future<void> setDistributor(String packageName) =>
      _api.setDistributor(packageName);

  /// Forgets the current distributor, disabling web push delivery.
  Future<void> removeDistributor() => _api.removeDistributor();

  Future<void> renewRegistration() => _api.renewRegistration();

  Future<void> suspendForProfileSwitch(String targetProfileId) =>
      _api.suspendForProfileSwitch(targetProfileId);

  Future<List<PushSubscription>> getSubscriptions() => _api.getSubscriptions();

  // GeckoPushEvents implementation

  @override
  void onPushStatusChanged(int sequence, PushStatus status) {
    if (_disposed ||
        (_lastStatusSequence != null && sequence <= _lastStatusSequence!)) {
      return;
    }

    _lastStatusSequence = sequence;
    _statusSubject.add(status);
  }

  Future<void> dispose() {
    return _disposeFuture ??= _dispose();
  }

  Future<void> _dispose() async {
    _disposed = true;
    if (_isSetUp) {
      GeckoPushEvents.setUp(
        null,
        binaryMessenger: _eventBinaryMessenger,
        messageChannelSuffix: _eventMessageChannelSuffix,
      );
      _isSetUp = false;
    }
    await _statusSubject.close();
  }
}
