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

class InlineCountBadge extends StatelessWidget {
  const InlineCountBadge({
    required this.count,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    super.key,
  });

  final int count;
  final Color backgroundColor;
  final Color foregroundColor;

  /// Optional glyph rendered inside the badge, trailing the count.
  final IconData? icon;

  static String formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatCount(count),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
          if (icon case final icon?) ...[
            const SizedBox(width: 2),
            Icon(icon, size: 12, color: foregroundColor),
          ],
        ],
      ),
    );
  }
}
