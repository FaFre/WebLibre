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
import 'package:drift/drift.dart' show Value;
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ordered_layout.dart';

part 'toolbar_button_configs.g.dart';

List<ToolbarButtonConfig> _buildDefaultToolbarButtonConfigs({
  required bool allHidden,
}) {
  String? lastKey;

  return toolbarButtonSpecs.map((spec) {
    final key = lexoRankBetween(lastKey, null);
    lastKey = key;

    return ToolbarButtonConfig(
      buttonId: spec.id.name,
      orderKey: key,
      isVisible: !allHidden && spec.defaultVisible,
      fallbackId: allHidden ? null : spec.defaultFallback?.name,
    );
  }).toList();
}

final _contextualDefaultConfigs = EquatableValue(
  _buildDefaultToolbarButtonConfigs(allHidden: false),
);

final _quickSwitcherDefaultConfigs = EquatableValue(
  _buildDefaultToolbarButtonConfigs(allHidden: true),
);

/// Default configuration set for [location], used as the reset target and as the
/// fallback while the persisted set is still loading. The quick switcher starts
/// with every button hidden.
EquatableValue<List<ToolbarButtonConfig>> defaultToolbarButtonConfigsFor(
  ToolbarConfigLocation location,
) {
  return switch (location) {
    ToolbarConfigLocation.contextual => _contextualDefaultConfigs,
    ToolbarConfigLocation.quickSwitcher => _quickSwitcherDefaultConfigs,
  };
}

@Riverpod(keepAlive: true)
Stream<List<ToolbarButtonConfig>> toolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) async* {
  final repository = ref.watch(toolbarConfigRepositoryProvider(location));
  await repository.seedMissingDefaults();
  yield* repository.watchAll();
}

/// The configuration of [location] as the profile stores it: known buttons
/// only, the defaults while loading or empty. Never the onboarding draft.
@Riverpod(keepAlive: true)
EquatableValue<List<ToolbarButtonConfig>> profileToolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) {
  return toolbarButtonConfigsAsStored(
    ref.watch(toolbarButtonConfigsProvider(location)),
    location,
  );
}

/// The buttons of the toolbar at [location] as its editor shows and changes
/// them: in the onboarding the draft's (the profile's until the first
/// change), otherwise the profile's ([profileToolbarButtonConfigs]).
///
/// The edit layer. A change is computed with the pure edits
/// ([moveToolbarButton] and its siblings) and goes into the draft while one
/// is open; otherwise it is saved to the profile
/// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
/// that changed).
///
/// Those writes are optimistic: the editor shows a change at once, and the
/// next one is computed from it rather than from a store that has not caught
/// up. The change is held in [_pending], not only in `state`: every emission
/// of the store rebuilds this provider, and a rebuild replaces `state`. It is
/// dropped once the store shows it, or when a write fails.
@Riverpod()
class ToolbarButtonLayout extends _$ToolbarButtonLayout {
  List<ToolbarButtonConfig>? _pending;

  @override
  EquatableValue<List<ToolbarButtonConfig>> build(
    ToolbarConfigLocation location,
  ) {
    final drafted = ref.watch(
      setupDraftControllerProvider.select(
        (draft) => draft?.toolbarButtons[location],
      ),
    );
    if (drafted != null) return EquatableValue(drafted);

    final stored = ref.watch(profileToolbarButtonConfigsProvider(location));
    if (_pending case final pending?) {
      if (!const ListEquality<ToolbarButtonConfig>().equals(
        stored.value,
        pending,
      )) {
        return EquatableValue(pending);
      }
      _pending = null;
    }
    return stored;
  }

  /// Moves a button within a list that shows only the buttons in [shown];
  /// see [moveToolbarButton].
  Future<void> move(List<String> shown, int oldIndex, int newIndex) =>
      _edit((configs) => moveToolbarButton(configs, shown, oldIndex, newIndex));

  Future<void> setVisibility(String buttonId, {required bool visible}) => _edit(
    (configs) =>
        setToolbarButtonVisibility(configs, buttonId, visible: visible),
  );

  Future<void> setFallback(String buttonId, String? fallbackId) => _edit(
    (configs) => setToolbarButtonFallback(configs, buttonId, fallbackId),
  );

  Future<void> setLongPress(String buttonId, BrowserAction? action) =>
      _edit((configs) => setToolbarButtonLongPress(configs, buttonId, action));

  /// The one edit that needs nothing loaded: it replaces everything.
  Future<void> resetToDefaults() =>
      _write(defaultToolbarButtonConfigsFor(location).value);

  /// Applies [change] to the buttons as they stand, once they are known.
  ///
  /// An edit must start from the stored buttons, never from the defaults
  /// shown while the store is loading or failed: every default that differs
  /// from what is stored would be saved as a change, overwriting the user's
  /// order, visibility, fallbacks and long presses. A store still loading is
  /// waited for; one that failed fails the edit, and nothing is written.
  Future<void> _edit(
    List<ToolbarButtonConfig> Function(List<ToolbarButtonConfig> configs)
    change,
  ) async {
    final drafted =
        ref.read(setupDraftControllerProvider)?.toolbarButtons[location] !=
        null;
    final stored = ref.read(toolbarButtonConfigsProvider(location));
    if (!drafted && _pending == null && stored is! AsyncData) {
      await ref.read(toolbarButtonConfigsProvider(location).future);
      if (!ref.mounted) return;
    }
    await _write(change(state.value));
  }

  Future<void> _write(List<ToolbarButtonConfig> configs) async {
    if (ref.read(setupDraftControllerProvider) != null) {
      ref
          .read(setupDraftControllerProvider.notifier)
          .setToolbarButtons(location, configs);
      return;
    }

    _pending = configs;
    state = EquatableValue(configs);
    try {
      // Serialized by the repository, which outlives this editor.
      await ref
          .read(toolbarConfigRepositoryProvider(location))
          .saveAll(configs);
    } catch (_) {
      if (ref.mounted && identical(_pending, configs)) {
        _pending = null;
        ref.invalidateSelf();
      }
      rethrow;
    }
  }
}

/// [configs] as the editors and the browser use them: known buttons only,
/// the defaults while loading, failed or empty.
EquatableValue<List<ToolbarButtonConfig>> toolbarButtonConfigsAsStored(
  AsyncValue<List<ToolbarButtonConfig>> configs,
  ToolbarConfigLocation location,
) {
  return configs.when(
    data: (configs) {
      final filtered = configs
          .where((config) => knownToolbarButtonIds.contains(config.buttonId))
          .toList();

      if (filtered.isEmpty) {
        return defaultToolbarButtonConfigsFor(location);
      }

      return EquatableValue(filtered);
    },
    loading: () => defaultToolbarButtonConfigsFor(location),
    error: (_, _) => defaultToolbarButtonConfigsFor(location),
  );
}

/// The configuration of [location] as it applies: [profileToolbarButtonConfigs]
/// with the default fallbacks and no long-press actions while the advanced
/// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
/// visibility are ordinary layout and stay as stored.
@Riverpod(keepAlive: true)
EquatableValue<List<ToolbarButtonConfig>> effectiveToolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) {
  final stored = ref.watch(profileToolbarButtonConfigsProvider(location));
  final advancedShown = ref.watch(
    shownFeaturesProvider.select(
      (shown) => shown.contains(FeatureId.layoutContextualToolbarAdvanced),
    ),
  );
  if (advancedShown) return stored;

  return EquatableValue(
    toolbarButtonConfigsAsApplied(stored.value, location, advancedShown: false),
  );
}

/// The buttons of [location] as the Toolbar & Layout preview draws them:
/// [ToolbarButtonLayout] as it applies, with the advanced options as the
/// displayed settings show them. Outside the onboarding the same as
/// [effectiveToolbarButtonConfigs], apart from a change still being written.
/// The browser's own toolbars read [effectiveToolbarButtonConfigs]
/// ([toolbarButtonConfigsShownBy]).
///
/// The displayed layer. Auto-disposed, like the editor it follows.
@Riverpod()
EquatableValue<List<ToolbarButtonConfig>> displayedToolbarButtonConfigs(
  Ref ref,
  ToolbarConfigLocation location,
) {
  final edited = ref.watch(toolbarButtonLayoutProvider(location));
  final advancedShown = ref.watch(
    displayedShownFeaturesProvider.select(
      (shown) => shown.contains(FeatureId.layoutContextualToolbarAdvanced),
    ),
  );
  if (advancedShown) return edited;

  return EquatableValue(
    toolbarButtonConfigsAsApplied(edited.value, location, advancedShown: false),
  );
}

/// The buttons of [location] as a toolbar widget drawn both in the browser
/// and in the Toolbar & Layout preview shows them: the live ones
/// ([effectiveToolbarButtonConfigs]) in the browser, the displayed ones
/// ([displayedToolbarButtonConfigs], in the onboarding the draft's) in the
/// preview. The browser never follows the draft.
ProviderListenable<EquatableValue<List<ToolbarButtonConfig>>>
toolbarButtonConfigsShownBy(
  ToolbarConfigLocation location, {
  required bool isPreview,
}) => isPreview
    ? displayedToolbarButtonConfigsProvider(location)
    : effectiveToolbarButtonConfigsProvider(location);

/// [stored] as it applies: with the advanced toolbar options hidden
/// ([advancedShown] false), every button falls back the default way and has
/// no long-press action.
List<ToolbarButtonConfig> toolbarButtonConfigsAsApplied(
  List<ToolbarButtonConfig> stored,
  ToolbarConfigLocation location, {
  required bool advancedShown,
}) {
  if (advancedShown) return stored;

  final defaultFallbacks = {
    for (final config in defaultToolbarButtonConfigsFor(location).value)
      config.buttonId: config.fallbackId,
  };
  return [
    for (final config in stored)
      config.copyWith(
        fallbackId: Value(defaultFallbacks[config.buttonId]),
        longPressAction: const Value(null),
      ),
  ];
}

/// [configs] in order-key order, as the stored repositories list them.
List<ToolbarButtonConfig> sortedToolbarButtons(
  List<ToolbarButtonConfig> configs,
) => [...configs]..sort((a, b) => a.orderKey.compareTo(b.orderKey));

/// [configs] with one button moved within its section (the shown or the
/// hidden buttons), for a list that shows only the buttons in [shown]:
/// [oldIndex] and [newIndex] (after removal) index into [shown], as for
/// [moveAmongShown].
///
/// Only the moved button gets a new order key, between its new neighbours in
/// its section: order keys are LexoRanks, ordered within the buttons of the
/// same visibility, as the stored queries order them.
///
/// [configs] are unchanged when [shown] is not a list of one section of
/// them: a move made on a list that has since changed (the defaults the
/// editor showed while the store was loading, say) has no place to land.
List<ToolbarButtonConfig> moveToolbarButton(
  List<ToolbarButtonConfig> configs,
  List<String> shown,
  int oldIndex,
  int newIndex,
) {
  final sorted = sortedToolbarButtons(configs);
  final movedId = shown[oldIndex];
  final moved = sorted.firstWhereOrNull((config) => config.buttonId == movedId);
  if (moved == null) return sorted;
  final sectionConfigs = [
    for (final config in sorted)
      if (config.isVisible == moved.isVisible) config,
  ];
  final sectionIds = {for (final config in sectionConfigs) config.buttonId};
  if (!shown.every(sectionIds.contains)) return sorted;

  final section = moveAmongShown(
    sectionConfigs,
    (config) => config.buttonId,
    shown,
    oldIndex,
    newIndex,
  );

  final index = section.indexOf(moved);
  final orderKey = lexoRankBetween(
    index > 0 ? section[index - 1].orderKey : null,
    index + 1 < section.length ? section[index + 1].orderKey : null,
  );
  return _updateToolbarButton(
    sorted,
    movedId,
    (config) => config.copyWith(orderKey: orderKey),
  );
}

/// [configs] with [buttonId] shown or hidden. It moves to the end of its new
/// section, so its order key stays inside that section.
List<ToolbarButtonConfig> setToolbarButtonVisibility(
  List<ToolbarButtonConfig> configs,
  String buttonId, {
  required bool visible,
}) {
  final section = [
    for (final config in sortedToolbarButtons(configs))
      if (config.isVisible == visible && config.buttonId != buttonId) config,
  ];
  final orderKey = lexoRankBetween(section.lastOrNull?.orderKey, null);
  return _updateToolbarButton(
    configs,
    buttonId,
    (config) => config.copyWith(isVisible: visible, orderKey: orderKey),
  );
}

/// [configs] with [buttonId] falling back to [fallbackId] (null: none).
List<ToolbarButtonConfig> setToolbarButtonFallback(
  List<ToolbarButtonConfig> configs,
  String buttonId,
  String? fallbackId,
) => _updateToolbarButton(
  configs,
  buttonId,
  (config) => config.copyWith(fallbackId: Value(fallbackId)),
);

/// [configs] with [buttonId]'s own long press replaced by [action]; null
/// restores the button's built-in long press.
List<ToolbarButtonConfig> setToolbarButtonLongPress(
  List<ToolbarButtonConfig> configs,
  String buttonId,
  BrowserAction? action,
) => _updateToolbarButton(
  configs,
  buttonId,
  (config) => config.copyWith(longPressAction: Value(action)),
);

List<ToolbarButtonConfig> _updateToolbarButton(
  List<ToolbarButtonConfig> configs,
  String buttonId,
  ToolbarButtonConfig Function(ToolbarButtonConfig config) change,
) => sortedToolbarButtons([
  for (final config in configs)
    if (config.buttonId == buttonId) change(config) else config,
]);
