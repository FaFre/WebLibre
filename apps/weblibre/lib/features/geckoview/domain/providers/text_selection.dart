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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'text_selection.g.dart';

/// Whether native text selection is currently on screen, mirroring the engine's
/// selection action mode (the floating copy/paste toolbar).
///
/// Exists so the touch-driven chrome can tell a selection-handle drag apart from
/// a swipe. Handles are drawn by the compositor rather than as Android views, so
/// dragging one produces an ordinary pointer stream that the toolbar auto-hide
/// accumulator would otherwise read as a scroll and re-show the toolbar.
///
/// Read this at pointer-down and hold the decision for the rest of the stream.
/// Sampling it mid-drag does not work: the engine tears the selection toolbar
/// down while a handle is being dragged, so it reports false during exactly the
/// interaction it is meant to describe. The native side compensates with a short
/// grace window after the toolbar disappears and again after a selection drag
/// ends, covering a quick re-grab of a handle.
///
/// See https://github.com/FaFre/WebLibre/issues/578.
@Riverpod(keepAlive: true)
class TextSelectionActive extends _$TextSelectionActive {
  @override
  bool build() {
    final gestureService = ref.watch(gestureServiceProvider);

    final subscription = gestureService.textSelectionActive.listen(
      (active) {
        if (active != state) {
          state = active;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in text selection active events',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      await subscription.cancel();
    });

    return gestureService.textSelectionActive.valueOrNull ?? false;
  }
}
