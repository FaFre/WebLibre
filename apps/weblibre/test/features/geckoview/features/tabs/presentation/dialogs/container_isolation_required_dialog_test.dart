import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/container_isolation_required_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('scrolls to the whole explanation in a short window', (
    tester,
  ) async {
    // A phone in landscape with enlarged text.
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showContainerIsolationRequiredDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Unscrollable content overflows here, which fails the test on its own.
    expect(tester.takeException(), isNull);

    final body = find.textContaining('create a new container');
    final scrollable = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsOneWidget);

    await tester.dragUntilVisible(body, scrollable, const Offset(0, -50));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
