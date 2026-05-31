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
import 'package:flutter/material.dart';
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';

extension GestureArrowIcon on GestureArrow {
  IconData get icon => switch (this) {
    GestureArrow.up => Icons.arrow_upward,
    GestureArrow.down => Icons.arrow_downward,
    GestureArrow.left => Icons.arrow_back,
    GestureArrow.right => Icons.arrow_forward,
  };
}

/// Compact visual rendering of a [GestureStroke]: the direction arrows in
/// sequence, prefixed by start-position and finger-count qualifiers when set.
///
/// All glyphs share a single foreground [color] so the view blends with
/// whatever surface it sits on; it defaults to the primary color, but callers
/// rendering on a contrasting surface (e.g. the live overlay) should pass the
/// matching `on…` color.
class GestureStrokeView extends StatelessWidget {
  final GestureStroke stroke;
  final Color? color;

  const GestureStrokeView({required this.stroke, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stroke.startPosition != GestureStartPosition.anywhere)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              stroke.startPosition.icon,
              size: 18,
              color: foreground,
            ),
          ),
        if (stroke.fingers >= 2)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '${stroke.fingers}×',
              style: theme.textTheme.labelLarge?.copyWith(color: foreground),
            ),
          ),
        for (final arrow in stroke.arrows)
          Icon(arrow.icon, size: 18, color: foreground),
      ],
    );
  }
}
