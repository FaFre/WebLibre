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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/certificate_tile.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/app_link_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/clear_site_data_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/desktop_mode_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/gesture_exclusion_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/permissions_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/routing_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
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

  /// Called when a section opens or closes a list, so the sheet can make room
  /// for it.
  final ValueChanged<bool>? onSectionExpandedChanged;

  const ViewTabSheetWidget({
    super.key,
    required this.initialTabState,
    required this.sheetScrollController,
    required this.draggableScrollableController,
    required this.onClose,
    required this.initialHeight,
    this.onSectionExpandedChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerKey = useMemoized(() => GlobalKey());

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

                      final sandboxSourceUri = ref.read(
                        sandboxSourceUriForTabProvider(
                          tabId: initialTabState.id,
                        ),
                      );

                      await SearchRoute(
                        tabId: initialTabState.id,
                        searchText: searchTextForTab(
                          initialTabState,
                          sandboxSourceUri,
                        ),
                        tabType: initialTabState.tabMode.toTabType(),
                      ).push(context);
                    },
                    child: WebsiteTitleTile(initialTabState),
                  ),
                ),
                CertificateTile(onClose: onClose),
                const Divider(),
              ],
            ),
          ),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.zero,
        controller: sheetScrollController,
        physics: const ClampingScrollPhysicsWithoutImplicit(),
        children: [
          // Ordered by the questions people open this sheet with: is the site
          // tracking me, where does my traffic go, what may it access. How the
          // browser behaves on it, and wiping it, come after.
          TrackingProtectionSection(
            tabId: initialTabState.id,
            onExpandedChanged: onSectionExpandedChanged,
          ),
          const Divider(),
          RoutingSection(tabId: initialTabState.id, onClose: onClose),
          PermissionsSection(
            origin: initialTabState.url.origin,
            isPrivate: initialTabState.tabMode is PrivateTabMode,
          ),
          const Divider(),
          _SectionHeader(
            AppLocalizations.of(context).browser_siteBehaviorSectionTitle,
          ),
          DesktopModeSection(
            tabId: initialTabState.id,
            url: initialTabState.url,
          ),
          AppLinkSection(
            url: initialTabState.url,
            contextId: initialTabState.contextId,
          ),
          GestureExclusionSection(url: initialTabState.url),
          // Clear Site Data Section. The clear covers the site in every
          // partition, so from a private or isolated tab it would mostly hit
          // data outside that tab; closing the tab already drops its own data.
          // Fenix hides it in private tabs for the same reason.
          if (initialTabState.tabMode is RegularTabMode) ...[
            const Divider(),
            ClearSiteDataSection(
              url: initialTabState.url,
              onExpandedChanged: onSectionExpandedChanged,
            ),
          ],
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

/// A group title in the sheet, styled like the permissions section's.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
