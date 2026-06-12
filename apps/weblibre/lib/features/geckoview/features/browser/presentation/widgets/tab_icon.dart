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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/widgets/safe_raw_image.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class TabIcon extends HookConsumerWidget {
  final TabState tabState;

  final double iconSize;

  const TabIcon({super.key, required this.tabState, required this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabState.id),
    );

    final icon = useCachedFuture(() async {
      if (tabState.icon case final EquatableImage tabIcon
          when !tabIcon.isDisposed) {
        return tabIcon;
      }

      final cachedIcon = await ref
          .read(genericWebsiteServiceProvider.notifier)
          .getCachedIcon(tabState.url);

      return cachedIcon?.image;
    }, [tabState.icon, tabState.url]);

    if (sandboxSourceUri != null) {
      return UrlIcon([sandboxSourceUri], iconSize: iconSize, cacheOnly: true);
    }

    // While the icon future is still resolving, show the skeleton bone. This is
    // the only state that needs the (comparatively expensive) Skeletonizer +
    // Skeleton.replace machinery.
    if (icon.connectionState != ConnectionState.done) {
      return Skeletonizer(
        enabled: true,
        child: Skeleton.replace(
          replacement: Bone.icon(size: iconSize),
          child: SizedBox.square(dimension: iconSize),
        ),
      );
    }

    // Resolved case (hit on virtually every rebuild once the favicon is known):
    // render the image directly without wrapping it in Skeletonizer, which the
    // rebuild profiler flagged as the most-rebuilt widget in the tab bar.
    return RepaintBoundary(
      child:
          icon.data.mapNotNull(
            (image) => SafeRawImage(
              image: image,
              height: iconSize,
              width: iconSize,
              fallback: Icon(MdiIcons.web, size: iconSize),
            ),
          ) ??
          Icon(MdiIcons.web, size: iconSize),
    );
  }
}
