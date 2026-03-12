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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/repositories/contextual_toolbar_config_repository.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_fallback_choice.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

class ContextualToolbarSettingsScreen extends HookConsumerWidget {
  const ContextualToolbarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(effectiveToolbarButtonConfigsProvider);
    final repository = ref.watch(contextualToolbarConfigRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Toolbar'),
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
                onPressed: () => _resetToDefaults(ref),
                child: const Text('Reset to Defaults'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _ToolbarPreviewDelegate(configs: configs.value),
            ),
            SliverToBoxAdapter(
              child: ListTile(
                title: Text(
                  'Button Order',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            SliverReorderableList(
              itemCount: configs.value.length,
              onReorder: (oldIndex, newIndex) =>
                  _onReorder(configs.value, oldIndex, newIndex, repository),
              itemBuilder: (context, index) {
                final config = configs.value[index];
                return _ToolbarButtonConfigTile(
                  key: ValueKey(config.buttonId),
                  index: index,
                  config: config,
                  repository: repository,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ({String movedId, int targetIndex}) _resolveToolbarReorder(
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int newIndex,
  ) {
    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }
    targetIndex = targetIndex.clamp(0, configs.length - 1);
    return (movedId: configs[oldIndex].buttonId, targetIndex: targetIndex);
  }

  void _onReorder(
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int newIndex,
    ContextualToolbarConfigRepository repository,
  ) {
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
      ),
    );
  }

  Future<void> _reorderViaDb(
    ContextualToolbarConfigRepository repository,
    List<ToolbarButtonConfig> configs,
    int oldIndex,
    int targetIndex,
    String movedId,
  ) async {
    final String orderKey;
    if (targetIndex <= 0) {
      orderKey = await repository.generateLeadingOrderKey();
    } else if (targetIndex >= configs.length - 1) {
      orderKey = await repository.generateTrailingOrderKey();
    } else if (targetIndex < oldIndex) {
      orderKey =
          await repository.generateOrderKeyAfterButtonId(
            configs[targetIndex - 1].buttonId,
          ) ??
          await repository.generateLeadingOrderKey();
    } else {
      orderKey = await repository.generateOrderKeyBeforeButtonId(
        configs[targetIndex + 1].buttonId,
      );
    }
    await repository.assignOrderKey(movedId, orderKey: orderKey);
  }

  Future<void> _resetToDefaults(WidgetRef ref) async {
    final repository = ref.read(contextualToolbarConfigRepositoryProvider);
    await repository.replaceAll(defaultToolbarButtonConfigs.value);
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
  final ContextualToolbarConfigRepository repository;

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

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(def.icon),
        title: Text(def.label),
        subtitle: hasStatefulFallback
            ? _FallbackPicker(
                current: ToolbarFallbackChoice.fromStored(config.fallbackId),
                options: fallbackOptions,
                onChanged: (newFallback) => repository.assignFallback(
                  config.buttonId,
                  (newFallback ?? ToolbarFallbackNone()).toStoredFallbackId(),
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: isVisible,
              onChanged: (v) =>
                  repository.assignVisibility(config.buttonId, visible: v),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return DropdownButton<ToolbarFallbackChoice>(
      value: current,
      hint: const Text('No fallback'),
      isExpanded: true,
      underline: const SizedBox.shrink(),
      items: [
        DropdownMenuItem(
          value: ToolbarFallbackNone(),
          child: const Text('No fallback'),
        ),
        for (final opt in options)
          DropdownMenuItem(
            value: ToolbarFallbackButton(buttonId: opt.spec.id.name),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(opt.icon, size: 16),
                const SizedBox(width: 8),
                Text(opt.label),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ToolbarPreviewDelegate extends SliverPersistentHeaderDelegate {
  const _ToolbarPreviewDelegate({required this.configs});

  final List<ToolbarButtonConfig> configs;

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
        child: _ToolbarPreview(configs: configs),
      ),
    );
  }

  @override
  bool shouldRebuild(_ToolbarPreviewDelegate old) => old.configs != configs;
}

class _ToolbarPreview extends ConsumerWidget {
  const _ToolbarPreview({required this.configs});

  final List<ToolbarButtonConfig> configs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleConfigs = configs.where((c) => c.isVisible).toList();

    final scope = ContextualToolbarScope(
      selectedTabId: null,
      displayedSheet: null,
      tabState: null,
      isPreview: true,
    );

    final buttons = visibleConfigs.map((config) {
      final def = toolbarButtonRegistryById[config.buttonId];
      if (def == null) return const SizedBox.shrink();
      return def.builder(scope, context, ref);
    }).toList();

    return ContextualToolbarView(buttons: buttons);
  }
}
