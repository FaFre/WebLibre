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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class WebsiteTitleTile extends HookConsumerWidget {
  final TabState initialTabState;

  const WebsiteTitleTile(this.initialTabState, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfoAsync = ref.watch(completePageInfoProvider(initialTabState));

    return Skeletonizer(
      enabled: pageInfoAsync.isLoading,
      child: pageInfoAsync.when(
        skipLoadingOnReload: true,
        data: (info) {
          return ListTile(
            leading: RawImage(
              image: info.favicon?.image.value,
              height: 24,
              width: 24,
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(
              info.title.whenNotEmpty ?? 'Untitled',
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(initialTabState.url.authority),
          );
        },
        error: (error, stackTrace) {
          return FailureWidget(
            title: error.toString(),
            onRetry: () => ref.refresh(
              pageInfoProvider(initialTabState.url, isImageRequest: false),
            ),
          );
        },
        loading: () => ListTile(
          leading: RawImage(
            image: initialTabState.favicon?.image.value,
            height: 24,
            width: 24,
          ),
          contentPadding: EdgeInsets.zero,
          title: Text(initialTabState.title.whenNotEmpty ?? 'Untitled'),
          subtitle: Text(initialTabState.url.authority),
        ),
      ),
    );
  }
}
