import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/domain/services/generic_website.dart';
import 'package:lensai/presentation/hooks/cached_future.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UrlIcon extends HookConsumerWidget {
  final double iconSize;
  final List<Uri> urlList;

  const UrlIcon(this.urlList, {required this.iconSize, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = useCachedFuture(
      () =>
      // ignore: discarded_futures
      ref.read(genericWebsiteServiceProvider.notifier).getUrlIcon(urlList),
      [urlList],
    );

    return Skeletonizer(
      enabled: !icon.hasData,
      child: SizedBox.square(
        dimension: iconSize,
        child:
            (icon.data != null)
                ? RepaintBoundary(
                  child: RawImage(
                    image: icon.data?.image.value,
                    height: iconSize,
                    width: iconSize,
                    fit: BoxFit.fill,
                  ),
                )
                : Icon(MdiIcons.web, size: iconSize),
      ),
    );
  }
}
