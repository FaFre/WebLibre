import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/widgets/split_member_mark.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpMarks(WidgetTester tester, {SplitPair? pair}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [splitPairShownProvider.overrideWithValue(pair)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Column(
            children: [
              SplitMemberMark(tabId: 'a'),
              SplitMemberMark(tabId: 'b'),
              SplitMemberMark(tabId: 'c'),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('marks the members of the shown pair only', (tester) async {
    await pumpMarks(
      tester,
      pair: SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b'),
    );
    expect(find.bySemanticsLabel('In split view'), findsNWidgets(2));
  });

  testWidgets('marks nothing without a pair', (tester) async {
    await pumpMarks(tester);
    expect(find.bySemanticsLabel('In split view'), findsNothing);
  });
}
