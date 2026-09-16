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
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/design/window_size_class.dart';

part 'window_size_class.g.dart';

/// The current window's [WindowSizeClass].
///
/// This is a provider rather than an `InheritedWidget` because both halves of
/// the app need it and only one of them has a `BuildContext`: the settings
/// resolvers are read from widgets (`browser.dart`) *and* from plain providers
/// that take only a `Ref` — `quickTabSwitcherRowCount` is the blocking
/// example. One mechanism keeps those two from drifting apart.
///
/// It observes the platform view directly instead of being fed from the widget
/// tree. That is not just convenience:
///
///  * Writing a provider from a widget's build (including from `useEffect`,
///    which still runs inside the build phase) trips Riverpod's
///    modify-during-build guard. Deferring the write to a post-frame callback
///    would work but would paint one frame of the wrong layout on every
///    change.
///  * The window size is a platform-global fact, not a property of any
///    subtree. The app's only `MediaQuery` override
///    (`applyAppMediaQueryOverrides`) touches `textScaler` and
///    `disableAnimations` and never `size`, so reading the view is equivalent
///    to reading `MediaQuery` and is honest about what it means.
///
/// The state is the discrete enum pair, never a size, so it notifies only when
/// a breakpoint is actually crossed. Dragging a freeform window from 400dp to
/// 1600dp produces two notifications, not one per frame — which is what keeps
/// the browser shell from re-laying out the GeckoView platform view mid-drag.
@Riverpod(keepAlive: true)
class WindowSizeClassController extends _$WindowSizeClassController {
  @override
  WindowSizeClass build() {
    final binding = WidgetsBinding.instance;
    final observer = _WindowMetricsObserver(_readFromPlatformView);

    binding.addObserver(observer);
    ref.onDispose(() => binding.removeObserver(observer));

    return _resolveFromPlatformView();
  }

  void _readFromPlatformView() {
    final next = _resolveFromPlatformView();
    if (next != state) {
      state = next;
    }
  }

  /// Classifies the implicit view's current logical size.
  ///
  /// Goes through the binding's dispatcher rather than
  /// [PlatformDispatcher.instance]: the latter is the real singleton and
  /// ignores the view overrides a widget test installs, so a test could never
  /// drive this.
  ///
  /// Falls back to [WindowSizeClass.compact] — today's phone behaviour —
  /// whenever the view cannot be measured, so a missing or degenerate view can
  /// never produce a large-screen layout by accident.
  static WindowSizeClass _resolveFromPlatformView() {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return WindowSizeClass.compact;

    final ratio = view.devicePixelRatio;
    if (ratio <= 0) return WindowSizeClass.compact;

    final physical = view.physicalSize;
    if (physical.isEmpty) return WindowSizeClass.compact;

    return WindowSizeClass.fromSize(physical / ratio);
  }
}

/// Bridges [WidgetsBindingObserver.didChangeMetrics] to a plain callback.
///
/// A Riverpod notifier cannot itself be the observer — the generated base
/// class already fixes its supertype — so the observer is a separate object
/// owned by the notifier and removed in `onDispose`.
class _WindowMetricsObserver extends WidgetsBindingObserver {
  final VoidCallback onChanged;

  _WindowMetricsObserver(this.onChanged);

  @override
  void didChangeMetrics() => onChanged();
}
