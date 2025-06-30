import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';

class TabIcon extends HookConsumerWidget {
  final TabState state;

  final double iconSize;

  const TabIcon({super.key, required this.state, this.iconSize = 16});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = useCachedFuture(() async {
      if (state.icon != null) {
        return state.icon!.value;
      }

      final icon = await ref
          .read(genericWebsiteServiceProvider.notifier)
          .getCachedIcon(state.url);

      return icon?.image.value;
    }, [state.icon, state.url]);

    return Skeletonizer(
      enabled:
          icon.connectionState != ConnectionState.done && icon.data == null,
      child: Skeleton.replace(
        replacement: Bone.icon(size: iconSize),
        child: RepaintBoundary(
          child: RawImage(image: icon.data, height: iconSize, width: iconSize),
        ),
      ),
    );
  }
}
