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

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/enums.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_selection_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_title.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ContainerSelectionScreen extends HookConsumerWidget {
  const ContainerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(watchContainersWithCountProvider);
    final selectedContainerId = ref.watch(selectedContainerProvider);

    Widget buildList(List<ContainerDataWithCount> containers) {
      return CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Select Container')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _UnassignedSelectionCard(
                      isSelected: selectedContainerId == null,
                      onTap: () {
                        context.pop<ContainerSelectionResult>(
                          const ContainerSelectionResult.unassigned(),
                        );
                      },
                    ),
                  );
                }

                final container = containers[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SelectionContainerCard(
                    container: container,
                    isSelected: container.id == selectedContainerId,
                    onTap: () {
                      context.pop<ContainerSelectionResult>(
                        ContainerSelectionResult.selected(container.id),
                      );
                    },
                  ),
                );
              }, childCount: containers.length + 1),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Skeletonizer(
        enabled: containersAsync.isLoading,
        child: containersAsync.when(
          skipLoadingOnReload: true,
          data: buildList,
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: 'Failed to load containers',
              exception: error,
              onRetry: () => ref.invalidate(watchContainersWithCountProvider),
            ),
          ),
          loading: () => buildList(
            List.generate(
              3,
              (index) => ContainerDataWithCount(
                id: Namespace.nil.value,
                name: 'Container',
                color: Colors.transparent,
                orderKey: '',
                tabCount: 0,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newContainer = await ref
              .read(containerRepositoryProvider.notifier)
              .createNewContainer();

          if (!context.mounted) return;

          await ContainerCreateRoute(
            containerData: jsonEncode(newContainer.toJson()),
          ).push(context);
        },
        label: const Text('Container'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _UnassignedSelectionCard extends StatelessWidget {
  const _UnassignedSelectionCard({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = colorScheme.primary;
    final palette = ContainerColors.palette(context, accentColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? palette.surfaceHighColor
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.fromBorderSide(palette.borderSide)
            : Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  child: const Icon(MdiIcons.folderHidden, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unassigned',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tabs without a container',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Chip(
                    avatar: Icon(
                      Icons.check,
                      size: 16,
                      color: palette.onContainerColor,
                    ),
                    label: const Text('Active'),
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: palette.containerColor,
                    labelStyle: TextStyle(color: palette.onContainerColor),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionContainerCard extends StatelessWidget {
  const _SelectionContainerCard({
    required this.container,
    required this.isSelected,
    required this.onTap,
  });

  final ContainerDataWithCount container;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final containerColor = container.color;
    final tabCount = container.tabCount ?? 0;
    final palette = ContainerColors.palette(context, containerColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? palette.surfaceHighColor
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.fromBorderSide(palette.borderSide)
            : Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: palette.avatarBackgroundColor,
                      foregroundColor: palette.avatarForegroundColor,
                      child: Icon(
                        resolveContainerIcon(container.metadata.iconData),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle.merge(
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            child: IconTheme.merge(
                              data: IconThemeData(color: colorScheme.onSurface),
                              child: ContainerTitle(container: container),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _SelectionInfoChip(
                                icon: Icons.tab_outlined,
                                label:
                                    '$tabCount ${tabCount == 1 ? 'tab' : 'tabs'}',
                              ),
                              if (container.metadata.contextualIdentity != null)
                                const _SelectionInfoChip(
                                  icon: Icons.cookie_outlined,
                                  label: 'Isolated',
                                ),
                              if (container.metadata.useProxy)
                                const _SelectionInfoChip(
                                  icon: Icons.route_outlined,
                                  label: 'Proxy',
                                ),
                              if (container.metadata.clearDataOnExit)
                                const _SelectionInfoChip(
                                  icon: Icons.cleaning_services_outlined,
                                  label: 'Clear on exit',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Chip(
                        avatar: Icon(
                          Icons.check,
                          size: 16,
                          color: palette.onContainerColor,
                        ),
                        label: const Text('Active'),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: palette.containerColor,
                        labelStyle: TextStyle(color: palette.onContainerColor),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionInfoChip extends StatelessWidget {
  const _SelectionInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconTheme.merge(
      data: IconThemeData(size: 14, color: theme.colorScheme.onSurfaceVariant),
      child: DefaultTextStyle.merge(
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon), const SizedBox(width: 4), Text(label)],
        ),
      ),
    );
  }
}
