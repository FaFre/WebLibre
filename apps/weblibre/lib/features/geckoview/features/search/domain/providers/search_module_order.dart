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
import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/storage_options.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/utils/ordered_layout.dart';

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
/// Thin wrapper over [mergeOrderedLayout], which carries the reconciliation
/// rules (drop modules that no longer exist, insert newly shipped ones at their
/// designed position rather than the bottom) shared with the browser menu's
/// layout. Kept as a named function because it is the tested entry point for
/// this surface.
List<ModuleOrderEntry> mergeModuleOrderWithDefaults(
  List<ModuleOrderEntry>? persisted,
  List<ModuleSurfaceDefault> defaults,
) {
  return mergeOrderedLayout(
    persisted: persisted,
    defaults: defaults,
    entryKey: (entry) => entry.type,
    defaultKey: (definition) => definition.type,
    fromDefault: (definition) =>
        ModuleOrderEntry(type: definition.type, visible: definition.visible),
  );
}

/// [entries] with one module moved, for a list that shows only the modules in
/// [shown]; see [moveAmongShown].
List<ModuleOrderEntry> reorderShownModules(
  List<ModuleOrderEntry> entries,
  List<SearchModuleType> shown,
  int oldIndex,
  int newIndex,
) => moveAmongShown(entries, (e) => e.type, shown, oldIndex, newIndex);

String encodeModuleOrder(List<ModuleOrderEntry> entries) =>
    encodeLayoutEntries(entries, (e) => e.toJson());

/// [encoded] (see [encodeModuleOrder]) as [SearchModuleOrder] restores
/// [surface]'s layout: merged with its defaults, to pick up newly added or
/// remove deleted modules.
List<ModuleOrderEntry> decodeModuleOrder(
  String encoded,
  ModuleSurface surface,
) => mergeModuleOrderWithDefaults(
  decodeLayoutEntries(encoded, ModuleOrderEntry.fromJson),
  surface.defaultModules,
);

/// [entries] with [type] shown if it was hidden and hidden if it was shown.
List<ModuleOrderEntry> toggleModuleVisibility(
  List<ModuleOrderEntry> entries,
  SearchModuleType type,
) => [
  for (final e in entries)
    if (e.type == type)
      ModuleOrderEntry(type: e.type, visible: !e.visible)
    else
      e,
];

@Riverpod(keepAlive: true)
class SearchModuleOrder extends _$SearchModuleOrder {
  /// Replaces the whole layout with [layout], as the onboarding's commit
  /// does. Invalidating this provider would not do: `persist` reads the store
  /// only on the first build, so a rebuild keeps the layout it had.
  // A setter is not allowed on a notifier (avoid_public_notifier_properties).
  // ignore: use_setters_to_change_properties
  void replace(List<ModuleOrderEntry> layout) {
    state = layout;
  }

  /// Discards the user's layout for this surface and returns to its defaults.
  ///
  /// Display state included: it persists too, so resetting only the order and
  /// visibility would hand back a "default" home with a section still collapsed
  /// or still expanded from before.
  void resetToDefaults() {
    state = mergeModuleOrderWithDefaults(null, surface.defaultModules);

    for (final module in SearchModuleType.values) {
      if (surface.offers(module)) {
        ref
            .read(
              searchModuleDisplayStateControllerProvider(
                surface,
                module,
              ).notifier,
            )
            .reset();
      }
    }
  }

  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: surface.key,
      options: foreverStorageOptions,
      encode: encodeModuleOrder,
      decode: (encoded) => decodeModuleOrder(encoded, surface),
    );

    return stateOrNull ??
        mergeModuleOrderWithDefaults(null, surface.defaultModules);
  }
}

/// The layout of [surface] as the screens that arrange it show and change
/// it: in the onboarding the draft's (what the commit would write), otherwise
/// the profile's ([SearchModuleOrder]).
///
/// The edit layer. A change goes into the draft while one is open, and into
/// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
/// its `persist()` stores whatever it holds.
@Riverpod()
class EditedModuleOrder extends _$EditedModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) {
    final drafted = ref.watch(
      setupDraftControllerProvider.select((draft) => draft?.layoutFor(surface)),
    );
    return drafted ?? ref.watch(searchModuleOrderProvider(surface));
  }

  // The preset's new-tab layout is built afresh on every read of the
  // draft: only a different layout is a change.
  @override
  bool updateShouldNotify(
    List<ModuleOrderEntry> previous,
    List<ModuleOrderEntry> next,
  ) => !const ListEquality<ModuleOrderEntry>().equals(previous, next);

  /// Moves a module within a list that shows only the modules in [shown];
  /// see [reorderShownModules].
  void reorderShown(List<SearchModuleType> shown, int oldIndex, int newIndex) =>
      _set(reorderShownModules(state, shown, oldIndex, newIndex));

  void toggleVisibility(SearchModuleType type) =>
      _set(toggleModuleVisibility(state, type));

  /// Returns to the surface's default layout. In the onboarding the
  /// sections' expanded or collapsed state stays: that is the profile's, and
  /// nothing reaches the profile before the commit.
  void resetToDefaults() {
    if (ref.read(setupDraftControllerProvider) == null) {
      ref.read(searchModuleOrderProvider(surface).notifier).resetToDefaults();
    } else {
      _set(mergeModuleOrderWithDefaults(null, surface.defaultModules));
    }
  }

  void _set(List<ModuleOrderEntry> layout) {
    if (ref.read(setupDraftControllerProvider) == null) {
      ref.read(searchModuleOrderProvider(surface).notifier).replace(layout);
    } else {
      ref
          .read(setupDraftControllerProvider.notifier)
          .setLayout(surface, layout);
    }
  }
}
