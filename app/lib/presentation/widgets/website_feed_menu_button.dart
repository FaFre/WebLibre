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
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/presentation/widgets/rounded_text.dart';

class WebsiteFeedMenuButton extends HookConsumerWidget {
  final String tabId;

  const WebsiteFeedMenuButton(this.tabId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedsAsync = ref.watch(websiteFeedProviderProvider(tabId));

    return Skeletonizer(
      enabled: feedsAsync.isLoading && feedsAsync.value?.value == null,
      child: feedsAsync.when(
        skipLoadingOnReload: true,
        data: (feeds) {
          if (feeds.value.isEmpty) {
            return const SizedBox.shrink();
          }

          return MenuItemButton(
            leadingIcon: const Icon(Icons.rss_feed),
            closeOnActivate: false,
            trailingIcon: RoundedBackground(
              child: Text(
                feeds.value!.length.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            onPressed: () async {
              await SelectFeedDialogRoute(
                feedsJson: jsonEncode(
                  feeds.value!.map((feed) => feed.toString()).toList(),
                ),
              ).push(context);
            },
            child: const Text('Available Web Feeds'),
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
        loading: () => const MenuItemButton(
          leadingIcon: Icon(Icons.rss_feed),
          trailingIcon: Bone.icon(),
          child: Text('Available Web Feeds'),
        ),
      ),
    );
  }
}
