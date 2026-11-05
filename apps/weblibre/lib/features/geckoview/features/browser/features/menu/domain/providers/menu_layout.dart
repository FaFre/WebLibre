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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/storage_options.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ordered_layout.dart';

part 'menu_layout.g.dart';

/// Where [MenuLayout] persists, for code that writes it outside the provider
/// (the onboarding commit).
const menuLayoutStorageKey = 'BrowserMenuLayout';

/// [layout] as [MenuLayout] persists it.
String encodeMenuLayout(List<MenuSectionEntry> layout) =>
    encodeLayoutEntries(layout, (e) => e.toJson());

/// [encoded] (see [encodeMenuLayout]) as [MenuLayout] restores it: merged
/// with the defaults, to pick up newly added or removed sections and rows.
List<MenuSectionEntry> decodeMenuLayout(String encoded) =>
    mergeMenuLayoutWithDefaults(
      decodeLayoutEntries(encoded, MenuSectionEntry.fromJson),
    );

/// [layout] with one section moved, for a list that shows only the sections
/// in [shown]; the others stay among the same neighbours (see
/// [moveAmongShown]).
List<MenuSectionEntry> reorderShownMenuSections(
  List<MenuSectionEntry> layout,
  List<MenuSectionType> shown,
  int oldIndex,
  int newIndex,
) => moveAmongShown(layout, (e) => e.type, shown, oldIndex, newIndex);

/// [layout] with section [type] shown if it was hidden and hidden if shown.
List<MenuSectionEntry> toggleMenuSectionVisibility(
  List<MenuSectionEntry> layout,
  MenuSectionType type,
) => [
  for (final section in layout)
    if (section.type == type)
      section.copyWith(visible: !section.visible)
    else
      section,
];

/// [layout] with a row of [section] moved, or — when [parent] is given — one
/// of the rows [parent] reveals when it expands, within a list that shows
/// only the rows in [shown]; the others stay among the same neighbours (see
/// [moveAmongShown]).
List<MenuSectionEntry> reorderShownMenuItems(
  List<MenuSectionEntry> layout,
  MenuSectionType section,
  MenuItemType? parent,
  List<MenuItemType> shown,
  int oldIndex,
  int newIndex,
) => _mapSectionItems(
  layout,
  section,
  parent,
  (items) => moveAmongShown(items, (e) => e.type, shown, oldIndex, newIndex),
);

/// [layout] with row [item] of [section] (or of [parent]'s rows) shown if it
/// was hidden and hidden if shown.
List<MenuSectionEntry> toggleMenuItemVisibility(
  List<MenuSectionEntry> layout,
  MenuSectionType section,
  MenuItemType? parent,
  MenuItemType item,
) => _mapSectionItems(
  layout,
  section,
  parent,
  (items) => [
    for (final candidate in items)
      if (candidate.type == item)
        candidate.copyWith(visible: !candidate.visible)
      else
        candidate,
  ],
);

List<MenuSectionEntry> _mapSectionItems(
  List<MenuSectionEntry> layout,
  MenuSectionType section,
  MenuItemType? parent,
  List<MenuItemEntry> Function(List<MenuItemEntry> items) update,
) => [
  for (final entry in layout)
    if (entry.type == section)
      entry.copyWith(items: _mapItems(entry.items, parent, update))
    else
      entry,
];

List<MenuItemEntry> _mapItems(
  List<MenuItemEntry> items,
  MenuItemType? parent,
  List<MenuItemEntry> Function(List<MenuItemEntry> items) update,
) {
  if (parent == null) return update(items);

  return [
    for (final item in items)
      if (item.type == parent)
        item.copyWith(items: update(item.items))
      else
        item,
  ];
}

/// The user's arrangement of the browser menu sheet: which sections appear, in
/// what order, how the rows inside each one are ordered, and how the rows an
/// expanding row reveals are ordered.
///
/// One persisted list rather than one per section, so a reorder and the
/// visibility toggle next to it are a single atomic write, and so the whole
/// layout can be reconciled against the shipped defaults in one pass on read.
@Riverpod(keepAlive: true)
class MenuLayout extends _$MenuLayout {
  /// Replaces the whole arrangement with [layout], as the onboarding's commit
  /// does. Invalidating this provider would not do: `persist` reads the store
  /// only on the first build, so a rebuild keeps the arrangement it had.
  // A setter is not allowed on a notifier (avoid_public_notifier_properties).
  // ignore: use_setters_to_change_properties
  void replace(List<MenuSectionEntry> layout) {
    state = layout;
  }

  @override
  List<MenuSectionEntry> build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: menuLayoutStorageKey,
      options: foreverStorageOptions,
      encode: encodeMenuLayout,
      decode: decodeMenuLayout,
    );

    return stateOrNull ?? mergeMenuLayoutWithDefaults(null);
  }
}

/// The menu as drawn: the user's arrangement ([MenuLayout]), or the shipped
/// one while menu customization is hidden (`layout.menu_customization`). The
/// arrangement is kept and comes back with the feature.
@Riverpod(keepAlive: true)
List<MenuSectionEntry> effectiveMenuLayout(Ref ref) {
  final customizationShown = ref.watch(
    shownFeaturesProvider.select(
      (shown) => shown.contains(FeatureId.layoutMenuCustomization),
    ),
  );
  if (!customizationShown) return defaultMenuLayout;
  return ref.watch(menuLayoutProvider);
}

/// The menu's arrangement as the screens that arrange it show and change it:
/// in the onboarding the draft's (the profile's until the first change),
/// otherwise the profile's ([MenuLayout]).
///
/// The edit layer. A change goes into the draft while one is open, and into
/// [MenuLayout] otherwise. [MenuLayout] never sees the draft: its `persist()`
/// stores whatever it holds.
@Riverpod()
class EditedMenuLayout extends _$EditedMenuLayout {
  @override
  List<MenuSectionEntry> build() {
    final drafted = ref.watch(
      setupDraftControllerProvider.select((draft) => draft?.menuLayout),
    );
    return drafted ?? ref.watch(menuLayoutProvider);
  }

  void reorderShownSections(
    List<MenuSectionType> shown,
    int oldIndex,
    int newIndex,
  ) => _set(reorderShownMenuSections(state, shown, oldIndex, newIndex));

  void toggleSectionVisibility(MenuSectionType type) =>
      _set(toggleMenuSectionVisibility(state, type));

  void reorderShownItems(
    MenuSectionType section,
    MenuItemType? parent,
    List<MenuItemType> shown,
    int oldIndex,
    int newIndex,
  ) => _set(
    reorderShownMenuItems(state, section, parent, shown, oldIndex, newIndex),
  );

  void toggleItemVisibility(
    MenuSectionType section,
    MenuItemType? parent,
    MenuItemType item,
  ) => _set(toggleMenuItemVisibility(state, section, parent, item));

  /// Returns to the shipped menu.
  void resetToDefaults() => _set(mergeMenuLayoutWithDefaults(null));

  void _set(List<MenuSectionEntry> layout) {
    if (ref.read(setupDraftControllerProvider) == null) {
      ref.read(menuLayoutProvider.notifier).replace(layout);
    } else {
      ref.read(setupDraftControllerProvider.notifier).setMenuLayout(layout);
    }
  }
}

/// The shipped menu, as drawn while menu customization is hidden.
final defaultMenuLayout = mergeMenuLayoutWithDefaults(null);

/// Where the sheet is in its arrangement UI: not in it at all, arranging the
/// sections, arranging the rows of one section, or arranging the rows one of
/// those reveals.
///
/// One state rather than a flag plus local drill-down state, so the sheet can
/// answer the system back gesture — a back has to unwind these levels one at a
/// time before the sheet itself is allowed to close.
typedef MenuReorderState = ({
  bool active,
  MenuSectionType? focusedSection,
  MenuItemType? focusedItem,
});

/// Whether the sheet is currently showing its arrangement UI instead of the
/// menu.
///
/// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
/// the menu while arranging and opening it again returns to the menu, which is
/// what a modal that is dismissed by tapping outside has to do.
@Riverpod()
class MenuReorderMode extends _$MenuReorderMode {
  void activate() =>
      state = (active: true, focusedSection: null, focusedItem: null);

  void deactivate() =>
      state = (active: false, focusedSection: null, focusedItem: null);

  void focusSection(MenuSectionType section) =>
      state = (active: true, focusedSection: section, focusedItem: null);

  void focusItem(MenuItemType item) => state = (
    active: true,
    focusedSection: state.focusedSection,
    focusedItem: item,
  );

  /// Steps back one level. Returns false once there is nothing left to step
  /// back to, which is the sheet's cue to let itself be dismissed.
  bool stepBack() {
    if (state.focusedItem != null) {
      state = (
        active: true,
        focusedSection: state.focusedSection,
        focusedItem: null,
      );
      return true;
    }

    if (state.focusedSection != null) {
      activate();
      return true;
    }

    if (state.active) {
      deactivate();
      return true;
    }

    return false;
  }

  @override
  MenuReorderState build() =>
      (active: false, focusedSection: null, focusedItem: null);
}
