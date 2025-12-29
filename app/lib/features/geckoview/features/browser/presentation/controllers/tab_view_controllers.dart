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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'tab_view_controllers.g.dart';

@Riverpod(keepAlive: true)
class TabSuggestionsController extends _$TabSuggestionsController {
  void enable() {
    state = true;
  }

  void disable() {
    state = false;
  }

  void hide() {
    if (state) {
      state = false;
    }
  }

  @override
  bool build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'TabSuggestions',
      encode: (state) => jsonEncode([state]),
      decode: (encoded) => (jsonDecode(encoded) as List<dynamic>).first as bool,
    );

    return stateOrNull ?? false;
  }
}

enum TabsViewMode {
  list(MdiIcons.folderTable, 'List'),
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
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'TabsViewMode',
      encode: (state) => jsonEncode([state.name]),
      decode: (encoded) {
        final name = (jsonDecode(encoded) as List<dynamic>).first as String;
        return TabsViewMode.values.firstWhere((e) => e.name == name);
      },
    );

    return stateOrNull ?? TabsViewMode.list;
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
