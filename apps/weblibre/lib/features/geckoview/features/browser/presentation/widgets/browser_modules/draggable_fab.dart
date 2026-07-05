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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DraggableFab extends HookConsumerWidget {
  final Widget child;
  final double fabSize;
  final bool bottomToolbarVisible;
  final double bottomAppBarHeight;
  final double bottomSafeArea;
  final double leftReservedWidth;
  final double rightReservedWidth;

  const DraggableFab({
    super.key,
    required this.child,
    this.fabSize = 56.0,
    required this.bottomToolbarVisible,
    required this.bottomAppBarHeight,
    required this.bottomSafeArea,
    this.leftReservedWidth = 0.0,
    this.rightReservedWidth = 0.0,
  });

  static const _edgePadding = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    final disableAnimations = mediaQuery.disableAnimations;

    final isDragging = useState(false);
    // Stored as distances from the bottom-right corner (dx = from right edge,
    // dy = from bottom edge) rather than a top-left position, so the FAB is
    // anchored by its bottom-right corner. This keeps the primary (bottom) FAB
    // in a stable slot when extra FABs are stacked above it (e.g. the re-dock
    // button while reading), independent of the child's height.
    final customOffset = useState<Offset?>(null);
    final dragStartOffset = useRef<Offset?>(null);
    final dragStartPosition = useRef<Offset?>(null);

    // Actual rendered size of the (possibly stacked) FAB child. Used for drag
    // clamping so a taller stacked column (e.g. dock + appearance FABs) can't be
    // dragged off-screen. Falls back to [fabSize] until first measured.
    final fabKey = useMemoized(GlobalKey.new);
    final fabRenderSize = useState<Size?>(null);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final size = fabKey.currentContext?.size;
        if (size != null && size != fabRenderSize.value) {
          fabRenderSize.value = size;
        }
      });
      return null;
    });

    final fabWidth = fabRenderSize.value?.width ?? fabSize;
    final fabHeight = fabRenderSize.value?.height ?? fabSize;

    // Calculate default position (bottom-right, respecting toolbar)
    final defaultBottom = bottomToolbarVisible
        ? bottomAppBarHeight + _edgePadding
        : _edgePadding + bottomSafeArea;
    final defaultRight = _edgePadding + rightReservedWidth;

    // Current position: custom if set, otherwise default
    final rawRight = customOffset.value?.dx ?? defaultRight;
    final rawBottom = customOffset.value?.dy ?? defaultBottom;
    final currentOffset = _clampToBounds(
      Offset(rawRight, rawBottom),
      screenSize: screenSize,
      padding: padding,
      fabWidth: fabWidth,
      fabHeight: fabHeight,
    );
    final currentRight = currentOffset.dx;
    final currentBottom = currentOffset.dy;

    return Positioned(
      right: currentRight,
      bottom: currentBottom,
      child: GestureDetector(
        onLongPressStart: (details) {
          isDragging.value = true;
          unawaited(HapticFeedback.mediumImpact());
          dragStartOffset.value = Offset(currentRight, currentBottom);
          dragStartPosition.value = details.globalPosition;
        },
        onLongPressMoveUpdate: (details) {
          if (!isDragging.value ||
              dragStartOffset.value == null ||
              dragStartPosition.value == null) {
            return;
          }

          final delta = details.globalPosition - dragStartPosition.value!;
          // Dragging right/down reduces the distance from the right/bottom edge.
          final newOffset = Offset(
            dragStartOffset.value!.dx - delta.dx,
            dragStartOffset.value!.dy - delta.dy,
          );

          // Clamp to screen bounds
          customOffset.value = _clampToBounds(
            newOffset,
            screenSize: screenSize,
            padding: padding,
            fabWidth: fabWidth,
            fabHeight: fabHeight,
          );
        },
        onLongPressEnd: (details) {
          isDragging.value = false;
          dragStartOffset.value = null;
          dragStartPosition.value = null;
        },
        child: AnimatedScale(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 150),
          scale: isDragging.value ? 1.1 : 1.0,
          child: KeyedSubtree(key: fabKey, child: child),
        ),
      ),
    );
  }

  Offset _clampToBounds(
    Offset offset, {
    required Size screenSize,
    required EdgeInsets padding,
    required double fabWidth,
    required double fabHeight,
  }) {
    const minEdgePadding = 8.0;
    final minRight =
        math.max(padding.right, rightReservedWidth) + minEdgePadding;
    final maxRight = math.max(
      minRight,
      screenSize.width -
          fabWidth -
          math.max(padding.left, leftReservedWidth) -
          minEdgePadding,
    );
    final minBottom = padding.bottom + minEdgePadding;
    final maxBottom = math.max(
      minBottom,
      screenSize.height - fabHeight - padding.top - minEdgePadding,
    );

    // Distances from the bottom-right corner: keep at least the safe-area inset
    // plus a margin on the near edge, and leave room for the (possibly stacked)
    // FAB on the far edge so it can't be dragged off-screen.
    return Offset(
      offset.dx.clamp(minRight, maxRight),
      offset.dy.clamp(minBottom, maxBottom),
    );
  }
}
