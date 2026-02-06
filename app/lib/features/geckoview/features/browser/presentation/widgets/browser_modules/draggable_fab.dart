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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DraggableFab extends HookConsumerWidget {
  final Widget child;
  final double fabSize;
  final bool bottomToolbarVisible;
  final double bottomAppBarHeight;
  final double bottomSafeArea;

  const DraggableFab({
    super.key,
    required this.child,
    this.fabSize = 56.0,
    required this.bottomToolbarVisible,
    required this.bottomAppBarHeight,
    required this.bottomSafeArea,
  });

  static const _edgePadding = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;

    final isDragging = useState(false);
    final customOffset = useState<Offset?>(null);
    final dragStartOffset = useRef<Offset?>(null);
    final dragStartPosition = useRef<Offset?>(null);

    // Calculate default position (bottom-right, respecting toolbar)
    final defaultBottom = bottomToolbarVisible
        ? bottomAppBarHeight + _edgePadding
        : _edgePadding + bottomSafeArea;
    const defaultRight = _edgePadding;
    final defaultLeft = screenSize.width - fabSize - defaultRight;
    final defaultTop = screenSize.height - fabSize - defaultBottom;

    // Current position: custom if set, otherwise default
    final currentLeft = customOffset.value?.dx ?? defaultLeft;
    final currentTop = customOffset.value?.dy ?? defaultTop;

    return Positioned(
      left: currentLeft,
      top: currentTop,
      child: GestureDetector(
        onLongPressStart: (details) {
          isDragging.value = true;
          unawaited(HapticFeedback.mediumImpact());
          dragStartOffset.value = Offset(currentLeft, currentTop);
          dragStartPosition.value = details.globalPosition;
        },
        onLongPressMoveUpdate: (details) {
          if (!isDragging.value ||
              dragStartOffset.value == null ||
              dragStartPosition.value == null) {
            return;
          }

          final delta = details.globalPosition - dragStartPosition.value!;
          final newOffset = dragStartOffset.value! + delta;

          // Clamp to screen bounds
          customOffset.value = _clampToBounds(
            newOffset,
            screenSize: screenSize,
            padding: padding,
          );
        },
        onLongPressEnd: (details) {
          isDragging.value = false;
          dragStartOffset.value = null;
          dragStartPosition.value = null;
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isDragging.value ? 1.1 : 1.0,
          child: child,
        ),
      ),
    );
  }

  Offset _clampToBounds(
    Offset offset, {
    required Size screenSize,
    required EdgeInsets padding,
  }) {
    const minEdgePadding = 8.0;

    return Offset(
      offset.dx.clamp(
        padding.left + minEdgePadding,
        screenSize.width - fabSize - padding.right - minEdgePadding,
      ),
      offset.dy.clamp(
        padding.top + minEdgePadding,
        screenSize.height - fabSize - padding.bottom - minEdgePadding,
      ),
    );
  }
}
