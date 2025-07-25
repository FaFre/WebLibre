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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/presentation/widgets/rounded_text.dart';

class WebsiteFeedTile extends HookConsumerWidget {
  final Uri url;
  final WebPageInfo? precachedInfo;

  const WebsiteFeedTile(this.url, {this.precachedInfo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfoAsync = ref.watch(
      completePageInfoProvider(url, precachedInfo),
    );

    return Skeletonizer(
      enabled: pageInfoAsync.isLoading && precachedInfo?.feeds == null,
      child: pageInfoAsync.when(
        skipLoadingOnReload: true,
        data: (info) {
          if (info.feeds.isEmpty) {
            return const SizedBox.shrink();
          }

          return ListTile(
            leading: const Icon(Icons.rss_feed),
            title: const Text('Available Web Feeds'),
            trailing: RoundedBackground(
              child: Text(
                info.feeds!.length.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            onTap: () async {
              await SelectFeedDialogRoute(
                feedsJson: jsonEncode(
                  info.feeds!.map((feed) => feed.toString()).toList(),
                ),
              ).push(context);
            },
          );
        },
        error: (error, stackTrace) {
          return const SizedBox.shrink();

          //Will be dispalyed on title already

          // return FailureWidget(
          //   title: error.toString(),
          //   onRetry: () => ref.refresh(pageInfoProvider(url)),
          // );
        },
        loading: () => const ListTile(
          leading: Icon(Icons.rss_feed),
          contentPadding: EdgeInsets.zero,
          title: Text('Available Web Feeds'),
          trailing: Bone.icon(),
        ),
      ),
    );
  }
}
