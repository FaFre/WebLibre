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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_title.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ContainerListScreen extends HookConsumerWidget {
  const ContainerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(watchContainersWithCountProvider);
    final selectedContainer = ref.watch(selectedContainerProvider);
    final repository = ref.watch(containerRepositoryProvider.notifier);

    Future<void> setSelectedContainer(ContainerDataWithCount container) async {
      final result = await ref
          .read(selectedContainerProvider.notifier)
          .setContainerId(container.id);

      if (context.mounted && result == SetContainerResult.success) {
        await ensureProxyStartedForContainer(context, ref, container);
      }
    }

    Future<void> editContainer(ContainerDataWithCount container) async {
      await ContainerEditRoute(
        containerData: jsonEncode(container.toJson()),
      ).push(context);
    }

    Widget buildList(List<ContainerDataWithCount> containers) {
      return CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Containers')),
          if (containers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No containers yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverReorderableList(
                itemCount: containers.length,
                onReorderItem: (oldIndex, newIndex) {
                  unawaited(
                    repository.reorderContainer(containers, oldIndex, newIndex),
                  );
                },
                itemBuilder: (context, index) {
                  final container = containers[index];
                  final isSelected = container.id == selectedContainer;
                  return Padding(
                    key: ValueKey(container.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ContainerCard(
                      container: container,
                      index: index,
                      isSelected: isSelected,
                      onTap: () => editContainer(container),
                      onSelect: isSelected
                          ? () => ref
                                .read(selectedContainerProvider.notifier)
                                .clearContainer()
                          : () => setSelectedContainer(container),
                    ),
                  );
                },
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
                id: 'loading-$index',
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

class _ContainerCard extends HookConsumerWidget {
  const _ContainerCard({
    required this.container,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.onSelect,
  });

  final ContainerDataWithCount container;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final containerColor = container.color;
    final tabCount = container.tabCount ?? 0;
    final palette = ContainerColors.palette(context, containerColor);
    final proxyOptions = ref.watch(proxyConnectionOptionsProvider);
    final proxyOptionsState = ref.watch(singboxProxyProfilesRepositoryProvider);
    final proxyOptionsLoading =
        proxyOptionsState.isLoading && !proxyOptionsState.hasValue;

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
                            child: ContainerTitle(container: container),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _ContainerInfoChip(
                                icon: Icons.tab_outlined,
                                label:
                                    '$tabCount ${tabCount == 1 ? 'tab' : 'tabs'}',
                              ),
                              if (container.metadata.contextualIdentity != null)
                                const _ContainerInfoChip(
                                  icon: Icons.cookie_outlined,
                                  label: 'Isolated',
                                ),
                              if (container.metadata.proxyConnectionId != null)
                                _ContainerInfoChip(
                                  icon: Icons.route_outlined,
                                  label: proxyConnectionTitle(
                                    proxyOptions,
                                    container.metadata.proxyConnectionId!,
                                    isLoading: proxyOptionsLoading,
                                  ),
                                ),
                              if (container.metadata.clearDataOnExit)
                                const _ContainerInfoChip(
                                  icon: Icons.cleaning_services_outlined,
                                  label: 'Clear on exit',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Icon(
                          Icons.drag_indicator,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
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
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: onSelect,
                      icon: Icon(isSelected ? Icons.close : Icons.check),
                      label: Text(isSelected ? 'Unselect' : 'Select'),
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

class _ContainerInfoChip extends StatelessWidget {
  const _ContainerInfoChip({required this.icon, required this.label});

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
