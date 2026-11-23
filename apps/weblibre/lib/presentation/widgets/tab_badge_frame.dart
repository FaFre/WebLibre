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

/// Lays out a tab badge (lock, sleep, split member…): [padding] around
/// [child], on a plate when [withBackground] (over a thumbnail in the tab
/// tray grid).
class TabBadgeFrame extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final bool withBackground;
  final Widget child;

  const TabBadgeFrame({
    required this.padding,
    required this.withBackground,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: withBackground
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(200),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Padding(padding: const EdgeInsets.all(6), child: child),
          )
        : child,
  );
}
