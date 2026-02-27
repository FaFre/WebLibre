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

import 'package:fading_scroll/fading_scroll.dart';
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
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ContainerSelectionScreen extends HookConsumerWidget {
  const ContainerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(watchContainersWithCountProvider);
    final selectedContainerId = ref.watch(selectedContainerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Container')),
      body: Skeletonizer(
        enabled: containersAsync.isLoading,
        child: containersAsync.when(
          skipLoadingOnReload: true,
          data: (containers) => FadingScroll(
            fadingSize: 25,
            builder: (context, controller) {
              return ListView.builder(
                controller: controller,
                itemCount: containers.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTileTheme(
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: ListTile(
                        selected: selectedContainerId == null,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(MdiIcons.folderHidden),
                        ),
                        title: const Text('Unassigned'),
                        onTap: () {
                          context.pop<ContainerSelectionResult>(
                            const ContainerSelectionResult.unassigned(),
                          );
                        },
                      ),
                    );
                  }

                  final container = containers[index - 1];
                  return ContainerListTile(
                    container,
                    isSelected: container.id == selectedContainerId,
                    onTap: () {
                      context.pop<ContainerSelectionResult>(
                        ContainerSelectionResult.selected(container.id),
                      );
                    },
                  );
                },
              );
            },
          ),
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: 'Failed to load containers',
              exception: error,
              onRetry: () => ref.invalidate(watchContainersWithCountProvider),
            ),
          ),
          loading: () => ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => ContainerListTile(
              ContainerData(id: Namespace.nil.value, color: Colors.transparent),
              isSelected: false,
              onTap: null,
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
