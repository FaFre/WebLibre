import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container_topic.dart';

class ContainerTitle extends HookConsumerWidget {
  final ContainerData container;

  const ContainerTitle({super.key, required this.container});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (container.name.isNotEmpty) {
      return Text(container.name!);
    }

    final topicAsync = ref.watch(containerTopicProvider(container.id));
    final containerHasTabs = ref.watch(
      containerTabCountProvider(
        // ignore: provider_parameters
        ContainerFilterById(containerId: container.id),
      ).select((value) => (value.valueOrNull ?? 0) > 0),
    );

    return topicAsync.when(
      data: (data) =>
          data.mapNotNull(
            (name) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: name),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  const WidgetSpan(child: Icon(MdiIcons.creation, size: 16)),
                ],
              ),
            ),
          ) ??
          Text(
            containerHasTabs ? 'Untitled' : 'Empty',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
      error: (error, stackTrace) {
        logger.e(
          'Could not determine container name ${container.id}',
          error: error,
          stackTrace: stackTrace,
        );

        return const Text('Untitled');
      },
      loading: () =>
          Skeletonizer(child: Text(topicAsync.valueOrNull ?? 'container')),
    );
  }
}
