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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

enum HistoryDeletePreset { lastHour, today, lastWeek }

/// The range a [preset] stands for, ending at [now].
DateTimeRange<DateTime> historyDeletePresetRange(
  HistoryDeletePreset preset,
  DateTime now,
) {
  return DateTimeRange(
    start: switch (preset) {
      HistoryDeletePreset.lastHour => now.subtract(const Duration(hours: 1)),
      HistoryDeletePreset.today => DateTime(now.year, now.month, now.day),
      HistoryDeletePreset.lastWeek => now.subtract(const Duration(days: 7)),
    },
    end: now,
  );
}

/// [date] at [time], at the first millisecond of that minute, or the last one
/// when [endOfMinute] is set. Times are picked by the minute, so an end of
/// 14:30 has to include a visit at 14:30:45.
DateTime historyDeleteBoundary(
  DateTime date,
  TimeOfDay time, {
  required bool endOfMinute,
}) {
  final start = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  return endOfMinute
      ? start.add(const Duration(minutes: 1) - const Duration(milliseconds: 1))
      : start;
}

/// Ask for a start and end date and time. Returns the range to delete, or
/// null when cancelled. The range starts at [initialRange] when given (the
/// history date filter), otherwise at the last hour.
Future<DateTimeRange<DateTime>?> showDeleteTimeRangeDialog(
  BuildContext context, {
  DateTimeRange<DateTime>? initialRange,
}) {
  return showDialog<DateTimeRange<DateTime>>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => _DeleteTimeRangeDialog(initialRange: initialRange),
  );
}

class _DeleteTimeRangeDialog extends HookWidget {
  const _DeleteTimeRangeDialog({required this.initialRange});

  final DateTimeRange<DateTime>? initialRange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final format = DateFormat.yMMMd().add_jm();

    final initial = useMemoized(
      () =>
          initialRange ??
          historyDeletePresetRange(
            HistoryDeletePreset.lastHour,
            DateTime.now(),
          ),
    );
    final start = useState(initial.start);
    final end = useState(initial.end);

    final isValid = start.value.isBefore(end.value);

    Future<void> pick(
      ValueNotifier<DateTime> boundary, {
      required bool endOfMinute,
    }) async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: boundary.value.isAfter(now) ? now : boundary.value,
        firstDate: DateTime(2000),
        lastDate: now,
      );
      if (date == null || !context.mounted) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(boundary.value),
      );
      if (time == null) return;

      boundary.value = historyDeleteBoundary(
        date,
        time,
        endOfMinute: endOfMinute,
      );
    }

    return AlertDialog(
      icon: const Icon(Icons.warning),
      title: Text(l10n.history_deleteTimeRangeTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final preset in HistoryDeletePreset.values)
                  ActionChip(
                    label: Text(switch (preset) {
                      HistoryDeletePreset.lastHour =>
                        l10n.history_deleteTimeRangeLastHour,
                      HistoryDeletePreset.today =>
                        l10n.history_deleteTimeRangeToday,
                      HistoryDeletePreset.lastWeek =>
                        l10n.history_deleteTimeRangeLastWeek,
                    }),
                    onPressed: () {
                      final range = historyDeletePresetRange(
                        preset,
                        DateTime.now(),
                      );
                      start.value = range.start;
                      end.value = range.end;
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(l10n.history_deleteTimeRangeFrom),
              subtitle: Text(format.format(start.value)),
              trailing: const Icon(Icons.edit),
              onTap: () => pick(start, endOfMinute: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.update),
              title: Text(l10n.history_deleteTimeRangeTo),
              subtitle: Text(format.format(end.value)),
              trailing: const Icon(Icons.edit),
              onTap: () => pick(end, endOfMinute: true),
            ),
            if (!isValid)
              Text(
                l10n.history_deleteTimeRangeInvalid,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              l10n.history_deleteTimeRangeExplanation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: isValid
              ? () => Navigator.pop(
                  context,
                  DateTimeRange(start: start.value, end: end.value),
                )
              : null,
          child: Text(l10n.common_delete),
        ),
      ],
    );
  }
}
