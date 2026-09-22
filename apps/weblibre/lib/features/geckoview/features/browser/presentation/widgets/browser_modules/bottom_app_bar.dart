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

import 'dart:async';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/addons/domain/providers.dart'
    show pinnedAddonIdsProvider;
import 'package:weblibre/features/addons/presentation/widgets/pinned_addon_bar.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/quick_switcher_button_row.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_view_reorder.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_accordion.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/side_rail_resize_handle.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_context_menu_draggable.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/scroll_to_active_chip.dart';
import 'package:weblibre/presentation/widgets/reorderable_hold_drag.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

export 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/quick_tab_switcher_chip.dart'
    show QuickTabSwitcherItem;

class BrowserTopAppBar extends StatelessWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final bool isSmallWebMode;
  final bool enableGestures;
  final bool suppressMainToolbar;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserTopAppBar({
    super.key,
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    this.enableGestures = true,
    this.suppressMainToolbar = false,
  }) {
    _tabBar = BrowserTabBar(
      showMainToolbar: showMainToolbar,
      displayedSheet: null,
      showContextualToolbar: false,
      quickTabSwitcherRowCount: 0,
      isSmallWebMode: isSmallWebMode,
      enableGestures: enableGestures,
      hideMainToolbarButtonsDuplicatedInContextualToolbar:
          showContextualToolbar,
      suppressMainToolbar: suppressMainToolbar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(height: preferredSize.height, child: _tabBar),
    );
  }

  Size get preferredSize => _size;
}

class BrowserBottomAppBar extends StatelessWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final bool isSmallWebMode;
  final Sheet? displayedSheet;
  final bool enableGestures;
  final bool suppressMainToolbar;

  late final BrowserTabBar _tabBar;
  late final _size = Size.fromHeight(_tabBar.getToolbarHeight());

  BrowserBottomAppBar({
    super.key,
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    this.enableGestures = true,
    this.suppressMainToolbar = false,
  }) {
    _tabBar = BrowserTabBar(
      displayedSheet: displayedSheet,
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      quickTabSwitcherRowCount: quickTabSwitcherRowCount,
      isSmallWebMode: isSmallWebMode,
      enableGestures: enableGestures,
      hideMainToolbarButtonsDuplicatedInContextualToolbar:
          showContextualToolbar,
      suppressMainToolbar: suppressMainToolbar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // Transparent so the navigation-bar inset region behind this padding is
      // filled by the BrowserSystemBars tint strip (matching the active
      // container color), instead of a fixed surfaceContainer fill.
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(height: _size.height, child: _tabBar),
      ),
    );
  }

  Size get preferredSize => _size;
}

/// Vertical side-rail wrapper (left/right positions). Exposes a fixed content
/// [preferredSize] width; the caller adds the horizontal safe-area inset on the
/// rail's outer edge to compute the browser content offset.
class BrowserSideRail extends ConsumerWidget {
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final bool isSmallWebMode;

  /// Resolved by the caller, which already knows the window size class and
  /// must hand the *same* value to the instance it renders and to the one it
  /// builds off-tree to measure. A mismatch would inset the browser for a rail
  /// of a different width than the one drawn.
  final double railWidth;

  /// Which edge the rail is docked to ([TabBarPosition.left] or
  /// [TabBarPosition.right]).
  final TabBarPosition position;

  final bool suppressMainToolbar;

  /// Whether the rail carries a handle on its inner edge for resizing it.
  final bool resizable;

  late final BrowserTabBar _tabBar;

  /// The rail's footprint, which the browser screen insets the page by.
  late final _size = Size.fromWidth(railWidth);

  BrowserSideRail({
    super.key,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    required this.position,
    required this.railWidth,
    this.suppressMainToolbar = false,
    this.resizable = false,
  }) {
    _tabBar = BrowserTabBar(
      displayedSheet: null,
      showMainToolbar: true,
      showContextualToolbar: showContextualToolbar,
      quickTabSwitcherRowCount: quickTabSwitcherRowCount,
      isSmallWebMode: isSmallWebMode,
      enableGestures: true,
      railWidth: railWidth,
      hideMainToolbarButtonsDuplicatedInContextualToolbar:
          showContextualToolbar,
      suppressMainToolbar: suppressMainToolbar,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLeft = position == TabBarPosition.left;

    // Tint the outer fill with the active container's surface color (same tint
    // the content and BrowserSystemBars use) so the rail's system safe-area
    // strips (status/nav bar, docked-edge notch) blend with the rail instead
    // of showing a neutral surfaceContainer gap. Falls back to surfaceContainer
    // when no container is active.
    final selectedTabId = ref.watch(selectedTabProvider);
    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showContainerUi),
    );
    final containerColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.color),
    );
    final useCustomColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.metadata.useCustomColor ?? false),
    );
    final effectiveContainerColor = (showContainerUi && containerColor != null)
        ? containerColor
        : null;
    final tintColor = effectiveContainerColor != null
        ? ContainerColors.palette(
            context,
            effectiveContainerColor,
            useCustomColor: useCustomColor,
          ).surfaceColor
        : Theme.of(context).colorScheme.surfaceContainer;

    return ColoredBox(
      color: tintColor,
      child: SafeArea(
        left: isLeft,
        right: !isLeft,
        child: SizedBox(
          width: _size.width,
          child: resizable
              ? Stack(
                  children: [
                    Positioned.fill(child: _tabBar),
                    // Inside the rail rather than straddling its edge, so the
                    // handle never takes touches meant for the page. It draws
                    // inside the [BrowserTabBar.panelInset] the panel already
                    // holds clear on this edge, so it costs the tab list no
                    // width and covers none of it; see [SideRailResizeHandle].
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: isLeft ? null : 0,
                      right: isLeft ? 0 : null,
                      width: SideRailResizeHandle.hitWidth,
                      child: SideRailResizeHandle(
                        railOnLeft: isLeft,
                        railWidth: railWidth,
                      ),
                    ),
                  ],
                )
              : _tabBar,
        ),
      ),
    );
  }

  Size get preferredSize => _size;
}

class BrowserTabBar extends HookConsumerWidget {
  final bool showMainToolbar;
  final bool showContextualToolbar;
  final int quickTabSwitcherRowCount;
  final Sheet? displayedSheet;
  final bool hideMainToolbarButtonsDuplicatedInContextualToolbar;
  final bool isSmallWebMode;
  final bool enableGestures;

  /// Width of the rail this bar is rendered in, when it is a rail at all.
  ///
  /// Ignored by the horizontal bars, which flow along their width.
  final double railWidth;

  /// Drops the main toolbar row entirely — not just its contents.
  ///
  /// Set on the home surface, where this row has nothing left to say: its
  /// address field is replaced by the home surface's own pinned search pill,
  /// and what sits beside it — the pinned add-ons, the reader button — acts on
  /// a page that is not open. Blanking only the title would strand the add-ons
  /// at the right of an empty strip and still reserve [kToolbarHeight] here.
  ///
  /// The caller resolves this rather than deriving it from
  /// `shouldShowBrowserHomeProvider`, for two reasons: [getToolbarHeight] runs
  /// outside the widget tree (from the wrappers' constructors, to size the bar
  /// before it is built), and the decision also depends on whether a contextual
  /// toolbar exists to take over the tab count and navigation menu — which the
  /// wrappers rewrite before it reaches this widget.
  final bool suppressMainToolbar;

  const BrowserTabBar({
    super.key,
    required this.showMainToolbar,
    required this.displayedSheet,
    required this.showContextualToolbar,
    required this.quickTabSwitcherRowCount,
    required this.isSmallWebMode,
    required this.enableGestures,
    this.railWidth = compactRailWidth,
    this.hideMainToolbarButtonsDuplicatedInContextualToolbar = false,
    this.suppressMainToolbar = false,
  });

  static const contextualToolabarHeight = 54.0;
  static const quickTabSwitcherHeight = 48.0;

  /// Rail width on a window too narrow to spare more, and the width the rail
  /// had before it could vary. Equal to [kToolbarHeight] so the rail reuses
  /// the same base sizing as the horizontal bar: a single column of icons.
  static const compactRailWidth = kToolbarHeight;

  /// Rail width once the window can spare it, but not enough for titles.
  ///
  /// Matches Material's collapsed navigation rail (80), which is the width at
  /// which an icon gets a comfortable touch target and some breathing room
  /// rather than filling its column edge to edge.
  static const mediumRailWidth = 80.0;

  /// Width of the tab panel before the user resizes it.
  ///
  /// Matches Material's *extended* navigation rail (256).
  static const expandedRailWidth = defaultSideRailWidth;

  /// Narrowest the tab panel can be resized to while still carrying titled,
  /// closable rows and an upright address field.
  static const minExpandedRailWidth = 200.0;

  /// Widest the tab panel can be resized to. Past this a tab list gains
  /// nothing but empty space after its titles.
  static const maxExpandedRailWidth = 480.0;

  /// Dragged narrower than this, the panel snaps to the icon rail.
  static const railCollapseThreshold = 140.0;

  /// The inset between the panel's edges and what it lays out inside them.
  ///
  /// The one number for the whole panel: the tab list's slices
  /// (`_TraySlice`) and the toolbar-and-address block above them both use it,
  /// which is what makes their left and right edges line up.
  static const panelInset = 4.0;

  /// Content width of the vertical side rail for [window] (excludes the system
  /// safe-area inset on the rail's outer edge, which is added by the caller).
  ///
  /// Deliberately a pure static function rather than anything that reads a
  /// `BuildContext`: `browser.dart` builds these bar widgets *outside* the tree
  /// purely to read `preferredSize` for its Stack inset math, so the width has
  /// to be knowable without a context. The caller passes in what it read.
  ///
  /// [hasTabList] is false when the quick tab switcher is switched off
  /// entirely ([TabBarStackingMode.disabled]). The panel exists to hold a list
  /// of tabs; without one, a column of address field and buttons is just width
  /// taken from the page, so it stays at the medium rail instead.
  ///
  /// [preferredWidth] is the width the user resized the panel to (or is
  /// dragging it to), and [windowWidth] the window it has to fit; see
  /// [panelWidthFor].
  static double railWidthFor(
    WindowSizeClass window, {
    required bool hasTabList,
    required double preferredWidth,
    required double windowWidth,
  }) {
    if (canResizeRail(window, hasTabList: hasTabList)) {
      return panelWidthFor(preferredWidth, windowWidth: windowWidth);
    }
    // By width alone, unlike where the auto position puts the bar: a rail the
    // user placed in a wide but short window still has the width for it.
    if (window.width != WindowWidthClass.compact) return mediumRailWidth;
    return compactRailWidth;
  }

  /// Whether [window] shows the resizable tab panel, or the icon rail it was
  /// collapsed to, rather than a rail of fixed width.
  static bool canResizeRail(
    WindowSizeClass window, {
    required bool hasTabList,
  }) => window.allowsWideRail && hasTabList;

  /// The width a panel the user sized to [preferredWidth] gets in a window
  /// [windowWidth] wide.
  ///
  /// Anything below [minExpandedRailWidth] is the collapsed icon rail.
  /// Otherwise the width is clamped between the panel limits and to half the
  /// window, so the page always keeps at least as much room as the panel. The
  /// panel only exists in windows at least 840dp wide, whose half already
  /// clears the minimum, so the clamp cannot invert.
  static double panelWidthFor(
    double preferredWidth, {
    required double windowWidth,
  }) {
    if (preferredWidth < minExpandedRailWidth) return mediumRailWidth;

    final halfWindow = windowWidth / 2;
    final upper = halfWindow < maxExpandedRailWidth
        ? halfWindow
        : maxExpandedRailWidth;
    if (upper <= minExpandedRailWidth) return minExpandedRailWidth;

    return preferredWidth.clamp(minExpandedRailWidth, upper);
  }

  /// The width a resize drag that has reached [rawWidth] shows, and saves if
  /// released there.
  ///
  /// Below [railCollapseThreshold] it is the icon rail. Between that and
  /// [minExpandedRailWidth] it holds at the minimum, which is what makes the
  /// snap a detent rather than a flicker between the two layouts.
  static double draggedRailWidth(
    double rawWidth, {
    required double windowWidth,
  }) {
    if (rawWidth < railCollapseThreshold) return mediumRailWidth;
    return panelWidthFor(
      rawWidth < minExpandedRailWidth ? minExpandedRailWidth : rawWidth,
      windowWidth: windowWidth,
    );
  }

  /// Whether a rail of [width] lists tabs as titled rows with close buttons
  /// under an upright address field.
  ///
  /// The single home of this threshold. The rail's contents are spread across
  /// three widgets that each have to make the same call — this view, the
  /// switcher view, and the accordion — and a copy of the comparison in each
  /// is how one of them ends up disagreeing.
  ///
  /// Keyed on the width actually in force rather than on the size class, so a
  /// caller that pins a width (the settings preview) gets a rail that looks
  /// the way that width would really look.
  static bool isWideRailWidth(double width) => width >= minExpandedRailWidth;

  /// Whether this bar's [railWidth] is wide enough to be a tab panel.
  bool get isWideRail => isWideRailWidth(railWidth);

  double getToolbarWidth() => railWidth;

  bool get displayAppBar =>
      showMainToolbar &&
      !suppressMainToolbar &&
      (!showContextualToolbar || displayedSheet is! ViewTabsSheet);

  bool get displayQuickTabSwitcher =>
      quickTabSwitcherRowCount > 0 && displayedSheet is! ViewTabsSheet;

  double getToolbarHeight() {
    var height = 0.0;

    if (displayAppBar) {
      height += kToolbarHeight;
    }

    if (showContextualToolbar) {
      height += contextualToolabarHeight;
    }

    if (displayQuickTabSwitcher) {
      height += quickTabSwitcherHeight * quickTabSwitcherRowCount;
    }

    return height;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabId = ref.watch(selectedTabProvider);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    // Determine which buttons are actually visible in the contextual toolbar
    // so we only hide them from the main toolbar when they're genuinely present there.
    final contextualConfigs = ref
        .watch(
          effectiveToolbarButtonConfigsProvider(
            ToolbarConfigLocation.contextual,
          ),
        )
        .value;

    final tabsCountInContextual =
        hideMainToolbarButtonsDuplicatedInContextualToolbar &&
        contextualConfigs.any(
          (c) => c.buttonId == ToolbarButtonId.tabsCount.name && c.isVisible,
        );

    final menuInContextual =
        hideMainToolbarButtonsDuplicatedInContextualToolbar &&
        contextualConfigs.any(
          (c) =>
              c.buttonId == ToolbarButtonId.navigationMenu.name && c.isVisible,
        );

    final showMainToolbarTabsCount = !isSmallWebMode && !tabsCountInContextual;
    final showMainToolbarNavigationButton =
        !isSmallWebMode && !menuInContextual;

    final containerColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.color),
    );
    final containerUseCustomColor = ref.watch(
      watchTabContainerDataProvider(
        selectedTabId,
      ).select((data) => data.value?.metadata.useCustomColor ?? false),
    );

    final stackingMode = ref.watch(effectiveTabBarStackingModeProvider);

    // Two-level stacking draws a row only when that row has something in it.
    // The same provider backs `quickTabSwitcherRowCountProvider`, which is
    // what reserved this bar's height — reading it here is what keeps the
    // rows drawn and the slots reserved for them identical, so an empty row
    // is not a blank band (#628).
    final twoLevelRows = stackingMode == TabBarStackingMode.twoLevel
        ? ref.watch(twoLevelQuickTabSwitcherRowsProvider).value
        : null;
    final showTwoLevelContainerRow = twoLevelRows?.containerRow ?? false;
    final showTwoLevelMruRow = twoLevelRows?.mruRow ?? false;

    final tabBarPosition = ref.watch(effectiveTabBarPositionProvider);
    final isVertical = tabBarPosition.isVertical;
    // Only a vertical rail has a width to be wide; the horizontal bars leave
    // railWidth at its compact default and never take these branches.
    final wideRail = isVertical && isWideRail;
    final switcherAxis = tabBarPosition.axis;
    // Left rail reads bottom-to-top, right rail top-to-bottom.
    final railQuarterTurns = tabBarPosition == TabBarPosition.left ? 3 : 1;

    final dragStartPosition = useRef(Offset.zero);

    // Runs what the user bound to [gesture], if anything. Swipes along the
    // bar are backward when they go right-to-left (or upward on the rail): the
    // swipe drags the list under the finger.
    Future<void> runSwipe(BuiltInGesture gesture) async {
      final action = ref.read(builtInGestureBindingProvider(gesture));
      if (action == null) return;
      await ref.read(browserActionDispatcherProvider.notifier).run(action);
    }

    // The swipes across the bar — toward the edge it is docked to, or away
    // from it — push the bar off screen and pull the tab view out of it by
    // default, so they read as one continuous control. Whatever they are bound
    // to, they stand down while a sheet covers the bar and confirm with a tap
    // of haptics, as they always did.
    Future<void> runCrossSwipe(BuiltInGesture gesture) async {
      if (ref.read(bottomSheetControllerProvider) != null) return;
      if (ref.read(builtInGestureBindingProvider(gesture)) == null) return;

      unawaited(HapticFeedback.lightImpact());
      await runSwipe(gesture);
    }

    final showTabTitle = displayedSheet is! ViewTabsSheet;

    final effectiveContainerColor =
        (settings.showContainerUi &&
            containerColor != null &&
            displayedSheet is! ViewTabsSheet)
        ? containerColor
        : null;
    final effectiveUseCustomColor =
        effectiveContainerColor != null && containerUseCustomColor;
    final effectiveContainerPalette = effectiveContainerColor != null
        ? ContainerColors.palette(
            context,
            effectiveContainerColor,
            useCustomColor: effectiveUseCustomColor,
          )
        : null;

    final mainActions = <Widget>[
      // A panel lays its actions out in rows, so its add-ons go in a row too.
      // It also spaces them evenly, where the empty box this renders with
      // nothing pinned would still take a share of the gaps.
      if (!wideRail || ref.watch(pinnedAddonIdsProvider).isNotEmpty)
        PinnedAddonBar(axis: wideRail ? Axis.horizontal : switcherAxis),
      if (isSmallWebMode)
        ReaderButton(
          buttonBuilder: (isLoading, readerActive, icon) => ToolbarButton(
            onTap: isLoading
                ? null
                : () async {
                    await ref
                        .read(readerableScreenControllerProvider.notifier)
                        .toggleReaderView(!readerActive);
                  },
            child: icon,
          ),
        ),
      if (showMainToolbarTabsCount)
        TabsCountButton(
          selectedTabId: selectedTabId,
          displayedSheet: displayedSheet,
          showLongPressMenu: true,
        ),
      if (showMainToolbarNavigationButton)
        NavigationMenuButton(selectedTabId: selectedTabId),
    ];

    return BrowserTabBarView(
      axis: switcherAxis,
      isWideRail: wideRail,
      railOnLeft: tabBarPosition == TabBarPosition.left,
      showMainToolbar: showMainToolbar,
      showContextualToolbar: showContextualToolbar,
      showQuickTabSwitcherBar: quickTabSwitcherRowCount > 0,
      displayAppBar: displayAppBar,
      displayQuickTabSwitcher: displayQuickTabSwitcher,
      backgroundColor: effectiveContainerPalette?.surfaceColor,
      title: showTabTitle
          // A wide rail takes the ordinary horizontal title. RailAppBarTitle
          // exists to survive a 56dp column by rotating 90 degrees; at panel
          // width there is nothing to survive and a sideways URL would just be
          // hard to read.
          ? (isVertical && !wideRail)
                ? RailAppBarTitle(
                    quarterTurns: railQuarterTurns,
                    containerColor: effectiveContainerColor,
                    useCustomColor: effectiveUseCustomColor,
                  )
                : settings.tabBarLayout == TabBarLayout.compact
                ? CompactAppBarTitle(
                    containerColor: effectiveContainerColor,
                    useCustomColor: effectiveUseCustomColor,
                  )
                : AppBarTitle(
                    containerColor: effectiveContainerColor,
                    useCustomColor: effectiveUseCustomColor,
                  )
          : null,
      // A panel wraps these together with the contextual buttons instead; see
      // the contextual toolbar below.
      actions: wideRail ? const [] : mainActions,
      quickTabSwitcher: _wrapQuickTabSwitcherWithButtonRow(
        axis: switcherAxis,
        // The button row lives on the switcher bar; when stacking is disabled
        // the whole bar is hidden anyway, but skip building it for clarity.
        buttonRow: stackingMode == TabBarStackingMode.disabled
            ? null
            : QuickSwitcherButtonRow(
                selectedTabId: selectedTabId,
                displayedSheet: displayedSheet,
                axis: wideRail ? Axis.horizontal : switcherAxis,
                wrap: wideRail,
              ),
        child: switch (stackingMode) {
          TabBarStackingMode.disabled => const SizedBox.shrink(),
          // Every switcher row carries its mode as a key, on whichever widget
          // occupies the slot (the Expanded on the rail). Rows of the same
          // type take each other's slots here — the two-level column drops one
          // when it runs empty, and changing stacking mode swaps one for the
          // other — so unkeyed, Flutter would match the surviving row to the
          // departed one's element and hand it that row's hook state: scroll
          // controller, user-scrolling timer and active-chip key.
          TabBarStackingMode.lastUsedTabs => QuickTabSwitcher(
            key: const ValueKey(QuickTabSwitcherMode.lastUsedTabs),
            quickTabSwitcherMode: QuickTabSwitcherMode.lastUsedTabs,
            axis: switcherAxis,
            railWidth: railWidth,
          ),
          TabBarStackingMode.containerTabs => QuickTabSwitcher(
            key: const ValueKey(QuickTabSwitcherMode.containerTabs),
            quickTabSwitcherMode: QuickTabSwitcherMode.containerTabs,
            axis: switcherAxis,
            railWidth: railWidth,
          ),
          TabBarStackingMode.accordion => AccordionQuickTabSwitcher(
            axis: switcherAxis,
            railWidth: railWidth,
          ),
          // History fallback only on the MRU row, so empty-state history chips
          // don't show twice.
          //
          // Reachable on a *wide* rail as well as the horizontal bars:
          // effectiveTabBarStackingMode degrades twoLevel to accordion only on
          // a narrow rail. Vertically the two rows have to share the rail's
          // height with Expanded — each switcher fills its axis, so a
          // min-sized Column would overflow.
          TabBarStackingMode.twoLevel =>
            switcherAxis == Axis.vertical
                ? Column(
                    children: [
                      if (showTwoLevelContainerRow)
                        Expanded(
                          key: const ValueKey(
                            QuickTabSwitcherMode.containerTabs,
                          ),
                          child: QuickTabSwitcher(
                            quickTabSwitcherMode:
                                QuickTabSwitcherMode.containerTabs,
                            enableHistoryFallback: false,
                            axis: switcherAxis,
                            railWidth: railWidth,
                          ),
                        ),
                      if (showTwoLevelMruRow)
                        Expanded(
                          key: const ValueKey(
                            QuickTabSwitcherMode.lastUsedTabs,
                          ),
                          child: QuickTabSwitcher(
                            quickTabSwitcherMode:
                                QuickTabSwitcherMode.lastUsedTabs,
                            axis: switcherAxis,
                            railWidth: railWidth,
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showTwoLevelContainerRow)
                        const QuickTabSwitcher(
                          key: ValueKey(QuickTabSwitcherMode.containerTabs),
                          quickTabSwitcherMode:
                              QuickTabSwitcherMode.containerTabs,
                          enableHistoryFallback: false,
                        ),
                      if (showTwoLevelMruRow)
                        const QuickTabSwitcher(
                          key: ValueKey(QuickTabSwitcherMode.lastUsedTabs),
                          quickTabSwitcherMode:
                              QuickTabSwitcherMode.lastUsedTabs,
                        ),
                    ],
                  ),
        },
      ),
      // On a panel this is one wrap holding every configured action — the
      // contextual buttons, when that bar is enabled, followed by the main
      // toolbar's — so all of them stay visible without a row of height each.
      contextualToolbar: ContextualToolbar(
        selectedTabId: selectedTabId,
        displayedSheet: displayedSheet,
        axis: wideRail ? Axis.horizontal : switcherAxis,
        wrap: wideRail,
        showConfiguredButtons: !wideRail || showContextualToolbar,
        trailing: wideRail && displayAppBar ? mainActions : const [],
      ),
      onHorizontalDragStart: !enableGestures
          ? null
          : (details) {
              dragStartPosition.value = details.globalPosition;
            },
      onHorizontalDragEnd: !enableGestures
          ? null
          : (details) async {
              final distance = dragStartPosition.value - details.globalPosition;
              const dismissThreshold = kToolbarHeight * 0.5;

              if (isVertical) {
                // Rail: horizontal swipe dismisses toward the docked edge, and
                // the opposite (inward) swipe opens the tab view.
                // distance = start - end, so a leftward swipe is positive dx.
                final shouldDismiss = switch (tabBarPosition) {
                  TabBarPosition.left => distance.dx > dismissThreshold,
                  TabBarPosition.right => distance.dx < -dismissThreshold,
                  _ => false,
                };
                final shouldShowTabView = switch (tabBarPosition) {
                  TabBarPosition.left => distance.dx < -dismissThreshold,
                  TabBarPosition.right => distance.dx > dismissThreshold,
                  _ => false,
                };
                if (shouldDismiss) {
                  await runCrossSwipe(BuiltInGesture.tabBarSwipeOutward);
                } else if (shouldShowTabView) {
                  await runCrossSwipe(BuiltInGesture.tabBarSwipeInward);
                }
              } else {
                // Horizontal bar: horizontal swipe switches tabs.
                if (distance.dx.abs() > 50 && distance.dy.abs() < 20) {
                  await runSwipe(
                    distance.dx > 0
                        ? BuiltInGesture.tabBarSwipeBackward
                        : BuiltInGesture.tabBarSwipeForward,
                  );
                }
              }
            },
      onVerticalDragStart: !enableGestures
          ? null
          : (details) {
              dragStartPosition.value = details.globalPosition;
            },
      onVerticalDragEnd: !enableGestures
          ? null
          : (details) async {
              final distance = dragStartPosition.value - details.globalPosition;

              if (isVertical) {
                // Rail: vertical swipe switches tabs.
                if (distance.dy.abs() > 50 && distance.dx.abs() < 20) {
                  await runSwipe(
                    distance.dy > 0
                        ? BuiltInGesture.tabBarSwipeBackward
                        : BuiltInGesture.tabBarSwipeForward,
                  );
                }
                return;
              }

              // Horizontal bar dismiss direction depends on position; the
              // opposite (inward) swipe opens the tab view:
              // - Bottom bar: swipe down to dismiss, swipe up for the tab view
              // - Top bar: swipe up to dismiss, swipe down for the tab view
              const dismissThreshold = kToolbarHeight * 0.5;
              final shouldDismiss = switch (tabBarPosition) {
                TabBarPosition.bottom =>
                  distance.dy.isNegative &&
                      distance.dy.abs() > dismissThreshold,
                TabBarPosition.top =>
                  !distance.dy.isNegative &&
                      distance.dy.abs() > dismissThreshold,
                _ => false,
              };
              final shouldShowTabView = switch (tabBarPosition) {
                TabBarPosition.bottom =>
                  !distance.dy.isNegative &&
                      distance.dy.abs() > dismissThreshold,
                TabBarPosition.top =>
                  distance.dy.isNegative &&
                      distance.dy.abs() > dismissThreshold,
                _ => false,
              };
              if (shouldDismiss) {
                await runCrossSwipe(BuiltInGesture.tabBarSwipeOutward);
              } else if (shouldShowTabView) {
                await runCrossSwipe(BuiltInGesture.tabBarSwipeInward);
              }
            },
    );
  }
}

class BrowserTabBarView extends StatelessWidget {
  const BrowserTabBarView({
    super.key,
    required this.showMainToolbar,
    required this.showContextualToolbar,
    required this.showQuickTabSwitcherBar,
    required this.displayAppBar,
    required this.displayQuickTabSwitcher,
    required this.backgroundColor,
    required this.title,
    required this.actions,
    required this.quickTabSwitcher,
    required this.contextualToolbar,
    this.axis = Axis.horizontal,
    this.isWideRail = false,
    this.railOnLeft = true,
    this.onHorizontalDragStart,
    this.onHorizontalDragEnd,
    this.onVerticalDragStart,
    this.onVerticalDragEnd,
  });

  /// Layout orientation. Vertical renders the side-rail form.
  final Axis axis;

  /// Whether the vertical rail is wide enough to be a tab panel.
  ///
  /// Changes how the rail divides its height and how the action buttons are
  /// arranged; the narrow rail has room for exactly one control per row.
  final bool isWideRail;

  /// For the vertical rail, whether it is docked to the left edge (affects
  /// nothing structural here yet; reserved for edge-specific tweaks).
  final bool railOnLeft;

  final bool showMainToolbar;
  final bool showContextualToolbar;
  final bool showQuickTabSwitcherBar;
  final bool displayAppBar;
  final bool displayQuickTabSwitcher;
  final Color? backgroundColor;
  final Widget? title;
  final List<Widget> actions;
  final Widget quickTabSwitcher;
  final Widget contextualToolbar;
  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragEndCallback? onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainer;

    if (axis == Axis.vertical && isWideRail) {
      return GestureDetector(
        onHorizontalDragStart: onHorizontalDragStart,
        onHorizontalDragEnd: onHorizontalDragEnd,
        onVerticalDragStart: onVerticalDragStart,
        onVerticalDragEnd: onVerticalDragEnd,
        child: ColoredBox(
          color: effectiveBackgroundColor,
          child: Column(
            children: [
              // Actions and address field at the top, where a large-screen
              // browser keeps them: in a desktop window the top edge is where
              // the eye already is. The tab list takes everything below.
              //
              // Inset by [panelInset], not by the 8dp the narrow rail uses:
              // the toolbar row and the address field have to line up with the
              // tab rows under them, and those are laid out by the tray slices
              // at that inset. Two different insets read as the top of the
              // panel being narrower than the rest of it.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BrowserTabBar.panelInset,
                  4.0,
                  BrowserTabBar.panelInset,
                  4.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    contextualToolbar,
                    if (showMainToolbar && title != null)
                      Visibility(
                        visible: displayAppBar,
                        maintainState: true,
                        child: title!,
                      ),
                  ],
                ),
              ),
              if (showQuickTabSwitcherBar)
                Expanded(
                  child: Visibility(
                    visible: displayQuickTabSwitcher,
                    maintainState: true,
                    child: quickTabSwitcher,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (axis == Axis.vertical) {
      return GestureDetector(
        onHorizontalDragStart: onHorizontalDragStart,
        onHorizontalDragEnd: onHorizontalDragEnd,
        onVerticalDragStart: onVerticalDragStart,
        onVerticalDragEnd: onVerticalDragEnd,
        child: ColoredBox(
          color: effectiveBackgroundColor,
          child: Column(
            children: [
              // Literal section order (switcher → URL+actions → contextual);
              // the switcher is the flexible scroll region.
              if (showQuickTabSwitcherBar)
                Expanded(
                  // The narrow rail stacks its actions vertically and needs a
                  // real share of the column for them.
                  flex: 3,
                  child: Visibility(
                    visible: displayQuickTabSwitcher,
                    maintainState: true,
                    child: quickTabSwitcher,
                  ),
                ),
              if (showMainToolbar)
                Expanded(
                  flex: 2,
                  child: Visibility(
                    visible: displayAppBar,
                    maintainState: true,
                    // Horizontal inset so the URL pile and action buttons
                    // don't sit flush against the rail edges, matching the
                    // breathing room the horizontal bar's title/actions get.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Expanded(child: title ?? const SizedBox.shrink()),
                          ...actions,
                        ],
                      ),
                    ),
                  ),
                ),
              if (showContextualToolbar) contextualToolbar,
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      // Tap handling moved to AppBarTitle for split icon/title behavior
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onVerticalDragStart: onVerticalDragStart,
      onVerticalDragEnd: onVerticalDragEnd,
      child: ColoredBox(
        color: effectiveBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showQuickTabSwitcherBar)
              Visibility(
                visible: displayQuickTabSwitcher,
                maintainState: true,
                child: quickTabSwitcher,
              ),
            if (showMainToolbar)
              Visibility(
                visible: displayAppBar,
                maintainState: true,
                child: AppBar(
                  primary: false,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 0.0,
                  leadingWidth: 40.0,
                  toolbarHeight: kToolbarHeight,
                  title: title,
                  actions: actions,
                ),
              ),
            if (showContextualToolbar) contextualToolbar,
          ],
        ),
      ),
    );
  }
}

/// Pins [buttonRow] to the trailing end of the quick tab switcher bar (right of
/// the horizontal bar / bottom of the side rail) while [child] (the scrollable
/// chips) fills the remaining space. The cluster is capped to a fraction of the
/// bar so it can never starve the chips; [QuickSwitcherButtonRow] scrolls any
/// overflow beyond that cap. [buttonRow] collapses to nothing when no buttons
/// are enabled, so the default state is unchanged.
Widget _wrapQuickTabSwitcherWithButtonRow({
  required Axis axis,
  required Widget? buttonRow,
  required Widget child,
}) {
  if (buttonRow == null) {
    return child;
  }

  // Never let the button cluster take more than this share of the bar; the tab
  // chips keep the rest.
  const maxClusterFraction = 0.6;

  return LayoutBuilder(
    builder: (context, constraints) {
      if (axis == Axis.vertical) {
        final maxExtent = constraints.maxHeight.isFinite
            ? constraints.maxHeight * maxClusterFraction
            : double.infinity;
        return Column(
          children: [
            Expanded(child: child),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxExtent),
              child: buttonRow,
            ),
          ],
        );
      }

      final maxExtent = constraints.maxWidth.isFinite
          ? constraints.maxWidth * maxClusterFraction
          : double.infinity;
      return Row(
        children: [
          Expanded(child: child),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxExtent),
            child: buttonRow,
          ),
        ],
      );
    },
  );
}

class QuickTabSwitcher extends HookConsumerWidget {
  final QuickTabSwitcherMode quickTabSwitcherMode;

  /// Whether the row falls back to history suggestion chips when it has no
  /// open tabs. Disabled for the top row in two-level stacking so history
  /// chips don't show twice.
  final bool enableHistoryFallback;

  /// Direction the chips list flows. Vertical for the side rail.
  final Axis axis;

  /// Width of the rail this switcher is rendered in, when [axis] is vertical.
  ///
  /// Drives whether chips can afford titles and close buttons.
  final double railWidth;

  const QuickTabSwitcher({
    super.key,
    required this.quickTabSwitcherMode,
    this.enableHistoryFallback = true,
    this.axis = Axis.horizontal,
    this.railWidth = BrowserTabBar.compactRailWidth,
  });

  /// Whether a vertical rail is wide enough to carry titled chips.
  bool get isWideRail =>
      axis == Axis.vertical && BrowserTabBar.isWideRailWidth(railWidth);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showIsolatedTabUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showIsolatedTabUi),
    );
    final showTitlesSetting = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    // Titles can't fit a *narrow* vertical rail, so icon-only chips are
    // forced there. A rail wide enough to be a tab panel has room for them,
    // and without titles a 256dp column of bare icons would be absurd.
    final showTitles =
        (axis != Axis.vertical || isWideRail) && showTitlesSetting;
    final titleMaxWidth = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherTitleWidth,
      ),
    );
    final closeButtonMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherCloseButtonMode,
      ),
    );
    final tabBarDirection = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarDirection),
    );
    final tabStates = ref.watch(
      quickTabSwitcherTabStatesProvider(quickTabSwitcherMode),
    );
    final selectedTabId = ref.watch(selectedTabProvider);
    final historySuggestions = enableHistoryFallback
        ? ref
              .watch(
                quickTabSwitcherHistorySuggestionsProvider(
                  quickTabSwitcherMode,
                ),
              )
              .value
        : null;
    final sandboxSourceUris = ref.watch(sandboxSourceUrisProvider).value;
    // Reorder is only meaningful when the bar renders the user's actual tab
    // order (containerTabs). Other modes (lastUsedTabs / MRU) sort by recency,
    // so dragging would just snap back on the next tab switch.
    final canManualReorder = ref.watch(canManualTabReorderProvider);
    final sortPinnedFirst = ref.watch(
      tabViewFilterControllerProvider.select((v) => v.sortPinnedFirst),
    );
    final hierarchyGlyphs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherHierarchyGlyphs,
      ),
    );
    final showHierarchicalTabs = hierarchyGlyphs > 0;
    final selectedContainerId = ref.watch(selectedContainerProvider);
    final hierarchyContainerId =
        quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs
        ? selectedContainerId
        : null;

    final tabDepthById = ref
        .watch(
          groupedTabListItemsProvider(
            containerId: hierarchyContainerId,
            scope: TabListScope.presentation,
          ).select((value) {
            return EquatableValue(<String, int>{
              if (showHierarchicalTabs)
                for (final item in value.value)
                  if (item is TabListChildItem) item.tabId: item.depth,
            });
          }),
        )
        .value;

    final pinnedTabIds = ref.watch(
      watchPinnedTabIdsProvider.select(
        (value) => value.value ?? const <String>{},
      ),
    );
    final restoreComplete = ref.watch(browserRestoreCompleteProvider);
    final nativeTabIds = ref
        .watch(
          tabStatesProvider.select(
            (states) => EquatableValue(states.keys.toSet()),
          ),
        )
        .value;
    final tabItems = tabStates.value
        .map(
          (state) => QuickTabSwitcherItem.tab(
            state,
            selectedTabId: selectedTabId,
            pinnedTabIds: pinnedTabIds,
            tabDepthById: tabDepthById,
            sandboxSourceUri: sandboxSourceUris[state.$1.id],
            isPlaceholder:
                !restoreComplete && !nativeTabIds.contains(state.$1.id),
          ),
        )
        .toList();
    // Reorder is disabled while placeholders are present: the engine doesn't
    // know those tabs yet, so a reorder couldn't be applied consistently.
    final reorderEnabled =
        quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs &&
        canManualReorder &&
        !tabItems.any((item) => item.isPlaceholder);
    final historyItems = (historySuggestions ?? [])
        .map(
          (visit) =>
              QuickTabSwitcherItem.history(url: visit.url, title: visit.title),
        )
        .toList();
    final availableItems = [...tabItems, ...historyItems];

    final activeItem = availableItems.isEmpty
        ? null
        : availableItems.firstWhere(
            (item) => item.isActive,
            orElse: () => availableItems.first,
          );

    final chipScrollController = useScrollController();
    final activeItemKey = useRef(GlobalKey());
    final isUserScrolling = useRef(false);
    final userScrollTimer = useRef<Timer?>(null);
    final scrollKey = PageStorageKey(
      'quick_tab_switcher_${quickTabSwitcherMode.name}',
    );

    useEffect(() {
      return userScrollTimer.value?.cancel;
    }, []);

    // Keep the active chip centered when the selection or ordering changes,
    // even if it is far outside the lazily-built range.
    useScrollToActiveChip<String>(
      controller: chipScrollController,
      activeChipKey: activeItemKey.value,
      activeId: (activeItem?.isActive ?? false) ? activeItem?.id : null,
      orderedIds: [for (final item in availableItems) item.id],
      isUserScrolling: () => isUserScrolling.value,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          isUserScrolling.value = true;
          userScrollTimer.value?.cancel();
          userScrollTimer.value = Timer(const Duration(milliseconds: 1500), () {
            isUserScrolling.value = false;
          });
        } else {
          userScrollTimer.value?.cancel();
          userScrollTimer.value = Timer(const Duration(milliseconds: 1500), () {
            isUserScrolling.value = false;
          });
        }

        return false;
      },
      child: QuickTabSwitcherView(
        availableItems: availableItems,
        reorderableItemCount: reorderEnabled ? tabItems.length : 0,
        activeItem: (activeItem?.isActive ?? false) ? activeItem : null,
        scrollController: chipScrollController,
        scrollKey: scrollKey,
        activeItemKey: activeItemKey.value,
        axis: axis,
        railWidth: railWidth,
        // Reordering the container tabs row is off while the tab view is
        // filtered or searched; say so instead of silently not dragging.
        reorderBlockedMessage:
            quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs &&
                !canManualReorder
            ? tabReorderBlockedMessage
            : null,
        showTitles: showTitles,
        showIsolatedTabUi: showIsolatedTabUi,
        hierarchyGlyphs: hierarchyGlyphs,
        titleMaxWidth: titleMaxWidth,
        closeButtonMode: closeButtonMode,
        enablePinTabInMenu:
            quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs,
        onCloseItem: (item) =>
            closeTabWithConfirmationAndUndo(context, ref, item.id),
        onSelected: (item) async {
          if (!item.isHistory && item.isActive) {
            return;
          }
          if (item.isHistory) {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: item.url,
                  tabMode: TabMode.regular,
                  selectTab: true,
                );
          } else {
            await ref.read(tabRepositoryProvider.notifier).selectTab(item.id);
          }
        },
        onReorderItem: !reorderEnabled
            ? null
            : (oldIndex, newIndex) async {
                if (oldIndex >= tabItems.length || newIndex > tabItems.length) {
                  return;
                }
                final visibleItems = [
                  for (final item in tabItems)
                    TabViewItem.standalone(tabId: item.id),
                ];
                final result = buildTabViewReorderResult(
                  visibleItems: visibleItems,
                  treeRows: const [],
                  collapsedGroups: const {},
                  pinnedTabIds: pinnedTabIds,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                  tabListDirection: tabBarDirection,
                  hierarchical: false,
                  sortPinnedFirst: sortPinnedFirst,
                );
                if (result == null) {
                  if (context.mounted) {
                    ui_helper.showInfoMessage(
                      context,
                      'Tab cannot be moved here',
                    );
                  }
                  return;
                }
                await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .reorderTabs(
                      movingTabIds: result.movingTabIds,
                      previousTabId: result.previousTabId,
                      nextTabId: result.nextTabId,
                      parentChange: result.parentChange,
                    );
              },
      ),
    );
  }
}

class QuickTabSwitcherView extends StatelessWidget {
  const QuickTabSwitcherView({
    super.key,
    required this.availableItems,
    required this.activeItem,
    required this.scrollController,
    this.scrollKey,
    this.activeItemKey,
    required this.showTitles,
    required this.showIsolatedTabUi,
    this.hierarchyGlyphs = defaultQuickTabSwitcherHierarchyGlyphs,
    this.titleMaxWidth = defaultQuickTabSwitcherTitleWidth,
    this.closeButtonMode = TabChipCloseButtonMode.activeTabOnly,
    required this.enablePinTabInMenu,
    required this.onSelected,
    this.onCloseItem,
    this.onReorderItem,
    this.reorderableItemCount = 0,
    this.axis = Axis.horizontal,
    this.railWidth = BrowserTabBar.compactRailWidth,
    this.reorderBlockedMessage,
  });

  /// Direction the chips flow. Vertical for the side rail.
  final Axis axis;

  /// Width of the rail this view is rendered in, when [axis] is vertical.
  final double railWidth;

  /// Shown when a tab is held and dragged while reordering is switched off for
  /// a reason the user can act on. Null when there is nothing to explain.
  final String? reorderBlockedMessage;

  final List<QuickTabSwitcherItem> availableItems;
  final QuickTabSwitcherItem? activeItem;
  final ScrollController scrollController;
  final Key? scrollKey;
  final GlobalKey? activeItemKey;
  final bool showTitles;
  final bool showIsolatedTabUi;

  /// Max inline chevron glyphs on a chip's depth indicator before collapsing
  /// into an icon + count badge. A value of 0 hides the indicator entirely.
  final int hierarchyGlyphs;

  /// Max width of a chip's title text.
  final double titleMaxWidth;

  /// Whether every tab chip shows a close button. The active tab's chip
  /// always shows one when [onCloseItem] is set.
  final TabChipCloseButtonMode closeButtonMode;

  final bool enablePinTabInMenu;
  final Future<void> Function(QuickTabSwitcherItem item) onSelected;

  /// Close handler backing the chips' close buttons. When null no close
  /// buttons are shown at all.
  final Future<void> Function(QuickTabSwitcherItem item)? onCloseItem;

  /// When non-null, the first [reorderableItemCount] items are rendered as a
  /// horizontal `ReorderableListView` driven by this callback. Otherwise the
  /// view falls back to the non-reorderable `SelectableChips` layout.
  final void Function(int oldIndex, int newIndex)? onReorderItem;

  /// Items at indices `< reorderableItemCount` are reorderable; items at
  /// or after are appended as a static trailing row (e.g. history hints).
  final int reorderableItemCount;

  bool get _reorderEnabled => onReorderItem != null && reorderableItemCount > 0;

  /// Whether [item]'s chip shows a close button. Never on the narrow vertical
  /// rail: an icon-only chip has no room for a close button beside it (it
  /// overflows). Closing stays available via the long-press menu.
  bool _canShowCloseButton(QuickTabSwitcherItem item) =>
      (!_isVertical || _isWideRail) &&
      onCloseItem != null &&
      !item.isHistory &&
      !item.isPlaceholder &&
      closeButtonMode.showsFor(isActive: item.isActive);

  bool get _isVertical => axis == Axis.vertical;

  /// A rail wide enough for a chip to carry a title *and* a close button
  /// beside it. On the narrow rail the chip is a bare icon with nowhere to put
  /// one.
  bool get _isWideRail =>
      _isVertical && BrowserTabBar.isWideRailWidth(railWidth);

  @override
  Widget build(BuildContext context) {
    if (availableItems.isEmpty) {
      // Hold the 48px slot rather than collapsing: whether a row exists at
      // all is decided upstream (quickTabSwitcherRowCountProvider, and the
      // two-level row gates that follow it), and the toolbar height is
      // already reserved for the rows it decided on. Shrinking here would
      // only desync the content from that reservation on the frames where an
      // item list empties before the count catches up.
      // On the rail the cross-axis width is fixed and the (vertical) list
      // fills the available height.
      return _isVertical
          ? SizedBox(width: railWidth)
          : const SizedBox(height: 48);
    }

    return Padding(
      padding: _isVertical
          ? const EdgeInsets.symmetric(vertical: 4.0)
          : const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        // Vertical fills both axes of the rail content column; horizontal keeps
        // the fixed 48px row height.
        height: _isVertical ? double.maxFinite : 48,
        width: double.maxFinite,
        child: _reorderEnabled
            ? _buildReorderableList(context)
            : _isWideRail
            ? _buildRows(context)
            : _buildSelectableChips(context),
      ),
    );
  }

  /// A panel's tab list: one full-width row per item.
  Widget _buildRows(BuildContext context) {
    return ListView.builder(
      key: scrollKey,
      controller: scrollController,
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      itemCount: availableItems.length,
      itemBuilder: (context, index) {
        final item = availableItems[index];
        final isSelected = activeItem?.id == item.id;
        final row = _row(item, isSelected);

        return KeyedSubtree(
          key: isSelected && activeItemKey != null
              ? activeItemKey
              : ValueKey(item.id),
          child: item.isHistory
              ? row
              : _withBlockedHint(_wrapWithMenu(item: item, child: row)),
        );
      },
    );
  }

  Widget _row(QuickTabSwitcherItem item, bool isSelected) {
    return QuickTabSwitcherRow(
      item: item,
      isSelected: isSelected,
      showIsolatedTabUi: showIsolatedTabUi,
      showTitles: showTitles,
      hierarchyGlyphs: hierarchyGlyphs,
      onTap: () => unawaited(onSelected(item)),
      onDelete: _canShowCloseButton(item)
          ? () => unawaited(onCloseItem!(item))
          : null,
    );
  }

  Widget _buildSelectableChips(BuildContext context) {
    return SelectableChips<QuickTabSwitcherItem, QuickTabSwitcherItem, String>(
      enableDelete: onCloseItem != null,
      sortSelectedFirst: false,
      maxCount: null,
      scrollController: scrollController,
      scrollKey: scrollKey,
      activeItemKey: activeItemKey,
      scrollDirection: axis,
      cacheExtent: 500,
      itemId: (item) => item.id,
      selectedItem: activeItem,
      selectedBorderColor: Theme.of(context).colorScheme.primary,
      decoration: _chipDecoration(context),
      itemLabel: (item) => _chipLabel(context, item, activeItem?.id == item.id),
      onSelected: onSelected,
      onDeleted: (item) {
        unawaited(onCloseItem?.call(item));
      },
      itemWrap: (child, item) => item.isHistory
          ? child
          : _withBlockedHint(_wrapWithMenu(item: item, child: child)),
      availableItems: availableItems,
    );
  }

  Widget _buildReorderableList(BuildContext context) {
    // History suggestions only appear when there are no tab items
    // (see quickTabSwitcherHistorySuggestionsProvider), so reorder mode
    // is mutually exclusive with the history trailing row in practice.
    // Defensively cap the reorderable range anyway.
    final reorderableCount = reorderableItemCount.clamp(
      0,
      availableItems.length,
    );

    return ReorderableListView.builder(
      key: scrollKey,
      scrollController: scrollController,
      scrollDirection: axis,
      // Drag handles are supplied per item so the drag arms later than the
      // long-press context menu (see [ReorderableHoldDragListener]).
      buildDefaultDragHandles: false,
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      itemCount: reorderableCount,
      itemBuilder: (context, index) {
        final item = availableItems[index];
        final isSelected = activeItem?.id == item.id;
        final chip = _isWideRail
            ? _row(item, isSelected)
            : QuickTabSwitcherChip(
                item: item,
                isSelected: isSelected,
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                decoration: _chipDecoration(context),
                label: _chipLabel(context, item, isSelected),
                onTap: () => onSelected(item),
                onDelete: _canShowCloseButton(item)
                    ? () => onCloseItem!(item)
                    : null,
              );
        final keyedForActive = isSelected && activeItemKey != null
            ? KeyedSubtree(key: activeItemKey, child: chip)
            : chip;
        return KeyedSubtree(
          key: ValueKey(item.id),
          child: ReorderableHoldDragListener(
            index: index,
            // Placeholders aren't backed by a native session yet, so they
            // can't be reordered.
            enabled: !item.isPlaceholder,
            child: TabContextMenuDraggable(
              tabId: item.id,
              externalDrag: true,
              enableCloseTab: true,
              feedbackSize: Size.zero,
              child: keyedForActive,
            ),
          ),
        );
      },
      onReorderItem: onReorderItem,
    );
  }

  Widget _withBlockedHint(Widget child) {
    final message = reorderBlockedMessage;
    return message == null
        ? child
        : HoldDragDisabledHint(message: message, child: child);
  }

  Widget _wrapWithMenu({
    required QuickTabSwitcherItem item,
    required Widget child,
  }) {
    return wrapQuickTabSwitcherChipWithMenu(
      itemId: item.id,
      enabled: !item.isPlaceholder,
      enablePinTab: enablePinTabInMenu,
      child: child,
    );
  }

  SelectableChipDecoration<QuickTabSwitcherItem> _chipDecoration(
    BuildContext context,
  ) {
    return buildQuickTabSwitcherChipDecoration(
      context,
      showTitles: showTitles,
      hierarchyGlyphs: hierarchyGlyphs,
      isVertical: _isVertical,
      canDelete: _canShowCloseButton,
    );
  }

  Widget _chipLabel(
    BuildContext context,
    QuickTabSwitcherItem item,
    bool isSelected,
  ) {
    return buildQuickTabSwitcherChipLabel(
      context,
      item,
      isSelected: isSelected,
      showTitles: showTitles,
      showIsolatedTabUi: showIsolatedTabUi,
      hierarchyGlyphs: hierarchyGlyphs,
      titleMaxWidth: titleMaxWidth,
      isVertical: _isVertical,
    );
  }
}
