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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/presentation/widgets/inline_count_badge.dart';

// Above this depth, collapse the chevrons into a single icon + count badge.
const int _maxInlineGlyphs = 3;

class TabDepthIndicator extends StatelessWidget {
  final int depth;
  final double height;
  final double iconSize;
  final double horizontalPadding;

  const TabDepthIndicator({
    required this.depth,
    this.height = 28.0,
    this.iconSize = 16.0,
    this.horizontalPadding = 6.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showBadge = depth > _maxInlineGlyphs;
    final glyphCount = showBadge ? 1 : depth;

    return SizedBox(
      height: height,
      child: Material(
        color: scheme.surfaceContainerHighest.withAlpha(200),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < glyphCount; i++)
                Icon(
                  MdiIcons.subdirectoryArrowRight,
                  size: iconSize,
                  color: scheme.onSurfaceVariant,
                ),
              if (showBadge) ...[
                const SizedBox(width: 2),
                InlineCountBadge(
                  count: depth,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
