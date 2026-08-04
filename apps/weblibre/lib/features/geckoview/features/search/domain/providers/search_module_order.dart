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

/// Reconciles a persisted module order with the surface's current defaults.
///
/// Persisted entries whose module no longer exists on the surface are dropped,
/// and modules that were added since the order was saved are inserted at their
/// position in [defaults] rather than appended, so a new module lands where it
/// was designed to sit instead of at the bottom of the user's list.
///
/// Pure and exported so the reconciliation can be tested directly — it runs on
/// every read of a persisted order, and a regression here silently rewrites
/// user configuration.
List<ModuleOrderEntry> mergeModuleOrderWithDefaults(
  List<ModuleOrderEntry>? persisted,
  List<ModuleSurfaceDefault> defaults,
) {
  List<ModuleOrderEntry> fromDefaults() => defaults
      .map((d) => ModuleOrderEntry(type: d.type, visible: d.visible))
      .toList();

  if (persisted == null) {
    return fromDefaults();
  }

  final offered = {for (final d in defaults) d.type: d};
  // Keep persisted entries that are still valid
  final result = persisted.where((e) => offered.containsKey(e.type)).toList();
  // Insert any new defaults at their position from the defaults list so newly
  // introduced modules land where they're meant to (e.g. at the top), instead
  // of trailing the user's persisted order. They keep the default's own
  // visibility, so a module can be offered without being switched on for
  // everyone who already customised this surface.
  final persistedTypes = result.map((e) => e.type).toSet();
  for (var i = 0; i < defaults.length; i++) {
    final entry = defaults[i];
    if (!persistedTypes.contains(entry.type)) {
      final insertAt = i.clamp(0, result.length);
      result.insert(
        insertAt,
        ModuleOrderEntry(type: entry.type, visible: entry.visible),
      );
    }
  }
  return result;
}

@Riverpod(keepAlive: true)
class SearchModuleOrder extends _$SearchModuleOrder {
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
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

  /// Discards the user's layout for this surface and returns to its defaults.
  void resetToDefaults() {
    state = mergeModuleOrderWithDefaults(null, surface.defaultModules);
  }

  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: surface.key,
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
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
        return mergeModuleOrderWithDefaults(decoded, surface.defaultModules);
      },
    );

    return stateOrNull ??
        mergeModuleOrderWithDefaults(null, surface.defaultModules);
  }
}
