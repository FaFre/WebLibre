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
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';

/// Marks which [ModuleSurface] the modules below it belong to.
///
/// The same module can appear on more than one surface, so a module cannot name
/// its own surface — the host does, once, above its scroll view. Every
/// `SearchModuleSection` reads it from here to find the order it should honour,
/// the reorder mode it should respond to, and the backdrop its pinned header
/// should sit on.
///
/// Inherited lookups walk the element tree, which includes sliver elements, so
/// sections nested inside `MultiSliver`s resolve this correctly.
class ModuleSurfaceScope extends InheritedWidget {
  final ModuleSurface surface;

  /// Painted behind the section headers, which pin to the top of the viewport
  /// when this is set. Null leaves them unpinned and unpainted.
  ///
  /// The two are one setting because they are one decision: a pinned header
  /// has content scrolling underneath it and therefore *must* be opaque, while
  /// an unpinned header never covers anything and so needs no backdrop at all.
  ///
  /// The search screen pins on `canvasColor`: its result lists are long, and
  /// the header tells you which module you are looking at. The browser home
  /// does not pin. Its sections are short, and on the `BrowserPage` aura
  /// gradient an opaque band per header stacks into a set of slabs cutting
  /// across the backdrop — with several short or collapsed modules in a row,
  /// the bands land next to each other and the surface reads as stripes.
  final Color? pinnedHeaderBackgroundColor;

  const ModuleSurfaceScope({
    super.key,
    required this.surface,
    required this.pinnedHeaderBackgroundColor,
    required super.child,
  });

  static ModuleSurfaceScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ModuleSurfaceScope>();
    assert(
      scope != null,
      'No ModuleSurfaceScope found. Surface modules must be hosted under one '
      'so they know which configuration to follow.',
    );
    return scope!;
  }

  /// The surface modules below [context] belong to.
  static ModuleSurface surfaceOf(BuildContext context) => of(context).surface;

  @override
  bool updateShouldNotify(ModuleSurfaceScope oldWidget) =>
      surface != oldWidget.surface ||
      pinnedHeaderBackgroundColor != oldWidget.pinnedHeaderBackgroundColor;
}
