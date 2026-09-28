import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/dialogs/delete_time_range.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  group('historyDeletePresetRange', () {
    final now = DateTime(2026, 9, 28, 14, 30, 15);

    test('last hour ends now', () {
      final range = historyDeletePresetRange(HistoryDeletePreset.lastHour, now);
      expect(range.start, DateTime(2026, 9, 28, 13, 30, 15));
      expect(range.end, now);
    });

    test('today starts at midnight', () {
      final range = historyDeletePresetRange(HistoryDeletePreset.today, now);
      expect(range.start, DateTime(2026, 9, 28));
      expect(range.end, now);
    });

    test('last week spans seven days', () {
      final range = historyDeletePresetRange(HistoryDeletePreset.lastWeek, now);
      expect(range.start, now.subtract(const Duration(days: 7)));
      expect(range.end, now);
    });
  });

  group('historyDeleteBoundary', () {
    final date = DateTime(2026, 9, 28, 9, 9, 9);
    const time = TimeOfDay(hour: 14, minute: 30);

    test('a start covers the whole minute from its first millisecond', () {
      expect(
        historyDeleteBoundary(date, time, endOfMinute: false),
        DateTime(2026, 9, 28, 14, 30),
      );
    });

    test('an end includes the whole minute', () {
      expect(
        historyDeleteBoundary(date, time, endOfMinute: true),
        DateTime(2026, 9, 28, 14, 30, 59, 999),
      );
    });
  });

  group('showDeleteTimeRangeDialog', () {
    // What the dialog pops, once it closes.
    late Future<DateTimeRange<DateTime>?> result;

    Future<void> open(
      WidgetTester tester, {
      DateTimeRange<DateTime>? initialRange,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                result = showDeleteTimeRangeDialog(
                  context,
                  initialRange: initialRange,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    TextButton deleteButton(WidgetTester tester) =>
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Delete'));

    testWidgets('returns the initial range on Delete', (tester) async {
      final initial = DateTimeRange(
        start: DateTime(2026, 9, 20),
        end: DateTime(2026, 9, 21, 23, 59, 59, 999),
      );
      await open(tester, initialRange: initial);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(await result, initial);
    });

    testWidgets('a preset replaces the range', (tester) async {
      await open(
        tester,
        initialRange: DateTimeRange(
          start: DateTime(2020),
          end: DateTime(2020, 1, 2),
        ),
      );

      await tester.tap(find.text('Last hour'));
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      final range = (await result)!;
      expect(range.duration, const Duration(hours: 1));
      expect(DateTime.now().difference(range.end).inMinutes, lessThan(1));
    });

    testWidgets('an empty range cannot be deleted', (tester) async {
      final instant = DateTime(2026, 9, 20, 12);
      await open(
        tester,
        initialRange: DateTimeRange(start: instant, end: instant),
      );

      expect(find.text('The start must be before the end.'), findsOneWidget);
      expect(deleteButton(tester).onPressed, isNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });
  });
}
