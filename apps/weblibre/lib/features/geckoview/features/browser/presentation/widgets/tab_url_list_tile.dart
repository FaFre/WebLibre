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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/widgets/url_list_tile.dart';

/// An open tab as a [UrlListTile]: its favicon, title, URL breadcrumb and
/// container. A sandbox-captured tab shows the page it captured, not its
/// loopback URL.
class TabUrlListTile extends ConsumerWidget {
  final TabState tabState;
  final ContainerData? containerData;
  final VoidCallback? onTap;

  const TabUrlListTile({
    required this.tabState,
    required this.containerData,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabState.id),
    );
    final displayUrl = sandboxSourceUri ?? tabState.url;
    final displayTitle = sandboxSourceUri != null && tabState.title.isEmpty
        ? sandboxSourceUri.authority
        : tabState.titleOrAuthority;

    return UrlListTile(
      title: displayTitle,
      uri: displayUrl,
      leading: TabIcon(tabState: tabState, iconSize: UrlListTile.iconSize),
      containerColor: containerData?.color,
      containerIcon: containerData?.metadata.iconData,
      useCustomColor: containerData?.metadata.useCustomColor ?? false,
      onTap: onTap,
    );
  }
}
