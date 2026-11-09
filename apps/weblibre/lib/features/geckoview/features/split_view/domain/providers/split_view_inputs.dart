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
import 'dart:ui';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

part 'split_view_inputs.g.dart';

/// The size of the platform view the pages are drawn in, in dp: after bars,
/// side rail, safe areas and the keyboard inset. Reported by the browser view
/// from a `LayoutBuilder` right around the engine view.
@Riverpod(keepAlive: true)
class BrowserContentGeometry extends _$BrowserContentGeometry {
  /// Changes smaller than this are layout noise, not a new size.
  static const _threshold = 0.5;

  @override
  Size? build() => null;

  void report(Size size) {
    final current = state;
    if (current != null &&
        (current.width - size.width).abs() < _threshold &&
        (current.height - size.height).abs() < _threshold) {
      return;
    }
    state = size;
  }
}

/// The separating hinge or half-open fold crossing the browser content, in
/// content-local dp, or null (see `separatingHingeInContent`). Reported by the
/// browser view with [BrowserContentGeometry].
@Riverpod(keepAlive: true)
class BrowserContentHinge extends _$BrowserContentHinge {
  @override
  Rect? build() => null;

  void report(Rect? hinge) {
    if (state != hinge) state = hinge;
  }
}

/// Whether the soft keyboard is up (settled, not animating).
@Riverpod(keepAlive: true)
Stream<bool> splitKeyboardVisible(Ref ref) {
  final viewport = ref.watch(viewportServiceProvider);
  return viewport.keyboardEvents
      .where((event) => !event.isAnimating)
      .map((event) => event.isVisible)
      .distinct();
}

/// Theme colors and localized labels the native split chrome is drawn with.
/// Reported by a widget, since they come from the theme and the app language.
class SplitViewChrome with FastEquatable {
  final Color divider;
  final Color grip;
  final Color dragPreview;
  final Color placeholder;
  final Color onPlaceholder;

  /// Focus outline of a tab without a container color.
  final Color regularAccent;
  final Color privateAccent;
  final Color isolatedAccent;

  final String dividerDescription;
  final String dividerOptionsAction;
  final String crashedTitle;
  final String crashedReload;

  SplitViewChrome({
    required this.divider,
    required this.grip,
    required this.dragPreview,
    required this.placeholder,
    required this.onPlaceholder,
    required this.regularAccent,
    required this.privateAccent,
    required this.isolatedAccent,
    required this.dividerDescription,
    required this.dividerOptionsAction,
    required this.crashedTitle,
    required this.crashedReload,
  });

  @override
  List<Object?> get hashParameters => [
    divider,
    grip,
    dragPreview,
    placeholder,
    onPlaceholder,
    regularAccent,
    privateAccent,
    isolatedAccent,
    dividerDescription,
    dividerOptionsAction,
    crashedTitle,
    crashedReload,
  ];
}

@Riverpod(keepAlive: true)
class SplitViewChromeController extends _$SplitViewChromeController {
  @override
  SplitViewChrome? build() => null;

  void report(SplitViewChrome chrome) {
    if (state != chrome) state = chrome;
  }
}

/// What a tab's focus outline is colored by: its container's color, else its
/// mode.
sealed class SplitTabIdentity with FastEquatable {
  SplitTabIdentity();
}

final class ContainerSplitTabIdentity extends SplitTabIdentity {
  final Color color;

  ContainerSplitTabIdentity(this.color);

  @override
  List<Object?> get hashParameters => [color];
}

final class ModeSplitTabIdentity extends SplitTabIdentity {
  final TabMode? mode;

  ModeSplitTabIdentity(this.mode);

  @override
  List<Object?> get hashParameters => [mode];
}

@Riverpod()
SplitTabIdentity splitTabIdentity(Ref ref, String tabId) {
  final container = ref.watch(
    watchTabContainerDataProvider(tabId).select((value) => value.value),
  );
  final mode = ref.watch(tabStatesProvider.select((s) => s[tabId]?.tabMode));
  if (container != null && mode is! IsolatedTabMode) {
    return ContainerSplitTabIdentity(container.color);
  }
  return ModeSplitTabIdentity(mode);
}

extension SplitTabIdentityAccent on SplitTabIdentity {
  Color accent(SplitViewChrome chrome) => switch (this) {
    ContainerSplitTabIdentity(:final color) => color,
    ModeSplitTabIdentity(:final mode) => switch (mode) {
      PrivateTabMode() => chrome.privateAccent,
      IsolatedTabMode() => chrome.isolatedAccent,
      _ => chrome.regularAccent,
    },
  };
}
