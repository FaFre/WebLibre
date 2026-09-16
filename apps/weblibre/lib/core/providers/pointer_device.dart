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
import 'package:flutter/gestures.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pointer_device.g.dart';

/// Whether the cursor is the input the user is currently driving the app with.
///
/// Set by any mouse or trackpad event, cleared by a touch or stylus press.
///
/// Deliberately not "is a mouse connected right now". Android reports the
/// cursor leaving the window as its pointer being removed, so connection flips
/// each time the cursor crosses the window edge, and a layout keyed on it would
/// jump with it. A press is a deliberate change of input and happens far less
/// often.
///
/// It has to clear at all because cursor-only affordances hang off it. The
/// auto-hiding side rail is revealed only by the cursor reaching the window
/// edge, so were this sticky for the process, a disconnected mouse or leaving
/// DeX would put the rail out of touch's reach until the app restarted.
///
/// Observed through a global pointer route, which sees every event the
/// framework dispatches — including hovers over the web page, which the
/// native pointer router replays into Flutter.
@Riverpod(keepAlive: true)
class CursorInUse extends _$CursorInUse {
  @override
  bool build() {
    final router = GestureBinding.instance.pointerRouter;

    void observe(PointerEvent event) {
      switch (event.kind) {
        case PointerDeviceKind.mouse || PointerDeviceKind.trackpad:
          if (!state) state = true;
        case PointerDeviceKind.touch ||
            PointerDeviceKind.stylus ||
            PointerDeviceKind.invertedStylus:
          if (state && event is PointerDownEvent) state = false;
        case PointerDeviceKind.unknown:
          break;
      }
    }

    router.addGlobalRoute(observe);
    ref.onDispose(() => router.removeGlobalRoute(observe));

    return false;
  }
}
