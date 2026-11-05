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
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/auto_hide_scroll_tracker.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/quick_switcher_button_row.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/side_rail.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/layout/browser_chrome_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/site_settings_badge_provider.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/settings/presentation/utils/toolbar_preview_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The window the layout preview draws.
enum PreviewDevice {
  /// The window the app runs in right now.
  thisWindow(null),
  phone(Size(392, 850)),
  phoneLandscape(Size(850, 392)),
  tablet(Size(1280, 800));

  const PreviewDevice(this.fixedSize);

  /// The window's size, or null for [thisWindow], whose size is read from the
  /// running app.
  final Size? fixedSize;
}

/// The moment of browsing the layout preview shows.
///
/// A toolbar hidden by scrolling is not one: [PreviewMode.tryIt] shows it
/// live.
enum PreviewSampleState { page, home, sidePanelCollapsed }

/// Why a [PreviewSampleState] cannot occur with the current settings.
enum PreviewStateBlocker { needsSidePanel }

/// Smallest height the sample page keeps between the bars when the preview
/// has to shorten the window to fit.
const kMinPreviewPageHeight = 80.0;

/// The window [device] stands for: its size and size class.
///
/// For [PreviewDevice.thisWindow] the real window, read the way the browser
/// reads it, so the preview resolves exactly as the browser behind it does.
({Size size, WindowSizeClass window}) resolvePreviewWindow(
  BuildContext context,
  WidgetRef ref,
  PreviewDevice device,
) {
  if (device.fixedSize case final size?) {
    return (size: size, window: WindowSizeClass.fromSize(size));
  }
  return (
    size: MediaQuery.sizeOf(context),
    window: ref.watch(windowSizeClassControllerProvider),
  );
}

/// How many switcher rows the sample tabs fill in [mode].
int previewQuickTabSwitcherRowCount(TabBarStackingMode mode) => switch (mode) {
  TabBarStackingMode.disabled => 0,
  TabBarStackingMode.twoLevel || TabBarStackingMode.tabGroups => 2,
  TabBarStackingMode.lastUsedTabs ||
  TabBarStackingMode.containerTabs ||
  TabBarStackingMode.accordion => 1,
};

/// The stacking mode [settings] resolve to in [window], in [state].
TabBarStackingMode previewStackingMode(
  GeneralSettings settings, {
  required ({Size size, WindowSizeClass window}) window,
  required PreviewSampleState state,
}) => settings.effectiveTabBarStackingMode(
  window: window.window,
  sideRailWidthOverride: _previewDragWidth(state),
);

/// A collapsed panel is drawn the way the browser draws one being dragged
/// shut: with a width below the panel minimum, which snaps to the icon rail.
double? _previewDragWidth(PreviewSampleState state) =>
    state == PreviewSampleState.sidePanelCollapsed ? 0.0 : null;

/// The browser chrome as [settings] lay it out in [window], in [state].
///
/// [cursorInUse] lays it out as with a mouse, which is when an auto-hiding
/// side panel moves over the page.
BrowserChromeLayout previewChromeLayout(
  GeneralSettings settings, {
  required ({Size size, WindowSizeClass window}) window,
  required PreviewSampleState state,
  bool cursorInUse = false,
}) {
  final dragWidth = _previewDragWidth(state);
  final stackingMode = previewStackingMode(
    settings,
    window: window,
    state: state,
  );

  return BrowserChromeLayout.fromSettings(
    settings,
    window: window.window,
    windowWidth: window.size.width,
    quickTabSwitcherRowCount: previewQuickTabSwitcherRowCount(stackingMode),
    showBrowserHome: state == PreviewSampleState.home,
    sideRailDragWidth: dragWidth,
    cursorInUse: cursorInUse,
  );
}

/// The layout the preview draws for [state] in [window], and the state it
/// draws: [PreviewSampleState.page] while [state] cannot occur.
({BrowserChromeLayout layout, PreviewSampleState state}) previewEffectiveLayout(
  GeneralSettings settings, {
  required ({Size size, WindowSizeClass window}) window,
  required PreviewSampleState state,
  bool cursorInUse = false,
}) {
  final pageLayout = previewChromeLayout(
    settings,
    window: window,
    state: PreviewSampleState.page,
    cursorInUse: cursorInUse,
  );
  if (state == PreviewSampleState.page ||
      previewStateBlocker(state, pageLayout) != null) {
    return (layout: pageLayout, state: PreviewSampleState.page);
  }
  return (
    layout: previewChromeLayout(
      settings,
      window: window,
      state: state,
      cursorInUse: cursorInUse,
    ),
    state: state,
  );
}

/// Height the bars of [layout] take on screen when the preview draws a
/// window of [device] [availableWidth] wide with no page between them, as it
/// does with [LayoutPreview.pageGivesWay]. Null for a side rail, which runs
/// the window's full height and is only ever scaled as a whole.
double? previewBarsExtent(
  BrowserChromeLayout layout, {
  required Size device,
  required double availableWidth,
}) {
  if (layout.isRail) return null;
  final scale = math.min(availableWidth / device.width, 1.0);
  return (layout.topBarHeight + layout.bottomBarHeight) * scale;
}

/// Why [state] cannot be shown in [pageLayout] (the layout of the plain page
/// state), or null when it can.
PreviewStateBlocker? previewStateBlocker(
  PreviewSampleState state,
  BrowserChromeLayout pageLayout,
) => switch (state) {
  PreviewSampleState.page || PreviewSampleState.home => null,
  PreviewSampleState.sidePanelCollapsed =>
    pageLayout.railResizable &&
            BrowserTabBar.isWideRailWidth(pageLayout.railWidth)
        ? null
        : PreviewStateBlocker.needsSidePanel,
};

/// Where the preview draws a window of [device] in [available] space.
///
/// The window is laid out at its own width, so every bar has the width it
/// really has, then scaled down to fit — never up. Horizontal bars keep their
/// real height: when the whole window does not fit, only the page between
/// them gets shorter, down to [minPageHeight]. A side rail runs the window's
/// full height, so a window with one is always scaled as a whole.
///
/// [chromeExtent] is the height the horizontal bars take together.
({Size layoutSize, double scale}) previewGeometry({
  required Size device,
  required Size available,
  required double chromeExtent,
  required bool isRail,
  double minPageHeight = kMinPreviewPageHeight,
}) {
  if (available.width <= 0 || available.height <= 0) {
    return (layoutSize: device, scale: 0.0);
  }

  if (isRail) {
    final scale = [
      available.width / device.width,
      available.height / device.height,
      1.0,
    ].reduce(math.min);
    return (layoutSize: device, scale: scale);
  }

  final widthScale = math.min(available.width / device.width, 1.0);
  if (device.height * widthScale <= available.height) {
    return (layoutSize: device, scale: widthScale);
  }

  final minHeight = math.min(device.height, chromeExtent + minPageHeight);
  final heightAtWidthScale = available.height / widthScale;
  if (heightAtWidthScale >= minHeight) {
    return (
      layoutSize: Size(device.width, heightAtWidthScale),
      scale: widthScale,
    );
  }

  // Not even the bars and the shortest page fit at the window's width: scale
  // that down as a whole instead.
  return (
    layoutSize: Size(device.width, minHeight),
    scale: math.min(widthScale, available.height / minHeight),
  );
}

/// Material's medium shape, for the card the window is drawn in.
const _windowRadius = BorderRadius.all(Radius.circular(12));

/// How the preview answers a tap.
enum PreviewMode {
  /// A tap selects the part of the toolbar under it.
  select,

  /// The preview behaves like the browser: the page scrolls and the toolbar
  /// hides with it, the buttons say what they would open. An auto-hiding side
  /// panel behaves as it does with a mouse, which a tap stands in for: it
  /// hides once the pointer rests on the page, and comes back at its edge.
  tryIt,
}

/// What a button did in [PreviewMode.tryIt].
enum PreviewTryAction {
  toolbarHidden,
  sidePanelHidden,
  openedTabView,
  openedMenu,
}

/// A picture of the browser as the current settings lay it out, drawn by the
/// same layout the browser uses ([BrowserChromeLayout]).
///
/// Reads the settings as they apply ([displayedGeneralSettingsProvider]),
/// which in the onboarding are the draft's.
///
/// Without a [mode] it is only a picture. With one, a tap either selects a
/// part ([onPartSelected]) or tries the layout out ([onTryAction]).
class LayoutPreview extends HookConsumerWidget {
  const LayoutPreview({
    super.key,
    required this.device,
    required this.state,
    this.mode,
    this.selectedPart,
    this.onPartSelected,
    this.onTryAction,
    this.pageGivesWay = false,
  });

  final PreviewDevice device;

  /// Falls back to [PreviewSampleState.page] while it cannot occur.
  final PreviewSampleState state;

  final PreviewMode? mode;
  final LayoutPart? selectedPart;
  final ValueChanged<LayoutPart?>? onPartSelected;
  final ValueChanged<PreviewTryAction>? onTryAction;

  /// Whether the page between horizontal bars may shrink to nothing, so the
  /// bars keep their real size however little room is left: while a part's
  /// settings take most of the screen, the window comes down to the bars
  /// holding it.
  final bool pageGivesWay;

  /// The touch target a part keeps however small it is drawn: Material's
  /// minimum, around the finger.
  static const _touchSlop = kMinInteractiveDimension / 2;

  /// How long the pointer rests on the page before an auto-hiding side panel
  /// hides, as in the browser.
  static const _railHideDelay = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(displayedGeneralSettingsProvider);
    final window = resolvePreviewWindow(context, ref, device);

    final windowKey = useMemoized(GlobalKey.new);
    final hovered = useState<LayoutPart?>(null);
    final tracker = useMemoized(AutoHideScrollTracker.new);
    // The trial the toolbar was hidden in (see `trial` below), null while it
    // shows.
    final hiddenInTrial = useState<Object?>(null);
    // The same for an auto-hiding side panel, which hides by the pointer
    // rather than by scrolling.
    final railHiddenInTrial = useState<Object?>(null);
    final railHideTimer = useRef<Timer?>(null);
    final pointerDown = useRef<Offset?>(null);
    // Where the outlined parts are, in the window's layout, measured after
    // each frame (see [layoutPartRects]).
    final partRects = useState<Map<LayoutPart, Rect>>(const {});

    void cancelRailHide() {
      railHideTimer.value?.cancel();
      railHideTimer.value = null;
    }

    useEffect(() => cancelRailHide, const []);

    // A mouse is what makes the side panel hide in the browser; Try stands in
    // for one, so the panel can be tried without.
    final (:layout, state: effectiveState) = previewEffectiveLayout(
      settings,
      window: window,
      state: state,
      cursorInUse: mode == PreviewMode.tryIt,
    );

    // A toolbar hidden while trying is shown again as soon as the trial no
    // longer applies: leaving Try, or a window or settings whose layout does
    // not hide its toolbar (a side rail). Left hidden, it could not be scrolled
    // back, since such a layout ignores the scrolling.
    final canTryHiding = mode == PreviewMode.tryIt && layout.autoHide;
    // Only ever true in Try, which lays the window out with a cursor.
    final canTryRailHiding = layout.railOverlay;
    // Another window starts the trial over too: a toolbar hidden in one trial
    // shows again in the next, without anything to reset.
    final trial = (
      device: device,
      canTryHiding: canTryHiding,
      canTryRailHiding: canTryRailHiding,
    );
    final triedHidden = canTryHiding && hiddenInTrial.value == trial;
    final railHidden = canTryRailHiding && railHiddenInTrial.value == trial;
    useEffect(() {
      tracker.reset();
      cancelRailHide();
      railHiddenInTrial.value = null;
      // Forget a hide from an earlier trial: coming back to it (Select and
      // back to Try, or another window and back) must start with the toolbar
      // shown, since the reset tracker has no scroll to show it again from.
      hiddenInTrial.value = null;
      return null;
    }, [trial]);
    useEffect(() {
      if (mode != PreviewMode.select) hovered.value = null;
      return null;
    }, [mode]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = previewGeometry(
          device: window.size,
          available: constraints.biggest,
          chromeExtent: layout.topBarHeight + layout.bottomBarHeight,
          isRail: layout.isRail,
          minPageHeight: pageGivesWay ? 0 : kMinPreviewPageHeight,
        );

        // Measured once laid out; set only when it changed, so the rebuild it
        // causes measures the same and stops there.
        final highlighted = {
          if (mode == PreviewMode.select) ...{
            ?selectedPart,
            ?selectedPart?.parent,
            ?hovered.value,
          },
        };
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final box =
              windowKey.currentContext?.findRenderObject() as RenderBox?;
          final rects = box == null || !box.hasSize || highlighted.isEmpty
              ? const <LayoutPart, Rect>{}
              : layoutPartRects(box, highlighted);
          if (!mapEquals(rects, partRects.value)) partRects.value = rects;
        });

        RenderBox? windowBox() {
          final box =
              windowKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null || !box.hasSize || geometry.scale <= 0) {
            return null;
          }
          return box;
        }

        List<LayoutPart> partsAt(Offset globalPosition) {
          final box = windowBox();
          if (box == null) return const [];
          return layoutPartsNear(
            box,
            box.globalToLocal(globalPosition),
            slop: _touchSlop / geometry.scale,
          );
        }

        void hideRail() {
          cancelRailHide();
          if (railHiddenInTrial.value == trial) return;
          railHiddenInTrial.value = trial;
          onTryAction?.call(PreviewTryAction.sidePanelHidden);
        }

        // The browser's auto-hiding side panel, with a tap standing in for
        // the mouse resting: at the window's edge the panel comes in, on the
        // page it goes again. The edge is a touch target wide on screen,
        // however small the window is drawn.
        void onRailPointer(Offset globalPosition, {required bool tap}) {
          if (!canTryRailHiding) return;
          final box = windowBox();
          if (box == null) return;

          final dx = box.globalToLocal(globalPosition).dx;
          final width = box.size.width;
          final railOnLeft = layout.position == TabBarPosition.left;
          final distanceFromEdge = railOnLeft ? dx : width - dx;

          if (railHidden) {
            if (distanceFromEdge <=
                math.max(sideRailRevealEdgeWidth, _touchSlop) /
                    geometry.scale) {
              cancelRailHide();
              railHiddenInTrial.value = null;
            }
            return;
          }
          if (distanceFromEdge <= layout.railWidth) {
            cancelRailHide();
          } else if (tap) {
            hideRail();
          } else {
            railHideTimer.value ??= Timer(_railHideDelay, hideRail);
          }
        }

        void onTap(Offset globalPosition) {
          switch (mode) {
            case PreviewMode.select:
              onPartSelected?.call(
                nextLayoutPartSelection(partsAt(globalPosition), selectedPart),
              );
            case PreviewMode.tryIt:
              // A hidden panel's buttons sit just past the edge, where the
              // slop around a tap would still find them.
              if (railHidden) {
                onRailPointer(globalPosition, tap: true);
                return;
              }
              final parts = partsAt(globalPosition);
              if (parts.contains(LayoutPart.tabView)) {
                onTryAction?.call(PreviewTryAction.openedTabView);
              } else if (parts.contains(LayoutPart.menu)) {
                onTryAction?.call(PreviewTryAction.openedMenu);
              } else {
                onRailPointer(globalPosition, tap: true);
              }
            case null:
          }
        }

        void onPageScroll(double scrollDelta) {
          if (!layout.autoHide) return;
          // The tracker takes the finger's move: up, while the page scrolls
          // down.
          switch (tracker.add(
            -scrollDelta,
            hideDistance: settings.autoHideTabBarDistance,
          )) {
            case AutoHideAction.hide when !triedHidden:
              hiddenInTrial.value = trial;
              onTryAction?.call(PreviewTryAction.toolbarHidden);
            case AutoHideAction.show:
              hiddenInTrial.value = null;
            case _:
          }
        }

        Widget preview = DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: _windowRadius,
          ),
          child: ClipRRect(
            borderRadius: _windowRadius,
            child: SizedBox(
              width: geometry.layoutSize.width * geometry.scale,
              height: geometry.layoutSize.height * geometry.scale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    child: SizedBox.fromSize(
                      size: geometry.layoutSize,
                      // Everything inside measures itself against the window it
                      // is drawn for, not the screen showing the preview.
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: geometry.layoutSize,
                          padding: EdgeInsets.zero,
                          viewPadding: EdgeInsets.zero,
                          viewInsets: EdgeInsets.zero,
                        ),
                        child: KeyedSubtree(
                          key: windowKey,
                          child: PreviewWindow(
                            layout: layout,
                            state: effectiveState,
                            hidden: triedHidden || railHidden,
                            stackingMode: previewStackingMode(
                              settings,
                              window: window,
                              state: effectiveState,
                            ),
                            onPageScroll: mode == PreviewMode.tryIt
                                ? onPageScroll
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Over the window, at screen size: nothing inside it can
                  // clip an outline or a label.
                  if (mode == PreviewMode.select)
                    IgnorePointer(
                      child: PreviewPartHighlights(
                        rects: {
                          for (final MapEntry(key: part, value: rect)
                              in partRects.value.entries)
                            part: Rect.fromLTRB(
                              rect.left * geometry.scale,
                              rect.top * geometry.scale,
                              rect.right * geometry.scale,
                              rect.bottom * geometry.scale,
                            ),
                        },
                        selected: selectedPart,
                        hovered: hovered.value,
                        labelFor: (part) => part.label(context),
                        windowRadius: _windowRadius.topLeft,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        // Only Try lets the preview's own widgets have the pointer: in Select
        // a tap belongs to the selection, not to a chip or a button.
        preview = IgnorePointer(
          ignoring: mode != PreviewMode.tryIt,
          child: preview,
        );

        if (mode != null) {
          // A listener, not a gesture detector: in Try the page's scrolling
          // and the buttons' own taps must still win, and a tap is told from
          // a drag by how far the pointer moved.
          preview = Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => pointerDown.value = event.position,
            onPointerUp: (event) {
              final down = pointerDown.value;
              pointerDown.value = null;
              if (down != null &&
                  (event.position - down).distance < kTouchSlop) {
                onTap(event.position);
              }
            },
            onPointerCancel: (_) => pointerDown.value = null,
            child: preview,
          );
        }

        if (mode == PreviewMode.select) {
          preview = MouseRegion(
            onHover: (event) {
              final candidate = nextLayoutPartSelection(
                partsAt(event.position),
                selectedPart,
              );
              hovered.value = candidate == selectedPart ? null : candidate;
            },
            onExit: (_) => hovered.value = null,
            child: preview,
          );
        } else if (canTryRailHiding) {
          preview = MouseRegion(
            onHover: (event) => onRailPointer(event.position, tap: false),
            // Out of the window: no longer resting on the page.
            onExit: (_) => cancelRailHide(),
            child: preview,
          );
        }

        return Center(
          child: Semantics(
            label: l10n.settings_layoutPreviewSemantics,
            image: true,
            child: ExcludeSemantics(child: preview),
          ),
        );
      },
    );
  }
}

/// The browser window inside the preview: the bars [layout] puts at its edges
/// around a sample page, unscaled.
class PreviewWindow extends StatelessWidget {
  const PreviewWindow({
    super.key,
    required this.layout,
    required this.state,
    required this.stackingMode,
    this.hidden = false,
    this.onPageScroll,
  });

  final BrowserChromeLayout layout;
  final PreviewSampleState state;

  /// Whether the tab bar is out of view, as [PreviewMode.tryIt] hides it:
  /// scrolled away, or an auto-hiding side panel slid out.
  final bool hidden;

  /// Makes the sample page scrollable and reports each scroll step, for
  /// [PreviewMode.tryIt]. Null keeps the page still.
  final ValueChanged<double>? onPageScroll;

  /// The stacking mode resolved for the previewed window, which need not be
  /// the one the app runs in.
  final TabBarStackingMode stackingMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final home = state == PreviewSampleState.home;

    final page = _PreviewPage(
      home: home,
      onScroll: onPageScroll,
      // The home surface's own pill, unless the address field is the home's
      // search entry. Resolved for the previewed window, as the layout is:
      // `auto` stands the pill down under a bottom tab bar.
      showHomeSearchPill:
          home &&
          layout.homeSearchBarPlacement != HomeSearchBarPlacement.tabBar,
    );

    final Widget window;
    if (layout.isRail) {
      final railOnLeft = layout.position == TabBarPosition.left;
      final rail = SizedBox(
        width: layout.railWidth,
        child: PreviewBar(
          bar: layout.rail!,
          railWidth: layout.railWidth,
          home: home,
          stackingMode: stackingMode,
        ),
      );
      if (layout.railOverlay) {
        // Over the page, sliding out to its edge, as the browser's
        // auto-hiding panel does.
        window = Stack(
          children: [
            Positioned.fill(child: page),
            Positioned(
              top: 0,
              bottom: 0,
              left: railOnLeft ? 0 : null,
              right: railOnLeft ? null : 0,
              child: AnimatedSlide(
                offset: hidden ? Offset(railOnLeft ? -1 : 1, 0) : Offset.zero,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : Durations.medium1,
                curve: Curves.easeInOut,
                child: DecoratedBox(
                  decoration: BoxDecoration(boxShadow: kElevationToShadow[3]),
                  child: rail,
                ),
              ),
            ),
          ],
        );
      } else {
        window = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (railOnLeft && !hidden) rail,
            Expanded(child: page),
            if (!railOnLeft && !hidden) rail,
          ],
        );
      }
    } else {
      window = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (layout.topBar case final top? when !hidden)
            SizedBox(
              height: top.height,
              child: PreviewBar(
                bar: top,
                home: home,
                stackingMode: stackingMode,
              ),
            ),
          Expanded(child: page),
          if (layout.bottomBar case final bottom? when !hidden)
            SizedBox(
              height: bottom.height,
              child: PreviewBar(
                bar: bottom,
                home: home,
                stackingMode: stackingMode,
              ),
            ),
        ],
      );
    }

    return ColoredBox(color: colorScheme.surface, child: window);
  }
}

/// One bar of the preview, built the way [BrowserTabBar] builds the real one,
/// from sample tabs instead of the open ones.
class PreviewBar extends HookConsumerWidget {
  const PreviewBar({
    super.key,
    required this.bar,
    required this.stackingMode,
    this.railWidth = BrowserTabBar.compactRailWidth,
    this.home = false,
  });

  /// What the bar holds, and the edge it is docked to.
  final BrowserBarSpec bar;

  /// See [PreviewWindow.stackingMode].
  final TabBarStackingMode stackingMode;
  final double railWidth;

  /// Whether the browser home is showing, where the address field is empty.
  final bool home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(displayedGeneralSettingsProvider);
    final quickTabsController = useScrollController();
    final quickTabsSecondRowController = useScrollController();

    final axis = bar.position.axis;
    final railOnLeft = bar.position == TabBarPosition.left;
    final isVertical = axis == Axis.vertical;
    final wideRail = isVertical && BrowserTabBar.isWideRailWidth(railWidth);

    // The address row leaves out what the contextual toolbar already
    // carries, by the real bar's rule.
    final inContextual = BrowserTabBar.mainButtonsInContextual(
      ref
          .watch(
            displayedToolbarButtonConfigsProvider(
              ToolbarConfigLocation.contextual,
            ),
          )
          .value,
      hideDuplicates: bar.hideMainToolbarButtonsDuplicatedInContextualToolbar,
    );

    // The real bar's actions, less two it cannot sample: the pinned add-ons
    // (a tap would run the extension on the open page) and small web's reader
    // button (the preview never shows small web).
    final mainActions = <Widget>[
      if (!inContextual.tabsCount)
        PreviewPartRegion(
          part: LayoutPart.tabView,
          child: TabsCountButtonView(
            isActive: false,
            onTap: _noop,
            onLongPress: _noop,
            buttonBuilder: (isActive, onTap, onLongPress) =>
                TabsActionButtonView(
                  isActive: isActive,
                  tabCountText: '5',
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
          ),
        ),
      if (!inContextual.navigationMenu)
        const PreviewPartRegion(
          part: LayoutPart.menu,
          child: NavigationMenuButtonView(onTap: _noop),
        ),
    ];

    final palette = settings.containerEntryPointsShown
        ? ContainerColors.palette(context, colorScheme.primary)
        : null;

    final previewTabState = TabState.$default('preview-tab').copyWith(
      url: Uri.parse('https://weblibre.eu/docs'),
      title: l10n.settings_previewPageTitle,
      securityInfoState: SecurityState(
        secure: true,
        host: 'weblibre.eu',
        issuer: 'WebLibre',
      ),
      // An article: the reader view is on offer, as on most pages.
      readerableState: ReaderableState(readerable: !home, active: false),
    );

    // The toolbars resolve their buttons against this tab, so a page action
    // shows as it would on a page, not disabled for want of one.
    final previewTab = ToolbarPreviewTab(
      id: previewTabState.id,
      tabState: previewTabState,
      historyState: HistoryState(
        items: const [],
        currentIndex: 0,
        canGoBack: !home,
        canGoForward: false,
      ),
    );

    // The tab count and the menu are parts of their own wherever they are
    // drawn: in the address bar row or among the contextual buttons.
    Widget wrapPartButton(String buttonId, Widget button) {
      if (buttonId == ToolbarButtonId.tabsCount.name) {
        return PreviewPartRegion(part: LayoutPart.tabView, child: button);
      }
      if (buttonId == ToolbarButtonId.navigationMenu.name) {
        return PreviewPartRegion(part: LayoutPart.menu, child: button);
      }
      return button;
    }

    final title = home
        ? _PreviewSearchField(hint: l10n.browser_searchOrEnterUrl)
        : switch (BrowserTabBar.titleStyleFor(
            position: bar.position,
            railWidth: railWidth,
            layout: settings.tabBarLayout,
          )) {
            BrowserTabBarTitleStyle.rail => _RailPreviewTitle(
              tabState: previewTabState,
              quarterTurns: railOnLeft ? 3 : 1,
            ),
            BrowserTabBarTitleStyle.compact => _CompactPreviewTitle(
              tabState: previewTabState,
            ),
            BrowserTabBarTitleStyle.regular => _RegularPreviewTitle(
              tabState: previewTabState,
            ),
          };

    final items = _previewItems(context, settings, stackingMode, colorScheme);

    Widget row(
      ScrollController controller,
      List<QuickTabSwitcherItem> rowItems,
    ) => QuickTabSwitcherView(
      availableItems: rowItems,
      activeItem: rowItems.firstWhere(
        (item) => item.isActive,
        orElse: () => rowItems.first,
      ),
      scrollController: controller,
      axis: axis,
      railWidth: railWidth,
      showTitles:
          (!isVertical || wideRail) && settings.quickTabSwitcherShowTitles,
      showIsolatedTabUi: settings.isolatedTabEntryPointsShown,
      hierarchyGlyphs: settings.effectiveQuickTabSwitcherHierarchyGlyphs,
      titleMaxWidth: settings.quickTabSwitcherTitleWidth,
      closeButtonMode: settings.quickTabSwitcherCloseButtonMode,
      enablePinTabInMenu: false,
      onSelected: (_) async {},
      onCloseItem: (_) async {},
    );

    final Widget switcherRows;
    if (bar.quickTabSwitcherRowCount >= 2) {
      final rows = [
        row(quickTabsController, items.first),
        row(quickTabsSecondRowController, items.second),
      ];
      switcherRows = isVertical
          ? Column(children: [for (final r in rows) Expanded(child: r)])
          : Column(mainAxisSize: MainAxisSize.min, children: rows);
    } else {
      switcherRows = row(quickTabsController, items.first);
    }

    final rowCount = bar.quickTabSwitcherRowCount;

    return PreviewPartRegion(
      part: LayoutPart.tabBar,
      child: BrowserTabBarView(
        axis: axis,
        isWideRail: wideRail,
        railOnLeft: railOnLeft,
        showMainToolbar: bar.showMainToolbar,
        showContextualToolbar: bar.showContextualToolbar,
        showQuickTabSwitcherBar: rowCount > 0,
        quickTabSwitcherOrder: bar.quickTabSwitcherOrder,
        displayAppBar: bar.displayAppBar,
        displayQuickTabSwitcher: rowCount > 0,
        backgroundColor: palette?.surfaceColor,
        title: title,
        actions: wideRail ? const [] : mainActions,
        quickTabSwitcher: PreviewPartRegion(
          part: LayoutPart.quickTabSwitcher,
          child: wrapQuickTabSwitcherWithButtonRow(
            axis: axis,
            buttonRow: stackingMode == TabBarStackingMode.disabled
                ? null
                : QuickSwitcherButtonRow(
                    selectedTabId: null,
                    displayedSheet: null,
                    axis: wideRail ? Axis.horizontal : axis,
                    wrap: wideRail,
                    isPreview: true,
                    previewTab: previewTab,
                    wrapButton: wrapPartButton,
                  ),
            child: PreviewPartRegion(
              part: LayoutPart.tabChip,
              child: switcherRows,
            ),
          ),
        ),
        contextualToolbar: PreviewPartRegion(
          part: LayoutPart.contextualToolbar,
          child: ContextualToolbar(
            selectedTabId: null,
            displayedSheet: null,
            isPreview: true,
            previewTab: previewTab,
            wrapButton: wrapPartButton,
            axis: wideRail ? Axis.horizontal : axis,
            wrap: wideRail,
            showConfiguredButtons: !wideRail || bar.showContextualToolbar,
            trailing: wideRail && bar.displayAppBar ? mainActions : const [],
          ),
        ),
      ),
    );
  }
}

/// The sample tabs: the first row, and the second one for the two-row
/// stacking modes.
({List<QuickTabSwitcherItem> first, List<QuickTabSwitcherItem> second})
_previewItems(
  BuildContext context,
  GeneralSettings settings,
  TabBarStackingMode stackingMode,
  ColorScheme colorScheme,
) {
  final l10n = AppLocalizations.of(context);
  final containerColor = settings.containerEntryPointsShown
      ? colorScheme.primary
      : null;

  final tabs = <QuickTabSwitcherItem>[
    QuickTabSwitcherItem(
      id: 'regular-preview-tab',
      isActive: true,
      title: l10n.settings_previewTabNews,
      tabMode: TabMode.regular,
      isHistory: false,
      isPinned: stackingMode == TabBarStackingMode.containerTabs,
      url: Uri.parse('https://example.com/news'),
      color: containerColor,
      avatar: const Icon(MdiIcons.web, size: 20),
    ),
    QuickTabSwitcherItem(
      id: 'private-preview-tab',
      isActive: false,
      title: l10n.settings_previewTabPrivate,
      tabMode: TabMode.private,
      isHistory: false,
      isPinned: false,
      depth: 1,
      url: Uri.parse('https://example.com/private'),
      color: null,
      avatar: const Icon(MdiIcons.web, size: 20),
    ),
    if (settings.isolatedTabEntryPointsShown)
      QuickTabSwitcherItem(
        id: 'isolated-preview-tab',
        isActive: false,
        title: l10n.settings_previewTabBank,
        tabMode: TabMode.isolated('preview-isolated-context'),
        isHistory: false,
        isPinned: false,
        depth: 3,
        url: Uri.parse('https://example.com/bank'),
        color: null,
        avatar: const Icon(MdiIcons.web, size: 20),
      ),
  ];

  return switch (stackingMode) {
    // The active group's tabs above, the groups row below: the tabs above as
    // one group, beside a lone tab. The active group's row never falls back to
    // history.
    TabBarStackingMode.tabGroups => (
      first: tabs,
      second: [
        QuickTabSwitcherItem(
          id: 'regular-preview-tab',
          isActive: true,
          title: l10n.settings_previewTabNews,
          tabMode: TabMode.regular,
          isHistory: false,
          isPinned: false,
          url: Uri.parse('https://example.com/news'),
          color: containerColor,
          avatar: const Icon(MdiIcons.web, size: 20),
          groupSize: tabs.length,
        ),
        QuickTabSwitcherItem(
          id: 'search-preview-tab',
          isActive: false,
          title: l10n.settings_previewTabSearch,
          tabMode: TabMode.regular,
          isHistory: false,
          isPinned: false,
          url: Uri.parse('https://search.example.com'),
          color: containerColor,
          avatar: const Icon(MdiIcons.web, size: 20),
        ),
      ],
    ),
    // History suggestions only fill a row that has no tabs, so the sample
    // tabs never show them.
    _ => (first: tabs, second: tabs),
  };
}

/// The page between the bars: a skeleton of a web page, or of the browser
/// home.
class _PreviewPage extends StatelessWidget {
  /// Height the home page is laid out in at least: its padding, the search
  /// pill and a row of shortcuts.
  static const _minHomeHeight = 160.0;

  const _PreviewPage({
    required this.home,
    required this.showHomeSearchPill,
    this.onScroll,
  });

  final bool home;
  final bool showHomeSearchPill;

  /// See [PreviewWindow.onPageScroll].
  final ValueChanged<double>? onScroll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final line = colorScheme.surfaceContainerHigh;

    Widget bar(double widthFactor, {double height = 10}) =>
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );

    if (home) {
      // Laid out at least [_minHomeHeight] tall and clipped to what is
      // left: with [LayoutPreview.pageGivesWay] the page can shrink to
      // nothing.
      return ColoredBox(
        color: colorScheme.surface,
        child: LayoutBuilder(
          builder: (context, constraints) => ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: math.max(constraints.maxHeight, _minHomeHeight),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (showHomeSearchPill)
                      SizedBox(
                        height: 48,
                        child: _PreviewSearchField(
                          hint: l10n.browser_searchOrEnterUrl,
                        ),
                      ),
                    const Spacer(),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < 4; i++)
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.secondaryContainer,
                          ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRect(
      child: ColoredBox(
        color: colorScheme.surfaceContainerLowest,
        child: Builder(
          builder: (context) {
            Widget article({required int repeat}) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < repeat; i++) ...[
                  bar(0.62, height: 22),
                  const SizedBox(height: 10),
                  bar(0.4),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  for (final width in [1.0, 0.94, 0.97, 0.7, 1.0, 0.88, 0.92])
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: bar(width),
                    ),
                  const SizedBox(height: 24),
                ],
              ],
            );

            final onScroll = this.onScroll;
            if (onScroll != null) {
              // Long enough to scroll well past any hide distance.
              return NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.depth == 0) {
                    onScroll(notification.scrollDelta ?? 0);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: article(repeat: 6),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxHeight: double.infinity,
                child: article(repeat: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// An empty address field, as the home surface shows it.
class _PreviewSearchField extends StatelessWidget {
  const _PreviewSearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegularPreviewTitle extends StatelessWidget {
  const _RegularPreviewTitle({required this.tabState});

  final TabState tabState;

  @override
  Widget build(BuildContext context) {
    return AppBarTitleView(
      tabState: tabState,
      isTabTunneled: false,
      siteSettingsBadgeState: SiteSettingsBadgeState.hidden,
      onSiteSettingsTap: _noop,
      onTitleTap: _noop,
      tabIcon: const Icon(MdiIcons.web, size: 24),
      longPressUrlCopy: false,
    );
  }
}

class _CompactPreviewTitle extends StatelessWidget {
  const _CompactPreviewTitle({required this.tabState});

  final TabState tabState;

  @override
  Widget build(BuildContext context) {
    return CompactAppBarTitleView(
      tabState: tabState,
      isTabTunneled: false,
      siteSettingsBadgeState: SiteSettingsBadgeState.hidden,
      onSiteSettingsTap: _noop,
      onTitleTap: _noop,
      tabIcon: const Icon(MdiIcons.web, size: 24),
    );
  }
}

class _RailPreviewTitle extends StatelessWidget {
  const _RailPreviewTitle({required this.tabState, required this.quarterTurns});

  final TabState tabState;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    return RailAppBarTitleView(
      tabState: tabState,
      quarterTurns: quarterTurns,
      isTabTunneled: false,
      siteSettingsBadgeState: SiteSettingsBadgeState.hidden,
      onSiteSettingsTap: _noop,
      onTitleTap: _noop,
      tabIcon: const Icon(MdiIcons.web, size: 24),
      longPressUrlCopy: false,
    );
  }
}

void _noop() {}
