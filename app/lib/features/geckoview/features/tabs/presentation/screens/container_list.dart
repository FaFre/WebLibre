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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ContainerListScreen extends HookConsumerWidget {
  const ContainerListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(watchContainersWithCountProvider);
    final selectedContainer = ref.watch(selectedContainerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Containers')),
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
                  final container = containers[index];
                  return Slidable(
                    key: ValueKey(container.id),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        if (container.id != selectedContainer)
                          SlidableAction(
                            onPressed: (context) async {
                              final result = await ref
                                  .read(selectedContainerProvider.notifier)
                                  .setContainerId(container.id);

                              if (context.mounted &&
                                  result ==
                                      SetContainerResult.successHasProxy) {
                                await ref
                                    .read(startProxyControllerProvider.notifier)
                                    .maybeStartProxy(context);
                              }
                            },
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            icon: Icons.check,
                            label: 'Select',
                          )
                        else
                          SlidableAction(
                            onPressed: (context) {
                              ref
                                  .read(selectedContainerProvider.notifier)
                                  .clearContainer();
                            },
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            icon: Icons.close,
                            label: 'Unselect',
                          ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            await ref
                                .read(containerRepositoryProvider.notifier)
                                .deleteContainer(container.id);
                          },
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onErrorContainer,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ContainerListTile(
                      container,
                      isSelected: container.id == selectedContainer,
                      onTap: () async {
                        await ContainerEditRoute(
                          containerData: jsonEncode(container.toJson()),
                        ).push(context);
                      },
                    ),
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
              ContainerData(id: 'null', color: Colors.transparent),
              onTap: null,
              isSelected: false,
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
