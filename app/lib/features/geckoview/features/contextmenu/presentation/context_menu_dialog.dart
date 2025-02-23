import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/copy_email.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/copy_image.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/copy_image_location.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/copy_link.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/launch_external.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/open_image_new_tab.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/open_new_tab.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/save_file.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/save_image.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/share_email.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/share_image.dart';
import 'package:lensai/features/geckoview/features/contextmenu/presentation/candidates/share_link.dart';
import 'package:lensai/presentation/hooks/cached_future.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ContextMenuDialog extends HookConsumerWidget {
  final HitResult hitResult;

  const ContextMenuDialog({super.key, required this.hitResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleDialog(
      title: AutoSizeText(
        hitResult.getTitle(),
        minFontSize: 18,
        maxFontSize: DefaultTextStyle.of(context).style.fontSize,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
      children: [
        if (OpenInNewTab.isSupported(hitResult))
          OpenInNewTab(hitResult: hitResult),
        if (CopyLink.isSupported(hitResult)) CopyLink(hitResult: hitResult),
        if (SaveFile.isSupported(hitResult)) SaveFile(hitResult: hitResult),
        if (ShareLink.isSupported(hitResult)) ShareLink(hitResult: hitResult),
        if (ShareImage.isSupported(hitResult)) ShareImage(hitResult: hitResult),
        if (OpenImageInNewTab.isSupported(hitResult))
          OpenImageInNewTab(hitResult: hitResult),
        if (CopyImage.isSupported(hitResult)) CopyImage(hitResult: hitResult),
        if (SaveImage.isSupported(hitResult)) SaveImage(hitResult: hitResult),
        if (CopyImageLocation.isSupported(hitResult))
          CopyImageLocation(hitResult: hitResult),
        if (ShareEmail.isSupported(hitResult)) ShareEmail(hitResult: hitResult),
        if (CopyEmail.isSupported(hitResult)) CopyEmail(hitResult: hitResult),
        HookBuilder(
          builder: (context) {
            final isSupported = useCachedFuture(
              // ignore: discarded_futures useFuture
              () => LaunchExternal.isSupported(hitResult),
            );

            if (isSupported.data == false) {
              return const SizedBox.shrink();
            }

            return Skeletonizer(
              enabled: isSupported.connectionState != ConnectionState.done,
              child: LaunchExternal(hitResult: hitResult),
            );
          },
        ),
      ],
    );
  }
}
