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
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final bool enabled;

  final String title;
  final String subtitle;
  final Widget? content;

  final Widget? prefix;
  final Widget? suffix;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.content,
    this.prefix,
    this.suffix,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleTextTheme = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          if (prefix != null) prefix!,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: enabled
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyLarge?.copyWith(
                          color: theme.disabledColor,
                        ),
                ),
                Text(
                  subtitle,
                  style: enabled
                      ? subtitleTextTheme
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                ),
                if (content != null) content!,
              ],
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
