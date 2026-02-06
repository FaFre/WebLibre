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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ContainerSelectionScreen extends HookConsumerWidget {
  const ContainerSelectionScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(watchContainersWithCountProvider);
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
                  final container = containers[index];
                  return ContainerListTile(
                    container,
                    isSelected: false,
                    onTap: () {
                      context.pop<String?>(container.id);
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
              ContainerData(id: 'null', color: Colors.transparent),
              isSelected: false,
              onTap: null,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final initialColor = await ref
              .read(containerRepositoryProvider.notifier)
              .unusedRandomContainerColor();

          if (context.mounted) {
            await ContainerCreateRoute(
              containerData: jsonEncode(
                ContainerData(id: uuid.v7(), color: initialColor).toJson(),
              ),
            ).push(context);
          }
        },
        label: const Text('Container'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
