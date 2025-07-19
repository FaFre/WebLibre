import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
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

    return topicAsync.when(
      skipLoadingOnReload: true,
      data: (data) =>
          data.mapNotNull(
            (name) => RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: name),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  const WidgetSpan(child: Icon(MdiIcons.creation, size: 16)),
                ],
              ),
            ),
          ) ??
          const Text('New Container'),
      error: (error, stackTrace) {
        logger.e(
          'Could not determine container name ${container.id}',
          error: error,
          stackTrace: stackTrace,
        );

        return const Text('New Container');
      },
      loading: () => const Skeletonizer(child: Text('container')),
    );
  }
}
