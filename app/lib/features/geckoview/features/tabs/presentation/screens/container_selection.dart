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

class ContainerSelectionScreen extends HookConsumerWidget {
  const ContainerSelectionScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Container')),
      body: HookConsumer(
        builder: (context, ref, child) {
          final containersAsync = ref.watch(containersWithCountProvider);

          return Skeletonizer(
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
              error: (error, stackTrace) => SizedBox.shrink(),
              loading: () => ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => ContainerListTile(
                  ContainerData(id: 'null', color: Colors.transparent),
                  isSelected: false,
                  onTap: null,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final initialColor = await ref
              .read(containerRepositoryProvider.notifier)
              .unusedRandomContainerColor();

          if (context.mounted) {
            final result = await ContainerCreateRoute(
              ContainerData(id: uuid.v7(), color: initialColor),
            ).push<ContainerData?>(context);

            if (result != null) {
              await ref
                  .read(containerRepositoryProvider.notifier)
                  .addContainer(result);
            }
          }
        },
        label: const Text('Container'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
