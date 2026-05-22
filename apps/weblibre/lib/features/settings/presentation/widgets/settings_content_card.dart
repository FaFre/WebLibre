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

/// Wraps [child] in the standard surface-container Card used by settings
/// content widgets — unless [embedded] is true, in which case the child is
/// returned as-is so the host container (typically a
/// [SettingsEntryDefinition] already inside a `Card.filled`) doesn't end
/// up with nested cards.
///
/// Use this anywhere a widget is rendered both stand-alone (e.g. inside a
/// dedicated screen) and embedded as the `child` of a
/// [SettingsEntryDefinition].
class SettingsContentCard extends StatelessWidget {
  const SettingsContentCard({
    super.key,
    required this.child,
    this.embedded = false,
  });

  final Widget child;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (embedded) return child;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
