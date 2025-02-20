import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/core/uuid.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:lensai/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ContainerListScreen extends HookConsumerWidget {
  const ContainerListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Containers')),
      body: HookConsumer(
        builder: (context, ref, child) {
          final containersAsync = ref.watch(containersWithCountProvider);
          final selectedContainer = ref.watch(selectedContainerProvider);

          return Skeletonizer(
            enabled: containersAsync.isLoading,
            child: containersAsync.when(
              data:
                  (containers) => FadingScroll(
                    fadingSize: 25,
                    builder: (context, controller) {
                      return ListView.builder(
                        controller: controller,
                        itemCount: containers.length,
                        itemBuilder: (context, index) {
                          final container = containers[index];
                          return Slidable(
                            key: ValueKey(container.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    await ref
                                        .read(
                                          containerRepositoryProvider.notifier,
                                        )
                                        .deleteContainer(container.id);
                                  },
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                  foregroundColor:
                                      Theme.of(
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
                                if (container.id == selectedContainer) {
                                  ref
                                      .read(selectedContainerProvider.notifier)
                                      .clearContainer();
                                } else {
                                  final result = await ref
                                      .read(selectedContainerProvider.notifier)
                                      .setContainerId(container.id);

                                  if (context.mounted &&
                                      result ==
                                          SetContainerResult.successHasProxy) {
                                    await ref
                                        .read(
                                          startProxyControllerProvider.notifier,
                                        )
                                        .maybeStartProxy(context);
                                  }
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
              error: (error, stackTrace) => SizedBox.shrink(),
              loading:
                  () => ListView.builder(
                    itemCount: 3,
                    itemBuilder:
                        (context, index) => ContainerListTile(
                          ContainerData(id: 'null', color: Colors.transparent),
                          isSelected: false,
                        ),
                  ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final initialColor =
              await ref
                  .read(containerRepositoryProvider.notifier)
                  .unusedRandomContainerColor();

          if (context.mounted) {
            final result = await context.push<ContainerData?>(
              ContainerCreateRoute().location,
              extra: ContainerData(id: uuid.v7(), color: initialColor),
            );

            if (result != null) {
              await ref
                  .read(containerRepositoryProvider.notifier)
                  .addContainer(result);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
