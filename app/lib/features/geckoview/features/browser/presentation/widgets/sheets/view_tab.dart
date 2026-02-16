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

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/certificate_tile.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/clear_site_data_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/permissions_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_section.dart';
import 'package:weblibre/presentation/widgets/website_title_tile.dart';

class ClampingScrollPhysicsWithoutImplicit extends ClampingScrollPhysics {
  const ClampingScrollPhysicsWithoutImplicit({super.parent});

  @override
  ClampingScrollPhysicsWithoutImplicit applyTo(ScrollPhysics? ancestor) {
    return ClampingScrollPhysicsWithoutImplicit(parent: buildParent(ancestor));
  }

  @override
  bool get allowImplicitScrolling => false;
}

class ViewTabSheetWidget extends HookConsumerWidget {
  final TabState initialTabState;
  final ScrollController sheetScrollController;
  final DraggableScrollableController draggableScrollableController;
  final VoidCallback onClose;
  final double initialHeight;
  final double bottomAppBarHeight;
  final ValueChanged<bool>? onClearSiteDataExpandedChanged;

  const ViewTabSheetWidget({super.key, 
    required this.initialTabState,
    required this.sheetScrollController,
    required this.draggableScrollableController,
    required this.onClose,
    required this.initialHeight,
    required this.bottomAppBarHeight,
    this.onClearSiteDataExpandedChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerKey = useMemoized(() => GlobalKey());

    final bottomInsets = useRef(0.0);
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final diff =
              ((MediaQuery.of(context).viewInsets.bottom / 2) /
                  MediaQuery.of(context).size.height) -
              bottomInsets.value;

          final jumpValue = (draggableScrollableController.size + diff).clamp(
            0.0,
            1.0,
          );

          draggableScrollableController.jumpTo(jumpValue);

          bottomInsets.value += diff;
        });

        return null;
      },
      [
        MediaQuery.of(context).viewInsets.bottom,
        MediaQuery.of(context).size.height,
      ],
    );

    return NestedScrollView(
      physics: const NeverScrollableScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: DraggableScrollableHeader(
            key: headerKey,
            controller: draggableScrollableController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                  child: GestureDetector(
                    onTap: () async {
                      // Dismiss sheet and open search screen with tab context
                      onClose();

                      // Don't pre-fill for internal URLs
                      final searchText = initialTabState.url.scheme == 'about'
                          ? ''
                          : initialTabState.url.toString();

                      await SearchRoute(
                        tabId: initialTabState.id,
                        searchText: searchText.isEmpty
                            ? SearchRoute.emptySearchText
                            : searchText,
                        tabType: initialTabState.isPrivate
                            ? TabType.private
                            : TabType.regular,
                      ).push(context);
                    },
                    child: WebsiteTitleTile(initialTabState),
                  ),
                ),
                const CertificateTile(),
                const Divider(),
              ],
            ),
          ),
        ),
      ],
      body: FadingScroll(
        fadingSize: 15,
        controller: sheetScrollController,
        builder: (context, controller) {
          return ListView(
            padding: EdgeInsets.zero,
            controller: controller,
            physics: const ClampingScrollPhysicsWithoutImplicit(),
            children: [
              // Tracking Protection Section
              TrackingProtectionSection(tabId: initialTabState.id),
              const Divider(),
              // Permissions Section
              PermissionsSection(
                origin: initialTabState.url.origin,
                isPrivate: initialTabState.isPrivate,
              ),
              const Divider(),
              // Clear Site Data Section
              ClearSiteDataSection(
                url: initialTabState.url,
                onExpandedChanged: onClearSiteDataExpandedChanged,
              ),
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }
}
