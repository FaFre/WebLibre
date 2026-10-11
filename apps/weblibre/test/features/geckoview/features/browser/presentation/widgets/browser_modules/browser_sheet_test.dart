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
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/browser_sheet.dart';
import 'package:weblibre/presentation/widgets/browser_sheet_surface.dart';

const _channel = MethodChannel('eu.weblibre.gecko/navigation_bar');

const _windowHeight = 800.0;
const _statusBar = 24.0;
const _navigationBar = 48.0;

const _behindLabel = 'Behind';
const _insideLabel = 'Inside';

final _contentKey = GlobalKey();

/// Pumps [BrowserSheetHost] with a sheet of [extent] (a fraction of the window
/// height) over a button, in a window with a status bar and a navigation bar.
/// Without [showSheet], only the button. A different [extent] builds a new
/// sheet in the same host. [sheetMaxWidth] caps the sheet's width the way the
/// browser's theme does.
Future<void> _pumpSheet(
  WidgetTester tester, {
  required double extent,
  bool navigationBarOutsideFlutter = false,
  bool showSheet = true,
  VoidCallback? onDismiss,
  DraggableScrollableController? controller,
  double sideInset = 0,
  double? sheetMaxWidth,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, _windowHeight);
  final insets = FakeViewPadding(
    left: sideInset,
    top: _statusBar,
    right: sideInset,
    bottom: _navigationBar,
  );
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
  addTearDown(tester.view.reset);

  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _channel,
    (_) async => {
      'outsideFlutter': navigationBarOutsideFlutter,
      'buttonsAtBottom': true,
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      null,
    ),
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            constraints: sheetMaxWidth == null
                ? null
                : BoxConstraints(maxWidth: sheetMaxWidth),
          ),
        ),
        home: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(_behindLabel),
              ),
            ),
            if (showSheet)
              Positioned.fill(
                child: BrowserSheetHost(
                  onDismiss: onDismiss ?? () {},
                  sheet: DraggableScrollableSheet(
                    key: ValueKey(extent),
                    controller: controller,
                    expand: false,
                    initialChildSize: extent,
                    minChildSize: 0.1,
                    builder: (context, scrollController) => BrowserSheetSurface(
                      // The sheet's controller moves it only once a scrollable
                      // uses this.
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverFillRemaining(
                            child: SizedBox.expand(
                              key: _contentKey,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(_insideLabel),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

MaterialLocalizations _localizations(WidgetTester tester) =>
    MaterialLocalizations.of(tester.element(find.byType(BrowserSheetHost)));

Rect _contentRect(WidgetTester tester) =>
    tester.getRect(find.byKey(_contentKey));

/// The radius of the corners the surface is clipped to, as painted: what
/// [Material] has animated to so far, not the shape it was given.
double _cornerRadius(WidgetTester tester) {
  final clip = tester.widget<PhysicalShape>(
    find
        .descendant(
          of: find.byType(BrowserSheetSurface),
          matching: find.byType(PhysicalShape),
        )
        .first,
  );
  final shape =
      (clip.clipper as ShapeBorderClipper).shape as RoundedRectangleBorder;
  return (shape.borderRadius as BorderRadius).topLeft.x;
}

/// The scrim's band above the sheet, as a screen reader finds it.
Rect _scrimRect(WidgetTester tester) => find.semantics
    .byLabel(_localizations(tester).scrimLabel)
    .evaluate()
    .single
    .rect;

/// The scrim reaches this far under the sheet's top edge, past its corners.
const _scrimOverlap = 32.0;

/// How many of the scrim's pieces cover [point].
int _scrimLayersAt(WidgetTester tester, Offset point) => find
    .descendant(
      of: find.byType(BrowserSheetHost),
      matching: find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color.a < 1,
      ),
    )
    .evaluate()
    .where((element) {
      final box = element.renderObject! as RenderBox;
      return (box.localToGlobal(Offset.zero) & box.size).contains(point);
    })
    .length;

FocusNode _focusOf(WidgetTester tester, String label) =>
    Focus.of(tester.element(find.text(label)));

SystemUiOverlayStyle _style(WidgetTester tester) => tester
    .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(
        of: find.byType(BrowserSheetSurface),
        matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      ),
    )
    .value;

void main() {
  testWidgets('reaches behind the navigation bar, content ends above it', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.5);

    final content = _contentRect(tester);
    expect(content.top, _windowHeight / 2);
    expect(content.bottom, _windowHeight - _navigationBar);
    expect(_cornerRadius(tester), BrowserSheetSurface.cornerRadius);
    expect(
      MediaQuery.paddingOf(tester.element(find.byKey(_contentKey))),
      EdgeInsets.zero,
    );
  });

  testWidgets('keeps its content above the keyboard', (tester) async {
    await _pumpSheet(tester, extent: 0.8);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();

    expect(_contentRect(tester).bottom, _windowHeight - 300);
  });

  testWidgets('expanded, it covers the status bar and drops its corners', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 1.0);

    final content = _contentRect(tester);
    expect(content.top, _statusBar);
    expect(content.bottom, _windowHeight - _navigationBar);
    expect(_cornerRadius(tester), 0);
  });

  testWidgets('its corners straighten as it slides under the status bar', (
    tester,
  ) async {
    // Top edge 14 below the window's: 10 under the status bar, halfway
    // through the 28 over which the corners straighten.
    await _pumpSheet(tester, extent: (_windowHeight - 14) / _windowHeight);

    expect(_contentRect(tester).top, closeTo(_statusBar, 1e-9));
    expect(
      _cornerRadius(tester),
      closeTo(BrowserSheetSurface.cornerRadius / 2, 1e-9),
    );
  });

  testWidgets('its corners keep up with its edge', (tester) async {
    final controller = DraggableScrollableController();
    addTearDown(controller.dispose);
    await _pumpSheet(tester, extent: 0.5, controller: controller);

    controller.jumpTo(1.0);
    await tester.pump();

    expect(_contentRect(tester).top, _statusBar);
    expect(_cornerRadius(tester), 0);
  });

  testWidgets('shown by showBrowserSheet, it slides under the status bar', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 1.0, showSheet: false);

    // A modal route takes the status bar out of its sheet's MediaQuery.
    unawaited(
      showBrowserSheet<void>(
        context: tester.element(find.text(_behindLabel)),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          builder: (context, scrollController) =>
              BrowserSheetSurface(child: SizedBox.expand(key: _contentKey)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final content = _contentRect(tester);
    expect(content.top, _statusBar);
    expect(content.bottom, _windowHeight - _navigationBar);
    expect(_cornerRadius(tester), 0);
    // Nothing of the route's own sheet shows around the surface.
    final routeSheet = tester.widget<Material>(
      find
          .ancestor(
            of: find.byType(BrowserSheetSurface),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(routeSheet.color, Colors.transparent);
    expect(routeSheet.elevation, 0);
  });

  testWidgets('shown above a fold, it slides under the status bar', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 1.0, showSheet: false);
    // Tabletop posture, the upper side the larger one, which the route then
    // lays the sheet out on. The window keeps its size in the sheet's
    // MediaQuery.
    const fold = 500.0;
    tester.view.displayFeatures = [
      const DisplayFeature(
        bounds: Rect.fromLTRB(0, fold, 400, fold),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ];
    await tester.pump();

    unawaited(
      showBrowserSheet<void>(
        context: tester.element(find.text(_behindLabel)),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          builder: (context, scrollController) =>
              BrowserSheetSurface(child: SizedBox.expand(key: _contentKey)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final content = _contentRect(tester);
    expect(content.top, _statusBar);
    // The navigation bar is on the other side.
    expect(content.bottom, fold);
    expect(_cornerRadius(tester), 0);
  });

  testWidgets('keeps its content out of a side inset it reaches into', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 1.0, showSheet: false);
    // A landscape phone a little wider than Material's 640 sheet, its
    // navigation bar on the right.
    tester.view.physicalSize = const Size(700, 400);
    const insets = FakeViewPadding(top: _statusBar, right: _navigationBar);
    tester.view.padding = insets;
    tester.view.viewPadding = insets;
    await tester.pump();

    unawaited(
      showBrowserSheet<void>(
        context: tester.element(find.text(_behindLabel)),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          builder: (context, scrollController) =>
              BrowserSheetSurface(child: SizedBox.expand(key: _contentKey)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final content = _contentRect(tester);
    expect(content.left, (700 - 640) / 2);
    expect(content.right, 700 - _navigationBar);
  });

  testWidgets('follows the status bar going away under it', (tester) async {
    await _pumpSheet(tester, extent: 1.0, showSheet: false);
    unawaited(
      showBrowserSheet<void>(
        context: tester.element(find.text(_behindLabel)),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1.0,
          builder: (context, scrollController) =>
              BrowserSheetSurface(child: SizedBox.expand(key: _contentKey)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_contentRect(tester).top, _statusBar);

    // The page goes fullscreen; the navigation bar stays.
    const insets = FakeViewPadding(bottom: _navigationBar);
    tester.view.padding = insets;
    tester.view.viewPadding = insets;
    await tester.pump();

    expect(_contentRect(tester).top, 0);
    expect(_cornerRadius(tester), 0);
  });

  testWidgets('keeps the side insets it is clear of from its content', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.5, sideInset: 48);

    expect(
      MediaQuery.paddingOf(tester.element(find.byKey(_contentKey))),
      EdgeInsets.zero,
    );
  });

  testWidgets('sets icons that contrast with its color', (tester) async {
    await _pumpSheet(tester, extent: 0.5);

    final style = _style(tester);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarColor, Colors.transparent);
  });

  testWidgets('colors a navigation bar outside Flutter itself', (tester) async {
    await _pumpSheet(tester, extent: 0.5, navigationBarOutsideFlutter: true);

    final sheetColor = Theme.of(
      tester.element(find.byType(BrowserSheetSurface)),
    ).colorScheme.surfaceContainerLow;
    expect(_style(tester).systemNavigationBarColor, sheetColor);
  });

  testWidgets('dims everything beside a narrow sheet exactly once', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.5, sheetMaxWidth: 300);

    final content = _contentRect(tester);
    expect(content.left, 50);
    expect(content.width, 300);

    // Above the sheet: beside it and over it.
    expect(_scrimLayersAt(tester, const Offset(25, 100)), 1);
    expect(_scrimLayersAt(tester, const Offset(200, 100)), 1);
    expect(_scrimLayersAt(tester, const Offset(375, 100)), 1);
    // Beside the sheet.
    expect(_scrimLayersAt(tester, const Offset(25, 600)), 1);
    expect(_scrimLayersAt(tester, const Offset(375, 600)), 1);
  });

  testWidgets('hides the controls it covers from screen readers', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.5, showSheet: false);
    expect(find.semantics.byLabel(_behindLabel), findsOne);

    await _pumpSheet(tester, extent: 0.5);
    expect(find.semantics.byLabel(_behindLabel), findsNothing);
    expect(find.semantics.byLabel(_insideLabel), findsOne);
  });

  testWidgets('its scrim dismisses the sheet for a screen reader', (
    tester,
  ) async {
    var dismissals = 0;
    await _pumpSheet(tester, extent: 0.5, onDismiss: () => dismissals++);

    final scrim = find.semantics.byLabel(_localizations(tester).scrimLabel);
    tester.semantics.tap(scrim);
    tester.semantics.dismiss(scrim);
    expect(dismissals, 2);
  });

  testWidgets('Escape dismisses the sheet', (tester) async {
    var dismissals = 0;
    await _pumpSheet(tester, extent: 0.5, onDismiss: () => dismissals++);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(dismissals, 1);
  });

  testWidgets('its scrim ends at a sheet built anew in its place', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.8);
    expect(_scrimRect(tester).height, _windowHeight * 0.2 + _scrimOverlap);

    // A new sheet reports no extent until it moves.
    await _pumpSheet(tester, extent: 0.5);
    expect(_scrimRect(tester).height, _windowHeight * 0.5 + _scrimOverlap);
  });

  testWidgets('announces itself as a route that covers only the sheet', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.5);

    final route = find.semantics.byFlag(SemanticsFlag.namesRoute);
    expect(route, findsOne);
    final node = route.evaluate().single;
    expect(node.label, _localizations(tester).dialogLabel);
    expect(node.rect.height, _windowHeight / 2);
  });

  testWidgets('keeps keyboard focus in the sheet until it closes', (
    tester,
  ) async {
    await _pumpSheet(tester, extent: 0.5, showSheet: false);
    _focusOf(tester, _behindLabel).requestFocus();
    await tester.pump();

    await _pumpSheet(tester, extent: 0.5);
    expect(_focusOf(tester, _behindLabel).hasFocus, isFalse);

    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusOf(tester, _behindLabel).hasFocus, isFalse);
      expect(_focusOf(tester, _insideLabel).hasPrimaryFocus, isTrue);
    }

    await _pumpSheet(tester, extent: 0.5, showSheet: false);
    expect(_focusOf(tester, _behindLabel).hasPrimaryFocus, isTrue);
  });
}
