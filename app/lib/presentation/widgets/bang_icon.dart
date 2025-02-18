import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/domain/services/generic_website.dart';
import 'package:lensai/presentation/hooks/cached_future.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UrlIcon extends HookConsumerWidget {
  final double iconSize;
  final Uri url;

  const UrlIcon(this.url, {required this.iconSize, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = useCachedFuture(
      () async =>
          ref.read(genericWebsiteServiceProvider.notifier).getUrlIcon(url),
      [url],
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
