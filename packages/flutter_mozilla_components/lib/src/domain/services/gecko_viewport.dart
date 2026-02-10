/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

/// Keyboard visibility event data
typedef KeyboardEvent = ({int heightPx, bool isVisible, bool isAnimating});

/// Service for controlling GeckoView's viewport behavior.
///
/// This service provides:
/// - Dynamic toolbar height management (setDynamicToolbarMaxHeight)
/// - Vertical clipping control (setVerticalClipping)
/// - Keyboard visibility events from native
///
/// Use this service to implement Firefox-style dynamic toolbars that adjust
/// the GeckoView viewport without resizing the Flutter platform view.
class GeckoViewportService extends GeckoViewportEvents {
  final GeckoViewportApi _api;

  // Stream controllers for events from native
  final _keyboardSubject = BehaviorSubject<KeyboardEvent>.seeded((
    heightPx: 0,
    isVisible: false,
    isAnimating: false,
  ));

  /// Stream of keyboard visibility changes.
  ///
  /// Emits events whenever the soft keyboard shows/hides.
  /// The [KeyboardEvent] includes:
  /// - [heightPx]: Keyboard height in pixels (0 when hidden)
  /// - [isVisible]: Whether keyboard is currently visible
  /// - [isAnimating]: Whether keyboard is currently animating
  ValueStream<KeyboardEvent> get keyboardEvents => _keyboardSubject.stream;

  /// Current keyboard height in pixels.
  int get currentKeyboardHeight => _keyboardSubject.value.heightPx;

  /// Whether the keyboard is currently visible.
  bool get isKeyboardVisible => _keyboardSubject.value.isVisible;

  /// Creates a new viewport service.
  ///
  /// Call [setUp] to register the event handlers after construction.
  GeckoViewportService({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _api = GeckoViewportApi(
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
    GeckoViewportEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  /// Sets the maximum height that dynamic toolbars can occupy.
  ///
  /// GeckoView will adjust its internal viewport calculations to account for
  /// this space. The website will receive proper viewport dimensions through
  /// standard web APIs (CSS viewport units, window.innerHeight).
  ///
  /// Call this once when toolbar dimensions are known, and again if they change.
  ///
  /// [heightPx] Combined height of top and bottom toolbars in pixels.
  Future<void> setDynamicToolbarMaxHeight(int heightPx) async {
    await _api.setDynamicToolbarMaxHeight(heightPx);
  }

  /// Sets the vertical clipping offset for GeckoView content.
  ///
  /// Use this as the toolbar animates to clip content at the bottom.
  /// Negative values clip from the bottom (for bottom toolbar sliding up).
  /// Positive values clip from the top (for top toolbar sliding down).
  ///
  /// Call this during toolbar animation frames to smoothly adjust the visible area.
  ///
  /// [clippingPx] The clipping offset in pixels. Negative = bottom clip.
  Future<void> setVerticalClipping(int clippingPx) async {
    await _api.setVerticalClipping(clippingPx);
  }

  // GeckoViewportEvents implementation

  @override
  void onKeyboardVisibilityChanged(
    int sequence,
    int heightPx,
    bool isVisible,
    bool isAnimating,
  ) {
    _keyboardSubject.addWhenMoreRecent(sequence, null, (
      heightPx: heightPx,
      isVisible: isVisible,
      isAnimating: isAnimating,
    ));
  }

  /// Disposes the service and closes all streams.
  Future<void> dispose() async {
    await _keyboardSubject.close();
  }
}
