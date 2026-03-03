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
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/open_in_container.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/open_new_tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/save_file.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/save_image.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/share_email.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/share_image.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/share_link.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/hooks/url_cleaner_controller.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/widgets/url_cleaner_tile.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/utils/ui_helper.dart';

class ContextMenuDialog extends HookConsumerWidget {
  final HitResult hitResult;

  const ContextMenuDialog({super.key, required this.hitResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final showContainerUi = settings.showContainerUi;
    final catalogAsync = ref.watch(urlCleanerCatalogServiceProvider);

    final effectiveHitResult = useState(hitResult);

    final url = hitResult.tryGetLink()?.toString();
    final isCleanable = hitResult.isHttpLink();
    final cleaner = useUrlCleanerController(
      sourceUrl: isCleanable
          ? effectiveHitResult.value.tryGetLink()?.toString()
          : null,
      rules: catalogAsync.value,
      cleanerEnabled: settings.urlCleanerEnabled,
      allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
      autoApply: settings.urlCleanerAutoApply,
      getCurrentUrl: () => effectiveHitResult.value.tryGetLink()?.toString(),
      onApplyCleanedUrl: (cleanedUrl) {
        effectiveHitResult.value = hitResult.withCleanedLink(cleanedUrl);
      },
    );

    void applyCleanUrl() {
      if (cleaner.applyCleanUrl()) {
        showInfoMessage(context, 'URL cleaned');
      }
    }

    void applySelectedTrackingRemovals(String previewUrl) {
      if (cleaner.applyPreviewUrl(previewUrl)) {
        showInfoMessage(context, 'URL preview applied');
      }
    }

    final effective = effectiveHitResult.value;
    final showCleanerTile = isCleanable && cleaner.showTile;

    return SimpleDialog(
      title: AutoSizeText(
        effective.getTitle(),
        minFontSize: 18,
        maxFontSize: DefaultTextStyle.of(context).style.fontSize,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
      children: [
        if (showCleanerTile)
          UrlCleanerTile(
            result: cleaner.result!,
            currentUrl: effective.tryGetLink()?.toString() ?? url ?? '',
            allowReferralMarketing: settings.urlCleanerAllowReferralMarketing,
            onClean: applyCleanUrl,
            onApplySelectedRemovals: applySelectedTrackingRemovals,
            applied: cleaner.applied,
          ),
        if (OpenInNewTab.isSupported(effective))
          OpenInNewTab(hitResult: effective),
        if (showContainerUi && OpenInContainer.isSupported(effective))
          OpenInContainer(hitResult: effective),
        if (CopyLink.isSupported(effective)) CopyLink(hitResult: effective),
        if (SaveFile.isSupported(effective)) SaveFile(hitResult: effective),
        if (ShareLink.isSupported(effective)) ShareLink(hitResult: effective),
        if (ShareImage.isSupported(effective)) ShareImage(hitResult: effective),
        if (OpenImageInNewTab.isSupported(effective))
          OpenImageInNewTab(hitResult: effective),
        if (CopyImage.isSupported(effective)) CopyImage(hitResult: effective),
        if (SaveImage.isSupported(effective)) SaveImage(hitResult: effective),
        if (CopyImageLocation.isSupported(effective))
          CopyImageLocation(hitResult: effective),
        if (ShareEmail.isSupported(effective)) ShareEmail(hitResult: effective),
        if (CopyEmail.isSupported(effective)) CopyEmail(hitResult: effective),
        HookBuilder(
          builder: (context) {
            final isSupported = useCachedFuture(
              // ignore: discarded_futures useFuture
              () => LaunchExternal.isSupported(effective),
              [effective],
            );

            if (isSupported.data == false) {
              return const SizedBox.shrink();
            }

            return Skeletonizer(
              enabled: isSupported.connectionState != ConnectionState.done,
              child: LaunchExternal(hitResult: effective),
            );
          },
        ),
      ],
    );
  }
}
