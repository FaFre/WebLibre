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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A hook that manages visibility state based on scroll direction.
///
/// Returns a [ValueNotifier<bool>] that automatically updates based on scroll behavior:
/// - Hides when scrolled down beyond [hideThreshold]
/// - Shows when scrolled up beyond [showThreshold] or at the top of the scroll view
/// - Measures both from where the scroll last turned, so a slow scroll counts
/// - Follows only the user's scrolling, not jumpTo/animateTo, and nothing at
///   all during [initializationDelay]
///
/// For a scroll view in a [DraggableScrollableSheet], pass the sheet's
/// [sheetController] as well. A drag first resizes the sheet and only scrolls
/// the view once the sheet is at its full size, so the sheet growing counts as
/// scrolling down and shrinking as scrolling up, by more than
/// [sheetThreshold] (a fraction of the sheet's maximum height).
///
/// Example:
/// ```dart
/// final scrollController = useScrollController();
/// final isVisible = useScrollVisibility(scrollController);
///
/// return AnimatedOpacity(
///   opacity: isVisible.value ? 1.0 : 0.0,
///   child: FloatingActionButton(...),
/// );
/// ```
ValueNotifier<bool> useScrollVisibility(
  ScrollController scrollController, {
  DraggableScrollableController? sheetController,
  double hideThreshold = 5.0,
  double showThreshold = 5.0,
  double sheetThreshold = 0.02,
  Duration initializationDelay = const Duration(milliseconds: 1000),
  bool disableAnimations = false,
}) {
  final isVisible = useState(true);
  // What each signal is measured against: the furthest up the view has been
  // scrolled and the smallest the sheet has been since the widget showed, and
  // the reverse since it hid. A slow scroll or drag, under the threshold from
  // one frame to the next, adds up from there.
  final scrollAnchor = useRef(0.0);
  final sheetAnchor = useRef<double?>(null);
  final isInitialized = useRef(false);

  useEffect(
    () {
      // Both signals start over from where they are whenever either one
      // changes the visibility.
      void rebase() {
        if (scrollController.hasClients) {
          scrollAnchor.value = scrollController.offset;
        }
        if (sheetController?.isAttached ?? false) {
          sheetAnchor.value = sheetController!.size;
        }
      }

      void setVisible(bool visible) {
        isVisible.value = visible;
        rebase();
      }

      // Start timer to enable the listeners after initialization delay
      final timer = Timer(
        disableAnimations ? Duration.zero : initializationDelay,
        () {
          rebase();
          isInitialized.value = true;
        },
      );

      void scrollListener() {
        // Ignore scroll events until initialization is complete
        if (!isInitialized.value) return;

        final offset = scrollController.offset;
        // The view moved by the app (jumpTo, animateTo), such as re-centring
        // the active item, isn't the user scrolling: only measure from there.
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.idle) {
          scrollAnchor.value = offset;
          return;
        }

        if (isVisible.value) {
          // Hide when scrolled down beyond threshold
          if (offset - scrollAnchor.value > hideThreshold) {
            setVisible(false);
          } else {
            scrollAnchor.value = math.min(scrollAnchor.value, offset);
          }
        }
        // Show when scrolled up beyond threshold or at top
        else if (scrollAnchor.value - offset > showThreshold || offset <= 0) {
          setVisible(true);
        } else {
          scrollAnchor.value = math.max(scrollAnchor.value, offset);
        }
      }

      void sheetListener() {
        final controller = sheetController!;
        if (!isInitialized.value || !controller.isAttached) return;

        final size = controller.size;
        final anchor = sheetAnchor.value ?? size;

        // The sheet growing is scrolling down, shrinking is scrolling up.
        if (isVisible.value) {
          if (size - anchor > sheetThreshold) {
            setVisible(false);
          } else {
            sheetAnchor.value = math.min(anchor, size);
          }
        } else if (anchor - size > sheetThreshold) {
          setVisible(true);
        } else {
          sheetAnchor.value = math.max(anchor, size);
        }
      }

      scrollController.addListener(scrollListener);
      sheetController?.addListener(sheetListener);
      return () {
        timer.cancel();
        scrollController.removeListener(scrollListener);
        sheetController?.removeListener(sheetListener);
      };
    },
    [
      scrollController,
      sheetController,
      hideThreshold,
      showThreshold,
      sheetThreshold,
      initializationDelay,
      disableAnimations,
    ],
  );

  return isVisible;
}
