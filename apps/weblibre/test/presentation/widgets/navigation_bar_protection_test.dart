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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/presentation/widgets/navigation_bar_protection.dart';

const _channel = MethodChannel('eu.weblibre.gecko/navigation_bar');

const _barHeight = 48.0;

final _pageKey = GlobalKey();

/// Mocks MainActivity's reply and pumps one page route, named [routeName],
/// in a window with a [_barHeight] navigation bar at the bottom.
Future<void> _pumpPage(
  WidgetTester tester, {
  required bool buttonsAtBottom,
  String routeName = '/',
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(bottom: _barHeight);
  tester.view.viewPadding = const FakeViewPadding(bottom: _barHeight);
  addTearDown(tester.view.reset);

  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _channel,
    (_) async => {'outsideFlutter': false, 'buttonsAtBottom': buttonsAtBottom},
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
          pageTransitionsTheme:
              const NavigationBarProtectedPageTransitionsTheme(),
        ),
        initialRoute: routeName,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(body: SizedBox.expand(key: _pageKey)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _pageHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(_pageKey)).height;

double _pageBottomPadding(WidgetTester tester) =>
    MediaQuery.paddingOf(tester.element(find.byKey(_pageKey))).bottom;

void main() {
  testWidgets('a page ends above navigation buttons', (tester) async {
    await _pumpPage(tester, buttonsAtBottom: true);

    final screenHeight = tester.view.physicalSize.height;
    expect(_pageHeight(tester), screenHeight - _barHeight);
    expect(_pageBottomPadding(tester), 0);
  });

  testWidgets('a page reaches under a gesture handle', (tester) async {
    await _pumpPage(tester, buttonsAtBottom: false);

    expect(_pageHeight(tester), tester.view.physicalSize.height);
    expect(_pageBottomPadding(tester), _barHeight);
  });

  testWidgets('the browser keeps the bar region to itself', (tester) async {
    await _pumpPage(
      tester,
      buttonsAtBottom: true,
      routeName: BrowserRoute.name,
    );

    expect(_pageHeight(tester), tester.view.physicalSize.height);
    expect(_pageBottomPadding(tester), _barHeight);
  });

  testWidgets('a dialog barrier still dims the bar region', (tester) async {
    await _pumpPage(tester, buttonsAtBottom: true);

    unawaited(
      showDialog<void>(
        context: tester.element(find.byKey(_pageKey)),
        builder: (_) => const AlertDialog(content: Text('dialog')),
      ),
    );
    await tester.pumpAndSettle();

    final barrier = find.byType(ModalBarrier).last;
    expect(tester.getRect(barrier).bottom, tester.view.physicalSize.height);
  });
}
