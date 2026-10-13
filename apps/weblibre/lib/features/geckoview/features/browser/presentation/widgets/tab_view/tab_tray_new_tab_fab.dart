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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/scroll_visibility.dart';

/// Room under the last tab so the new-tab button cannot cover it: the
/// full-screen tray's regular button (56dp) over its 16dp margin, and a gap.
const tabTrayListBottomPadding = 88.0;

/// The kind of tab the tray's new-tab buttons open.
///
/// The kind the tray is filtered to, so a tab opened while only private tabs
/// are listed is private, and shows up in the list it was opened from.
/// Otherwise the selected tab's kind, or the default one. The filter only
/// counts where it is shown: the tree view lists every kind whatever it says,
/// and synced tabs have no kind.
TabType trayNewTabType(WidgetRef ref) {
  final filterIgnored =
      ref.read(tabsViewModeControllerProvider) == TabsViewMode.tree ||
      ref.read(effectiveTabsTrayScopeProvider) == TabsTrayScope.synced;
  final typeFilter = filterIgnored
      ? TabTypeFilter.all
      : ref.read(tabViewFilterControllerProvider).tabTypeFilter;

  return switch (typeFilter) {
    TabTypeFilter.regularOnly => TabType.regular,
    TabTypeFilter.privateOnly => TabType.private,
    TabTypeFilter.isolatedOnly => TabType.isolated,
    TabTypeFilter.all =>
      ref.read(selectedTabTypeProvider) ??
          ref
              .read(generalSettingsWithDefaultsProvider)
              .effectiveDefaultCreateTabType,
  };
}

/// The tab tray's new-tab button, over the bottom-right corner of the tab list
/// (list, grid and tree alike).
///
/// It slides away while the list scrolls down and comes back as soon as it
/// scrolls up, like the full-screen tab view's button. In the tray's sheet
/// ([sheetController]) the sheet growing and shrinking count as scrolling too:
/// a drag resizes the sheet first and only scrolls the list once the sheet is
/// at its full height.
class TabTrayNewTabFab extends HookConsumerWidget {
  final ScrollController scrollController;
  final DraggableScrollableController? sheetController;
  final VoidCallback onClose;

  /// The view the button sits over, whose header it stays clear of.
  final TabsViewMode tabsViewMode;

  const TabTrayNewTabFab({
    required this.scrollController,
    required this.sheetController,
    required this.onClose,
    required this.tabsViewMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isVisible = useScrollVisibility(
      scrollController,
      sheetController: sheetController,
      disableAnimations: disableAnimations,
    );
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return AnimatedSlide(
      duration: duration,
      offset: isVisible.value ? Offset.zero : const Offset(0, 2),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: duration,
        opacity: isVisible.value ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.only(
            // Clear of the header, which runs behind the status bar once the
            // sheet slides under it, and grows by its height.
            top:
                TabViewHeader.headerSize +
                (watchTabTypeFilterBarVisible(ref, tabsViewMode)
                    ? tabTypeFilterBarHeight
                    : 0) +
                MediaQuery.paddingOf(context).top +
                4,
            right: 4,
          ),
          child: FloatingActionButton.small(
            onPressed: () async {
              await SearchRoute(tabType: trayNewTabType(ref)).push(context);

              // A search usually closes the tray, and this button with it.
              if (context.mounted) onClose();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
