/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A hook that manages visibility state based on scroll direction.
///
/// Returns a [ValueNotifier<bool>] that automatically updates based on scroll behavior:
/// - Hides when scrolling down beyond [hideThreshold]
/// - Shows when scrolling up beyond [showThreshold] or at the top of the scroll view
/// - Ignores scroll events during [initializationDelay] to prevent hiding during jumpTo/animateTo
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
  double hideThreshold = 5.0,
  double showThreshold = 5.0,
  Duration initializationDelay = const Duration(milliseconds: 1000),
}) {
  final isVisible = useState(true);
  final lastScrollOffset = useRef(0.0);
  final isInitialized = useRef(false);

  useEffect(() {
    // Start timer to enable scroll listener after initialization delay
    final timer = Timer(initializationDelay, () {
      isInitialized.value = true;
    });

    void scrollListener() {
      // Ignore scroll events until initialization is complete
      if (!isInitialized.value) return;

      final currentOffset = scrollController.offset;
      final difference = currentOffset - lastScrollOffset.value;

      // Hide when scrolling down beyond threshold
      if (difference > hideThreshold && isVisible.value) {
        isVisible.value = false;
      }
      // Show when scrolling up beyond threshold or at top
      else if ((difference < -showThreshold || currentOffset <= 0) &&
          !isVisible.value) {
        isVisible.value = true;
      }

      lastScrollOffset.value = currentOffset;
    }

    scrollController.addListener(scrollListener);
    return () {
      timer.cancel();
      scrollController.removeListener(scrollListener);
    };
  }, [scrollController, hideThreshold, showThreshold, initializationDelay]);

  return isVisible;
}
