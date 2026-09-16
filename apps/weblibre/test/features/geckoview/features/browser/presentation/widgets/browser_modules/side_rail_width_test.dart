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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/side_rail.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/side_rail_resize_handle.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

final phone = WindowSizeClass.fromSize(const Size(412, 915));
final smallTablet = WindowSizeClass.fromSize(const Size(700, 1000));
final tablet = WindowSizeClass.fromSize(const Size(1280, 800));
final landscapePhone = WindowSizeClass.fromSize(const Size(840, 390));
final dexStrip = WindowSizeClass.fromSize(const Size(1400, 300));

double railFor(
  WindowSizeClass window, {
  bool hasTabList = true,
  double preferredWidth = BrowserTabBar.expandedRailWidth,
  double windowWidth = 1280,
}) => BrowserTabBar.railWidthFor(
  window,
  hasTabList: hasTabList,
  preferredWidth: preferredWidth,
  windowWidth: windowWidth,
);

void main() {
  group('BrowserTabBar.railWidthFor', () {
    test('a compact window keeps the width the rail always had', () {
      expect(
        railFor(phone),
        kToolbarHeight,
        reason: 'an explicit rail on a phone must not change',
      );
    });

    test('a medium window gets the collapsed navigation rail width', () {
      expect(railFor(smallTablet), BrowserTabBar.mediumRailWidth);
    });

    test('an expanded window gets the panel at its default width', () {
      expect(railFor(tablet), BrowserTabBar.expandedRailWidth);
      expect(BrowserTabBar.expandedRailWidth, defaultSideRailWidth);
    });

    test('an expanded window gets the width the panel was resized to', () {
      expect(railFor(tablet, preferredWidth: 320), 320);
    });

    test('a resized width only applies where the panel exists', () {
      for (final window in [phone, smallTablet, landscapePhone, dexStrip]) {
        expect(
          railFor(window, preferredWidth: 400),
          railFor(window),
          reason: 'window $window',
        );
      }
    });

    test('a wide but short window does not get the panel', () {
      // Both are expanded by width. Neither has the height to spend on a
      // stacked, titled tab list.
      for (final window in [landscapePhone, dexStrip]) {
        expect(
          railFor(window),
          BrowserTabBar.mediumRailWidth,
          reason: 'window $window',
        );
      }
    });

    test('the panel collapses when there is no tab list to show', () {
      expect(railFor(tablet, hasTabList: false), BrowserTabBar.mediumRailWidth);
    });

    test('never returns a width below the compact rail', () {
      for (final window in [
        phone,
        smallTablet,
        tablet,
        landscapePhone,
        dexStrip,
      ]) {
        for (final hasTabList in [true, false]) {
          for (final preferredWidth in [0.0, 80.0, 256.0, 9999.0]) {
            expect(
              railFor(
                window,
                hasTabList: hasTabList,
                preferredWidth: preferredWidth,
              ),
              greaterThanOrEqualTo(BrowserTabBar.compactRailWidth),
              reason: '$window / $hasTabList / $preferredWidth',
            );
          }
        }
      }
    });
  });

  group('BrowserTabBar.canResizeRail', () {
    test('only where the panel exists', () {
      expect(BrowserTabBar.canResizeRail(tablet, hasTabList: true), isTrue);
      expect(BrowserTabBar.canResizeRail(tablet, hasTabList: false), isFalse);
      for (final window in [phone, smallTablet, landscapePhone, dexStrip]) {
        expect(
          BrowserTabBar.canResizeRail(window, hasTabList: true),
          isFalse,
          reason: 'window $window',
        );
      }
    });
  });

  group('BrowserTabBar.panelWidthFor', () {
    test('keeps a width inside the limits', () {
      expect(BrowserTabBar.panelWidthFor(300, windowWidth: 1280), 300);
    });

    test('caps at the maximum', () {
      expect(
        BrowserTabBar.panelWidthFor(1000, windowWidth: 2560),
        BrowserTabBar.maxExpandedRailWidth,
      );
    });

    test('never takes more than half the window', () {
      expect(BrowserTabBar.panelWidthFor(480, windowWidth: 900), 450);

      for (final windowWidth in [840.0, 1000.0, 1280.0, 2560.0]) {
        for (final preferred in [200.0, 256.0, 480.0, 9999.0]) {
          final width = BrowserTabBar.panelWidthFor(
            preferred,
            windowWidth: windowWidth,
          );
          expect(
            windowWidth - width,
            greaterThanOrEqualTo(windowWidth / 2),
            reason: '$preferred in $windowWidth',
          );
        }
      }
    });

    test('a width below the minimum is the collapsed icon rail', () {
      expect(
        BrowserTabBar.panelWidthFor(
          BrowserTabBar.mediumRailWidth,
          windowWidth: 1280,
        ),
        BrowserTabBar.mediumRailWidth,
      );
      expect(
        BrowserTabBar.panelWidthFor(
          BrowserTabBar.minExpandedRailWidth - 0.5,
          windowWidth: 1280,
        ),
        BrowserTabBar.mediumRailWidth,
      );
      expect(
        BrowserTabBar.panelWidthFor(
          BrowserTabBar.minExpandedRailWidth,
          windowWidth: 1280,
        ),
        BrowserTabBar.minExpandedRailWidth,
      );
    });
  });

  group('BrowserTabBar.draggedRailWidth', () {
    double dragged(double raw) =>
        BrowserTabBar.draggedRailWidth(raw, windowWidth: 1280);

    test('snaps to the icon rail below the collapse threshold', () {
      expect(dragged(40), BrowserTabBar.mediumRailWidth);
      expect(
        dragged(BrowserTabBar.railCollapseThreshold - 1),
        BrowserTabBar.mediumRailWidth,
      );
    });

    test('holds at the minimum between the threshold and the minimum', () {
      // The detent: without it the drag would flicker between two layouts.
      for (final raw in [
        BrowserTabBar.railCollapseThreshold,
        170.0,
        BrowserTabBar.minExpandedRailWidth - 1,
      ]) {
        expect(
          dragged(raw),
          BrowserTabBar.minExpandedRailWidth,
          reason: '$raw',
        );
      }
    });

    test('follows the drag inside the limits', () {
      expect(dragged(320), 320);
    });

    test('a collapsed rail can be dragged back out to a panel', () {
      const raw = BrowserTabBar.mediumRailWidth + 70;
      expect(dragged(raw), BrowserTabBar.minExpandedRailWidth);
    });

    test('a dragged width survives being resolved again', () {
      // What is saved on release must render at the width that was on screen.
      for (final raw in [40.0, 150.0, 320.0, 9999.0]) {
        final width = dragged(raw);
        expect(
          BrowserTabBar.panelWidthFor(width, windowWidth: 1280),
          width,
          reason: '$raw',
        );
      }
    });
  });

  group('BrowserTabBar.isWideRail', () {
    BrowserTabBar barWith(double railWidth) => BrowserTabBar(
      showMainToolbar: true,
      displayedSheet: null,
      showContextualToolbar: false,
      quickTabSwitcherRowCount: 1,
      isSmallWebMode: false,
      enableGestures: false,
      railWidth: railWidth,
    );

    test('is false at the compact and medium widths', () {
      expect(barWith(BrowserTabBar.compactRailWidth).isWideRail, isFalse);
      expect(barWith(BrowserTabBar.mediumRailWidth).isWideRail, isFalse);
    });

    test('is true at every panel width', () {
      expect(barWith(BrowserTabBar.minExpandedRailWidth).isWideRail, isTrue);
      expect(barWith(BrowserTabBar.expandedRailWidth).isWideRail, isTrue);
      expect(barWith(BrowserTabBar.maxExpandedRailWidth).isWideRail, isTrue);
    });

    test('defaults to the compact rail, so horizontal bars are never wide', () {
      const horizontalBar = BrowserTabBar(
        showMainToolbar: true,
        displayedSheet: null,
        showContextualToolbar: false,
        quickTabSwitcherRowCount: 1,
        isSmallWebMode: false,
        enableGestures: false,
      );

      expect(horizontalBar.railWidth, BrowserTabBar.compactRailWidth);
      expect(horizontalBar.isWideRail, isFalse);
    });
  });

  group('SideRailResizeHandle', () {
    test('draws inside the inset the panel already holds clear', () {
      // The line costs the tab list nothing only as long as it stays within
      // the padding the rows and the toolbar block leave at that edge — that
      // is what lets the rail hand the tab bar its full width.
      expect(
        SideRailResizeHandle.laneWidth,
        lessThanOrEqualTo(BrowserTabBar.panelInset),
      );
      // The drag reaches further in than the line, so it stays grabbable.
      expect(
        SideRailResizeHandle.hitWidth,
        greaterThan(SideRailResizeHandle.laneWidth),
      );
    });
  });

  group('BrowserTabBarView panel layout', () {
    testWidgets('insets its top block by the same panel inset as the tab '
        'list below it', (tester) async {
      // The toolbar row and the address field share their left and right edges
      // with the tab rows; a top block on its own inset reads as the panel
      // being narrower up there than it is below.
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 300,
              height: 600,
              child: BrowserTabBarView(
                axis: Axis.vertical,
                isWideRail: true,
                showMainToolbar: true,
                showContextualToolbar: true,
                showQuickTabSwitcherBar: true,
                displayAppBar: true,
                displayQuickTabSwitcher: true,
                backgroundColor: Colors.black,
                title: Container(key: const Key('title'), height: 40),
                actions: const [],
                quickTabSwitcher: Container(key: const Key('list')),
                contextualToolbar: const SizedBox(
                  key: Key('toolbar'),
                  height: 40,
                ),
              ),
            ),
          ),
        ),
      );

      const inset = BrowserTabBar.panelInset;
      final list = tester.getRect(find.byKey(const Key('list')));
      expect(list.left, 0.0);
      expect(list.right, 300.0);

      for (final key in ['title', 'toolbar']) {
        final rect = tester.getRect(find.byKey(Key(key)));
        expect(rect.left, list.left + inset, reason: key);
        expect(rect.right, list.right - inset, reason: key);
      }
    });
  });

  group('BrowserSideRail', () {
    test('reports the width it was given as its preferred size', () {
      // browser.dart reads preferredSize off an instance built outside the
      // tree to inset the browser content. If that disagreed with the rail it
      // renders, the page would overlap the rail or leave a gap beside it.
      for (final width in [
        BrowserTabBar.compactRailWidth,
        BrowserTabBar.mediumRailWidth,
        BrowserTabBar.minExpandedRailWidth,
        BrowserTabBar.expandedRailWidth,
        BrowserTabBar.maxExpandedRailWidth,
      ]) {
        final rail = BrowserSideRail(
          showContextualToolbar: false,
          quickTabSwitcherRowCount: 1,
          isSmallWebMode: false,
          position: TabBarPosition.left,
          railWidth: width,
        );

        expect(rail.preferredSize.width, width);
      }
    });
  });

  group('BrowserTabBar.isWideRailWidth', () {
    // The single threshold the rail's three widgets share: the layout in
    // BrowserTabBarView, the rows in QuickTabSwitcherView, and the accordion.
    test('is false below the panel minimum', () {
      expect(
        BrowserTabBar.isWideRailWidth(BrowserTabBar.compactRailWidth),
        isFalse,
      );
      expect(
        BrowserTabBar.isWideRailWidth(BrowserTabBar.mediumRailWidth),
        isFalse,
      );
      expect(
        BrowserTabBar.isWideRailWidth(BrowserTabBar.minExpandedRailWidth - 1),
        isFalse,
      );
    });

    test('is true at and above the panel minimum', () {
      expect(
        BrowserTabBar.isWideRailWidth(BrowserTabBar.minExpandedRailWidth),
        isTrue,
      );
      expect(BrowserTabBar.isWideRailWidth(400), isTrue);
    });

    test('agrees with every width railWidthFor can produce', () {
      for (final window in [phone, smallTablet, landscapePhone, dexStrip]) {
        for (final hasTabList in [true, false]) {
          expect(
            BrowserTabBar.isWideRailWidth(
              railFor(window, hasTabList: hasTabList),
            ),
            isFalse,
            reason: '$window / hasTabList: $hasTabList',
          );
        }
      }

      expect(BrowserTabBar.isWideRailWidth(railFor(tablet)), isTrue);
      expect(
        BrowserTabBar.isWideRailWidth(railFor(tablet, hasTabList: false)),
        isFalse,
      );
      // Collapsed by the user.
      expect(
        BrowserTabBar.isWideRailWidth(
          railFor(tablet, preferredWidth: BrowserTabBar.mediumRailWidth),
        ),
        isFalse,
      );
    });
  });

  group('isAtSideRailEdge', () {
    test('a left rail reveals at the left window edge', () {
      expect(isAtSideRailEdge(dx: 0, width: 1280, railOnLeft: true), isTrue);
      expect(
        isAtSideRailEdge(
          dx: sideRailRevealEdgeWidth,
          width: 1280,
          railOnLeft: true,
        ),
        isTrue,
      );
      expect(
        isAtSideRailEdge(
          dx: sideRailRevealEdgeWidth + 1,
          width: 1280,
          railOnLeft: true,
        ),
        isFalse,
      );
      expect(
        isAtSideRailEdge(dx: 1279, width: 1280, railOnLeft: true),
        isFalse,
      );
    });

    test('a right rail reveals at the right window edge', () {
      expect(
        isAtSideRailEdge(dx: 1280, width: 1280, railOnLeft: false),
        isTrue,
      );
      expect(
        isAtSideRailEdge(
          dx: 1280 - sideRailRevealEdgeWidth,
          width: 1280,
          railOnLeft: false,
        ),
        isTrue,
      );
      expect(isAtSideRailEdge(dx: 0, width: 1280, railOnLeft: false), isFalse);
    });
  });
}
