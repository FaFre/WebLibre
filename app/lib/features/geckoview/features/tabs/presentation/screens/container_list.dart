import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';

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
              skipLoadingOnReload: true,
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
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                if (container.id != selectedContainer)
                                  SlidableAction(
                                    onPressed: (context) async {
                                      final result = await ref
                                          .read(
                                            selectedContainerProvider.notifier,
                                          )
                                          .setContainerId(container.id);

                                      if (context.mounted &&
                                          result ==
                                              SetContainerResult
                                                  .successHasProxy) {
                                        await ref
                                            .read(
                                              startProxyControllerProvider
                                                  .notifier,
                                            )
                                            .maybeStartProxy(context);
                                      }
                                    },
                                    foregroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                    backgroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                    icon: Icons.check,
                                    label: 'Select',
                                  )
                                else
                                  SlidableAction(
                                    onPressed: (context) {
                                      ref
                                          .read(
                                            selectedContainerProvider.notifier,
                                          )
                                          .clearContainer();
                                    },
                                    foregroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                    backgroundColor:
                                        Theme.of(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final initialColor =
              await ref
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
