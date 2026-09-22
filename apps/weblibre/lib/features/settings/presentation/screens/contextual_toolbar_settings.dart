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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/toolbar_button_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_fallback_choice.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_action_picker.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

class ContextualToolbarSettingsScreen extends HookConsumerWidget {
  const ContextualToolbarSettingsScreen({
    super.key,
    this.location = ToolbarConfigLocation.contextual,
    this.title = 'Customize Toolbar',
  });

  /// Which independently-configured toolbar this screen edits.
  final ToolbarConfigLocation location;

  /// App bar title, so the quick switcher variant reads distinctly.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(effectiveToolbarButtonConfigsProvider(location));
    final repository = ref.watch(toolbarConfigRepositoryProvider(location));
    final search = useSettingsSearch();
    final query = search.normalizedQuery;

    bool matchesQuery(ToolbarButtonConfig config) {
      if (query.isEmpty) return true;
      final def = toolbarButtonRegistryById[config.buttonId];
      if (def == null) return false;
      return matchesSettingsSearch(query, [
        def.label,
        ...def.longPressActions,
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
    final hiddenConfigs = useMemoized(
      () => configs.value
          .where((c) => !c.isVisible)
          .where(matchesQuery)
          .toList(growable: false),
      [configs, query],
    );

    return SettingsCustomScrollScaffold(
      title: title,
      searchController: search.controller,
      searchHintText: 'Search toolbar buttons',
      actions: [
        MenuAnchor(
          builder: (context, controller, child) => IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.more_vert),
          ),
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.restore),
              onPressed: () => _resetToDefaults(ref, location),
              child: const Text('Reset to Defaults'),
            ),
          ],
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
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(child: _SectionLabel(label: 'Enabled')),
        ),
        if (visibleConfigs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                query.isEmpty
                    ? 'No enabled buttons. Toggle a button below to enable it.'
                    : 'No enabled buttons match "${search.rawQuery}".',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverReorderableList(
            itemCount: visibleConfigs.length,
            onReorderItem: (oldIndex, newIndex) => _onReorder(
              visibleConfigs,
              oldIndex,
              newIndex,
              repository,
              isVisible: true,
            ),
            itemBuilder: (context, index) {
              final config = visibleConfigs[index];
              return _ToolbarButtonConfigTile(
                key: ValueKey(config.buttonId),
                index: index,
                config: config,
                repository: repository,
              );
            },
          ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(child: _SectionLabel(label: 'Disabled')),
        ),
        if (hiddenConfigs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                query.isEmpty
                    ? 'All buttons are enabled.'
                    : 'No disabled buttons match "${search.rawQuery}".',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverReorderableList(
            itemCount: hiddenConfigs.length,
            onReorderItem: (oldIndex, newIndex) => _onReorder(
              hiddenConfigs,
              oldIndex,
              newIndex,
              repository,
              isVisible: false,
            ),
            itemBuilder: (context, index) {
              final config = hiddenConfigs[index];
              return _ToolbarButtonConfigTile(
                key: ValueKey(config.buttonId),
                index: index,
                config: config,
                repository: repository,
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  ({String movedId, int targetIndex}) _resolveToolbarReorder(
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int newIndex,
  ) {
    final targetIndex = newIndex.clamp(0, configs.length - 1);
    return (movedId: configs[oldIndex].buttonId, targetIndex: targetIndex);
  }

  void _onReorder(
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int newIndex,
    ToolbarButtonConfigRepository repository, {
    required bool isVisible,
  }) {
    if (oldIndex == newIndex) return;
    final reorder = _resolveToolbarReorder(configs, oldIndex, newIndex);
    if (reorder.targetIndex == oldIndex) return;
    unawaited(
      _reorderViaDb(
        repository,
        configs,
        oldIndex,
        reorder.targetIndex,
        reorder.movedId,
        isVisible: isVisible,
      ),
    );
  }

  Future<void> _reorderViaDb(
    ToolbarButtonConfigRepository repository,
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int targetIndex,
    String movedId, {
    required bool isVisible,
  }) async {
    // [configs] still contains the moved item. [targetIndex] is the
    // post-removal destination index, clamped to [0, configs.length - 1].
    // Because of the clamp, `>= configs.length - 1` only fires when the user
    // dropped past the very last surviving item; `configs[targetIndex + 1]`
    // is otherwise always a valid neighbour in the original list (since the
    // moved item sits at oldIndex < targetIndex + 1 in the else branch).
    final String orderKey;
    if (targetIndex <= 0) {
      orderKey = await repository.generateLeadingOrderKey(isVisible: isVisible);
    } else if (targetIndex >= configs.length - 1) {
      orderKey = await repository.generateTrailingOrderKey(
        isVisible: isVisible,
      );
    } else if (targetIndex < oldIndex) {
      orderKey =
          await repository.generateOrderKeyAfterButtonId(
            configs[targetIndex - 1].buttonId,
            isVisible: isVisible,
          ) ??
          await repository.generateLeadingOrderKey(isVisible: isVisible);
    } else {
      orderKey = await repository.generateOrderKeyBeforeButtonId(
        configs[targetIndex + 1].buttonId,
        isVisible: isVisible,
      );
    }
    await repository.assignOrderKey(movedId, orderKey: orderKey);
  }

  Future<void> _resetToDefaults(
    WidgetRef ref,
    ToolbarConfigLocation location,
  ) async {
    final repository = ref.read(toolbarConfigRepositoryProvider(location));
    await repository.replaceAll(defaultToolbarButtonConfigsFor(location).value);
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
    required this.repository,
  });

  final int index;
  final ToolbarButtonConfig config;
  final ToolbarButtonConfigRepository repository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = toolbarButtonRegistryById[config.buttonId];
    if (def == null) return const SizedBox.shrink();

    final isVisible = config.isVisible;
    final hasStatefulFallback =
        def.isPrimaryAvailable != null || def.spec.defaultFallback != null;

    final fallbackOptions = toolbarButtonRegistry
        .where(
          (d) =>
              d.spec.id.name != config.buttonId && d.spec.canBeFallbackTarget,
        )
        .toList();

    final longPressActions = def.longPressActions;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(def.icon, color: colorScheme.onSurface),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      def.label,
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
                    onChanged: (v) => repository.assignVisibility(
                      config.buttonId,
                      visible: v,
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
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasStatefulFallback) ...[
                      _FallbackPicker(
                        current: ToolbarFallbackChoice.fromStored(
                          config.fallbackId,
                        ),
                        options: fallbackOptions,
                        onChanged: (newFallback) => repository.assignFallback(
                          config.buttonId,
                          (newFallback ?? ToolbarFallbackNone())
                              .toStoredFallbackId(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _LongPressPicker(
                      builtInActions: longPressActions,
                      current: config.longPressAction,
                      onChanged: (action) => repository.assignLongPressAction(
                        config.buttonId,
                        action,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chooses what holding the button does: its own built-in long press
/// ([builtInActions], possibly nothing) or any [BrowserAction].
class _LongPressPicker extends StatelessWidget {
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
  UnsetActionOption get _builtInOption => builtInActions.isEmpty
      ? (
          title: 'None',
          description: 'Default for this button: holding it does nothing extra',
          icon: Icons.block,
        )
      : (
          title: builtInActions.join(', '),
          description: 'Default for this button',
          icon: Icons.touch_app_outlined,
        );

  @override
  Widget build(BuildContext context) {
    final builtIn = _builtInOption;

    return _ButtonSettingRow(
      icon: Icons.touch_app_outlined,
      label: 'Long press',
      value: current?.title ?? builtIn.title,
      valueIcon: current?.icon ?? builtIn.icon,
      isCustomized: current != null,
      onTap: () async {
        final picked = await showOptionalBrowserActionPicker(
          context,
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
class _FallbackPicker extends StatelessWidget {
  const _FallbackPicker({
    required this.current,
    required this.options,
    required this.onChanged,
  });

  final ToolbarFallbackChoice current;
  final List<ToolbarButtonDefinition> options;
  final ValueChanged<ToolbarFallbackChoice?> onChanged;

  @override
  Widget build(BuildContext context) {
    final currentId = current.resolveRuntimeFallbackId();
    final currentDef = currentId == null
        ? null
        : toolbarButtonRegistryById[currentId];
    final currentLabel = currentId == null
        ? 'Grey out'
        : (currentDef?.label ?? currentId);
    final checkColor = Theme.of(context).colorScheme.primary;

    Widget? check(bool selected) =>
        selected ? Icon(Icons.check, size: 18, color: checkColor) : null;

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.block, size: 18),
          trailingIcon: check(currentId == null),
          onPressed: () => onChanged(ToolbarFallbackNone()),
          child: const Text('Grey out'),
        ),
        for (final opt in options)
          MenuItemButton(
            leadingIcon: Icon(opt.icon, size: 18),
            trailingIcon: check(currentId == opt.spec.id.name),
            onPressed: () =>
                onChanged(ToolbarFallbackButton(buttonId: opt.spec.id.name)),
            child: Text(opt.label),
          ),
      ],
      builder: (context, controller, _) => _ButtonSettingRow(
        icon: Icons.swap_horiz,
        label: 'If unavailable',
        value: currentLabel,
        valueIcon: currentDef?.icon ?? Icons.block,
        isCustomized: currentId != null,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// One setting inside a toolbar button's card: [icon] and [label] as a
/// caption, the current [value] in a filled, tappable field below. Both
/// settings share it so they line up and read the same way (issue #469 was the
/// two being mistaken for each other).
class _ButtonSettingRow extends StatelessWidget {
  const _ButtonSettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueIcon,
    required this.isCustomized,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;

  /// What [value] stands for: the fallback button's icon, or the action's.
  final IconData valueIcon;

  /// Whether [value] is something other than the button's default, which is
  /// then shown in the primary color.
  final bool isCustomized;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = colorScheme.onSurfaceVariant;
    final valueColor = isCustomized
        ? colorScheme.primary
        : colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: mutedColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: mutedColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Material(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Icon(valueIcon, size: 18, color: valueColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: valueColor,
                        fontWeight: isCustomized ? FontWeight.w500 : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: mutedColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
        child: _ToolbarPreview(configs: configs, location: location),
      ),
    );
  }

  @override
  bool shouldRebuild(_ToolbarPreviewDelegate old) =>
      old.configs != configs || old.location != location;
}

class _ToolbarPreview extends ConsumerWidget {
  const _ToolbarPreview({required this.configs, required this.location});

  final List<ToolbarButtonConfig> configs;
  final ToolbarConfigLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleConfigs = configs.where((c) => c.isVisible).toList();

    final scope = ContextualToolbarScope(
      selectedTabId: null,
      displayedSheet: null,
      tabState: null,
      isPreview: true,
      location: location,
    );

    final buttons = visibleConfigs.map((config) {
      final def = toolbarButtonRegistryById[config.buttonId];
      if (def == null) return const SizedBox.shrink();
      return def.builder(scope, context, ref);
    }).toList();

    return ContextualToolbarView(buttons: buttons);
  }
}
