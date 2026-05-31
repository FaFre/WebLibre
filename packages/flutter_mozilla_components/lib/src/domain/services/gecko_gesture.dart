/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

/// Service for native touch-gesture recognition.
///
/// Pushes the user's gesture configuration to the native recognizer via
/// [setGestureConfig] and exposes a stream of recognized gesture keys. The
/// native side is purely observational (it never consumes touch input for
/// gestures), so recognized events fire on touch release for multi-stroke
/// gestures only.
///
/// A gesture key is the canonical encoding shared with native: an optional
/// start-position prefix (`L:`/`R:`/`T:`/`B:`/`W:`/`E:`), an optional
/// finger-count prefix (`2:` …), and the dash-joined directions (`U`/`D`/`L`/
/// `R`), e.g. `R:2:D-L` or `D-R`.
class GeckoGestureService extends GeckoGestureEvents {
  final GeckoGestureApi _api;

  final _recognizedGestureSubject = PublishSubject<String>();

  final _gestureProgressSubject = BehaviorSubject<String?>.seeded(null);

  /// Stream of recognized gesture keys.
  ///
  /// Emits the canonical key (e.g. `D-R`) each time the native recognizer
  /// matches a configured gesture.
  Stream<String> get recognizedGestures => _recognizedGestureSubject.stream;

  /// Stream of the in-progress stroke for the live feedback overlay.
  ///
  /// Emits the current partial canonical key (e.g. `R:D`) each time a new
  /// arrow is drawn, and `null` when the stroke ends (release, cancel or idle
  /// timeout). Consumers render the overlay while non-null.
  Stream<String?> get gestureProgress => _gestureProgressSubject.stream;

  /// Creates a new gesture service.
  ///
  /// Call [setUp] to register the event handlers after construction.
  GeckoGestureService({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _api = GeckoGestureApi(
         binaryMessenger: binaryMessenger,
         messageChannelSuffix: messageChannelSuffix,
       );

  /// Sets up the service to receive events from native.
  ///
  /// Must be called before events will be received.
  void setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoGestureEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  /// Pushes the gesture-recognition configuration to native.
  ///
  /// Call whenever the user's gesture settings change.
  Future<void> setGestureConfig(GestureConfig config) async {
    await _api.setGestureConfig(config);
  }

  // GeckoGestureEvents implementation

  @override
  void onGestureRecognized(int sequence, String gestureKey) {
    _recognizedGestureSubject.addWhenMoreRecent(sequence, null, gestureKey);
  }

  @override
  void onGestureProgress(int sequence, String partialKey) {
    _gestureProgressSubject.addWhenMoreRecent(sequence, null, partialKey);
  }

  @override
  void onGestureReset(int sequence) {
    _gestureProgressSubject.addWhenMoreRecent(sequence, null, null);
  }

  /// Disposes the service and closes all streams.
  Future<void> dispose() async {
    await _recognizedGestureSubject.close();
    await _gestureProgressSubject.close();
  }
}
