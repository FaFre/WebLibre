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
import 'dart:math';

import 'package:flutter/material.dart';

class DraggableScrollableHeader extends StatefulWidget {
  final DraggableScrollableController controller;
  final Widget child;

  // Velocity control parameters
  final double velocitySensitivity;
  final double maxVelocity;
  final double minVelocity;
  final Duration animationDuration;
  final Curve animationCurve;
  final double dragSensitivity;

  const DraggableScrollableHeader({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _animationController.stop();

        // Apply drag sensitivity
        final adjustedDelta = details.delta.dy * widget.dragSensitivity;

        widget.controller.jumpTo(
          min(
            1,
            widget.controller.pixelsToSize(
              widget.controller.pixels - adjustedDelta,
            ),
          ),
        );
      },
      onVerticalDragEnd: (details) async {
        final velocity = details.primaryVelocity ?? 0;
        final currentSize = widget.controller.size;

        // Clamp velocity to defined range
        final clampedVelocity = velocity.clamp(
          -widget.maxVelocity,
          widget.maxVelocity,
        );

        // Only apply momentum if velocity exceeds minimum threshold
        if (clampedVelocity.abs() < widget.minVelocity) {
          return; // No momentum, stay at current position
        }

        // Calculate momentum-based target with sensitivity control
        final velocityFactor =
            clampedVelocity / 1000 * widget.velocitySensitivity;
        double targetSize = currentSize - velocityFactor;

        // Clamp to valid range
        targetSize = targetSize.clamp(0.0, 1.0);

        // Calculate animation duration based on velocity (faster velocity = longer animation)
        final velocityRatio = clampedVelocity.abs() / widget.maxVelocity;
        final dynamicDuration = Duration(
          milliseconds:
              (widget.animationDuration.inMilliseconds * (0.5 + velocityRatio))
                  .round(),
        );

        await _animateToPosition(targetSize, customDuration: dynamicDuration);
      },
      child: widget.child,
    );
  }
}
