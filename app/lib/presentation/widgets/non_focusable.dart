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

/// A wrapper that prevents a widget from receiving keyboard focus.
///
/// This fixes the issue where arrow keys on a bluetooth keyboard navigate
/// to toolbar buttons instead of moving the text cursor in input fields.
///
/// Example:
/// ```dart
/// NonFocusable(
///   child: IconButton(
///     onPressed: () {},
///     icon: Icon(Icons.menu),
///   ),
/// )
/// ```
class NonFocusable extends StatelessWidget {
  final Widget child;

  const NonFocusable({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Focus(canRequestFocus: false, skipTraversal: true, child: child);
  }
}
