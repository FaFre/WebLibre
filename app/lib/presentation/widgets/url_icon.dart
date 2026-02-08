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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/widgets/safe_raw_image.dart';

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
      [EquatableValue(urlList)],
    );

    return Skeletonizer(
      enabled: icon.connectionState != ConnectionState.done,
      child: SizedBox.square(
        dimension: iconSize,
        child: (icon.data != null)
            ? RepaintBoundary(
                child: SafeRawImage(
                  image: icon.data?.image,
                  height: iconSize,
                  width: iconSize,
                  fit: BoxFit.fill,
                  fallback: Icon(MdiIcons.web, size: iconSize),
                ),
              )
            : Icon(MdiIcons.web, size: iconSize),
      ),
    );
  }
}
