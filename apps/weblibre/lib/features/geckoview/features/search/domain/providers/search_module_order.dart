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
import 'dart:convert';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'search_module_order.g.dart';

@JsonSerializable()
class ModuleOrderEntry with FastEquatable {
  final SearchModuleType type;
  final bool visible;

  ModuleOrderEntry({required this.type, required this.visible});

  factory ModuleOrderEntry.fromJson(Map<String, dynamic> json) =>
      _$ModuleOrderEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleOrderEntryToJson(this);

  @override
  List<Object?> get hashParameters => [type, visible];
}

List<ModuleOrderEntry> _mergeWithDefaults(
  List<ModuleOrderEntry>? persisted,
  List<SearchModuleType> defaults,
) {
  if (persisted == null) {
    return defaults
        .map((type) => ModuleOrderEntry(type: type, visible: true))
        .toList();
  }

  final defaultSet = defaults.toSet();
  // Keep persisted entries that are still valid
  final result = persisted.where((e) => defaultSet.contains(e.type)).toList();
  // Add any new defaults not in persisted
  final persistedTypes = result.map((e) => e.type).toSet();
  for (final type in defaults) {
    if (!persistedTypes.contains(type)) {
      result.add(ModuleOrderEntry(type: type, visible: true));
    }
  }
  return result;
}

@Riverpod(keepAlive: true)
class SearchModuleOrder extends _$SearchModuleOrder {
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(insertIndex, item);
    state = list;
  }

  void toggleVisibility(SearchModuleType type) {
    state = [
      for (final e in state)
        if (e.type == type)
          ModuleOrderEntry(type: e.type, visible: !e.visible)
        else
          e,
    ];
  }

  @override
  List<ModuleOrderEntry> build(SearchModuleGroup group) {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: group.key,
      encode: (state) => jsonEncode(state.map((e) => e.toJson()).toList()),
      decode: (encoded) {
        final decoded = (jsonDecode(encoded) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((e) {
              try {
                return ModuleOrderEntry.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<ModuleOrderEntry>()
            .toList();
        // Merge with defaults to pick up newly added or remove deleted modules
        return _mergeWithDefaults(decoded, group.defaultModules);
      },
    );

    return stateOrNull ??
        group.defaultModules
            .map((type) => ModuleOrderEntry(type: type, visible: true))
            .toList();
  }
}
