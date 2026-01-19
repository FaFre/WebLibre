/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';

class TabIcon extends HookConsumerWidget {
  final TabState tabState;

  final double iconSize;

  const TabIcon({super.key, required this.tabState, required this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = useCachedFuture(() async {
      final faviconIcon = tabState.icon?.value;

      if (faviconIcon != null) {
        return faviconIcon;
      }

      final icon = await ref
          .read(genericWebsiteServiceProvider.notifier)
          .getCachedIcon(tabState.url);

      return icon?.image.value;
    }, [tabState.icon, tabState.url]);

    return Skeletonizer(
      enabled: icon.connectionState != ConnectionState.done,
      child: Skeleton.replace(
        replacement: Bone.icon(size: iconSize),
        child: RepaintBoundary(
          child:
              icon.data.mapNotNull(
                (icon) =>
                    RawImage(image: icon, height: iconSize, width: iconSize),
              ) ??
              Icon(MdiIcons.web, size: iconSize),
        ),
      ),
    );
  }
}
