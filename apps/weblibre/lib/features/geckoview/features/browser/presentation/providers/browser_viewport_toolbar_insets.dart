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
import 'dart:math' as math;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'browser_viewport_toolbar_insets.g.dart';

@CopyWith()
class BrowserViewportToolbarInsetsState with FastEquatable {
  final int dynamicToolbarMaxHeightPx;
  final int verticalClippingPx;

  BrowserViewportToolbarInsetsState({
    this.dynamicToolbarMaxHeightPx = 0,
    this.verticalClippingPx = 0,
  });

  static final zero = BrowserViewportToolbarInsetsState();

  int get effectiveBottomInsetPx =>
      math.max(0, dynamicToolbarMaxHeightPx + verticalClippingPx);

  @override
  List<Object?> get hashParameters => [
    dynamicToolbarMaxHeightPx,
    verticalClippingPx,
  ];
}

@Riverpod(keepAlive: true)
class BrowserViewportToolbarInsetsController
    extends _$BrowserViewportToolbarInsetsController {
  @override
  BrowserViewportToolbarInsetsState build() {
    return BrowserViewportToolbarInsetsState.zero;
  }

  void setDynamicToolbarMaxHeight(int heightPx) {
    if (state.dynamicToolbarMaxHeightPx == heightPx) {
      return;
    }

    state = state.copyWith(dynamicToolbarMaxHeightPx: heightPx);
  }

  void setVerticalClipping(int clippingPx) {
    if (state.verticalClippingPx == clippingPx) {
      return;
    }

    state = state.copyWith(verticalClippingPx: clippingPx);
  }

  void reset() {
    if (state == BrowserViewportToolbarInsetsState.zero) {
      return;
    }

    state = BrowserViewportToolbarInsetsState.zero;
  }
}
