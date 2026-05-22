// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_singbox_proxy_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows proxy runtime status label', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Without a native messenger in widget tests the future remains pending,
    // but the static label should still be present.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data!.startsWith('sing-box proxy status:'),
      ),
      findsOneWidget,
    );
  });
}
