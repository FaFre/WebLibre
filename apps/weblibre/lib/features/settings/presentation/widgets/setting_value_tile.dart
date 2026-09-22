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

/// A setting whose value is a choice, such as the action a gesture runs: what
/// it is about ([title], with [description] as context), then its current
/// [value] with the value's own [valueIcon].
///
/// The value sits under the text in the primary color with the dropdown arrow
/// right beside it, so it reads as the thing to change. Without [onTap] the
/// setting is fixed: the value is shown muted, with a lock instead.
class SettingValueTile extends StatelessWidget {
  const SettingValueTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.valueIcon,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  /// What the setting is about (a gesture's movement, say); [valueIcon] is
  /// the chosen value's.
  final IconData icon;
  final String title;
  final String description;
  final String value;
  final IconData valueIcon;
  final VoidCallback? onTap;

  /// Around the whole tile; narrower where a surrounding card already pads.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editable = onTap != null;
    final valueColor = editable
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(valueIcon, size: 18, color: valueColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          value,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: valueColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        editable ? Icons.arrow_drop_down : Icons.lock_outline,
                        color: valueColor,
                        size: editable ? 20 : 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
