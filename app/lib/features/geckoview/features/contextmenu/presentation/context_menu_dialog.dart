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
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/copy_email.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/copy_image.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/copy_image_location.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/copy_link.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/launch_external.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/open_image_new_tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/open_new_tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/save_file.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/save_image.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/share_email.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/share_image.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/share_link.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';

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
              [hitResult],
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
