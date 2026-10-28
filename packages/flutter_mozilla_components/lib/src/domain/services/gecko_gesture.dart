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

  final _textSelectionActiveSubject = BehaviorSubject<bool>.seeded(false);

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

  /// Whether native text selection is currently on screen.
  ///
  /// Selection handles are drawn by the compositor rather than as Android
  /// views, so dragging one produces a plain touch stream that pointer-delta
  /// consumers (the toolbar auto-hide accumulator) would read as a swipe. Latch
  /// this on pointer-down and ignore the stream while it is set, rather than
  /// sampling it mid-drag: the engine tears the selection toolbar down for the
  /// duration of a handle drag, so it reads false exactly while one is in
  /// progress. See https://github.com/FaFre/WebLibre/issues/578.
  ValueStream<bool> get textSelectionActive =>
      _textSelectionActiveSubject.stream;

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
  Future<void> onGestureRecognized(int sequence, String gestureKey) async {
    _recognizedGestureSubject.addWhenMoreRecent(sequence, null, gestureKey);
  }

  @override
  Future<void> onGestureProgress(int sequence, String partialKey) async {
    _gestureProgressSubject.addWhenMoreRecent(sequence, null, partialKey);
  }

  @override
  Future<void> onGestureReset(int sequence) async {
    _gestureProgressSubject.addWhenMoreRecent(sequence, null, null);
  }

  @override
  Future<void> onTextSelectionActiveChange(int sequence, bool active) async {
    _textSelectionActiveSubject.addWhenMoreRecent(sequence, null, active);
  }

  /// Disposes the service and closes all streams.
  Future<void> dispose() async {
    await _recognizedGestureSubject.close();
    await _gestureProgressSubject.close();
    await _textSelectionActiveSubject.close();
  }
}
