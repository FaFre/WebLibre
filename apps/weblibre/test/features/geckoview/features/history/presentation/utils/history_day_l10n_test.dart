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
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weblibre/features/geckoview/features/history/presentation/utils/history_day_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  // Shortly after midnight, so "yesterday" is only minutes ago.
  final now = DateTime(2026, 10, 13, 0, 5);

  setUpAll(() async {
    await initializeDateFormatting('en');
    Intl.defaultLocale = 'en';
  });

  String label(DateTime visit) => historyDayLabel(
    l10n,
    historyDayOf(visit.millisecondsSinceEpoch),
    now: now,
  );

  test('visits group by the calendar day they fall on', () {
    expect(
      historyDayOf(DateTime(2026, 10, 12, 23, 59).millisecondsSinceEpoch),
      isNot(historyDayOf(DateTime(2026, 10, 13, 0, 1).millisecondsSinceEpoch)),
    );
    expect(
      historyDayOf(DateTime(2026, 10, 12, 0, 1).millisecondsSinceEpoch),
      historyDayOf(DateTime(2026, 10, 12, 23, 59).millisecondsSinceEpoch),
    );
  });

  test('the last two days are named, older ones dated', () {
    expect(label(DateTime(2026, 10, 13, 0, 1)), 'Today');
    expect(label(DateTime(2026, 10, 12, 23, 59)), 'Yesterday');
    expect(label(DateTime(2026, 10, 11, 12)), 'Sunday, October 11');
  });

  test('yesterday crosses the start of a month and of a year', () {
    expect(
      historyDayLabel(
        l10n,
        DateTime(2026, 9, 30),
        now: DateTime(2026, 10, 1, 9),
      ),
      'Yesterday',
    );
    expect(
      historyDayLabel(
        l10n,
        DateTime(2025, 12, 31),
        now: DateTime(2026, 1, 1, 9),
      ),
      'Yesterday',
    );
  });

  test('a day from another year carries its year', () {
    expect(label(DateTime(2025, 10, 11, 12)), 'Saturday, October 11, 2025');
  });
}
