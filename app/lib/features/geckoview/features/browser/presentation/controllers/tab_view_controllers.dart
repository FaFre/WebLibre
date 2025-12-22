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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_view_controllers.g.dart';

@Riverpod(keepAlive: true)
class TabSuggestionsController extends _$TabSuggestionsController {
  void toggle() {
    state = !state;
  }

  void hide() {
    if (state) {
      state = false;
    }
  }

  @override
  bool build() {
    return false;
  }
}

enum TabsViewMode {
  grid(MdiIcons.table, 'Grid'),
  tree(MdiIcons.familyTree, 'Tree');

  final IconData icon;
  final String label;

  const TabsViewMode(this.icon, this.label);
}

@Riverpod(keepAlive: true)
class TabsViewModeController extends _$TabsViewModeController {
  void set(TabsViewMode mode) {
    if (mode != state) {
      state = mode;
    }
  }

  @override
  TabsViewMode build() {
    return TabsViewMode.grid;
  }
}

@Riverpod()
class TabsReorderableController extends _$TabsReorderableController {
  void toggle() {
    state = !state;
  }

  void hide() {
    if (state) {
      state = false;
    }
  }

  @override
  bool build() {
    return false;
  }
}
