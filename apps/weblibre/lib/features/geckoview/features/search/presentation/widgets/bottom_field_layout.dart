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

/// A scrolling [body] above a [footer] that ends in a text field.
///
/// The footer takes its natural height and the body gets what is left. In a
/// window too short for the whole footer — landscape or split screen with the
/// keyboard up — the footer scrolls instead of overflowing. It is anchored to
/// its bottom edge, so the field stays above the keyboard and the rows above it
/// give way first.
class BottomFieldLayout extends StatelessWidget {
  final Widget body;
  final Widget footer;

  const BottomFieldLayout({
    super.key,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuilt on every frame of the keyboard's slide, but [body] and [footer]
    // are the same widgets each time, so only the layout runs again.
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Expanded(child: body),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: SingleChildScrollView(reverse: true, child: footer),
          ),
        ],
      ),
    );
  }
}
