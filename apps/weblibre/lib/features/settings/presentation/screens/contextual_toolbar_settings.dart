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
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/entities/browser_action_policy.dart';
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_fallback_choice.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/utils/toolbar_button_id_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/configured_toolbar_buttons_preview.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_action_picker.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/reset_to_defaults_menu.dart';
import 'package:weblibre/features/settings/presentation/widgets/setting_value_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';
import 'package:weblibre/utils/ui_helper.dart';

class ContextualToolbarSettingsScreen extends HookConsumerWidget {
  const ContextualToolbarSettingsScreen({
    super.key,
    this.location = ToolbarConfigLocation.contextual,
    required this.title,
  });

  /// Which independently-configured toolbar this screen edits.
  final ToolbarConfigLocation location;

  /// App bar title, so the quick switcher variant reads distinctly.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final configs = ref.watch(toolbarButtonLayoutProvider(location));
    final search = useSettingsSearch();

    return SettingsCustomScrollScaffold(
      title: title,
      searchController: search.controller,
      searchHintText: l10n.settings_contextualToolbarSearchHint,
      actions: [
        ResetToDefaultsMenu(
          onReset: () => unawaited(
            reportFailedToolbarEdit(
              context,
              ref
                  .read(toolbarButtonLayoutProvider(location).notifier)
                  .resetToDefaults(),
            ),
          ),
        ),
      ],
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _ToolbarPreviewDelegate(
            configs: configs.value,
            location: location,
          ),
        ),
        ToolbarButtonConfigEditor(
          location: location,
          query: search.normalizedQuery,
          rawQuery: search.rawQuery,
        ),
      ],
    );
  }
}

/// The buttons of the toolbar at [location]: the enabled ones in their order,
/// then the disabled ones, each reorderable and configurable.
///
/// A sliver, so it can sit in the button settings screen and in the Toolbar &
/// Layout editor's sheet alike.
class ToolbarButtonConfigEditor extends HookConsumerWidget {
  const ToolbarButtonConfigEditor({
    super.key,
    required this.location,
    this.query = '',
    this.rawQuery = '',
  });

  /// Which independently-configured toolbar this edits.
  final ToolbarConfigLocation location;

  /// The normalized search query, empty to list every button.
  final String query;

  /// The query as typed, for the "nothing matches" messages.
  final String rawQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final configs = ref.watch(toolbarButtonLayoutProvider(location));

    final settings = ref.watch(storedGeneralSettingsProvider);

    bool matchesQuery(ToolbarButtonConfig config) {
      if (query.isEmpty) return true;
      final def = toolbarButtonRegistryById[config.buttonId];
      if (def == null) return false;
      return matchesSettingsSearch(query, [
        def.spec.id.label(context),
        ...def.spec.id.longPressActions(context, settings),
        config.buttonId,
      ]);
    }

    final visibleConfigs = useMemoized(
      () => configs.value
          .where((c) => c.isVisible)
          .where(matchesQuery)
          .toList(growable: false),
      [configs, query],
    );
    // A switched-off button is offered only while the feature its action
    // belongs to is shown, like the action pickers (`shownBrowserActions`).
    // One already on the toolbar stays listed so it can still be taken off.
    bool offered(ToolbarButtonConfig config) =>
        ToolbarButtonId.values.asNameMap()[config.buttonId]?.action?.isShownIn(
          settings,
        ) ??
        true;
    final hiddenConfigs = useMemoized(
      () => configs.value
          .where((c) => !c.isVisible)
          .where(offered)
          .where(matchesQuery)
          .toList(growable: false),
      [configs, query, settings],
    );

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _SectionLabel(
              label: l10n.settings_contextualToolbarEnabledSection,
            ),
          ),
        ),
        if (visibleConfigs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                query.isEmpty
                    ? l10n.settings_contextualToolbarNoEnabledButtons
                    : l10n.settings_contextualToolbarNoEnabledButtonsMatch(
                        rawQuery,
                      ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverReorderableList(
            itemCount: visibleConfigs.length,
            onReorderItem: (oldIndex, newIndex) =>
                _onReorder(context, ref, visibleConfigs, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final config = visibleConfigs[index];
              return _ToolbarButtonConfigTile(
                key: ValueKey(config.buttonId),
                index: index,
                config: config,
                location: location,
              );
            },
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _SectionLabel(
              label: l10n.settings_contextualToolbarDisabledSection,
            ),
          ),
        ),
        if (hiddenConfigs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                query.isEmpty
                    ? l10n.settings_contextualToolbarAllButtonsEnabled
                    : l10n.settings_contextualToolbarNoDisabledButtonsMatch(
                        rawQuery,
                      ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverReorderableList(
            itemCount: hiddenConfigs.length,
            onReorderItem: (oldIndex, newIndex) =>
                _onReorder(context, ref, hiddenConfigs, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final config = hiddenConfigs[index];
              return _ToolbarButtonConfigTile(
                key: ValueKey(config.buttonId),
                index: index,
                config: config,
                location: location,
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  /// [configs] is the list as shown, search and offered filter applied;
  /// [newIndex] counts after the moved button's removal.
  void _onReorder(
    BuildContext context,
    WidgetRef ref,
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex == newIndex) return;
    unawaited(
      reportFailedToolbarEdit(
        context,
        ref
            .read(toolbarButtonLayoutProvider(location).notifier)
            .move([for (final c in configs) c.buttonId], oldIndex, newIndex),
      ),
    );
  }
}

/// Waits for [edit], a change made through [ToolbarButtonLayout], and tells
/// the user when it could not be saved. The editor has already gone back to
/// what is stored by then.
///
/// [context] is resolved before the wait: the widget that made the change is
/// often gone once it fails (a tile shown or hidden moves to the other list).
Future<void> reportFailedToolbarEdit(
  BuildContext context,
  Future<void> edit,
) async {
  final showError = errorMessengerFor(context);
  final message = AppLocalizations.of(
    context,
  ).settings_contextualToolbarSaveFailed;
  try {
    await edit;
  } catch (error, stackTrace) {
    logger.e(
      'Failed to save the toolbar buttons',
      error: error,
      stackTrace: stackTrace,
    );
    showError(message);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ToolbarButtonConfigTile extends HookConsumerWidget {
  const _ToolbarButtonConfigTile({
    super.key,
    required this.index,
    required this.config,
    required this.location,
  });

  final int index;
  final ToolbarButtonConfig config;
  final ToolbarConfigLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = toolbarButtonRegistryById[config.buttonId];
    if (def == null) return const SizedBox.shrink();
    ToolbarButtonLayout layout() =>
        ref.read(toolbarButtonLayoutProvider(location).notifier);
    void save(Future<void> edit) =>
        unawaited(reportFailedToolbarEdit(context, edit));

    final isVisible = config.isVisible;
    final hasStatefulFallback =
        def.isPrimaryAvailable != null || def.spec.defaultFallback != null;

    // Fallbacks and long-press actions are advanced
    // (`layout.contextual_toolbar_advanced`), grayed out while it is hidden.
    // One the user changed does not apply then, and says so.
    final defaultFallbackId = defaultToolbarButtonConfigsFor(
      location,
    ).value.firstWhereOrNull((c) => c.buttonId == config.buttonId)?.fallbackId;
    final fallbackChanged = config.fallbackId != defaultFallbackId;

    final fallbackOptions = toolbarButtonRegistry
        .where(
          (d) =>
              d.spec.id.name != config.buttonId && d.spec.canBeFallbackTarget,
        )
        .toList();

    final longPressActions = def.spec.id.longPressActions(
      context,
      ref.watch(storedGeneralSettingsProvider),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Same card treatment as the container list, the other reorderable card
    // list in the app.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        // Keep a Material ancestor when the tile moves into the drag overlay.
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(def.icon, color: colorScheme.onSurface),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        def.spec.id.label(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch.adaptive(
                      value: isVisible,
                      onChanged: (v) => save(
                        layout().setVisibility(config.buttonId, visible: v),
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.drag_handle,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                // The settings take the card's full width; the right inset
                // matches the left one past the drag handle's own padding.
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasStatefulFallback)
                        HiddenFeatureGate.feature(
                          FeatureId.layoutContextualToolbarAdvanced,
                          hiddenSettings: fallbackChanged
                              ? const [HiddenSetting.toolbarButtons]
                              : const [],
                          child: _FallbackPicker(
                            current: ToolbarFallbackChoice.fromStored(
                              config.fallbackId,
                            ),
                            options: fallbackOptions,
                            onChanged: (newFallback) => save(
                              layout().setFallback(
                                config.buttonId,
                                newFallback.toStoredFallbackId(),
                              ),
                            ),
                          ),
                        ),
                      HiddenFeatureGate.feature(
                        FeatureId.layoutContextualToolbarAdvanced,
                        hiddenSettings: config.longPressAction != null
                            ? const [HiddenSetting.toolbarButtons]
                            : const [],
                        child: _LongPressPicker(
                          builtInActions: longPressActions,
                          current: config.longPressAction,
                          onChanged: (action) => save(
                            layout().setLongPress(config.buttonId, action),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chooses what holding the button does: its own built-in long press
/// ([builtInActions], possibly nothing) or any [BrowserAction].
class _LongPressPicker extends ConsumerWidget {
  const _LongPressPicker({
    required this.builtInActions,
    required this.current,
    required this.onChanged,
  });

  final List<String> builtInActions;
  final BrowserAction? current;
  final ValueChanged<BrowserAction?> onChanged;

  /// The button's own long press, named by what it does rather than as a
  /// generic "default".
  UnsetActionOption _builtInOption(AppLocalizations l10n) =>
      builtInActions.isEmpty
      ? (
          title: l10n.settings_longPressNoneTitle,
          description: l10n.settings_longPressNoneDescription,
          icon: Icons.block,
        )
      : (
          title: builtInActions.join(', '),
          description: l10n.settings_longPressDefaultDescription,
          icon: Icons.touch_app_outlined,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final builtIn = _builtInOption(l10n);

    return SettingValueTile(
      padding: _settingPadding,
      icon: Icons.touch_app_outlined,
      title: l10n.settings_longPressTitle,
      description: l10n.settings_longPressDescription,
      value: current?.label(context) ?? builtIn.title,
      valueIcon: current?.icon ?? builtIn.icon,
      onTap: () async {
        final picked = await showOptionalBrowserActionPicker(
          context,
          ref,
          title: l10n.settings_longPressTitle,
          selected: current,
          unsetOption: builtIn,
        );
        if (picked != null && picked.action != current) {
          onChanged(picked.action);
        }
      },
    );
  }
}

/// Chooses the button that takes this one's place while its own action is
/// unavailable, or none to show it greyed out.
///
/// Picked from the long press's list, under the names of the actions the
/// buttons do. A replacement is still a button, so the list only holds the
/// actions of buttons that can stand in.
class _FallbackPicker extends ConsumerWidget {
  const _FallbackPicker({
    required this.current,
    required this.options,
    required this.onChanged,
  });

  final ToolbarFallbackChoice current;
  final List<ToolbarButtonDefinition> options;
  final ValueChanged<ToolbarFallbackChoice> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentId = current.resolveRuntimeFallbackId();
    final currentDef = currentId == null
        ? null
        : toolbarButtonRegistryById[currentId];
    final currentLabel = currentId == null
        ? l10n.settings_fallbackGreyOutLabel
        : (currentDef?.spec.id.label(context) ?? currentId);

    return SettingValueTile(
      padding: _settingPadding,
      icon: Icons.swap_horiz,
      title: l10n.settings_fallbackIfUnavailableTitle,
      description: l10n.settings_fallbackIfUnavailableDescription,
      value: currentLabel,
      valueIcon: currentDef?.icon ?? Icons.block,
      onTap: () async {
        final optionActions = {for (final def in options) ?def.spec.id.action};
        final picked = await showOptionalBrowserActionPicker(
          context,
          ref,
          title: l10n.settings_fallbackIfUnavailableTitle,
          selected: currentDef?.spec.id.action,
          unsetOption: (
            title: l10n.settings_fallbackGreyOutLabel,
            description: l10n.settings_fallbackGreyOutDescription,
            icon: Icons.block,
          ),
          // In the order the long press lists them.
          actions: BrowserAction.values.where(optionActions.contains).toList(),
        );
        if (picked == null) return;

        final buttonId = toolbarButtonIdsByAction[picked.action];
        final choice = buttonId == null
            ? ToolbarFallbackNone()
            : ToolbarFallbackButton(buttonId: buttonId.name);
        if (choice != current) onChanged(choice);
      },
    );
  }
}

/// The card already pads its sides, so a setting only needs room above and
/// below; its icon then lines up under the button's own.
const _settingPadding = EdgeInsets.symmetric(vertical: 8);

class _ToolbarPreviewDelegate extends SliverPersistentHeaderDelegate {
  const _ToolbarPreviewDelegate({
    required this.configs,
    required this.location,
  });

  final List<ToolbarButtonConfig> configs;
  final ToolbarConfigLocation location;

  static const _previewHeight = BrowserTabBar.contextualToolabarHeight;

  @override
  double get minExtent => _previewHeight;
  @override
  double get maxExtent => _previewHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: maxExtent,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: ConfiguredToolbarButtonsPreview(
          configs: configs,
          location: location,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ToolbarPreviewDelegate old) =>
      old.configs != configs || old.location != location;
}
